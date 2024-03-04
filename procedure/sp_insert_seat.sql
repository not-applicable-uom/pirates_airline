CREATE PROCEDURE sp_insert_seat @placement CHAR,
                                @seat_type VARCHAR(15)
AS
BEGIN
    SELECT * FROM fare_info WHERE seat_type = @seat_type;

    IF @@ROWCOUNT = 0
        BEGIN
            PRINT 'Invalid seat type.';
        END
    ELSE
        BEGIN
            DECLARE @max AS INTEGER;
            SELECT @max = MAX(seat_number) FROM seat GROUP BY seat_number;

            IF @@ROWCOUNT = 0
                BEGIN
                    INSERT INTO seat VALUES (1, @placement, @seat_type);
                END
            ELSE
                BEGIN
                    INSERT INTO seat VALUES (@max + 1, @placement, @seat_type);
                END
        END
END