#  🚕 Uber Data Analysis: Operational Efficiency & Revenue Optimization

## 📌 Project Overview

This project analyzes **150,000 Uber ride bookings** to uncover demand patterns, cancellation behavior, operational inefficiencies, customer behavior, and revenue opportunities. Using **SQL, PowerBI, Python and Pandas**, the analysis identifies a major ride-fulfillment gap, with only **62% of bookings successfully completed**. The findings highlight **driver cancellations, high-demand zone reliability, short-distance ride completion, and peak-period operations** as the most important areas for improving platform performance and recover an estimated ₹2.43 Cr in lost revenue.


---

# 🎯 Business Questions

1. What are the peak ride hours and days?
2. Which pickup locations generate the highest ride demand?
3. How do cancellation rates vary by time and location?
4. What are the key booking trends over time?
5. How can Uber improve driver utilization and ride fulfillment?
6. Which factors contribute to higher booking value?
7. How does customer behavior vary by ride distance?
8. Where are the biggest revenue opportunities?

---

## Objectives

- Clean and structure raw booking data to establish a reliable analysis grain
- Engineer features (time slots, cancellation categories, revenue tiers) to enable segmentation
- Quantify booking success/failure rates and isolate their root causes
- Identify demand patterns by hour, day, and location
- Diagnose the primary drivers of cancellations
- Estimate revenue lost to cancellations and incomplete rides
- Translate findings into concrete, prioritized business recommendations

---

## Dataset Description

- Row_ID	Date	
- Time	
- Booking ID	
- Booking Status	
- Customer ID	
- Vehicle Type	
- Pickup Location	
- Drop Location	
- Avg VTAT	
- Avg CTAT	
- Cancelled Rides by Customer	
- Reason for cancelling by Customer	
- Cancelled Rides by Driver	
- Driver Cancellation Reason	
- Incomplete Rides	
- Incomplete Rides Reason	
- Booking Value	
- Ride Distance	
- Driver Ratings	
- Customer Rating	
- Payment Method	
- Datetime	
- Hour	
- DayOfWeek

---

## Tech Stack


| Tool             | Purpose                                 |
| ---------------- | --------------------------------------- |
| Python (Pandas)  | Data cleaning, transformation, EDA      |
| SQL              | Business queries and KPI generation     |
| Power BI         | Interactive dashboard and visualization |
| Jupyter Notebook | Analysis environment                    |


---

## Project Workflow

- **Data Understanding & Cleaning** – Assessed 150,000 bookings, identified and resolved 1,233 Booking ID collisions, and established row count (not Booking ID) as the correct booking grain
- **SQL Analysis** – Used SQL to calculate KPIs and answer business questions
- **Feature Engineering** – Created Time Slot, Booking Success, Cancellation Category, Revenue Category, Driver Cancellation Reason, Pickup Location, and Vehicle Type features
- **Exploratory Analysis** – Answered business questions 1–3 (peak hours/days, top locations, cancellation patterns)
- **Trend Analysis** – Answered business questions 4–6 (booking trends, driver utilization, booking value drivers)
- **Behavioral & Revenue Analysis** – Answered business questions 7–8 (customer behavior by distance, revenue opportunities)
- **Synthesis** – Consolidated findings into an executive summary and prioritized recommendations

---

## Screenshots

---

### Overview

![Uber Data Analysis](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/1%20Overview.png)

## 📈 Dashboard Features

**Business Requirement**
Provide a high-level snapshot of Uber’s operational and financial performance.

**KPIs Displayed**
- Total Bookings
- Lost Bookings
- Revenue
- Revenue Lost
- Average Ride value

**Insights Provided**
- Booking & revenue trends (monthly/quarterly) 
- Revenue by vehicle type
- Top pickup/drop locations, 
- Customer & driver ratings

**Business Value**
- Enables quick executive-level decision-making
- Identifies overall growth, decline, or inefficiencies

