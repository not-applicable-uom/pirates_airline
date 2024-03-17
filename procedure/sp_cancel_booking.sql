CREATE PROCEDURE sp_cancel_booking @booking_id INT,
                                   @date DATE
AS
BEGIN
    DECLARE @departure_time DATE,@seat_number INTEGER,@passenger_id INTEGER, @flight_id INTEGER;

    SELECT @departure_time = departure_time, @seat_number = seat_number, @passenger_id = passenger_id, @flight_id = flight.flight_id
    FROM booking
             JOIN flight ON booking.flight_id = flight.flight_id
    WHERE booking_id = @booking_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Booking not found';
            RETURN;
        END
    IF DATEDIFF(DAY, @date, @departure_time) < 0
        BEGIN
            PRINT 'The departure date has already passed';
            RETURN;
        END
    IF DATEDIFF(DAY, @date, @departure_time) < 3
        BEGIN
            PRINT 'There will be a 75% cancellation charge since the departure date is within 3 days';
            INSERT INTO booking_cancellation_by_passenger_refund VALUES (@date, @seat_number, @passenger_id, @flight_id, 0.25);
        END
    ELSE
        BEGIN
            PRINT 'There will be a 25% cancellation charge since the departure date is more than 3 days away';
            INSERT INTO booking_cancellation_by_passenger_refund VALUES (@date, @seat_number, @passenger_id, @flight_id, 0.75);
        END
    DELETE FROM booking WHERE booking_id = @booking_id;
    PRINT 'Booking cancelled successfully';
END
GO

CREATE TABLE booking_cancellation_by_passenger_refund
(
    booking_id   INTEGER IDENTITY(1,1) PRIMARY KEY,
    date         DATE,
    seat_number  INTEGER,
    passenger_id INTEGER,
    flight_id    INTEGER,
    refund_amount       DECIMAL(7,2)
);

-- Test if the procedure fails when the booking is not found
EXECUTE sp_cancel_booking 50, '03-22-2024';
-- Test for a booking cancellation that has already passed
EXECUTE sp_cancel_booking 12, '04-04-2024';
-- Test for a booking cancellation that is within 3 days of departure
EXECUTE sp_cancel_booking 12, '03-31-2024';
-- reverse the cancellation
EXECUTE sp_book_flight 5, '03-22-2024', 'W', 'BUSINESS CLASS', 5;
-- Test for a booking cancellation that is more than 3 days away
EXECUTE sp_cancel_booking 12, '03-28-2024';
-- reverse the cancellation
EXECUTE sp_book_flight 5, '03-22-2024', 'W', 'BUSINESS CLASS', 5;

SELECT * FROM booking_cancellation_refund;
