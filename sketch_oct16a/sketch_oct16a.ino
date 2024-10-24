// edited with sim800l and mpu

#include <WiFi.h>
#include <HTTPClient.h>
#include <Wire.h>
#include <Adafruit_MPU6050.h>
#include <Adafruit_Sensor.h>
#include <SoftwareSerial.h>

// Replace with your network credentials
const char* ssid = "Test";
const char* password = "test@123";

// Flask API URL
const String api_url = "http://192.168.247.9:5000/api/send_data";

// SIM800L setup
SoftwareSerial sim800(26, 27);  // RX, TX for SIM800L

// MPU6050 setup
Adafruit_MPU6050 mpu;

// Variables to store sensor data
float x_sum = 0;
float y_sum = 0;
float z_sum = 0;
int data_count = 0;
unsigned long start_time = 0;
bool accident_detected = false;

void setup() {
  Serial.begin(115200);
  
  // Initialize WiFi
  connectToWiFi();
  
  // Initialize SIM800L
  sim800.begin(9600);

  // Initialize MPU6050
  if (!mpu.begin()) {
    Serial.println("Failed to initialize MPU6050!");
    while (1);
  }

  // Configure the MPU6050
  mpu.setAccelerometerRange(MPU6050_RANGE_16_G);
  mpu.setGyroRange(MPU6050_RANGE_250_DEG);
  mpu.setFilterBandwidth(MPU6050_BAND_21_HZ);

  // Start the 30-second cycle
  start_time = millis();
}

void loop() {
  // Collect data from MPU6050 sensor
  sensors_event_t a, g, temp;
  mpu.getEvent(&a, &g, &temp);

  // Add sensor values to the sum
  x_sum += a.acceleration.x;
  y_sum += a.acceleration.y;
  z_sum += a.acceleration.z;
  data_count++;

  // Calculate elapsed time in the current 1-second window
  unsigned long elapsed_time = millis() - start_time;

  // Every 1 second, compute the mean and send data
  if (elapsed_time >= 1000) {
    float x_mean = x_sum / data_count;
    float y_mean = y_sum / data_count;
    float z_mean = z_sum / data_count;

    // Check for accident condition based on accelerometer values
    accident_detected = (abs(x_mean) > 2.0 || abs(y_mean) > 2.0 || abs(z_mean) > 2.0) ? true : false;
    
    // Send data (accident_detected = 1 for accident, 0 for normal)
    sendMeanDataToAPI(x_mean, y_mean, z_mean, accident_detected);

    // Clear data for the next second
    x_sum = 0;
    y_sum = 0;
    z_sum = 0;
    data_count = 0;

    // Reset the start_time for the next second
    start_time = millis();
  }

  // After 30 seconds, start a new set
  if (elapsed_time >= 30000) {
    start_time = millis();  // Reset the timer for the next 30-second window
  }
}

void connectToWiFi() {
  Serial.print("Connecting to ");
  Serial.println(ssid);
  WiFi.begin(ssid, password);
  while (WiFi.status() != WL_CONNECTED) {
    delay(1000);
    Serial.print(".");
  }
  Serial.println("");
  Serial.println("WiFi connected");
}

void sendMeanDataToAPI(float x_mean, float y_mean, float z_mean, bool accident_detected) {
  if (WiFi.status() == WL_CONNECTED) {
    HTTPClient http;

    // Prepare JSON data for the POST request
    String postData = "{\"driver_id\":\"1\",\"x_val\":" + String(x_mean) +
                      ",\"y_val\":" + String(y_mean) + ",\"z_val\":" + String(z_mean) +
                      ",\"accident\":" + String(accident_detected ? 1 : 0) + "}";

    // Specify content type and API URL
    http.begin(api_url);
    http.addHeader("Content-Type", "application/json");

    // Send HTTP POST request
    int httpResponseCode = http.POST(postData);

    // Print response
    if (httpResponseCode > 0) {
      String response = http.getString();
      Serial.println(httpResponseCode);  // Print HTTP response code
      Serial.println(response);          // Print response payload
    } else {
      Serial.println("Error in sending POST request");
      Serial.println(httpResponseCode);
    }

    // End HTTP connection
    http.end();
  } else {
    Serial.println("WiFi not connected, sending via SIM800L...");
    sendViaSIM800(x_mean, y_mean, z_mean, accident_detected);
  }
}

