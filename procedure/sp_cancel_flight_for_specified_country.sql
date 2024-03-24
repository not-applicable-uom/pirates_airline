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
SELECT * FROM airport;
SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;
EXEC sp_cancel_flight_for_specified_country 'Australia';
SELECT * FROM airport;
SELECT * FROM flight;
SELECT * FROM booking;
SELECT * FROM booking_refund;
-- Reverse change
INSERT INTO flight VALUES (1, 300.0, 'ab001', 'smp01', '03-28-2024 08:00:00', 'bab01', '03-28-2024 15:00:00', 1);
INSERT INTO flight VALUES (3, 305.0, 'eb001', 'smp01', '03-28-2024 10:00:00', 'cac01', '03-28-2024 17:00:00', 2);
INSERT INTO booking VALUES (1, '03-10-2024', 3, 1, 1);
INSERT INTO booking VALUES (2, '03-11-2024', 5, 2, 1);
INSERT INTO booking VALUES (3, '03-10-2024', 1, 3, 1);
INSERT INTO booking VALUES (7, '03-19-2024', 3, 4, 3);
INSERT INTO booking VALUES (8, '03-22-2024', 2, 5, 3);
DELETE FROM booking_refund;


--Test procedure for deleting flights to nonexistent country.
EXEC sp_cancel_flight_for_specified_country 'Indonesia';


