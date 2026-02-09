CREATE DATABASE ride_hailing_db;
USE ride_hailing_db;

CREATE TABLE drivers (
    driver_id INT PRIMARY KEY,
    name VARCHAR(50),
    rating DECIMAL(3,2),
    join_date DATE
);

CREATE TABLE riders (
    rider_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(50)
);

CREATE TABLE trips (
    trip_id INT PRIMARY KEY,
    driver_id INT,
    rider_id INT,
    city VARCHAR(50),
    distance_km DECIMAL(5,2),
    start_time DATETIME,
    status VARCHAR(20)
);

CREATE TABLE payments (
    payment_id INT PRIMARY KEY,
    trip_id INT,
    amount DECIMAL(10,2),
    payment_method VARCHAR(20)
);
