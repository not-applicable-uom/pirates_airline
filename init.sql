CREATE TABLE airline
(
    airline_id      VARCHAR(5) PRIMARY KEY,
    airline_name    VARCHAR(40),
    additional_fees DECIMAL(7, 2)
);
CREATE TABLE airplane
(
    airplane_id       VARCHAR(5) PRIMARY KEY,
    airline_id        VARCHAR(5),
    airplane_model_id VARCHAR(5)
);
CREATE TABLE airplane_model
(
    airplane_model_id VARCHAR(5) PRIMARY KEY,
    model_name        VARCHAR(40),
    manufacturer      VARCHAR(40)
);
CREATE TABLE seat
(
    seat_number INTEGER PRIMARY KEY,
    placement   CHAR CHECK (placement IN ('W', 'M', 'A')),
    seat_type   VARCHAR(15)
);
CREATE TABLE fare_info
(
    seat_type       VARCHAR(15) PRIMARY KEY CHECK (seat_type IN ('ECONOMY CLASS', 'BUSINESS CLASS', 'FIRST CLASS')),
    additional_fees DECIMAL(7, 2)
);
CREATE TABLE airport
(
    airport_id VARCHAR(5) PRIMARY KEY,
    name       VARCHAR(40),
    country    VARCHAR(40),
    city       VARCHAR(40)
);

CREATE TABLE booking
(
    booking_id   INTEGER PRIMARY KEY,
    date         DATE,
    seat_number  INTEGER,
    passenger_id INTEGER,
    flight_id    INTEGER
);
CREATE TABLE crew
(
    crew_id INTEGER PRIMARY KEY,
    name    VARCHAR(40)
);
CREATE TABLE employee
(
    employee_id  INTEGER PRIMARY KEY,
    first_name   VARCHAR(40),
    last_name    VARCHAR(40),
    gender       CHAR CHECK (gender IN ('M', 'F')),
    dob          DATE,
    address      VARCHAR(40),
    phone_number VARCHAR(15),
    email        VARCHAR(40) CHECK (email LIKE '%_@__%.__%'),
    role         VARCHAR(40) CHECK (role IN
                                    ('Captain', 'Co-pilot', 'Flight Attendant', 'Flight Engineer', 'Air Marshal',
                                     'Loadmaster', 'Flight Dispatcher')),
    crew_id      INTEGER
);
CREATE TABLE flight
(
    flight_id              INTEGER PRIMARY KEY,
    price                  DECIMAL(7, 2),
    airplane_id            VARCHAR(5),
    origin_airport_id      VARCHAR(5),
    departure_time         DATETIME,
    destination_airport_id VARCHAR(5),
    arrival_time           DATETIME,
    crew_id                INTEGER
);
CREATE TABLE passenger
(
    passenger_id    INTEGER PRIMARY KEY,
    first_name      VARCHAR(40),
    last_name       VARCHAR(40),
    dob             DATE,
    address         VARCHAR(40),
    gender          CHAR CHECK (gender IN ('M', 'F')),
    passport_number VARCHAR(15),
    phone_number    VARCHAR(15),
    email           VARCHAR(40) CHECK (email LIKE '%_@__%.__%')
);
ALTER TABLE airplane
    ADD FOREIGN KEY (airline_id) REFERENCES airline (airline_id);
ALTER TABLE airplane
    ADD FOREIGN KEY (airplane_model_id) REFERENCES airplane_model (airplane_model_id);
ALTER TABLE employee
    ADD FOREIGN KEY (crew_id) REFERENCES crew (crew_id);
ALTER TABLE booking
    ADD FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id);
ALTER TABLE booking
    ADD FOREIGN KEY (flight_id) REFERENCES flight (flight_id) ON DELETE NO ACTION;
ALTER TABLE booking
    ADD FOREIGN KEY (seat_number) REFERENCES seat (seat_number);
ALTER TABLE flight
    ADD FOREIGN KEY (airplane_id) REFERENCES airplane (airplane_id);
ALTER TABLE flight
    ADD FOREIGN KEY (destination_airport_id) REFERENCES airport (airport_id);
ALTER TABLE flight
    ADD FOREIGN KEY (origin_airport_id) REFERENCES airport (airport_id);
