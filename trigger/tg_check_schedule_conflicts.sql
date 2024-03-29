-- Check schedule conflicts
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

SELECT * FROM flight;

-- Test if trigger detects error where arrival time is less than or equal to departure time
INSERT INTO flight VALUES (7, 300.0, 'ab001', 'smp01', '04-28-2024 08:00:00', 'bab01', '04-28-2024 07:00:00', 1);
-- Test if trigger detects error where flight duration exceeds 20 hours
INSERT INTO flight VALUES (7, 300.0, 'ab001', 'smp01', '04-28-2024 08:00:00', 'bab01', '04-29-2024 07:00:00', 1);
-- Test if trigger detects error where airplane is already assigned to another flight for the date entered
INSERT INTO flight VALUES (7, 300.0, 'ab001', 'lul01', '03-28-2024 12:00:00', 'hul02', '03-28-2024 15:00:00', 2);
-- Test if trigger detects error where crew is already assigned to another flight for the date entered
INSERT INTO flight VALUES (7, 450.0, 'ab001', 'cfp01', '04-01-2024 10:00:00', 'hul01', '04-01-2024 14:00:00', 1);
-- Test if trigger successfully inserts a new flight
INSERT INTO flight VALUES (7, 450.0, 'ab001', 'cfp01', '03-30-2024 10:00:00', 'hul01', '03-30-2024 14:00:00', 2);
-- Reverse change
DELETE FROM flight WHERE flight_id = 7;

SELECT * FROM booking_refund;