---

### Vehicles

![Uber Data Analysis](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/2%20Vehicle.png)

## 📈 Dashboard Features

**Business Requirement**
Analyze vehicle performance to optimize fleet usage.

**Key Metrics**

* Bookings by vehicle
* Revenue by vehicle type
* Revenue contribution %
* Completion rate
* Incomplete rate

**Insights Provided**

* Top revenue-generating vehicles
* Completion efficiency by vehicle type
* Completed booking trends

**Business Value**

* Improves fleet utilization
* Supports pricing and incentive strategies


---

### Revenue

![Uber Data Analysis](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/3%20Revenue.png)

## 📈 Dashboard Features

**Business Requirement**
Analyze financial performance and revenue risks.

**Key Analysis**

* Monthly and quarterly revenue trends
* Revenue by vehicle type
* Revenue by payment method
* Revenue from top customers

**Efficiency & Risk Metrics**

* MoM revenue change
* Average revenue per booking
* Revenue per kilometer
* Lost revenue

**Business Value**

* Identifies profitable segments
* Detects revenue leakage
* Supports financial planning

---

# SQL 

## Schema Design

```sql
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
```

---

## Q1) What's the overall platform demand?

```sql
SELECT COUNT(DISTINCT Row_ID) AS total_bookings
FROM ride_bookings;
```

**Output:** 150000

---

## Q2) Where is the booking funnel leaking?

### a) Booking Status Counts (Absolute Numbers)

```sql
SELECT 
    Booking_Status,
    COUNT(*) AS status_count
FROM ride_bookings
GROUP BY booking_Status
ORDER BY status_count DESC;
```

**Output:** 
| Booking status                 | Value       |
| --------------------- | ----------- |
| Completed             |   93000 |
|Cancelled by Driver    |  27000|
|No Driver Found         | 10500|
|Cancelled by Customer  |  10500|
|Incomplete             |   9000|

---

### b) Booking Status Percentages

```sql
SELECT 
    Booking_Status,
    COUNT(*) AS status_count,
    ROUND(COUNT(*) * 100.0 / (SELECT COUNT(*) FROM ride_bookings), 2) AS status_pct
FROM ride_bookings
GROUP BY booking_Status
ORDER BY status_pct DESC;
```

**Output:** 
| Booking status         | Value (%)      |
| --------------------- | ----------- |
| Completed              |   62.0| 
| Cancelled by Driver    |   18.0| 
| No Driver Found        |    7.0| 
| Cancelled by Customer   |   7.0| 
| Incomplete           |      6.0| 

---

### c) Ride Completion Rate

```sql
SELECT 
    ROUND(
        SUM(CASE WHEN booking_Status = 'Completed' THEN 1 ELSE 0 END) * 100.0 
        / COUNT(*), 2
    ) AS completion_rate_pct
FROM ride_bookings;
```

**Output:** Ride Completion Rate: 62.00%

---

### d) Customer Cancellation Rate

```sql
SELECT 
    ROUND(
        SUM(Cancelled_Rides_by_Customer) * 100.0 
        / COUNT(*), 2
    ) AS cust_cancel_rate_pct
FROM ride_bookings;
```

**Output:** Customer Cancellation Rate: 7.00%

---

### e) Driver Cancellation Rate

```sql
SELECT 
    ROUND(
        SUM(Cancelled_Rides_by_Driver) * 100.0 
        / COUNT(*), 2
    ) AS driver_cancel_rate_pct
FROM ride_bookings;
```

**Output:** Driver Cancellation Rate: 18.00%

---

### f) Incomplete Rides Rate

```sql
SELECT 
    ROUND(
        SUM(Incomplete_Rides) * 100.0 
        / COUNT(*), 2
    ) AS incomplete_rate_pct
FROM ride_bookings;
```

**Output:** Incomplete Rides Rate: 6.00%

---

## Q3) What revenue did completed rides generate?