ALTER TABLE flight
    ADD FOREIGN KEY (crew_id) REFERENCES crew (crew_id);
ALTER TABLE seat
    ADD FOREIGN KEY (seat_type) REFERENCES fare_info (seat_type);

GO
CREATE TRIGGER tg_check_schedule_conflicts
    ON flight
    INSTEAD OF INSERT
    AS
BEGIN
    DECLARE @flight_id INTEGER, @departure_time DATETIME, @arrival_time DATETIME, @crew_id INTEGER,
        @price DECIMAL(7, 2), @airplane_id VARCHAR(5), @origin_airport_id VARCHAR(5), @destination_airport_id VARCHAR(5);

    SELECT @flight_id = flight_id,
           @departure_time = departure_time,
           @arrival_time = arrival_time,
           @crew_id = crew_id,
           @price = price,
           @airplane_id = airplane_id,
           @origin_airport_id = origin_airport_id,
           @destination_airport_id = destination_airport_id
    FROM inserted;

    IF @arrival_time <= @departure_time
        BEGIN
            PRINT 'Arrival time cannot be less than or equal to departure time.'
            RETURN
        END

    IF DATEDIFF(HOUR, @departure_time, @arrival_time) > 20
        BEGIN
            PRINT 'Flight duration cannot exceed 20 hours.'
            RETURN
        END

    SELECT *
    FROM flight
    WHERE airplane_id = @airplane_id
      AND ((@departure_time BETWEEN departure_time AND arrival_time) OR
           (@arrival_time BETWEEN departure_time AND arrival_time));
    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT 'Airplane specified is already assigned to an another flight for the date entered.';

            DECLARE @airplane_model VARCHAR(40), @airline_name VARCHAR(40), @airline_additional_fees DECIMAL(7, 2);
            DECLARE airplane_cursor CURSOR LOCAL FOR
                SELECT airplane.airplane_id,
                       airplane_model.model_name,
                       airline.airline_name,
                       airline.additional_fees
                FROM ((airplane JOIN airline ON airplane.airline_id = airline.airline_id)
				JOIN airplane_model ON airplane.airplane_model_id = airplane_model.airplane_model_id)
				LEFT JOIN flight ON airplane.airplane_id = flight.airplane_id
				WHERE airplane.airplane_id NOT IN (
												SELECT airplane_id FROM flight
												WHERE (@departure_time BETWEEN departure_time AND arrival_time) OR
												(@arrival_time BETWEEN departure_time AND arrival_time));
            OPEN airplane_cursor;

            FETCH NEXT FROM airplane_cursor INTO @airplane_id, @airplane_model, @airline_name, @airline_additional_fees;

            IF @@FETCH_STATUS <> 0
                BEGIN
                    PRINT 'No other airplane is currently available for the date specified.';
                END
            ELSE
                BEGIN
                    PRINT 'Listing available airplanes for the date specified.';
                    WHILE @@FETCH_STATUS = 0 BEGIN
                        PRINT CONCAT(@airplane_id, ', ', @airplane_model, ', ', @airline_name, ', ',
                                     @price * (@airline_additional_fees + 1));
                        FETCH NEXT FROM airplane_cursor INTO @airplane_id, @airplane_model, @airline_name, @airline_additional_fees;
                    END
                    CLOSE airplane_cursor;
                    DEALLOCATE airplane_cursor;
                END
            RETURN
        END


    SELECT *
    FROM flight
    WHERE crew_id = @crew_id
      AND ((@departure_time BETWEEN departure_time AND arrival_time) OR
           (@arrival_time BETWEEN departure_time AND arrival_time));
    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT 'Crew specified is already assigned to an another flight for the date entered.';

            DECLARE @crew_name VARCHAR(40);
            DECLARE crew_cursor CURSOR LOCAL FOR
                SELECT * FROM crew WHERE crew_id NOT IN (
										SELECT crew_id FROM flight
										WHERE (@departure_time BETWEEN departure_time AND arrival_time) OR
										(@arrival_time BETWEEN departure_time AND arrival_time));
            OPEN crew_cursor;

            FETCH NEXT FROM crew_cursor INTO @crew_id, @crew_name;

            IF @@FETCH_STATUS <> 0
                BEGIN
                    PRINT 'No other crew is currently available for the date specified.';
                END
            ELSE
                BEGIN
                    PRINT 'Listing available crews for the date specified.';
                    WHILE @@FETCH_STATUS = 0 BEGIN
                        PRINT CONCAT(@crew_id, ', ', @crew_name)
                        FETCH NEXT FROM crew_cursor INTO @crew_id, @crew_name;
                    END
                    CLOSE crew_cursor;
                    DEALLOCATE crew_cursor;
                END
            RETURN
        END

    INSERT INTO flight
    VALUES (@flight_id, @price, @airplane_id, @origin_airport_id, @departure_time, @destination_airport_id,
            @arrival_time, @crew_id)
