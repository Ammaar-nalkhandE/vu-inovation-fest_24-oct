
from flask import Flask, jsonify, request
import mysql.connector

app = Flask(__name__)

# Configure MySQL connection
def get_mysql_connection():
    return mysql.connector.connect(
        host='localhost',        # Your MySQL host (usually 'localhost')
        user='root',  # Your MySQL username
        password='202201495',# Your MySQL password
        database='driver_data'   # Your MySQL database name
    )

# Fetch latest 5 ADXL readings from MySQL
@app.route('/get-latest-readings', methods=['GET'])
def get_latest_readings():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    cursor.execute('SELECT x_accel, y_accel, z_accel FROM adxl_data ORDER BY id DESC LIMIT 10')
    readings = [{'x': row[0], 'y': row[1], 'z': row[2]} for row in cursor.fetchall()]
    conn.close()
    return jsonify(readings)

# Send alert if driver rating is poor (just prints the message for now)
@app.route('/send-alert', methods=['POST'])
def send_alert():
    data = request.json
    message = data.get('message', '')
    # Here you would add logic to send alerts (SMS, Email, etc.)
    print(f'ALERT: {message}')
    return jsonify({'status': 'Alert sent successfully!'})

# @app.route('/check-accident', methods=['GET'])
# def check_accident():
#     conn = get_mysql_connection()
#     cursor = conn.cursor()
    
#     # Fetch the latest record to check for accident status
#     cursor.execute('SELECT acc_status FROM adxl_data LIMIT 10')
#     result = cursor.fetchone()
#     conn.close()

#     if result:
#         accident_status = result[0]  # This will be a boolean value (0 or 1)
#         return jsonify({'accident': accident_status})  # Return as JSON
#     else:
#         return jsonify({'accident': "0"})  # No records found

@app.route('/check-accident', methods=['GET'])
def check_accident():
    conn = get_mysql_connection()
    cursor = conn.cursor()
    
    # Fetch the acc_status for the latest 10 records
    cursor.execute('SELECT acc_status FROM adxl_data ORDER BY id DESC LIMIT 10')
    results = cursor.fetchall()
    conn.close()

    # Check if any of the acc_status values indicate an accident
    accident_status = any(result[0] for result in results)  # Returns True if any acc_status is 1 (True)
    
    return jsonify({'accident': int(accident_status)})  # Return as JSON (0 or 1)

# API to get the latest readings
@app.route('/for-graph', methods=['GET'])
def for_graph():
    conn = get_mysql_connection()
    cursor = conn.cursor(dictionary=True)

    query = "SELECT x_accel AS x, y_accel AS y, z_accel AS z, acc_status FROM adxl_data ORDER BY timestamp DESC LIMIT 10"
    cursor.execute(query)
    readings = cursor.fetchall()

    return jsonify(readings)


@app.route('/api/send_data', methods=['POST'])
def receive_data():
    connection = None  # Initialize connection
    try:
        data = request.json
        
        # Extracting data from the incoming JSON
        driver_id = data.get('driver_id')
        x_accel = data.get('x_val')  # Assuming 'x_val', 'y_val', 'z_val' match your app's JSON
        y_accel = data.get('y_val')
        z_accel = data.get('z_val')
        acc_status = data.get('accident')  # 0 for no accident, 1 for accident
        
        # Check if all necessary data fields are provided
        if None in [driver_id, x_accel, y_accel, z_accel, acc_status]:
            return jsonify({"error": "Missing required data"}), 400

        # Establishing MySQL connection and executing SQL query
        connection = get_mysql_connection()
        cursor = connection.cursor()
        sql = """
            INSERT INTO adxl_data (driver_id, x_accel, y_accel, z_accel, acc_status) 
            VALUES (%s, %s, %s, %s, %s)
        """
        cursor.execute(sql, (driver_id, x_accel, y_accel, z_accel, acc_status))
        connection.commit()

        return jsonify({"message": "Data stored successfully"}), 201

    except Exception as e:
        return jsonify({"error": str(e)}), 400

    finally:
        if connection:  # Ensure connection is closed if open
            connection.close()

# @app.route('/api/send_data', methods=['POST'])
# def receive_data():
#     connection = None  # Initialize connection
#     try:
#         data = request.json
#         driver_id = data.get('driver_id')
#         x_accel = data.get('x_accel')
#         y_accel = data.get('y_accel')
#         z_accel = data.get('z_accel')

#         connection = get_mysql_connection()
#         cursor = connection.cursor()
#         sql = "INSERT INTO adxl_readings (driver_id, x_accel, y_accel, z_accel, acc_status) VALUES (%s, %s, %s, %s,%s)"
#         cursor.execute(sql, (driver_id, x_accel, y_accel, z_accel))
#         connection.commit()

#         return jsonify({"message": "Data stored successfully"}), 201

#     except Exception as e:
#         return jsonify({"error": str(e)}), 400

#     finally:
#         if connection:  # Check if connection is not None before closing
#             connection.close()

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000,debug=True)
