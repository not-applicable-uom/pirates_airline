CREATE TABLE airline
(
    airline_id      VARCHAR(5) PRIMARY KEY,
    airline_name    VARCHAR(40),
    additional_fees DECIMAL(7, 2)
);
CREATE TABLE airplane
(
    airplane_id       VARCHAR(5) PRIMARY KEY,
    airline_id        VARCHAR(5),
    airplane_model_id VARCHAR(5)
);
CREATE TABLE airplane_model
(
    airplane_model_id VARCHAR(5) PRIMARY KEY,
    model_name        VARCHAR(40),
    manufacturer      VARCHAR(40)
);
CREATE TABLE seat
(
    seat_number INTEGER PRIMARY KEY,
    placement   CHAR CHECK (placement IN ('W', 'M', 'A')),
    seat_type   VARCHAR(15)
);
CREATE TABLE fare_info
(
    seat_type       VARCHAR(15) PRIMARY KEY CHECK (seat_type IN ('ECONOMY CLASS', 'BUSINESS CLASS', 'FIRST CLASS')),
    additional_fees DECIMAL(7, 2)
);
CREATE TABLE airport
(
    airport_id VARCHAR(5) PRIMARY KEY,
    name       VARCHAR(40),
    country    VARCHAR(40),
    city       VARCHAR(40)
);

CREATE TABLE booking
(
    booking_id   INTEGER PRIMARY KEY,
    date         DATE,
    seat_number  INTEGER,
    passenger_id INTEGER,
    flight_id    INTEGER
);
CREATE TABLE crew
(
    crew_id INTEGER PRIMARY KEY,
    name    VARCHAR(40)
);
CREATE TABLE employee
(
    employee_id  INTEGER PRIMARY KEY,
    first_name   VARCHAR(40),
    last_name    VARCHAR(40),
    gender       CHAR CHECK (gender IN ('M', 'F')),
    dob          DATE,
    address      VARCHAR(40),
    phone_number VARCHAR(15),
    email        VARCHAR(40) CHECK (email LIKE '%_@__%.__%'),
    role         VARCHAR(40) CHECK (role IN
                                    ('Captain', 'Co-pilot', 'Flight Attendant', 'Flight Engineer', 'Air Marshal',
                                     'Loadmaster', 'Flight Dispatcher')),
    crew_id      INTEGER
);
CREATE TABLE flight
(
    flight_id              INTEGER PRIMARY KEY,
    price                  DECIMAL(7, 2),
    airplane_id            VARCHAR(5),
    origin_airport_id      VARCHAR(5),
    departure_time         DATETIME,
    destination_airport_id VARCHAR(5),
    arrival_time           DATETIME,
    crew_id                INTEGER
);
CREATE TABLE passenger
(
    passenger_id    INTEGER PRIMARY KEY,
    first_name      VARCHAR(40),
    last_name       VARCHAR(40),
    dob             DATE,
    address         VARCHAR(40),
    gender          CHAR CHECK (gender IN ('M', 'F')),
    passport_number VARCHAR(15),
    phone_number    VARCHAR(15),
    email           VARCHAR(40) CHECK (email LIKE '%_@__%.__%')
);
ALTER TABLE airplane
    ADD FOREIGN KEY (airline_id) REFERENCES airline (airline_id);
ALTER TABLE airplane
    ADD FOREIGN KEY (airplane_model_id) REFERENCES airplane_model (airplane_model_id);
ALTER TABLE employee
    ADD FOREIGN KEY (crew_id) REFERENCES crew (crew_id);
ALTER TABLE booking
    ADD FOREIGN KEY (passenger_id) REFERENCES passenger (passenger_id);
ALTER TABLE booking
    ADD FOREIGN KEY (flight_id) REFERENCES flight (flight_id) ON DELETE NO ACTION;
ALTER TABLE booking
    ADD FOREIGN KEY (seat_number) REFERENCES seat (seat_number);
ALTER TABLE flight
    ADD FOREIGN KEY (airplane_id) REFERENCES airplane (airplane_id);
ALTER TABLE flight
    ADD FOREIGN KEY (destination_airport_id) REFERENCES airport (airport_id);
ALTER TABLE flight
    ADD FOREIGN KEY (origin_airport_id) REFERENCES airport (airport_id);
ALTER TABLE flight
    ADD FOREIGN KEY (crew_id) REFERENCES crew (crew_id);
ALTER TABLE seat
    ADD FOREIGN KEY (seat_type) REFERENCES fare_info (seat_type);
