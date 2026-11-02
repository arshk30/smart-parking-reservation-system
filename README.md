# Smart Parking and Reservation Management System

## Project Overview
The Smart Parking and Reservation Management System is a database-driven application developed using Python, Flask, and MySQL. It helps manage parking slots, vehicle reservations, customer details, parking entries and exits, and payments.

## Technologies Used
- Python
- Flask
- MySQL
- HTML
- CSS
- JavaScript
- MySQL Connector

## Features
- Customer management
- Vehicle registration
- Parking slot management
- Parking reservation system
- Vehicle entry and exit recording
- Automatic parking fee calculation
- Payment management
- Audit log using database triggers
- Stored procedures for parking operations
- Dashboard for viewing parking information

## Database Tables
1. users
2. vehicles
3. parking_slots
4. reservations
5. parking_records
6. payments
7. audit_log

## Project Structure
```text
SmartParkingDashboard/
├── app.py
├── requirements.txt
├── database.sql
├── templates/
│   └── index.html
└── static/
    ├── style.css
    └── script.js
```

## Installation and Execution

1. Clone or download this repository.
2. Install the required packages:

```bash
pip install -r requirements.txt
```

3. Open MySQL Workbench.
4. Execute the `database.sql` file to create the database and tables.
5. Configure your MySQL connection details in `app.py`.
6. Run the Flask application:

```bash
python app.py
```

7. Open the local URL displayed in the terminal in your browser.

## Learning Outcomes
- Understanding database management using MySQL.
- Implementing CRUD operations using Python and Flask.
- Working with stored procedures and database triggers.
- Understanding parking reservation and payment management.
- Connecting a web application with a relational database.

