# Pirates Airline Database Project

This project contains a relational database schema and supporting SQL code designed for a fictional airline named "Pirates Airline."  The database supports the core functionality of passenger registration, flight booking, and airline operations management.

## **Database Schema**

Key entities within the schema include:

* **Airline:** Stores basic airline information (airline_id, airline_name, additional_fees).
* **Airplane:**  Holds airplane details (airplane_id, airline_id, airplane_model_id).
* **AirplaneModel:** Specifications of airplane models (airplane_model_id, model_name, manufacturer).
* **Airport:**  Airport data (airport_id, name, country, city).
* **Booking:** Tracks flight bookings (booking_id, date, seat_number, passenger_id, flight_id).
* **Crew:**  Airline crew information (crew_id, name).
* **Employee:**  Stores employee details (employee_id, first_name, last_name, gender, dob, address, phone_number, email, role, crew_id).
* **Flight:**  Flight routes (flight_id, price, airplane_id, origin_airport_id, departure_time, destination_airport_id, arrival_time, crew_id).
* **Passenger:**  Passenger data (passenger_id, first_name, last_name, dob, address, gender, passport_number, phone_number, email).
* **Seat:**  Information about seats in an airplane (seat_number, placement, seat_type).
* **FareInfo:**  Stores details of different seat types and associated additional fees.

## **SQL Statements**

The repository includes:

* **Table Creation:** SQL statements (DDL) for creating the database schema.
* **Data Insertion:** SQL statements (DML) for populating the tables with sample data.
* **Queries:** Examples of SQL queries (DQL) to retrieve and analyze data, such as:
   * Listing available flights based on origin and destination
   * Generating passenger manifests
   * Calculating revenue reports
   * Scheduling crew assignments

## **Stored Procedures and Functions**

The repository may contain:

* **Stored Procedures:** For complex or frequently used operations like:
   * The complete flight booking process.
   * Automatic seat assignment.
* **Functions:** For modular calculations such as:
   * Calculating total ticket cost including additional fees.

## **How to Use**

1. Clone the repository locally.
2. Create a database instance on your SQL server.
3. Execute the SQL statements in the provided files to set up the schema and optional sample data.
