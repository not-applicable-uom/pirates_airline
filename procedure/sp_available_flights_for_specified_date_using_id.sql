-- checks for available flight for specified date using id
CREATE PROCEDURE sp_available_flights_for_specified_date_using_id @date DATE,
                                                                  @origin_airport_id VARCHAR(5),
                                                                  @destination_airport_id VARCHAR(5)
AS
BEGIN
    SELECT *
    FROM flight
    WHERE CAST(departure_time AS DATE) >= @date
      AND origin_airport_id = @origin_airport_id
      AND destination_airport_id = @destination_airport_id
      AND (SELECT COUNT(*) AS num FROM fn_seat_availability(flight_id)) > 0
    ORDER BY departure_time;
END
GO

EXECUTE sp_available_flights_for_specified_date_using_id '2024-03-25', 'smp01', 'bab01';