END

GO
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
                    VALUES (@booking_id, @date, @seat_number, @passenger_id, @flight_id);

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

GO
CREATE TRIGGER tg_reschedule_flight_departure_time
    ON flight
    AFTER UPDATE
    AS
BEGIN
    DECLARE @flight_id INTEGER, @departure_time DATETIME, @arrival_time DATETIME, @new_departure_time DATETIME, @airplane_id VARCHAR(5);

    SELECT @flight_id = flight_id,
           @departure_time = departure_time,
           @arrival_time = arrival_time,
           @airplane_id = airplane_id
    FROM deleted;

    SELECT @new_departure_time = departure_time FROM inserted;
    DECLARE @diff INTEGER = DATEDIFF(MINUTE, @departure_time, @new_departure_time);
    UPDATE flight
    SET arrival_time = DATEADD(MINUTE, @diff, @arrival_time)
    WHERE flight_id = @flight_id;
    DECLARE flight_cursor CURSOR FOR
        SELECT flight_id, departure_time, arrival_time
        FROM flight
        WHERE departure_time > @new_departure_time
          AND airplane_id = @airplane_id;
    OPEN flight_cursor;
    FETCH NEXT FROM flight_cursor INTO @flight_id, @departure_time, @arrival_time;
    WHILE @@FETCH_STATUS = 0 BEGIN
        UPDATE flight
        SET departure_time = DATEADD(MINUTE, @diff, @departure_time),
            arrival_time   = DATEADD(MINUTE, @diff, @arrival_time)
        WHERE flight_id = @flight_id;
        FETCH NEXT FROM flight_cursor INTO @flight_id, @departure_time, @arrival_time;
    END
    CLOSE flight_cursor;
    DEALLOCATE flight_cursor;
END

GO
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
CREATE FUNCTION fn_seat_availability(@flight_id INTEGER)
    RETURNS @return TABLE
                    (
                        seat_number INTEGER,
                        placement   CHAR,
                        seat_type   VARCHAR(40),
                        price       DECIMAL(7, 2)
                    )
AS
BEGIN
    DECLARE @price DECIMAL(7, 2);
    SELECT @price = price FROM flight WHERE flight_id = @flight_id;
    INSERT @return
    SELECT seat_number, placement, seat.seat_type, (@price * (additional_fees + 1)) AS price_for_seat
    FROM seat
             JOIN fare_info ON seat.seat_type = fare_info.seat_type
    WHERE seat.seat_number IN
          ((SELECT seat_number FROM seat) except (SELECT seat_number FROM booking WHERE flight_id = @flight_id));
    RETURN;
END

GO
CREATE PROCEDURE sp_available_flights_for_specified_date_using_country @date DATE,
                                                                       @origin_country VARCHAR(40),
                                                                       @destination_country VARCHAR(40)
AS
BEGIN
    SELECT flight_id,
           price,
           airplane_id,
           DATEDIFF(HOUR, departure_time, arrival_time) AS flight_duration,
           origin_airport_id,
           origin.name                                  AS origin_airport,
           origin.country                               AS origin_country,
           departure_time,
           destination_airport_id,
           dest.name                                    as destination_airport,
           dest.country                                 AS destination_country,
           arrival_time
    FROM (flight JOIN airport AS origin ON flight.origin_airport_id = origin.airport_id)
             JOIN airport AS dest ON flight.destination_airport_id = dest.airport_id
    WHERE CAST(departure_time AS DATE) >= @date
      AND origin.country = @origin_country
      AND dest.country = @destination_country
      AND (SELECT COUNT(*) AS num FROM fn_seat_availability(flight_id)) > 0
    ORDER BY departure_time;
