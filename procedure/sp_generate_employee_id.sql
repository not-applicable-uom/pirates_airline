--generate employee_id & insert data into employee table.
CREATE PROCEDURE sp_generate_employee_id @first_name VARCHAR(40),@last_name VARCHAR(40),@gender CHAR,
@dob DATE,@address VARCHAR(40),@phone_number VARCHAR(15),@email VARCHAR(40),@role VARCHAR(40),@crew_id INTEGER
AS
BEGIN
	DECLARE @employee_id INTEGER;

	SELECT *
	FROM crew
	WHERE @crew_id = crew_id;

	IF @@ROWCOUNT = 0 
		BEGIN
			PRINT 'This crew id does not exist!';
		END;
	ELSE
		BEGIN
			SELECT @employee_id = MAX(employee_id)
			FROM employee
			GROUP BY employee_id;
		END;

	IF @@ROWCOUNT <> 0
		BEGIN
			PRINT @employee_id
			INSERT INTO employee VALUES ((@employee_id + 1),@first_name,@last_name,@gender,@dob,@address,@phone_number,@email,@role,@crew_id);
		END;
	ELSE
		BEGIN
			INSERT INTO employee VALUES (1,@first_name,@last_name,@gender,@dob,@address,@phone_number,@email,@role,@crew_id);
		END;	
END;

EXEC sp_generate_crew_id 'Ali'
SELECT * FROM employee;
EXEC sp_generate_employee_id 'Ali', 'Bliss', 'F', '10/28/1984', '79074 Waubesa Circle', '(728) 3175390', 'abliss0@cloudflare.com', 'Captain', 1;
SELECT * FROM employee;

DELETE FROM crew;
DELETE FROM employee;
