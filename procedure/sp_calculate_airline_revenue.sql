CREATE PROCEDURE sp_calculate_airline_revenue @airline_id VARCHAR(5)
AS
BEGIN
    SELECT YEAR(booking.date)                                                     AS Year,
           airline.airline_name,
           SUM(price * (airline.additional_fees + fare_info.additional_fees + 1)) AS revenue
    FROM ((((booking JOIN flight ON booking.flight_id = flight.flight_id)
        JOIN seat ON seat.seat_number = booking.seat_number) JOIN fare_info
           ON seat.seat_type = fare_info.seat_type)
        JOIN airplane ON flight.airplane_id = airplane.airplane_id)
             JOIN airline ON airline.airline_id = airplane.airline_id
    WHERE airline.airline_id = @airline_id
    GROUP BY airline.airline_name, YEAR(booking.date)
    ORDER BY YEAR(booking.date);
END
GO

-- Test if the stored procedure displays the correct result
EXECUTE sp_calculate_airline_revenue 'ai001';
