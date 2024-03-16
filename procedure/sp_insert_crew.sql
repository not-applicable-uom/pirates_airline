CREATE PROCEDURE sp_insert_crew @name VARCHAR(40)
AS
BEGIN
    DECLARE @crew_id AS INTEGER;
    SELECT @crew_id = MAX(crew_id)
    FROM crew
    GROUP BY crew_id;

    IF @@ROWCOUNT <> 0
        BEGIN
            PRINT @crew_id
            INSERT INTO crew VALUES ((@crew_id + 1), @name);
        END;
    ELSE
        BEGIN
            INSERT INTO crew VALUES (1, @name);
        END;
END;
GO

-- Test if the id is being incremented
EXEC sp_insert_crew 'Example';