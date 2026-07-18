-- Table Schema ---

-- =========================
-- CREATING TABLE
-- =========================
CREATE TABLE ride_bookings (
    row_id INT PRIMARY KEY,
    booking_date DATE,
    booking_time TIME,
    booking_id VARCHAR(20),
    booking_status VARCHAR(30),
    customer_id VARCHAR(20),
    vehicle_type VARCHAR(30),
    pickup_location VARCHAR(100),
    drop_location VARCHAR(100),
    avg_vtat DECIMAL(5,2),
    avg_ctat DECIMAL(5,2),
    cancelled_by_customer INT,
    customer_cancel_reason VARCHAR(100),
    cancelled_by_driver INT,
    driver_cancel_reason VARCHAR(100),
    incomplete_rides INT,
    incomplete_ride_reason VARCHAR(100),
    booking_value DECIMAL(10,2),
    ride_distance DECIMAL(6,2),
    driver_rating DECIMAL(3,1),
    customer_rating DECIMAL(3,1),
    payment_method VARCHAR(30),
    booking_datetime DATETIME,
    booking_hour INT,
    day_of_week VARCHAR(10)
);

--------------------------------------------------

--A. Demand & Funnel Health
-- Q1) What's the overall platform demand?

SELECT COUNT(DISTINCT Row_ID) AS total_bookings
FROM ride_bookings;

-- Q2) Where is the booking funnel leaking?

-- a) Booking Status Counts (Absolute Numbers)
SELECT 
    Booking_Status,
    COUNT(*) AS status_count
FROM ride_bookings
GROUP BY booking_Status
ORDER BY status_count DESC;

-- b) Booking Status Percentages
SELECT 
    Booking_Status,
    COUNT(*) AS status_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ride_bookings), 2) AS status_pct
FROM ride_bookings
GROUP BY booking_Status
ORDER BY status_pct DESC;

-- c) Ride Completion Rate
SELECT 
    ROUND(
        SUM(CASE WHEN booking_Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS completion_rate_pct
FROM ride_bookings;

-- d) Customer Cancellation Rate
SELECT 
    ROUND(
        SUM(Cancelled_Rides_by_Customer) * 100.0 
        / COUNT(*), 2
    ) AS cust_cancel_rate_pct
FROM ride_bookings;

-- e) Driver Cancellation Rate
SELECT 
    ROUND(
        SUM(Cancelled_Rides_by_Driver) * 100.0 
        / COUNT(*), 2
    ) AS driver_cancel_rate_pct
FROM ride_bookings;

-- f) Incomplete Rides Rate
SELECT 
    ROUND(
        SUM(Incomplete_Rides) * 100.0 
        / COUNT(*), 2
    ) AS incomplete_rate_pct
FROM ride_bookings;

-------------------------------------------------------

-- B. Revenue
-- Q3) What revenue did completed rides generate?

SELECT SUM(booking_value) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q4) What's the typical ride ticket size?

SELECT ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Completed';

-- Q5) How much revenue is at risk from failed bookings?

SELECT 
    (SELECT COUNT(*) 
     FROM ride_bookings 
     WHERE booking_status != 'Completed') 
    * 
    (SELECT ROUND(AVG(booking_value)) 
     FROM ride_bookings 
     WHERE booking_status = 'Completed') 
    AS revenue_lost_proxy;

--------------------------------------------------

-- C. Operational Efficiency
-- Q6) How long do customers wait for a driver to arrive?

SELECT ROUND(AVG(avg_vtat)) AS avg_vtat
FROM ride_bookings;

-- Q7) How long does the actual trip take on average?

SELECT ROUND(AVG(avg_ctat)) AS avg_ctat
FROM ride_bookings;

-- 8. What's the typical trip length (fleet utilization indicator)?

SELECT ROUND(AVG(ride_distance)) AS avg_distance
FROM ride_bookings
WHERE booking_status = 'Completed';

------------------------------------------------------

-- D. Quality / Satisfaction
-- Q9) Is service quality acceptable on both sides of the marketplace?

SELECT 
    ROUND(AVG(driver_rating), 2) AS avg_driver_rating,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ride_bookings;

---------------------------------------------------------

-- E. Vehicle & Location Mix
-- Q10) Which vehicle type drives the most completed rides/revenue?

-- a) Top 5 Vehicle Types by Completed Bookings

SELECT 
    vehicle_type,
    COUNT(*) AS completed_bookings
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY completed_bookings DESC
LIMIT 5;

-- b) Total Revenue by Vehicle Type (Completed Bookings), sorted highest to lowest

SELECT 
    vehicle_type,
    SUM(booking_value) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY total_revenue DESC;

-- Q11) Where should Uber focus driver supply/marketing?

SELECT 
    pickup_location,
    COUNT(*) AS booking_count
FROM ride_bookings
GROUP BY pickup_location
ORDER BY booking_count DESC
LIMIT 10;

----------------------------------------------------------
-- F. Trend
-- Q12) Is revenue growing, flat, or declining over the period?

SELECT 
    booking_date,
    SUM(booking_value) AS daily_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY booking_date
ORDER BY booking_date;