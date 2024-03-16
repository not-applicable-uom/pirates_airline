EXECUTE sp_insert_airline 'Air Mauritius', 0.0;
EXECUTE sp_insert_airline 'British Airways', 0.1;
EXECUTE sp_insert_airline 'Emirates', 0.25;

EXECUTE sp_insert_airplane_model 'Beechcraft', 'King Air 350';
EXECUTE sp_insert_airplane_model 'Dassault Aviation', 'Falcon 7X';

EXECUTE sp_insert_airplane 'ai001', 'bk001';
EXECUTE sp_insert_airplane 'br001', 'df001';
EXECUTE sp_insert_airplane 'br001', 'bk001';
EXECUTE sp_insert_airplane 'em001', 'df001';
EXECUTE sp_insert_airplane 'em001', 'bk001';

EXECUTE sp_insert_airport 'Sir Seewoosagur Ramgoolam International Airport', 'Mauritius', 'Plaine Magnien';
EXECUTE sp_insert_airport 'Brisbane Airport', 'Australia', 'Brisbane';
EXECUTE sp_insert_airport 'Cairns Airport', 'Australia', 'Cairns';
EXECUTE sp_insert_airport 'Heathrow Airport', 'United Kingdom', 'London';
EXECUTE sp_insert_airport 'Los Angeles Airport', 'United States', 'Los Angeles';
EXECUTE sp_insert_airport 'Heathrow Airport', 'United Kingdom', 'London';
EXECUTE sp_insert_airport 'Charles de Gaulle Airport', 'France', 'Paris';

EXECUTE sp_insert_crew 'Zephyr';
EXECUTE sp_insert_crew 'Jetstream';

EXECUTE sp_insert_employee 'Ali', 'Bliss', 'F', '10/28/1984', '79074 Waubesa Circle', '(728) 3175390', 'abliss0@cloudflare.com', 'Captain', 1;
EXECUTE sp_insert_employee 'Zitella', 'Meegin', 'F', '8/10/1990', '50 Artisan Pass', '(250) 7709520', 'zmeegin1@quantcast.com', 'Co-pilot', 1;
EXECUTE sp_insert_employee 'Lacy', 'Llywarch', 'F', '10/11/1995', '754 Mallard Plaza', '(340) 7210403', 'lllywarch2@gizmodo.com', 'Flight Attendant', 1;
EXECUTE sp_insert_employee 'Gipsy', 'Chasmoor', 'F', '12/21/1991', '561 Dawn Court', '(168) 7732904', 'gchasmoor3@un.org', 'Flight Engineer', 1;
EXECUTE sp_insert_employee 'Chucho', 'Keune', 'M', '7/19/1980', '8722 Magdeline Pass', '(530) 9783328', 'ckeune4@reference.com', 'Air Marshal', 1;
EXECUTE sp_insert_employee 'Danya', 'Polglase', 'F', '9/30/1982', '4405 Myrtle Hill', '(909) 9287861', 'dpolglase5@google.cn', 'Loadmaster', 1;
EXECUTE sp_insert_employee 'Jerry', 'Sperrett', 'M', '11/25/1994', '99 Ridgeview Way', '(698) 6452306', 'jsperrett6@canalblog.com', 'Flight Dispatcher', 1;
EXECUTE sp_insert_employee 'Sarina', 'Jossel', 'F', '7/1/1983', '942 Orin Crossing', '(956) 7233345', 'sjossel7@1und1.de', 'Captain', 2;
EXECUTE sp_insert_employee 'Edie', 'Haselup', 'F', '11/18/2004', '11831 Petterle Center', '(972) 6492307', 'ehaselup8@squidoo.com', 'Co-pilot', 2;
EXECUTE sp_insert_employee 'Davide', 'McAlarney', 'M', '1/7/1989', '26326 Independence Plaza', '(746) 3809772', 'dmcalarney9@arizona.edu', 'Flight Attendant', 2;
EXECUTE sp_insert_employee 'Aube', 'Derwin', 'M', '12/28/1971', '3045 Westend Junction', '(387) 4344133', 'aderwina@bandcamp.com', 'Flight Engineer', 2;
EXECUTE sp_insert_employee 'Shurlock', 'Staite', 'M', '10/4/1979', '869 Walton Trail', '(970) 8861358', 'sstaiteb@wiley.com', 'Air Marshal', 2;
EXECUTE sp_insert_employee 'Cleavland', 'OHagirtie', 'M', '12/17/1972', '43 Pennsylvania Trail', '(720) 4993537', 'cohagirtiec@seesaa.net', 'Loadmaster', 2;
EXECUTE sp_insert_employee 'Gaston', 'Kinnier', 'M', '1/3/1998', '39259 Oak Hill', '(764) 8260304', 'gkinnierd@cisco.com', 'Flight Dispatcher', 2;

