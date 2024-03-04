-- Rescheduling flights departure time
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