create database VuHacathon;
use VuHacathon;

CREATE TABLE sensor_data (
    id INT AUTO_INCREMENT PRIMARY KEY,
    x_val FLOAT NOT NULL,
    y_val FLOAT NOT NULL,
    z_val FLOAT NOT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

ALTER TABLE sensor_data ADD COLUMN device_id VARCHAR(50) NOT NULL;


select * from  sensor_data;