END

GO
CREATE PROCEDURE sp_available_flights_for_specified_date_using_id @date DATE,
                                                                  @origin_airport_id VARCHAR(5),
                                                                  @destination_airport_id VARCHAR(5)
AS
BEGIN
    SELECT *
    FROM flight
    WHERE CAST(departure_time AS DATE) >= @date
      AND origin_airport_id = @origin_airport_id
      AND destination_airport_id = @destination_airport_id
      AND (SELECT COUNT(*) AS num FROM fn_seat_availability(flight_id)) > 0
    ORDER BY departure_time;
END

GO
CREATE PROCEDURE sp_insert_passenger @passenger_id INTEGER OUTPUT,
                                     @first_name VARCHAR(40),
                                     @last_name VARCHAR(40),
                                     @dob DATE,
                                     @address VARCHAR(40),
                                     @gender CHAR,
                                     @passport_number VARCHAR(15),
                                     @phone_number VARCHAR(15),
                                     @email VARCHAR(40)
AS
BEGIN
	SELECT * FROM passenger WHERE passport_number = @passport_number;
	IF @@ROWCOUNT <> 0
		BEGIN
			PRINT 'There is an another passenger with the same passport number.';
			RETURN;
		END

    DECLARE @max AS INTEGER;
    SELECT @max = MAX(passenger_id) FROM passenger GROUP BY passenger_id;
    IF @@ROWCOUNT = 0
        BEGIN
            INSERT INTO passenger
            VALUES (1, @first_name, @last_name, @dob, @address, @gender,
                    @passport_number, @phone_number, @email);
            SET @max = 0;
        END
    ELSE
        BEGIN
            INSERT INTO passenger
            VALUES (@max + 1, @first_name, @last_name, @dob, @address, @gender,
                    @passport_number, @phone_number, @email);
        END
    SET @passenger_id = @max + 1;
END

GO
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
            PRINT CONCAT('Passenger with id ', @passenger_id, ' inserted.');
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
    PRINT 'Booking successful.';
END

GO
CREATE PROCEDURE sp_calculate_airline_revenue @airline_id VARCHAR(5)
AS
BEGIN
    SELECT YEAR(booking.date)                                                     AS Year,
           airline.airline_name,
           SUM(price * (airline.additional_fees + fare_info.additional_fees + 1)) AS revenue
    FROM ((((booking JOIN flight ON booking.flight_id = flight.flight_id)
        JOIN seat ON seat.seat_number = booking.seat_number) JOIN fare_info
           ON seat.seat_type = fare_info.seat_type)
        JOIN airplane ON flight.airplane_id = airplane.airplane_id)
             JOIN airline ON airline.airline_id = airplane.airline_id
    WHERE airline.airline_id = @airline_id
    GROUP BY airline.airline_name, YEAR(booking.date)
    ORDER BY YEAR(booking.date);
END

GO
CREATE PROCEDURE sp_cancel_flight_for_specified_country @country VARCHAR(40)
AS
BEGIN

    SELECT *
    FROM airport
    WHERE country = @country;

    IF
        @@ROWCOUNT > 0
        BEGIN
            DELETE
            FROM flight
            WHERE destination_airport_id IN (SELECT airport_id
                                             FROM airport
                                             WHERE country = @country);
            IF
                @@ROWCOUNT = 0
                BEGIN
                    PRINT
                        'There is no flight scheduled for ' + @country;
                END
        END
    ELSE
        PRINT 'We do not operate in ' + @country;
END;

GO
CREATE PROCEDURE sp_check_if_crew_member_assigned_to_flight @employee_id INTEGER,
                                                            @date DATE
