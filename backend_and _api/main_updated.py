

from flask import Flask, request, jsonify
import pymysql
from bcrypt import hashpw, gensalt, checkpw

app = Flask(__name__)

# MySQL database connection
def connect_db():
    return pymysql.connect(
        host='localhost',  # Replace with your DB host
        user='root',       # Replace with your DB username
        password='202201495',  # Replace with your DB password
        db='VuHacathon'     # Replace with your DB name
    )

# API to receive data from ESP32
@app.route('/api/send_data', methods=['POST'])
def receive_data():
    connection = None  # Initialize connection
    try:
        data = request.json
        driver_id = data.get('driver_id')
        x_accel = data.get('x_accel')
        y_accel = data.get('y_accel')
        z_accel = data.get('z_accel')

        connection = connect_db()
        cursor = connection.cursor()
        sql = "INSERT INTO adxl_readings (driver_id, x_accel, y_accel, z_accel) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (driver_id, x_accel, y_accel, z_accel))
        connection.commit()

        return jsonify({"message": "Data stored successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Check if connection is not None before closing
            connection.close()

@app.route('/api/get_data/<driver_id>', methods=['GET'])
def get_data_by_device(driver_id):
    connection = None  # Initialize connection
    try:
        connection = connect_db()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        sql = "SELECT * FROM adxl_readings WHERE driver_id = %s ORDER BY timestamp DESC LIMIT 10"
        cursor.execute(sql, (driver_id,))
        results = cursor.fetchall()

        return jsonify(results), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Check if connection is not None before closing
            connection.close()

@app.route('/api/signup', methods=['POST'])
def signup():
    connection = None  # Initialize connection
    try:
        data = request.json
        username = data.get('username')
        email = data.get('email')
        password = data.get('password')

        hashed_password = hashpw(password.encode('utf-8'), gensalt())

        connection = connect_db()
        cursor = connection.cursor()
        sql = "INSERT INTO users (username, email, password) VALUES (%s, %s, %s)"
        cursor.execute(sql, (username, email, hashed_password))
        connection.commit()

        return jsonify({"message": "User registered successfully"}), 201

    except pymysql.MySQLError as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Check if connection is not None before closing
            connection.close()

@app.route('/api/login', methods=['POST'])
def login():
    connection = None  # Initialize connection
    try:
        data = request.json
        username = data.get('username')
        password = data.get('password')

        connection = connect_db()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        sql = "SELECT * FROM users WHERE username = %s"
        cursor.execute(sql, (username,))
        user = cursor.fetchone()

        if user and checkpw(password.encode('utf-8'), user['password'].encode('utf-8')):
            return jsonify({"message": "Login successful"}), 200
        else:
            return jsonify({"message": "Invalid username or password"}), 401

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Check if connection is not None before closing
            connection.close()

@app.route('/api/get_driver_rating/<driver_id>', methods=['GET'])
def get_driver_rating(driver_id):
    connection = None  # Initialize connection
    try:
        connection = connect_db()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        
        # Fetch acceleration readings
        cursor.execute("""SELECT x_accel, y_accel, z_accel, timestamp FROM adxl_readings WHERE driver_id = %s""", (driver_id,))
        readings = cursor.fetchall()

        # Calculate driver rating based on ADXL readings
        rating = calculate_driver_rating(readings)
        
        # Fetch reviews
        cursor.execute("""SELECT review FROM driver_reviews WHERE driver_id = %s""", (driver_id,))
        reviews = cursor.fetchall()

        return jsonify({
            'driver_id': driver_id,
            'rating': rating,
            'reviews': reviews
        })

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Check if connection is not None before closing
            connection.close()

def calculate_driver_rating(readings):
    # Basic example: Calculate a rating based on average acceleration
    if not readings:
        return "No readings available"

    total_accel = sum(abs(reading['x_accel']) + abs(reading['y_accel']) + abs(reading['z_accel']) for reading in readings)
    avg_accel = total_accel / len(readings)
    
    # Simple logic: Higher avg_accel = lower rating
    if avg_accel < 5:
        return 5  # Excellent driving
    elif avg_accel < 10:
        return 4  # Good driving
    elif avg_accel < 15:
        return 3  # Average driving
    elif avg_accel < 20:
        return 2  # Below Average driving
    else:
        return 1  # Poor driving


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