```sql
SELECT SUM(booking_value) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed';
```

**Output:** 47260574

---

## Q4) What's the typical ride ticket size?

```sql
SELECT ROUND(AVG(booking_value), 2) AS avg_booking_value
FROM ride_bookings
WHERE booking_status = 'Completed';
```

**Output:** 508

---

##  Q5) How much revenue is at risk from failed bookings?

```sql
SELECT 
    (SELECT COUNT(*) 
     FROM ride_bookings 
     WHERE booking_status != 'Completed') 
    * 
    (SELECT ROUND(AVG(booking_value)) 
     FROM ride_bookings 
     WHERE booking_status = 'Completed') 
    AS revenue_lost_proxy;
```

**Output:** 28956000

---


##  Q6) How long do customers wait for a driver to arrive?

```sql
SELECT ROUND(AVG(avg_vtat)) AS avg_vtat
FROM ride_bookings;
```

**Output:** 8

---

##  Q7) How long does the actual trip take on average?

```sql
SELECT ROUND(AVG(avg_ctat)) AS avg_ctat
FROM ride_bookings;
```

**Output:** 29

---

##  Q8) What's the typical trip length (fleet utilization indicator)?

```sql
SELECT ROUND(AVG(ride_distance)) AS avg_distance
FROM ride_bookings
WHERE booking_status = 'Completed';
```

**Output:** 26

---

##  Q9) Is service quality acceptable on both sides of the marketplace?

```sql
SELECT 
    ROUND(AVG(driver_rating), 2) AS avg_driver_rating,
    ROUND(AVG(customer_rating), 2) AS avg_customer_rating
FROM ride_bookings;
WHERE booking_status = 'Completed';
```

**Output:** 
Average Driver Rating:  4.23
Average Customer Rating:  4.4

---


##  Q10) Which vehicle type drives the most completed rides/revenue?

### a) Top 5 Vehicle Types by Completed Bookings

```sql
SELECT 
    vehicle_type,
    COUNT(*) AS completed_bookings
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY completed_bookings DESC
LIMIT 5;
```

**Output:** 
| Vehicle Type          | Booking Value       |
| --------------------- | ----------- |
|Auto          |   23155|
|Go Mini       |   18549|
|Go Sedan      |   16676|
|Bike          |   14034|
|Premier Sedan  |  11252|

---

### b) Total Revenue by Vehicle Type (Completed Bookings), sorted highest to lowest

```sql
SELECT 
    vehicle_type,
    SUM(booking_value) AS total_revenue
FROM ride_bookings
WHERE booking_status = 'Completed'
GROUP BY vehicle_type
ORDER BY total_revenue DESC;
```

**Output:** 
| Vehicle Type          | total Revenue     |
| --------------------- | ----------- |
|Auto            | 11727615.0|
|Go Mini          | 9411418.0|
|Go Sedan        |  8538560.0|
|Bike            |  7144913.0|
|Premier Sedan   |  5733655.0|
|eBike            | 3298157.0|
|Uber XL          | 1406256.0|

---

## Q11) Where should Uber focus driver supply/marketing?

```sql
SELECT 
    pickup_location,
    COUNT(*) AS booking_count
FROM ride_bookings
GROUP BY pickup_location
ORDER BY booking_count DESC
LIMIT 10;
```

**Output:** 
| Pickup Location          | total Booking     |
| --------------------- | ----------- |
|Khandsa           |  949|
|Barakhamba Road   |  946|
|Saket            |   931|
|Badarpur          |  921|
|Pragati Maidan    |  920|
|Madipur          |   919|
|AIIMS             |  918|
|Mehrauli          |  915|
|Dwarka Sector 21  |  914|
|Pataudi Chowk     |  907|

---

### Key Performance Indicators

