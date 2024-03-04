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
        AND (@departure_time BETWEEN departure_time AND arrival_time)
       OR (@arrival_time BETWEEN departure_time AND arrival_time);

    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT 'You already have a flight scheduled for that date';
            RETURN;
        END
    INSERT INTO booking VALUES (@booking_id, @date, @seat_number, @passenger_id, @flight_id);
END