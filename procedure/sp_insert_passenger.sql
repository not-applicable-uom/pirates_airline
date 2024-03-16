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

-- Test if the procedure fails when the passport number is already in the database
EXECUTE sp_insert_passenger @passenger_id = 0,
                            @first_name = 'Barn',
                            @last_name = 'Kellaway',
                            @dob = '1/3/1994',
                            @address = '94536 Monument Hill',
                            @gender = 'M',
                            @passport_number = 'PQR98765432100C',
                            @phone_number = '(641) 5273154',
                            @email = 'bkellaway0@delicious.com';
-- Test if the procedure works when the passport number is not in the database
EXECUTE sp_insert_passenger @passenger_id = 0,
                            @first_name = 'Barn',
                            @last_name = 'Kellaway',
                            @dob = '1/3/1994',
                            @address = '94536 Monument Hill',
                            @gender = 'M',
                            @passport_number = 'PQR9876543210DC',
                            @phone_number = '(641) 5273154',
                            @email = 'bkellaway0@delicious.com';