| KPI                             | Value        |
| -------------------------------- | ------------ |
| Total Platform Demand (Bookings) | 150,000      |
| Ride Completion Rate             | 62.0%        |
| Driver Cancellation Rate         | 18.0%        |
| Customer Cancellation Rate       | 7.0%         |
| Incomplete Rides Rate            | 6.0%         |
| Total Revenue (Completed Rides)  | ₹4,72,60,574 |
| Average Revenue per Ride         | ₹508         |
| Revenue at Risk (Failed Bookings)| ₹2,89,56,000 |
| Avg. Driver Arrival Time         | 8 min        |
| Avg. Trip Duration               | 29 min       |
| Avg. Trip Distance                | 26 km        |
| Average Driver Rating            | 4.23 / 5     |
| Average Customer Rating          | 4.4 / 5      |
| Top Vehicle Type (Revenue)       | Auto (₹1.17 Cr) |
| Top Pickup Location (Demand)     | Khandsa (949 bookings) |

**Key SQL Insight**

1. **Driver cancellations (18%) are 2.5x customer cancellations (7%)** — supply-side reliability is the core problem.
2. **~₹2.9 Cr revenue at risk** from failed/incomplete bookings (~38% of demand).
3. **Auto + Go Mini = ~45% of revenue** — top priority for fleet investment.

---

# 📊 Pandas Data Analysis

booking conversion → time slots → cancellation drivers → peak demand → location → trends → distance → revenue impact

---

## Data Cleaning & Grain Validation

### How much demand actually converts?

![Booking Status Breakdown](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/2a.png)

### Insight

Only 62% of 150K bookings completed.

---

## Feature Engineering Analysis

### Time Slot Analysis

![Time Slot Analysis](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/3a.png)

### Insight

Demand is concentrated in the **Morning (30%)** and **Evening (29%)**, which together represent approximately **59% of total booking volume**.

---

### Cancellation Categories

![Cancellation Categories](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/3b.png)

### Insight

Among failed bookings, **driver cancellations account for 27,000 bookings**, making them the largest failure category.Driver cancellation behavior is broadly uniform indicating a platform-wide reliability issue rather than a problem isolated to a particular vehicle type or zone.

---

## What Are the Peak Ride Hours and Days?

### Peak Demand

![Peak Demand](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/4a.png)

### Insight

Demand peaks during the **evening commute**, particularly between **6 PM and 7 PM**, with **12,397 bookings**, followed by the surrounding evening hours. A secondary demand peak occurs between approximately **9 AM and 11 AM**.

---

## Which Pickup Locations Generate the Highest Ride Demand?

### High-Demand, High-Cancellation Locations

![High-Demand, High-Cancellation Locations](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/4b.png)

### Insight

High-demand pickup locations also show elevated cancellation rates. Locations such as:

* **Pragati Maidan:** 27.0%
* **Saket:** 26.7%
* **AIIMS:** 25.7%

have cancellation rates above the platform average.

---

### Cancellation Imbalance

![Cancellation Imbalance](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/4c.png)

### Insight

Drivers cause 72% of all cancellations vs. 28% by customers.

---

## What Are the Booking Trends and Cancelation Rate Over Time?

### Booking Trends and Cancelation Rate

![Booking Trends and Cancelation Rate](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/5a.png)

### Insight

The cancellation problem is persistent rather than seasonal. The consistency of driver cancellations throughout the year suggests an ongoing operational issue requiring structural intervention.

---

## How Does Bookings Vary by Ride Distance?

### Distance vs. Completion

![Distance vs. Completion](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/6a.png)

### Insight

Approximately 24% of short rides (0–5 km) with recorded distance remain incomplete, while rides above 30 km show a 100% completion rate in the analyzed subset. Short-distance rides show a significantly higher in-trip incomplete rate and should be investigated for possible driver incentive, trip economics, routing, or service-quality issues.

---

## Where Are the Biggest Revenue Opportunities?

### Revenue Leakage

