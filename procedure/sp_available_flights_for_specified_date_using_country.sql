-- checks for available flight for specified date using country
CREATE PROCEDURE sp_available_flights_for_specified_date_using_country @date DATE,
                                                                       @origin_country VARCHAR(40),
                                                                       @destination_country VARCHAR(40)
AS
BEGIN
    SELECT flight_id,
           price,
           airplane_id,
           DATEDIFF(HOUR, departure_time, arrival_time) AS flight_duration,
           origin_airport_id,
           origin.name                                  AS origin_airport,
           origin.country                               AS origin_country,
           departure_time,
           destination_airport_id,
           dest.name                                    as destination_airport,
           dest.country                                 AS destination_country,
           arrival_time
    FROM (flight JOIN airport AS origin ON flight.origin_airport_id = origin.airport_id)
             JOIN airport AS dest ON flight.destination_airport_id = dest.airport_id
    WHERE CAST(departure_time AS DATE) >= @date
      AND origin.country = @origin_country
      AND dest.country = @destination_country
      AND (SELECT COUNT(*) AS num FROM fn_seat_availability(flight_id)) > 0
    ORDER BY departure_time;
END
GO

EXECUTE sp_available_flights_for_specified_date_using_country '2024-03-25', 'Mauritius', 'Australia';