-- returns available seats in a flight and displays related information
CREATE FUNCTION fn_seat_availability(@flight_id INTEGER)
    RETURNS @return TABLE
                    (
                        seat_number INTEGER,
                        placement   CHAR,
                        seat_type   VARCHAR(40),
                        price       DECIMAL(7, 2)
                    )
AS
BEGIN
    DECLARE @price DECIMAL(7, 2), @airline_additional_fees DECIMAL(7, 2);
    SELECT @price = price, @airline_additional_fees = additional_fees
    FROM (flight LEFT JOIN airplane ON flight.airplane_id = airplane.airplane_id)
             LEFT JOIN airline ON airplane.airline_id = airline.airline_id
    WHERE flight_id = @flight_id;
    INSERT @return
    SELECT seat_number, placement, seat.seat_type, (@price * (additional_fees + @airline_additional_fees + 1)) AS price_for_seat
    FROM seat
             JOIN fare_info ON seat.seat_type = fare_info.seat_type
    WHERE seat.seat_number IN
          ((SELECT seat_number FROM seat) except (SELECT seat_number FROM booking WHERE flight_id = @flight_id));
    RETURN;
END;
GO

-- returns seats that are available for booking in a flight
SELECT * FROM fn_seat_availability(3);