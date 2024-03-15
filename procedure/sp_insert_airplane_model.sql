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