INSERT INTO fare_info (seat_type, additional_fees) VALUES ('ECONOMY CLASS', 0.0);
INSERT INTO fare_info (seat_type, additional_fees) VALUES ('BUSINESS CLASS', 0.15);
INSERT INTO fare_info (seat_type, additional_fees) VALUES ('FIRST CLASS', 0.5);

EXECUTE sp_insert_seat 'A', 'FIRST CLASS';
EXECUTE sp_insert_seat 'W', 'BUSINESS CLASS';
EXECUTE sp_insert_seat 'A', 'ECONOMY CLASS';
EXECUTE sp_insert_seat 'M', 'ECONOMY CLASS';
EXECUTE sp_insert_seat 'M', 'ECONOMY CLASS';

EXECUTE sp_insert_flight 300.0, 'ab001', 'smp01', '03-28-2024 08:00:00', 'bab01', '03-28-2024 15:00:00', 1;
EXECUTE sp_insert_flight 300.0, 'ab001', 'bab01', '03-28-2024 20:00:00', 'smp01', '03-29-2024 03:00:00', 1;
EXECUTE sp_insert_flight 305.0, 'eb001', 'smp01', '03-28-2024 10:00:00', 'cac01', '03-28-2024 17:00:00', 2;
EXECUTE sp_insert_flight 305.0, 'eb001', 'cac01', '03-28-2024 22:00:00', 'smp01', '03-29-2024 05:00:00', 2;
EXECUTE sp_insert_flight 450.0, 'bd001', 'cfp01', '03-30-2024 10:00:00', 'hul01', '03-30-2024 14:00:00', 1;
EXECUTE sp_insert_flight 450.0, 'bd001', 'hul01', '03-30-2024 22:00:00', 'cfp01', '03-31-2024 02:00:00', 1;

EXECUTE sp_book_flight 1, '03-10-2024', 'A', 'ECONOMY CLASS', NULL,  'Barn', 'Kellaway', '1/3/1994', '94536 Monument Hill', 'M', 'PQR98765432100C', '(641) 5273154', 'bkellaway0@delicious.com';
EXECUTE sp_book_flight 1, '03-11-2024', 'M', 'ECONOMY CLASS', NULL,  'Ines', 'Geffcock', '9/30/1992', '1 Bultman Hill', 'F', 'RST45678912300J', '(469) 9887706', 'igeffcock1@usgs.gov';
EXECUTE sp_book_flight 1, '03-10-2024', 'A', 'FIRST CLASS', NULL,  'Dilan', 'Grinnov', '4/1/1989', '359 Debra Crossing', 'M', 'LMN12345678900F', '(787) 7352146', 'dgrinnov2@gravatar.com';
EXECUTE sp_book_flight 2, '03-10-2024', 'A', 'ECONOMY CLASS', 1;
EXECUTE sp_book_flight 2, '03-11-2024', 'M', 'ECONOMY CLASS', 2;
EXECUTE sp_book_flight 2, '03-10-2024', 'A', 'FIRST CLASS', 3;

EXECUTE sp_book_flight 3, '03-19-2024', 'A', 'ECONOMY CLASS', NULL,  'Gerhard', 'Lowdwell', '12/6/1998', '27 Bayside Center', 'M', 'EFG45678912300H', '(573) 3323616', 'glowdwell3@flavors.me';
EXECUTE sp_book_flight 3, '03-22-2024', 'W', 'BUSINESS CLASS', NULL,  'Angelita', 'Connealy', '8/23/2009', '48624 4th Pass', 'F', 'BCD98765432100A', '(764) 1512114', 'aconnealy4@unblog.fr';
EXECUTE sp_book_flight 4, '03-19-2024', 'A', 'ECONOMY CLASS', 4;
EXECUTE sp_book_flight 4, '03-22-2024', 'W', 'BUSINESS CLASS', 5;

SELECT * FROM airline;
SELECT * FROM airplane;
SELECT * FROM airplane_model;
SELECT * FROM airport;
SELECT * FROM booking;
SELECT * FROM booking_refund;
SELECT * FROM crew;
SELECT * FROM employee;
SELECT * FROM fare_info;
SELECT * FROM flight;
SELECT * FROM passenger
SELECT * FROM seat;

