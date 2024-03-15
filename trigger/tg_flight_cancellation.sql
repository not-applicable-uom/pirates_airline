--Flight cancellation.
CREATE TRIGGER tg_flight_cancellation
    ON flight
    INSTEAD OF
        DELETE
    AS
BEGIN
    DECLARE
        @flight_id AS INTEGER;

    --Retrieve values deleted.
    SELECT @flight_id = flight_id
    FROM deleted;

    --If a flight is deleted.
    IF
        @@ROWCOUNT > 0
        BEGIN

            DECLARE
                @booking_id INTEGER,@date DATE,@seat_number INTEGER,@passenger_id INTEGER;

            --Declare cursor.
            DECLARE
                my_cursor CURSOR FOR
                    SELECT booking_id, date, seat_number, passenger_id
                    FROM booking
                    WHERE flight_id = @flight_id;

            --Open cursor
            OPEN my_cursor

            --Fetch rows one by one and process them.
            FETCH NEXT FROM my_cursor INTO @booking_id, @date , @seat_number, @passenger_id

            WHILE @@FETCH_STATUS = 0
                BEGIN
                    --Insert the bookings that will be refund into booking_refund table//processed fetched row.
                    INSERT INTO booking_refund
                    VALUES (@booking_id, @date, @seat_number, @passenger_id, @flight_id);

                    --Delete each row in booking table for flight canceled.
                    DELETE
                    FROM booking
                    WHERE booking_id = @booking_id;

                    --Fetch next row.
                    FETCH NEXT FROM my_cursor INTO @booking_id,@date, @seat_number, @passenger_id
                END;

            --Close cursor.
            CLOSE my_cursor;
            DEALLOCATE
                my_cursor;

            --Delete the flight from flight table.
            DELETE
            FROM flight
            WHERE flight_id = @flight_id;

        END;
    ELSE
        PRINT 'Error!'
END;
GO

--Create Table booking_refund
CREATE TABLE booking_refund
(
    booking_id   INTEGER PRIMARY KEY,
    date         DATE,
    seat_number  INTEGER,
    passenger_id INTEGER,
    flight_id    INTEGER
);

ALTER TABLE booking_refund
    ADD FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id);
ALTER TABLE booking_refund
    ADD FOREIGN KEY (seat_number) REFERENCES seat (seat_number);