AS
BEGIN
    DECLARE @output VARCHAR(200);
    SELECT @output = CONCAT('You are scheduled for flight_id ', flight_id, ' on ', @date)
    FROM (employee JOIN crew ON employee.crew_id = crew.crew_id)
             JOIN flight ON crew.crew_id = flight.crew_id
    WHERE employee_id = @employee_id
      AND @date BETWEEN CAST(departure_time AS DATE) AND CAST(arrival_time AS DATE);
    IF @@ROWCOUNT = 0
        PRINT 'You are not scheduled for any flights on this date';
    ELSE
        PRINT @output;
END

GO
CREATE PROCEDURE sp_insert_airline @airline_name VARCHAR(40),
                                   @additional_fees DECIMAL(7, 2)
AS
BEGIN
    DECLARE @start_str AS VARCHAR(2) = LOWER(SUBSTRING(@airline_name, 1, 2));
    DECLARE @max AS INTEGER;
    SELECT @max = MAX(CAST(SUBSTRING(airline_id, 3, 3) AS INTEGER))
    FROM airline
    WHERE SUBSTRING(airline_id, 1, 2) = @start_str
    GROUP BY airline_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO airline
            VALUES (CONCAT(@start_str, RIGHT('000' + CAST((@max + 1) AS VARCHAR(3)), 3)), @airline_name,
                    @additional_fees);
        END
    ELSE
        BEGIN
            INSERT INTO airline VALUES (CONCAT(@start_str, '001'), @airline_name, @additional_fees);
        END
END

GO
CREATE PROCEDURE sp_insert_airplane @airline_id AS VARCHAR(5),
                                    @airplane_model_id AS VARCHAR(5)
AS
BEGIN
    DECLARE @start_str AS VARCHAR(2) = SUBSTRING(@airline_id, 1, 1) + SUBSTRING(@airplane_model_id, 1, 1);
    DECLARE @max AS INTEGER;
    SELECT @max = MAX(CAST(SUBSTRING(airplane_id, 3, 3) AS INTEGER))
    FROM airplane
    WHERE SUBSTRING(airplane_id, 1, 2) = @start_str
    GROUP BY airplane_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO airplane
            VALUES (CONCAT(@start_str, RIGHT('000' + CAST((@max + 1) AS VARCHAR(3)), 3)),
                    @airline_id, @airplane_model_id);
        END
    ELSE
        BEGIN
            INSERT INTO airplane
            VALUES (CONCAT(@start_str, '001'), @airline_id, @airplane_model_id);
        END
END

GO
CREATE PROCEDURE sp_insert_airplane_model @manufacturer AS VARCHAR(40),
                                          @model_name AS VARCHAR(40)
AS
BEGIN
    DECLARE @start_str AS VARCHAR(2) = LOWER(SUBSTRING(@manufacturer, 1, 1) + SUBSTRING(@model_name, 1, 1));
    DECLARE @max AS INTEGER;
    SELECT @max = MAX(CAST(SUBSTRING(airplane_model_id, 3, 3) AS INTEGER))
    FROM airplane_model
    WHERE SUBSTRING(airplane_model_id, 1, 2) = @start_str
    GROUP BY airplane_model_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO airplane_model
            VALUES (CONCAT(@start_str, RIGHT('000' + CAST((@max + 1) AS VARCHAR(3)), 3)),
                    @model_name, @manufacturer);
        END
    ELSE
        BEGIN
            INSERT INTO airplane_model
            VALUES (CONCAT(@start_str, '001'), @model_name, @manufacturer);
        END
END

GO
CREATE PROCEDURE sp_insert_airport @name VARCHAR(40),
                                  @country VARCHAR(40),
                                  @city VARCHAR(40)
AS
BEGIN
    DECLARE @start_str AS VARCHAR(3) = LOWER(SUBSTRING(@name, 1, 1) +
                                             SUBSTRING(@country, 1, 1) +
                                             SUBSTRING(@city, 1, 1));
    DECLARE @max AS INTEGER;
    SELECT @max = MAX(CAST(SUBSTRING(airport_id, 4, 2) AS INTEGER))
    FROM airport
    WHERE SUBSTRING(airport_id, 1, 3) = @start_str
    GROUP BY airport_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO airport
            VALUES (CONCAT(@start_str, RIGHT('00' + CAST((@max + 1) AS VARCHAR(2)), 2)),
                    @name, @country, @city);
        END
    ELSE
        BEGIN
            INSERT INTO airport VALUES (CONCAT(@start_str, '01'), @name, @country, @city);
        END