// Function to send data via SIM800L in case WiFi is not available
void sendViaSIM800(float x_mean, float y_mean, float z_mean, bool accident_detected) {
  String smsData = "Driver ID: 1\nX: " + String(x_mean) +
                   "\nY: " + String(y_mean) +
                   "\nZ: " + String(z_mean) +
                   "\nAccident: " + String(accident_detected ? 1 : 0);

  sim800.print("AT+CMGF=1\r");  // Set SMS mode
  delay(100);
  sim800.print("AT+CMGS=\"+1234567890\"\r");  // Replace with actual phone number
  delay(100);
  sim800.print(smsData);  // Send data via SMS
  delay(100);
  sim800.write(26);  // Send Ctrl+Z to send the message
  delay(1000);
}


// #include <WiFi.h>
// #include <HTTPClient.h>
// #include <Wire.h>
// #include <Adafruit_Sensor.h>
// #include <Adafruit_ADXL345_U.h>

// // Replace with your network credentials
// const char* ssid = "Airtel_ARAFAT";
// const char* password = "9881498567";

// // Flask API URL
// const String api_url = "http://192.168.1.165:5000/api/send_data";

// // ADXL sensor setup
// Adafruit_ADXL345_Unified accel = Adafruit_ADXL345_Unified(12345);

// // Variables to store sensor data
// float x_sum = 0;
// float y_sum = 0;
// float z_sum = 0;
// int data_count = 0;
// unsigned long start_time = 0;

// void setup() {
//   Serial.begin(115200);
//   connectToWiFi();
  
//   // Initialize ADXL345
//   if (!accel.begin()) {
//     Serial.println("Failed to initialize ADXL345!");
//     while (1);
//   }

//   // Initialize sensor and WiFi
//   accel.setRange(ADXL345_RANGE_16_G);
  
//   // Start the 30-second cycle
//   start_time = millis();
// }

// void loop() {
//   // Collect data from ADXL sensor
//   sensors_event_t event;
//   accel.getEvent(&event);

//   // Add sensor values to the sum
//   x_sum += event.acceleration.x;
//   y_sum += event.acceleration.y;
//   z_sum += event.acceleration.z;
//   data_count++;

//   // Calculate how much time has passed in the current 30-second window
//   unsigned long elapsed_time = millis() - start_time;

//   // Every 1 second, compute the mean and send data to the Flask API
//   if (elapsed_time >= 1000) {
//     float x_mean = x_sum / data_count;
//     float y_mean = y_sum / data_count;
//     float z_mean = z_sum / data_count;

//     sendMeanDataToAPI(x_mean, y_mean, z_mean);

//     // Clear data for the next second
//     x_sum = 0;
//     y_sum = 0;
//     z_sum = 0;
//     data_count = 0;

//     // Reset the start_time for the next second
//     start_time = millis();
//   }

//   // After 30 seconds, start a new set
//   if (elapsed_time >= 30000) {
//     start_time = millis();  // Reset the timer for the next 30-second window
//   }
// }

// void connectToWiFi() {
//   Serial.print("Connecting to ");
//   Serial.println(ssid);
//   WiFi.begin(ssid, password);
//   while (WiFi.status() != WL_CONNECTED) {
//     delay(1000);
//     Serial.print(".");
//   }
//   Serial.println("");
//   Serial.println("WiFi connected");
// }

// void sendMeanDataToAPI(float x_mean, float y_mean, float z_mean) {
//   if (WiFi.status() == WL_CONNECTED) {
//     HTTPClient http;

//     // Prepare JSON data for the POST request
//     String postData = "{\"driver_id\":\"1\",\"x_val\":" + String(x_mean) +
//                       ",\"y_val\":" + String(y_mean) + ",\"z_val\":" + String(z_mean) + "}";

//     // Specify content type and API URL
//     http.begin(api_url);
//     http.addHeader("Content-Type", "application/json");


//     // Send HTTP POST request
//     int httpResponseCode = http.POST(postData);

//     // Print response
//     if (httpResponseCode > 0) {
//       String response = http.getString();
//       Serial.println(httpResponseCode);  // Print HTTP response code
//       Serial.println(response);          // Print response payload
//     } else {
//       Serial.println("Error in sending POST request");
//       Serial.println(httpResponseCode);
//     }

//     // End HTTP connection
//     http.end();
//   } else {
//     Serial.println("WiFi not connected");
//   }
// }
