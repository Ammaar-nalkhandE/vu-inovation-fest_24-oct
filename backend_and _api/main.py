# this is done for the basiic level now the UID is to updated every where 


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
    try:
        data = request.json
        device_id = data.get('device_id')
        x_val = data.get('x_val')
        y_val = data.get('y_val')
        z_val = data.get('z_val')
        
        connection = connect_db()
        cursor = connection.cursor()
        sql = "INSERT INTO sensor_data (device_id, x_val, y_val, z_val) VALUES (%s, %s, %s, %s)"
        cursor.execute(sql, (device_id, x_val, y_val, z_val))
        connection.commit()
        
        return jsonify({"message": "Data stored successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        connection.close()


@app.route('/api/get_data/<device_id>', methods=['GET'])
def get_data_by_device(device_id):
    try:
        connection = connect_db()
        cursor = connection.cursor(pymysql.cursors.DictCursor)
        sql = "SELECT * FROM sensor_data WHERE device_id = %s ORDER BY timestamp DESC LIMIT 10"
        cursor.execute(sql, (device_id,))
        results = cursor.fetchall()
        
        return jsonify(results), 200

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        connection.close()


@app.route('/api/signup', methods=['POST'])
def signup():
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
        connection.close()

# Login API
@app.route('/api/login', methods=['POST'])
def login():
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
        connection.close()

@app.route('/get-driver-rating/<driver_id>', methods=['GET'])
def get_driver_rating(driver_id):
    cursor = db.cursor(dictionary=True)
    cursor.execute("""
        SELECT x_accel, y_accel, z_accel, timestamp FROM adxl_readings
        WHERE driver_id = %s
    """, (driver_id,))
    readings = cursor.fetchall()

    # Calculate driver rating based on ADXL readings
    rating = calculate_driver_rating(readings)
    
    # Fetch reviews if needed
    cursor.execute("""
        SELECT review FROM driver_reviews WHERE driver_id = %s
    """, (driver_id,))
    reviews = cursor.fetchall()

    return jsonify({
        'driver_id': driver_id,
        'rating': rating,
        'reviews': reviews
    })

def calculate_driver_rating(readings):
    # Basic example: Calculate a rating based on average acceleration
    total_accel = 0
    for reading in readings:
        total_accel += abs(reading['x_accel']) + abs(reading['y_accel']) + abs(reading['z_accel'])
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
    app.run(debug=True)


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
