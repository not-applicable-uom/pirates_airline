CREATE PROCEDURE sp_insert_airplane @airline_id AS VARCHAR(5),
                                    @airplane_model_id AS VARCHAR(5)
AS
BEGIN
    DECLARE @start_str AS VARCHAR(2) = SUBSTRING(@airline_id, 1, 1) + SUBSTRING(@airplane_model_id, 1, 1);
    DECLARE @max AS INTEGER;
    SELECT @max = MAX(CAST(SUBSTRING(airplane_id, 3, 3) AS INTEGER))
    FROM airplane
    WHERE SUBSTRING(airplane_id, 1, 2) = @start_str
    GROUP BY airplane_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            INSERT INTO airplane
            VALUES (CONCAT(@start_str, RIGHT('000' + CAST((@max + 1) AS VARCHAR(3)), 3)),
                    @airline_id, @airplane_model_id);
        END
    ELSE
        BEGIN
            INSERT INTO airplane
            VALUES (CONCAT(@start_str, '001'), @airline_id, @airplane_model_id);
        END
END
GO

SELECT *
FROM airplane;
SELECT *
FROM airline;
SELECT *
FROM airplane_model;
--Test for inserting airplane for nonexistent airline_id and airplane_model_id
EXEC sp_insert_airplane 'ai003', 'bk002';

--Test for inserting airplane for existent airline_id and airplane_model.
EXEC sp_insert_airplane 'ai001', 'bk001';
SELECT *
FROM airplane;
SELECT *
FROM airline;
SELECT *
FROM airplane_model;
DELETE
FROM airplane
WHERE airplane_id = 'ab004';