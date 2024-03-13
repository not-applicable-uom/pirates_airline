--generate flight_id & insert data into flight table.
CREATE PROCEDURE sp_generate_flight_id @price DECIMAL(7,2),@airplane_id VARCHAR(5),@origin_airport_id VARCHAR(5),
@departure_time DATETIME,@destination_airport_id VARCHAR(5),@arrival_time DATETIME,@crew_id INTEGER
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
			PRINT @flight_id
			INSERT INTO flight VALUES ((@flight_id + 1),@price,@airplane_id,@origin_airport_id,@departure_time,@destination_airport_id,@arrival_time,@crew_id);
		END;
	ELSE
		BEGIN
			INSERT INTO flight VALUES (1,@price,@airplane_id,@origin_airport_id,@departure_time,@destination_airport_id,@arrival_time,@crew_id);
		END;	
END;	