![Distance vs. Completion](https://github.com/parthadata7/Uber-Ride-Booking-Analysis-SQL-Power-BI-Python/blob/main/screenshot/Charts/7a.png)

### Insight

An estimated **₹2.43 Cr in revenue was lost** due to ride cancellations. Incomplete rides still generated ₹45.86L in partial fares.

---

## Insights & Recommendations

### Key Insights

Analyzed 150K ride bookings to uncover why 38% of demand goes unfulfilled, found it's a systemic driver-cancellation problem (not customers, not location, not fares) costing ₹2.43 Cr in lost revenue.

- **38% demand lost** : Only 62% of 150K bookings completed; ₹2.43 Cr in revenue lost to cancellations.
- **Drivers, not customers, are the bottleneck** : Driver cancellations (18%) are 2.6x customer cancellations (7%), consistent across every hour, day, and month of 2024.
- **Systemic issue, not a hotspot** : Cancellation rates are near-identical across vehicle types (17–18.5%) and locations (top location = 0.7% of failures) , points to a platform-wide fix, not a local one.
- **Short rides are the weak link** : 24% of rides under 5 km go incomplete vs. 100% completion for rides over 30 km.
- **Demand ≠ reliability** : Top pickup zones (Pragati Maidan, Saket, AIIMS: ~26–27% of volume) also have above-average cancellation rates.
- **Revenue is volume-driven, not fare-driven** : Booking value is flat across vehicle/time/payment (₹503–511); Auto leads revenue (₹1.17 Cr) purely on ride volume; weekends/evenings drive 45% more revenue than weekdays.
- **Auto and Go Mini drive ~45% of completed-ride revenue** , clear priority segments for fleet and driver-supply investment.


**💡 Recommendations**

- Prioritize reducing driver-side cancellations (18% of all bookings) as the single highest-impact fix for completion rate and revenue
- Investigate and address soft/generic driver cancellation reasons (e.g., "customer related issue") to determine whether they mask acceptance or matching problems
- Prioritize Auto and Go Mini in fleet expansion and driver incentives, as these two vehicle types together drive ~45% of completed-ride revenue
- Focus reliability efforts on high-demand, high-cancellation zones (Pragati Maidan, Saket, AIIMS) where fixes will have outsized impact
- Investigate the 24% incomplete rate on short-distance (0–5 km) rides as a distinct service reliability issue
- Increase driver supply and reliability during evening peak hours (5–9 PM) and weekends, the highest-revenue periods
- Treat cancellation reduction as a revenue initiative, not just an operations metric, given the estimated **₹2.43Cr** in lost revenue

---

# 📝 Executive Summary

Analysis of 150,000 Uber bookings shows stable, commute-driven demand but inefficient operations: 38% of bookings fail to complete, driven overwhelmingly by driver-side cancellations (18%) rather than demand shortfalls, vehicle type, time of day, or location-specific factors. This failure is uniform across hours, days, and vehicle types, indicating a systemic behavioral issue. High-demand zones and short-distance rides show disproportionately higher failure rates, and cancellations alone are estimated to cost **₹2.43Cr** in lost revenue.


---

## 🏁 Conclusion

Improving ride reliability and reducing driver cancellations must be the top operational priority. The data clearly shows that fixing these behavioral and process-level issues will deliver a significantly greater business impact than any pricing or service-tier changes. By targeting high-risk zones, protecting short-distance rides, and aligning driver incentives with proven high-revenue windows, Uber can recover millions in lost revenue and drastically improve the customer experience.

---

## Project Structure

```text
├── data
├── Powerbi
├── screenshot
├── python
├── SQL
└── README.md
```

---

## Contact

**Name:** Partha Pratim Das

**Email:** [parthadataanalyst@gmail.com](mailto:parthadataanalyst@gmail.com)

**LinkedIn:** [LinkedIn](linkedin.com/in/partha-pratim-das-01a579423) 

**Portfolio:** []()
