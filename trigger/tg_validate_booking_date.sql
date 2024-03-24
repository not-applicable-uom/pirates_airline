-- Flight needs to be 3+ from current date + booking conflicts
CREATE TRIGGER tg_validate_booking_date
    ON booking
    INSTEAD OF INSERT
    AS
BEGIN
    DECLARE @booking_id INTEGER, @date DATETIME,
        @seat_number INTEGER, @passenger_id INTEGER,
        @flight_id INTEGER, @departure_time DATETIME,
        @arrival_time DATETIME;

    SELECT @booking_id = booking_id,
           @date = date,
           @seat_number = seat_number,
           @passenger_id = passenger_id,
           @flight_id = flight_id
    FROM inserted;
    SELECT @departure_time = departure_time, @arrival_time = arrival_time FROM flight WHERE flight_id = @flight_id;

    IF DATEDIFF(DAY, @date, @departure_time) < 3
        BEGIN
            PRINT 'Flight should be booked 3 days ahead';
            RETURN;
        END

    SELECT *
    FROM booking
             JOIN flight ON booking.flight_id = flight.flight_id
    WHERE passenger_id = @passenger_id
        AND ((@departure_time BETWEEN departure_time AND arrival_time)
       OR (@arrival_time BETWEEN departure_time AND arrival_time));

    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT 'You already have a flight scheduled for that date';
            RETURN;
        END
    INSERT INTO booking VALUES (@booking_id, @date, @seat_number, @passenger_id, @flight_id);
END
GO

SELECT * FROM booking;

-- Test if trigger checks if flight is booked 3 days ahead
INSERT INTO booking VALUES (13, '03-27-2024', 2, 1, 1);
-- Test if trigger checks for booking conflicts(passenger already has a flight scheduled for that date)
INSERT INTO booking VALUES (13, '03-20-2024', 2, 1, 3);
-- Test if trigger successfully inserts a booking
INSERT INTO booking VALUES (13, '03-20-2024', 2, 1, 5);
-- Reverse change
DELETE FROM booking WHERE booking_id = 13;
DELETE FROM booking_cancellation_by_passenger_refund;