END

GO
CREATE PROCEDURE sp_insert_crew @name VARCHAR(40)
AS
BEGIN
    DECLARE @crew_id AS INTEGER;
    SELECT @crew_id = MAX(crew_id)
    FROM crew
    GROUP BY crew_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT @crew_id
            INSERT INTO crew VALUES ((@crew_id + 1), @name);
        END;
    ELSE
        BEGIN
            INSERT INTO crew VALUES (1, @name);
        END;
END;

GO
CREATE PROCEDURE sp_insert_employee @first_name VARCHAR(40), @last_name VARCHAR(40), @gender CHAR,
                                    @dob DATE, @address VARCHAR(40), @phone_number VARCHAR(15), @email VARCHAR(40),
                                    @role VARCHAR(40), @crew_id INTEGER
AS
BEGIN
    DECLARE @employee_id INTEGER;

    SELECT *
    FROM crew
    WHERE @crew_id = crew_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'This crew id does not exist!';
            RETURN;
        END;
    ELSE
        BEGIN
            SELECT @employee_id = MAX(employee_id)
            FROM employee
            GROUP BY employee_id;
        END;

    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT @employee_id
            INSERT INTO employee
            VALUES ((@employee_id + 1), @first_name, @last_name, @gender, @dob, @address, @phone_number, @email, @role,
                    @crew_id);
        END;
    ELSE
        BEGIN
            INSERT INTO employee
            VALUES (1, @first_name, @last_name, @gender, @dob, @address, @phone_number, @email, @role, @crew_id);
        END;
END;

GO
CREATE PROCEDURE sp_insert_flight @price DECIMAL(7, 2), @airplane_id VARCHAR(5), @origin_airport_id VARCHAR(5),
                                  @departure_time DATETIME, @destination_airport_id VARCHAR(5), @arrival_time DATETIME,
                                  @crew_id INTEGER
AS
BEGIN
    DECLARE @flight_id INTEGER;

    --check if airplane_id exists.
    SELECT *
    FROM airplane
    WHERE @airplane_id = airplane_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'This airplane id does not exist!';
            RETURN;
        END;

    --check if origin_airport_id exists.
    SELECT *
    FROM airport
    WHERE @origin_airport_id = airport_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'This origin airport id does not exist!';
            RETURN;
        END;

    --check if destination_airport_id exists.
    SELECT *
    FROM airport
    WHERE @destination_airport_id = airport_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'This destination airport id does not exist!';
            RETURN;
        END;

    --check if crew id exists.
    SELECT *
    FROM crew
    WHERE @crew_id = crew_id;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'This crew id does not exist!';
            RETURN;
        END;

    SELECT @flight_id = MAX(flight_id)
    FROM flight
    GROUP BY flight_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO flight
            VALUES ((@flight_id + 1), @price, @airplane_id, @origin_airport_id, @departure_time,
                    @destination_airport_id, @arrival_time, @crew_id);
        END;
    ELSE
        BEGIN
            INSERT INTO flight
            VALUES (1, @price, @airplane_id, @origin_airport_id, @departure_time, @destination_airport_id,
                    @arrival_time, @crew_id);
        END;
END;

GO
CREATE PROCEDURE sp_insert_seat @placement CHAR,
                               @seat_type VARCHAR(15)
AS
BEGIN
    IF
        @placement <> 'A' AND @placement <> 'W' AND @placement <> 'M'
        BEGIN
            Print
                'Invalid placement.';
            RETURN;
        END

    SELECT *
    FROM fare_info
    WHERE seat_type = @seat_type;

    IF
        @@ROWCOUNT = 0
        BEGIN
            PRINT
                'Invalid seat type.';
        END
    ELSE
        BEGIN
            DECLARE
                @max AS INTEGER;
            SELECT @max = MAX(seat_number)
            FROM seat
            GROUP BY seat_number;

            IF
                @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO seat
                    VALUES (1, @placement, @seat_type);
                END
            ELSE
                BEGIN
                    INSERT INTO seat
                    VALUES (@max + 1, @placement, @seat_type);
                END
        END
END;
