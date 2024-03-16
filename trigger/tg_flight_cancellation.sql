--Flight cancellation.
CREATE TRIGGER tg_flight_cancellation
ON flight
INSTEAD OF DELETE
AS
BEGIN
    DECLARE @flight_id AS INTEGER;

	--Declare flight_cursor and retrieve values deleted.
	DECLARE flight_cursor CURSOR FOR
		SELECT flight_id 
		FROM deleted;

	--Open flight_cursor.
	OPEN flight_cursor;

	
     --Fetch rows one by one and process them.
     FETCH NEXT FROM flight_cursor INTO @flight_id;

	 WHILE @@FETCH_STATUS = 0
		BEGIN
            DECLARE
                @booking_id INTEGER,@date DATE,@seat_number INTEGER,@passenger_id INTEGER;

            --Declare booking_cursor.
            DECLARE
                booking_cursor CURSOR FOR
                    SELECT booking_id, date, seat_number, passenger_id
                    FROM booking
                    WHERE flight_id = @flight_id;

            --Open booking_cursor
            OPEN booking_cursor;

            --Fetch rows one by one and process them.
            FETCH NEXT FROM booking_cursor INTO @booking_id, @date , @seat_number, @passenger_id;

            WHILE @@FETCH_STATUS = 0
                BEGIN
                    --Insert the bookings that will be refund into booking_refund table//processed fetched row.
                    INSERT INTO booking_refund
                    VALUES (@booking_id, @date, @seat_number, @passenger_id, @flight_id);

                    --Delete each row in booking table for flight canceled.
                    DELETE
                    FROM booking
                    WHERE booking_id = @booking_id;

                    --Fetch next row for booking.
                    FETCH NEXT FROM booking_cursor INTO @booking_id,@date, @seat_number, @passenger_id;
                END;

            --Close booking_cursor.
            CLOSE booking_cursor;
            DEALLOCATE booking_cursor;

            --Delete the flight from flight table.
            DELETE
            FROM flight
            WHERE flight_id = @flight_id;

			--Fetch next row flight.
			FETCH NEXT FROM flight_cursor INTO @flight_id;
        END;
		
		--Close flight_cursor.
		CLOSE flight_cursor
		DEALLOCATE flight_cursor;;
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


SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;

--Test trigger if flight does not exists.
DELETE FROM flight WHERE flight_id = 10;

--Test trigger if deleting a flight with no bookings.
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 1;
SELECT * FROM flight;
SELECT * FROM booking;
DELETE FROM flight WHERE flight_id = 7;
SELECT * FROM flight;
SELECT * FROM booking;

--Test trigger if no flight id is given when deleting.
DELETE FROM flight;