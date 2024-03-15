-- crew member checks if scheduled for a flight for a specified date
CREATE PROCEDURE sp_check_if_crew_member_assigned_to_flight @employee_id INTEGER,
                                                            @date DATE
AS
BEGIN
    SELECT CONCAT('You are scheduled for flight_id ', flight_id, ' on ', @date)
    FROM (employee JOIN crew ON employee.crew_id = crew.crew_id)
             JOIN flight ON crew.crew_id = flight.crew_id
    WHERE employee_id = @employee_id
      AND @date BETWEEN CAST(departure_time AS DATE) AND CAST(arrival_time AS DATE);
END