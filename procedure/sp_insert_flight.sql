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

SELECT * FROM flight;
-- Test if procedure fails when airplane_id does not exist.
EXECUTE sp_insert_flight 450.0, 'bd005', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 1;
-- Test if procedure fails when origin_airport_id does not exist.
EXECUTE sp_insert_flight 450.0, 'bd001', 'noo01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 1;
-- Test if procedure fails when destination_airport_id does not exist.
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '04-01-2024 22:00:00', 'noo01', '04-02-2024 02:00:00', 1;
-- Test if procedure fails when crew_id does not exist.
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 100;
-- Test if procedure works when all parameters are correct.
EXECUTE sp_insert_flight 450.0, 'bb001', 'hul01', '04-01-2024 22:00:00', 'cfp01', '04-02-2024 02:00:00', 2;
--Reverse change
DELETE FROM flight WHERE airplane_id = 'bb001';
