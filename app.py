
from flask import Flask, render_template, request, jsonify
from datetime import datetime
from decimal import Decimal
import mysql.connector

app = Flask(__name__)

# MySQL database connection
DB_CONFIG = {
    "host": "localhost",
    "user": "root",
    "password": "@arsh30306",
    "database": "smart_parking",
    "port": 3306
}


def get_connection():
    return mysql.connector.connect(**DB_CONFIG)


def fetch_all(query, params=()):
    con = get_connection()
    try:
        cur = con.cursor(dictionary=True)
        cur.execute(query, params)
        return cur.fetchall()
    finally:
        con.close()


def call_procedure(name, params):
    con = get_connection()
    try:
        cur = con.cursor()
        cur.callproc(name, params)
        con.commit()
    except Exception:
        con.rollback()
        raise
    finally:
        con.close()


def convert(rows):
    for row in rows:
        for key, value in row.items():
            if isinstance(value, (datetime,)):
                row[key] = value.strftime("%Y-%m-%d %H:%M:%S")
            elif isinstance(value, Decimal):
                row[key] = float(value)
    return rows


@app.route("/")
def home():
    return render_template("index.html")


# Dashboard statistics
@app.route("/api/dashboard")
def dashboard():
    queries = {
        "total_slots": "SELECT COUNT(*) n FROM parking_slots",
        "available_slots": "SELECT COUNT(*) n FROM parking_slots WHERE slot_status='AVAILABLE'",
        "occupied_slots": "SELECT COUNT(*) n FROM parking_slots WHERE slot_status='OCCUPIED'",
        "active_reservations": "SELECT COUNT(*) n FROM reservations WHERE booking_status IN ('BOOKED','ACTIVE')",
        "revenue": "SELECT COALESCE(SUM(amount),0) n FROM payments WHERE payment_status='PAID'"
    }

    result = {}

    for key, query in queries.items():
        result[key] = fetch_all(query)[0]["n"]

    return jsonify(convert([result])[0])


# Parking slots
@app.route("/api/slots")
def slots():
    rows = fetch_all("""
        SELECT * FROM parking_slots
        ORDER BY floor_number, slot_number
    """)
    return jsonify(convert(rows))


# Customers, vehicles and slots for booking form
@app.route("/api/options")
def options():
    users = fetch_all("SELECT user_id, full_name FROM users")
    vehicles = fetch_all("""
        SELECT vehicle_id, user_id, vehicle_number, vehicle_type
        FROM vehicles
    """)
    slots = fetch_all("""
        SELECT slot_id, slot_number, slot_type, slot_status
        FROM parking_slots
        WHERE slot_status <> 'MAINTENANCE'
    """)

    return jsonify({
        "users": convert(users),
        "vehicles": convert(vehicles),
        "slots": convert(slots)
    })


# View reservations
@app.route("/api/reservations")
def reservations():
    rows = fetch_all("""
        SELECT r.reservation_id, u.full_name,
               v.vehicle_number, v.vehicle_type,
               s.slot_number, r.start_time,
               r.end_time, r.booking_status
        FROM reservations r
        JOIN users u ON r.user_id = u.user_id
        JOIN vehicles v ON r.vehicle_id = v.vehicle_id
        JOIN parking_slots s ON r.slot_id = s.slot_id
        ORDER BY r.reservation_id DESC
    """)
    return jsonify(convert(rows))


# Book a parking slot
@app.route("/api/book", methods=["POST"])
def book():
    data = request.get_json()

    try:
        start = datetime.strptime(data["start_time"], "%Y-%m-%dT%H:%M")
        end = datetime.strptime(data["end_time"], "%Y-%m-%dT%H:%M")

        call_procedure("book_parking_slot", (
            int(data["user_id"]),
            int(data["vehicle_id"]),
            int(data["slot_id"]),
            start,
            end
        ))

        return jsonify({"message": "Reservation created successfully."})

    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Cancel reservation
@app.route("/api/cancel", methods=["POST"])
def cancel():
    data = request.get_json()

    try:
        call_procedure("cancel_reservation", (
            int(data["reservation_id"]),
        ))
        return jsonify({"message": "Reservation cancelled successfully."})

    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Vehicle entry
@app.route("/api/entry", methods=["POST"])
def entry():
    data = request.get_json()

    try:
        call_procedure("record_vehicle_entry", (
            int(data["reservation_id"]),
        ))
        return jsonify({"message": "Vehicle entry recorded."})

    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Parking records
@app.route("/api/records")
def records():
    rows = fetch_all("""
        SELECT pr.record_id, r.reservation_id,
               u.full_name, v.vehicle_number,
               s.slot_number, pr.entry_time,
               pr.exit_time, pr.duration_hours,
               pr.parking_fee
        FROM parking_records pr
        JOIN reservations r ON pr.reservation_id = r.reservation_id
        JOIN users u ON r.user_id = u.user_id
        JOIN vehicles v ON r.vehicle_id = v.vehicle_id
        JOIN parking_slots s ON r.slot_id = s.slot_id
        ORDER BY pr.record_id DESC
    """)
    return jsonify(convert(rows))


# Vehicle exit
@app.route("/api/exit", methods=["POST"])
def exit_vehicle():
    data = request.get_json()

    try:
        call_procedure("record_vehicle_exit", (
            int(data["record_id"]),
        ))
        return jsonify({"message": "Vehicle exit recorded and fee calculated."})

    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Payments
@app.route("/api/payments")
def payments():
    rows = fetch_all("""
        SELECT p.payment_id, p.record_id,
               v.vehicle_number, s.slot_number,
               p.amount, p.payment_status, p.payment_date
        FROM payments p
        JOIN parking_records pr ON p.record_id = pr.record_id
        JOIN reservations r ON pr.reservation_id = r.reservation_id
        JOIN vehicles v ON r.vehicle_id = v.vehicle_id
        JOIN parking_slots s ON r.slot_id = s.slot_id
        ORDER BY p.payment_id DESC
    """)
    return jsonify(convert(rows))


# Confirm payment
@app.route("/api/payments/confirm", methods=["POST"])
def confirm_payment():
    data = request.get_json()

    try:
        call_procedure("confirm_payment", (
            int(data["payment_id"]),
        ))
        return jsonify({"message": "Payment marked as paid."})

    except Exception as e:
        return jsonify({"error": str(e)}), 400


# Audit logs
@app.route("/api/audit")
def audit():
    rows = fetch_all("""
        SELECT a.log_id, s.slot_number,
               a.old_status, a.new_status,
               a.change_date, a.changed_by
        FROM audit_log a
        LEFT JOIN parking_slots s ON a.slot_id = s.slot_id
        ORDER BY a.log_id DESC
    """)
    return jsonify(convert(rows))


if __name__ == "__main__":
    app.run(debug=True)
