CREATE PROCEDURE sp_book_flight @flight_id INTEGER,
                               @date DATE,
                               @placement CHAR,
                               @seat_type VARCHAR(15),
                               @passenger_id INTEGER = NULL,
                               @first_name VARCHAR(40) = NULL,
                               @last_name VARCHAR(40) = NULL,
                               @dob DATE = NULL,
                               @address VARCHAR(40) = NULL,
                               @gender CHAR = NULL,
                               @passport_number VARCHAR(15) = NULL,
                               @phone_number VARCHAR(15) = NULL,
                               @email VARCHAR(40) = NULL
AS
BEGIN
    SELECT * FROM flight WHERE flight_id = @flight_id;
    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Flight does not exist.';
            RETURN;
        END

    SELECT * FROM fn_seat_availability(@flight_id);
    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'No seats available for specified flight.';
            RETURN;
        END

    DECLARE @seat_number AS INTEGER, @max AS INTEGER;
    SELECT @seat_number = seat_number
    FROM fn_seat_availability(@flight_id)
    WHERE seat_type = @seat_type
      AND placement = @placement;
    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'No seat available for the specified seat type and placement.';
            PRINT 'Listing all the seats available for the flight:'
            PRINT '';
            DECLARE seat_cursor CURSOR FOR
                SELECT seat_number, seat_type, placement, price
                FROM ((SELECT * FROM fn_seat_availability(@flight_id))
                      EXCEPT
                      (SELECT *
                       FROM fn_seat_availability(@flight_id)
                       WHERE seat_type = @seat_type
                         AND placement = @placement)) available_seat;
            DECLARE @price AS DECIMAL(7, 2);
            OPEN seat_cursor;
            FETCH NEXT FROM seat_cursor INTO @seat_number, @seat_type, @placement, @price;
            WHILE @@FETCH_STATUS = 0
                BEGIN
                    PRINT CONCAT('Seat number: ', @seat_number, ', Seat type: ', @seat_type, ', Placement: ',
                                 @placement, ', Price: ', @price);
                    FETCH NEXT FROM seat_cursor INTO @seat_number, @seat_type, @placement, @price;
                END
            CLOSE seat_cursor;
            DEALLOCATE seat_cursor;
            RETURN;
        END

    IF @passenger_id IS NOT NULL
        BEGIN
            SELECT * FROM passenger WHERE passenger_id = @passenger_id;
            IF @@ROWCOUNT <> 0
                BEGIN
                    SELECT @max = MAX(booking_id) FROM booking GROUP BY booking_id;
                    IF @@ROWCOUNT = 0
                        BEGIN
                            INSERT INTO booking
                            VALUES (1, @date, @seat_number, @passenger_id,
                                    @flight_id);
                        END
                    ELSE
                        BEGIN
                            INSERT INTO booking
                            VALUES (@max + 1, @date, @seat_number, @passenger_id,
                                    @flight_id);
                        END
                END
            ELSE
                BEGIN
                    PRINT 'Passenger with the specified id does not exist.'
                    RETURN;
                END
        END
    ELSE
        BEGIN

            EXEC sp_insert_passenger @passenger_id OUTPUT, @first_name, @last_name, @dob,
                 @address, @gender, @passport_number, @phone_number, @email;

            SELECT @max = MAX(booking_id) FROM booking GROUP BY booking_id;

            IF @@ROWCOUNT = 0
                BEGIN
                   SET @max = 0;
                END

            PRINT CONCAT('Passenger with id ', @passenger_id, ' inserted.');

            INSERT INTO booking
            VALUES (@max + 1, @date, @seat_number, @passenger_id, @flight_id);

        END
    PRINT 'Booking successful.';
END
GO

-- Test if booking a non existent flight fails
EXECUTE sp_book_flight 10, '03-20-2024', 'A', 'ECONOMY CLASS', 1;
-- Test if booking a flight with no available seats fails
EXECUTE sp_book_flight 2, '03-10-2024', 'A', 'ECONOMY CLASS', 1;
-- Test if booking a flight with no available seats for the specified seat type and placement fails and lists all the available seats
EXECUTE sp_book_flight 1, '03-10-2024', 'A', 'ECONOMY CLASS', 3;
-- Test if booking a flight with a non existent passenger fails
EXECUTE sp_book_flight 1, '03-10-2024', 'M', 'ECONOMY CLASS', 20;
-- Test if booking a flight with a new passenger is successful
EXECUTE sp_book_flight 1, '03-10-2024', 'M', 'ECONOMY CLASS', NULL, 'Burnaby', 'Cumber', '04/09/1966',
        '030 Hudson Plaza', 'F', 'F7654321', '729-746-2994', 'rsymms2q@google.ca';
-- Test if booking a flight with an existing passenger is successful
EXECUTE sp_book_flight 1, '03-10-2024', 'M', 'ECONOMY CLASS', 7;
SELECT *
FROM booking;
