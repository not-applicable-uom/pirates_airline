ALTER PROCEDURE sp_book_flight @flight_id INTEGER,
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
            PRINT 'Listing all the seats available for the flight.'
            SELECT *
            FROM ((SELECT * FROM fn_seat_availability(@flight_id))
                  EXCEPT
                  (SELECT *
                   FROM fn_seat_availability(@flight_id)
                   WHERE seat_type = @seat_type
                     AND placement = @placement)) available_seat;
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
                END
        END
    ELSE
        BEGIN

            EXEC sp_insert_passenger @passenger_id OUTPUT, @first_name, @last_name, @dob,
                 @address, @gender, @passport_number, @phone_number, @email;
            SELECT @max = MAX(booking_id) FROM booking GROUP BY booking_id;
            IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO booking
                    VALUES (1, @date, @seat_number, @passenger_id, @flight_id);
                END
            ELSE
                BEGIN
                    INSERT INTO booking
                    VALUES (@max + 1, @date, @seat_number, @passenger_id, @flight_id);
                END
        END
END