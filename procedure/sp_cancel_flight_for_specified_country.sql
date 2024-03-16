CREATE PROCEDURE sp_cancel_flight_for_specified_country @country VARCHAR(40)
AS
BEGIN

    SELECT *
    FROM airport
    WHERE country = @country;

    IF
        @@ROWCOUNT > 0
        BEGIN
            DELETE
            FROM flight
            WHERE destination_airport_id IN (SELECT airport_id
                                             FROM airport
                                             WHERE country = @country);
            IF
                @@ROWCOUNT = 0
                BEGIN
                    PRINT
                        'There is no flight scheduled for ' + @country;
                END
        END
    ELSE
        PRINT 'We do not operate in ' + @country;
END;
GO

--Test procedure for deleting flights to Australia.
SELECT *
FROM airport;
SELECT *
FROM flight;
SELECT *
FROM booking;
SELECT *
FROM booking_refund;
EXEC sp_cancel_flight_for_specified_country 'Australia';
SELECT *
FROM airport;
SELECT *
FROM flight;
SELECT *
FROM booking;
SELECT *
FROM booking_refund;

--Test procedure for deleting flights to inexistent country.
EXEC sp_cancel_flight_for_specified_country 'Indonesia';


