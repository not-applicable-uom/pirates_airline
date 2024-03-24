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
    DECLARE
        flight_cursor CURSOR FOR
            SELECT flight_id
            FROM deleted;
    OPEN flight_cursor;
    FETCH NEXT FROM flight_cursor INTO @flight_id;
    WHILE @@FETCH_STATUS = 0
        BEGIN

            DECLARE
                @booking_id INTEGER,@date DATE,@seat_number INTEGER,@passenger_id INTEGER;

            --Declare cursor.
            DECLARE
                booking_cursor CURSOR FOR
                    SELECT booking_id, date, seat_number, passenger_id
                    FROM booking
                    WHERE flight_id = @flight_id;

            --Open cursor
            OPEN booking_cursor

            --Fetch rows one by one and process them.
            FETCH NEXT FROM booking_cursor INTO @booking_id, @date , @seat_number, @passenger_id

            WHILE @@FETCH_STATUS = 0
                BEGIN
                    --Insert the bookings that will be refund into booking_refund table//processed fetched row.
                    INSERT INTO booking_refund
                    VALUES (@date, @seat_number, @passenger_id, @flight_id);

                    --Delete each row in booking table for flight canceled.
                    DELETE
                    FROM booking
                    WHERE booking_id = @booking_id;

                    --Fetch next row.
                    FETCH NEXT FROM booking_cursor INTO @booking_id,@date, @seat_number, @passenger_id
                END;

            --Close cursor.
            CLOSE booking_cursor;
            DEALLOCATE
                booking_cursor;

            --Delete the flight from flight table.
            DELETE
            FROM flight
            WHERE flight_id = @flight_id;
            FETCH NEXT FROM flight_cursor INTO @flight_id;
        END;
    CLOSE flight_cursor;
    DEALLOCATE flight_cursor;
END;
GO

--Create Table booking_refund
CREATE TABLE booking_refund
(
    booking_id   INTEGER IDENTITY(1,1) PRIMARY KEY,
    date         DATE,
    seat_number  INTEGER,
    passenger_id INTEGER,
    flight_id    INTEGER
);

ALTER TABLE booking_refund
    ADD FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id);
ALTER TABLE booking_refund
    ADD FOREIGN KEY (seat_number) REFERENCES seat (seat_number);

SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;

--Test trigger if flight does not exists.
DELETE FROM flight WHERE flight_id = 10;

--Test trigger if deleting a flight with no bookings.
DELETE FROM flight WHERE flight_id = 6;
SELECT * FROM flight;
SELECT * FROM booking;
-- Reverse change
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 1;

--Test trigger if deleting for a flight with bookings will refund the passenger.
DELETE FROM flight WHERE flight_id = 5;
SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;
-- Reverse change
EXECUTE sp_insert_flight 450.0, 'bd001', 'cfp01', '04-01-2024 10:00:00', 'hul01', '04-01-2024 14:00:00', 1;
EXECUTE sp_book_flight 5, '03-19-2024', 'A', 'ECONOMY CLASS', 4;
EXECUTE sp_book_flight 5, '03-22-2024', 'W', 'BUSINESS CLASS', 5;
DELETE FROM booking_refund;

-- Test trigger if all the flights with or without booking is canceled
DELETE FROM flight;
SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;
-- Reverse change
DELETE FROM booking_refund;
EXECUTE sp_insert_flight 300.0, 'ab001', 'smp01', '03-28-2024 08:00:00', 'bab01', '03-28-2024 15:00:00', 1;
EXECUTE sp_insert_flight 300.0, 'ab001', 'bab01', '03-28-2024 20:00:00', 'smp01', '03-29-2024 03:00:00', 1;
EXECUTE sp_insert_flight 305.0, 'eb001', 'smp01', '03-28-2024 10:00:00', 'cac01', '03-28-2024 17:00:00', 2;
EXECUTE sp_insert_flight 305.0, 'eb001', 'cac01', '03-28-2024 22:00:00', 'smp01', '03-29-2024 05:00:00', 2;
EXECUTE sp_insert_flight 450.0, 'bd001', 'cfp01', '04-01-2024 10:00:00', 'hul01', '04-01-2024 14:00:00', 1;
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 1;
EXECUTE sp_book_flight 1, '03-10-2024', 'A', 'ECONOMY CLASS', 1;
EXECUTE sp_book_flight 1, '03-11-2024', 'M', 'ECONOMY CLASS', 2;
EXECUTE sp_book_flight 1, '03-10-2024', 'A', 'FIRST CLASS', 3;
EXECUTE sp_book_flight 2, '03-10-2024', 'A', 'ECONOMY CLASS', 1;
EXECUTE sp_book_flight 2, '03-11-2024', 'M', 'ECONOMY CLASS', 2;
EXECUTE sp_book_flight 2, '03-10-2024', 'A', 'FIRST CLASS', 3;
EXECUTE sp_book_flight 3, '03-19-2024', 'A', 'ECONOMY CLASS', 4;
EXECUTE sp_book_flight 3, '03-22-2024', 'W', 'BUSINESS CLASS', 5;
EXECUTE sp_book_flight 2, '03-10-2024', 'W', 'BUSINESS CLASS', 4;
EXECUTE sp_book_flight 2, '03-9-2024', 'M', 'ECONOMY CLASS', 5;
EXECUTE sp_book_flight 5, '03-19-2024', 'A', 'ECONOMY CLASS', 4;
EXECUTE sp_book_flight 5, '03-22-2024', 'W', 'BUSINESS CLASS', 5;