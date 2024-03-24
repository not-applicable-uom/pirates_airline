CREATE PROCEDURE sp_insert_seat @placement CHAR,
                               @seat_type VARCHAR(15)
AS
BEGIN

	SELECT *
    FROM fare_info
    WHERE seat_type = @seat_type;

    IF
        @placement <> 'A' AND @placement <> 'W' AND @placement <> 'M' AND @@ROWCOUNT = 0
        BEGIN
            Print
                'Invalid placement and invalid seat type.';
            RETURN;
        END

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
GO

SELECT *
FROM seat;

--Test for inserting seat for invalid placement and seat type.
EXEC sp_insert_seat 'B', 'PREMIUM CLASS';

--Test for inserting seat for invalid seat_type.
EXEC sp_insert_seat 'A', 'PREMIUM CLASS';

--Test for inserting seat for invalid placement.
EXEC sp_insert_seat 'B', 'FIRST CLASS';

--Test for inserting seat for correct parameters.
EXECUTE sp_insert_seat 'M', 'ECONOMY CLASS';

--Reverse change
DELETE FROM seat WHERE seat_number = 6;