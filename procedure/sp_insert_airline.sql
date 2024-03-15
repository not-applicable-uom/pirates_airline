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