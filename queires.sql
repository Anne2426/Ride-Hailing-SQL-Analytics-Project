1️⃣ TOP EARNING DRIVERS (WINDOW FUNCTION + RANK)
SELECT d.name AS driver_name,
       SUM(p.amount) AS total_earning,
       RANK() OVER (ORDER BY SUM(p.amount) DESC) AS earning_rank
FROM drivers d
JOIN trips t ON d.driver_id = t.driver_id
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY d.name;

2️⃣ DRIVER PERFORMANCE METRICS
SELECT d.name AS driver_name,
       COUNT(t.trip_id) AS total_trips,
       SUM(p.amount) AS total_revenue,
       AVG(d.rating) AS avg_rating
FROM drivers d
LEFT JOIN trips t ON d.driver_id = t.driver_id
LEFT JOIN payments p ON t.trip_id = p.trip_id
GROUP BY d.name;

3️⃣ TOP RIDERS BY TOTAL SPENDING
SELECT r.name AS rider_name,
       SUM(p.amount) AS total_spent,
       COUNT(t.trip_id) AS trips_taken
FROM riders r
JOIN trips t ON r.rider_id = t.rider_id
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY r.name
ORDER BY total_spent DESC
LIMIT 5;

4️⃣ PEAK DEMAND HOURS
SELECT HOUR(start_time) AS hour_of_day,
       COUNT(*) AS total_trips
FROM trips
GROUP BY HOUR(start_time)
ORDER BY total_trips DESC;

5️⃣ CANCELLATION RATE BY CITY
SELECT city,
       COUNT(CASE WHEN status='cancelled' THEN 1 END)*100.0/COUNT(*) AS cancel_percentage
FROM trips
GROUP BY city;

6️⃣ MONTHLY REVENUE TREND (CTE)
WITH monthly_revenue AS (
    SELECT MONTH(start_time) AS month,
           SUM(p.amount) AS revenue
    FROM trips t
    JOIN payments p ON t.trip_id = p.trip_id
    GROUP BY MONTH(start_time)
)
SELECT * FROM monthly_revenue
ORDER BY month;

7️⃣ MOVING AVERAGE REVENUE (WINDOW FUNCTION)
SELECT month,
       revenue,
       AVG(revenue) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS moving_avg
FROM (
    SELECT MONTH(start_time) AS month,
           SUM(p.amount) AS revenue
    FROM trips t
    JOIN payments p ON t.trip_id = p.trip_id
    GROUP BY MONTH(start_time)
) t;

8️⃣ TOP 3 CITIES BY REVENUE (DENSE_RANK)
SELECT city, revenue
FROM (
    SELECT t.city, SUM(p.amount) AS revenue,
           DENSE_RANK() OVER (ORDER BY SUM(p.amount) DESC) AS rnk
    FROM trips t
    JOIN payments p ON t.trip_id = p.trip_id
    GROUP BY t.city
) x
WHERE rnk <= 3;

9️⃣ RIDER RETENTION (REPEAT USERS)
SELECT rider_id, COUNT(trip_id) AS trips_taken
FROM trips
GROUP BY rider_id
HAVING COUNT(trip_id) > 1
ORDER BY trips_taken DESC;

🔟 LONGEST TRIP BY CITY
SELECT city, MAX(distance_km) AS longest_trip_km
FROM trips
GROUP BY city;

1️⃣1️⃣ PERCENTAGE CONTRIBUTION OF CITY TO TOTAL REVENUE
SELECT t.city,
       SUM(p.amount) * 100.0 / (SELECT SUM(amount) FROM payments) AS revenue_percentage
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY t.city;

1️⃣2️⃣ DRIVER TENURE VS EARNINGS
SELECT d.name,
       DATEDIFF(CURDATE(), d.join_date)/365 AS years_with_company,
       SUM(p.amount) AS total_revenue
FROM drivers d
JOIN trips t ON d.driver_id = t.driver_id
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY d.name;

1️⃣3️⃣ HIGHEST EARNING DAY
SELECT DATE(start_time) AS day,
       SUM(p.amount) AS revenue
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY DATE(start_time)
ORDER BY revenue DESC
LIMIT 1;

1️⃣4️⃣ SURGE PRICING SIMULATION
SELECT trip_id,
       distance_km,
       CASE 
           WHEN HOUR(start_time) BETWEEN 18 AND 22 THEN amount * 1.5
           ELSE amount
       END AS surge_price
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id;

1️⃣5️⃣ DRIVER CHURN (NO TRIPS)
SELECT d.name
FROM drivers d
LEFT JOIN trips t ON d.driver_id = t.driver_id
WHERE t.trip_id IS NULL;

1️⃣6️⃣ RUNNING TOTAL OF REVENUE (WINDOW FUNCTION)
SELECT DATE(start_time) AS day,
       SUM(p.amount) AS daily_revenue,
       SUM(SUM(p.amount)) OVER (ORDER BY DATE(start_time)) AS running_total
FROM trips t
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY DATE(start_time);

1️⃣7️⃣ TOP DRIVER PER CITY
SELECT city, driver_name, MAX(total_earning) AS top_earning
FROM (
    SELECT t.city, d.name AS driver_name, SUM(p.amount) AS total_earning
    FROM drivers d
    JOIN trips t ON d.driver_id = t.driver_id
    JOIN payments p ON t.trip_id = p.trip_id
    GROUP BY t.city, d.name
) x
GROUP BY city;

1️⃣8️⃣ AVERAGE TRIP DISTANCE BY CITY
SELECT city, AVG(distance_km) AS avg_trip_distance
FROM trips
GROUP BY city;

1️⃣9️⃣ TOP 3 RIDERS PER CITY
SELECT city, rider_name, trips_taken
FROM (
    SELECT t.city, r.name AS rider_name, COUNT(t.trip_id) AS trips_taken,
           RANK() OVER (PARTITION BY t.city ORDER BY COUNT(t.trip_id) DESC) AS rnk
    FROM trips t
    JOIN riders r ON t.rider_id = r.rider_id
    GROUP BY t.city, r.name
) x
WHERE rnk <= 3;

2️⃣0️⃣ DRIVER PERFORMANCE INDEX (COMPLEX KPI)
SELECT d.name,
       COUNT(t.trip_id) AS total_trips,
       SUM(p.amount) AS total_revenue,
       AVG(d.rating) AS avg_rating,
       (SUM(p.amount)/COUNT(t.trip_id))*AVG(d.rating) AS performance_index
FROM drivers d
JOIN trips t ON d.driver_id = t.driver_id
JOIN payments p ON t.trip_id = p.trip_id
GROUP BY d.name
ORDER BY performance_index DESC;

2️⃣1️⃣ AVERAGE DAILY REVENUE PER DRIVER
SELECT d.name,
       AVG(daily_revenue) AS avg_daily_revenue
FROM (
    SELECT d.driver_id, d.name, DATE(t.start_time) AS day, SUM(p.amount) AS daily_revenue
    FROM drivers d
    JOIN trips t ON d.driver_id = t.driver_id
    JOIN payments p ON t.trip_id = p.trip_id
    GROUP BY d.driver_id, d.name, DATE(t.start_time)
) x
GROUP BY name;