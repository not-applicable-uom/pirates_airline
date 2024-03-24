CREATE PROCEDURE sp_insert_airport @name VARCHAR(40),
                                  @country VARCHAR(40),
                                  @city VARCHAR(40)
AS
BEGIN

	SELECT * 
	FROM airport
	WHERE LOWER(name) = LOWER(@name);

	IF @@ROWCOUNT <> 0 
		BEGIN
			PRINT'Another airport with same name already exists!';
			RETURN;
		END

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

--Test if airport name already exists
EXECUTE sp_insert_airport 'Sir Seewoosagur Ramgoolam International Airport', 'Mauritius', 'Plaine Magnien';

-- Test if the id is generated correctly
EXECUTE sp_insert_airport 'Mumbai International Airport', 'India', 'Mumbai';

--Reverse change
DELETE FROM airport WHERE airport_id = 'mim01';

SELECT * FROM airport;