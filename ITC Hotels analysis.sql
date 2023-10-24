--Exploring the tables
SELECT * 
FROM fact_aggregated_bookings$

SELECT*
FROM fact_bookings$

SELECT*
FROM dim_date$

SELECT*
FROM dim_hotels$

SELECT*
FROM dim_rooms$

--View table design, with all the attributes

SELECT a.property_id,
       a.check_in_date,
	   b.checkout_date,
       b.room_category,
	   a.capacity,
	   a.successful_bookings,
	   b.no_guests,
	   b.booking_platform,
	   b.revenue_generated,
	   b.revenue_realized,
	   b.booking_status
FROM fact_aggregated_bookings$ a,
     fact_bookings$ b
WHERE a.property_id=b.property_id
AND a.check_in_date=b.check_in_date

--View table revision
SELECT *
FROM dbo.Tab

--Look for duplicate values: 538360 and 538360, no duplicate values
SELECT DISTINCT COUNT(*),
COUNT(*)
FROM Tab


--Total revenue calculation : $6,835,084,916
SELECT SUM(revenue_realized) AS total_revenue
FROM Tab

--Total Bookings: 134,590
SELECT COUNT(booking_id) AS total_bookings
FROM fact_bookings$

--Total Capacity: 13,943,961
SELECT SUM(capacity) AS total_capacity
FROM Tab

--Total successful bookings: 8,556,406
SELECT SUM(successful_bookings) AS total_successful_bookings
FROM Tab

--Ocupancy percentage rate: 61%
SELECT (SUM(successful_bookings)/SUM(capacity))*100 AS Ocupancy_rate
FROM Tab

--Average rating: 3.61 stars
SELECT ISNULL(AVG(ratings_given),0) AS Average_ratings_given
FROM fact_bookings$

--No. of days: 92 days
SELECT COUNT(DISTINCT(check_in_date)) AS Num_days
FROM Tab

--Room category name
SELECT 
room_category,
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name
FROM fact_bookings$

--Booking status individual analysis

--Total cancelled bookings: 33,420
SELECT COUNT(booking_status) AS Total_cancelled_bookings
FROM fact_bookings$
WHERE booking_status='Cancelled'

--Cancelled rooms by room category:
--Premium: 7,605
--Elite: 12,357
--Standard: 9,530
--Presidential: 3,928
SELECT
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name,

COUNT(booking_status) AS Total_cancelled_bookings
FROM fact_bookings$
WHERE booking_status='Cancelled'
GROUP BY room_category

--Cancellation percentage 25%
SELECT 
100*
(SELECT CONVERT (decimal (9,2),COUNT(booking_status))
FROM fact_bookings$
WHERE booking_status='Cancelled'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(booking_status))
FROM fact_bookings$
) AS Cancelation_percentage


--Total checked out: 94,411
SELECT COUNT(booking_status)
FROM fact_bookings$
WHERE booking_status='Checked Out'

--Total checked out by room category
SELECT
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name,

COUNT(booking_status) AS Total_checked_out
FROM fact_bookings$
WHERE booking_status='Checked Out'
GROUP BY room_category

--Total no show bookings : 6,759
SELECT COUNT(booking_status)
FROM fact_bookings$
WHERE booking_status='No Show'

--Total no show by room category
SELECT
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name,

COUNT(booking_status) AS Total_no_show
FROM fact_bookings$
WHERE booking_status='No show'
GROUP BY room_category

--No show rate: 5%
SELECT
100*
(
SELECT CONVERT (decimal (9,2),COUNT(booking_status))
FROM fact_bookings$
WHERE booking_status= 'No show'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(booking_status))
FROM fact_bookings$
) AS No_show_rate

--TOP BOOKINGS BY ROOM CATEGORY
--RT2 Elite        3,119,189
--RT1 Standard	   2,459,637
--RT3 Premium	   1,927,608
--RT4 Presidential 1,049,972
SELECT 
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name,
SUM(successful_bookings) AS Top_bookings
FROM Tab
GROUP BY room_category
ORDER BY Top_bookings DESC

--Booking % by room class
--RT1 Standard: 29% of the total
SELECT 
100*
(SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
WHERE room_category='RT1'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
) AS Booking_rate_RT1_Standard

--RT2 Elite: 37%
SELECT 
100*
(SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
WHERE room_category='RT2'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
) AS Booking_rate_RT2_Elite

--RT3 Premium: 23%
SELECT 
100*
(SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
WHERE room_category='RT3'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
) AS Booking_rate_RT3_Premium

--RT4 Presidential: 12%
SELECT 
100*
(SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
WHERE room_category='RT4'
)
/
(
SELECT CONVERT (decimal (9,2),COUNT(successful_bookings))
FROM Tab
) AS Booking_rate_RT4_Presidential

--Revenue rates ADR (Average Daily Rate) and RevPAR (Revenue per Available room)
-- ADR (Average Daily Rate) revenue by day: 74,294,401.26
SELECT
CAST(
    (
        SELECT SUM(revenue_realized)
        FROM Tab
    )
    AS float
)
/
CAST(
    (
        SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))
		 FROM Tab)
       AS float
) AS ADR

--RevPRT(Revenue per room type)
--Presidential	23,440.10
--Premium	    15,120.27
--Elite	        11,317.46
--Standard	     8,052.35
SELECT T.room_category,
CASE room_category
    WHEN 'RT1'
	THEN 'Standard'
	WHEN 'RT2'
	THEN 'Elite'
	WHEN 'RT3'
	THEN 'Premium'
	WHEN 'RT4'
	THEN 'Presidential'
	ELSE 'New category'
	END Room_class_name,
AVG(T.revenue_realized) as rev_avg
FROM Tab T, dim_rooms$ R
WHERE T.room_category=R.room_id
GROUP BY T.room_category
ORDER BY rev_avg DESC

--RevPAR (Revenue per Available room): $12,696.123255814
SELECT
CAST(
    (
        SELECT SUM(revenue_realized)
        FROM Tab
    )
    AS float
)
/
CAST(
    (
        SELECT COUNT(capacity)
		 FROM Tab)
       AS float
) AS RevPAR

--Date rates
--DBRN (Daily Booked Room Nights): 93,004 rooms per night
SELECT
CAST(
    (
        SELECT SUM(successful_bookings)
        FROM Tab
    )
    AS float
)
/
CAST(
    (
        SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))
		 FROM Tab)
       AS float
) AS DBRN

--DSRN (Daily Sellable Room Nights): 5,851 rooms
SELECT
CAST(
    (
        SELECT COUNT(capacity)
        FROM Tab
    )
    AS float
)
/
CAST(
    (
        SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))
		 FROM Tab)
       AS float
) AS DSRN

--DURN (Daily Utilized Room Nights): 1,026 daily rooms
SELECT
CAST(
    (
        SELECT COUNT(booking_status)
FROM fact_bookings$
WHERE booking_status='Checked Out'
    )
    AS float
)
/
CAST(
    (
        SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))
		 FROM Tab)
       AS float
) AS DURN

--DAILY USED CAPACITY PERCENTAGE: 18%
SELECT
100*
(SELECT
CAST((SELECT COUNT(booking_status)
FROM fact_bookings$
WHERE booking_status='Checked Out')AS float)/
CAST((SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))FROM Tab)
       AS float))
	   /
(SELECT
(CAST((SELECT COUNT(capacity)FROM Tab)
    AS float))/
CAST((SELECT COUNT(DISTINCT(CONVERT(DATETIME, check_in_date, 101)))
		 FROM Tab)AS float))

--CITY ANALYTICS

--Revenue per city
--Bangalore	$420,397,050
--Delhi	    $294,500,318
--Hyderabad	$325,232,870
--Mumbai	$668,640,991
SELECT a.city,
       sum(b.revenue_realized) AS revenue_per_city
FROM dim_hotels$ a,
     fact_bookings$ b
WHERE b.property_id=a.property_id
GROUP BY city


--Occupancy per city
--Bangalore	55.76%
--Delhi	    60.54%
--Hyderabad	58.07%
--Mumbai	57.88%
SELECT a.city,
      (sum(b.successful_bookings)/
       sum(b.capacity)) as occupancy_rate
FROM dim_hotels$ a,
     fact_aggregated_bookings$ b
WHERE b.property_id=a.property_id
GROUP BY city

--Succesful bookings by city
--Bangalore	$32,016
--Delhi	    $24,231
--Hyderabad	$34,888
--Mumbai	$43,455
SELECT a.city,
       sum(b.successful_bookings) as Total_bookings
FROM dim_hotels$ a,
     fact_aggregated_bookings$ b
WHERE b.property_id=a.property_id
GROUP BY city

--Rating per city
--Mumbai	3.65
--Hyderabad	3.66
--Delhi	    3.77
--Bangalore	3.40
SELECT a.city,
       avg(b.ratings_given) as Ratings
FROM dim_hotels$ a,
     fact_bookings$ b
WHERE b.property_id=a.property_id
GROUP BY city
ORDER BY city desc

--ROOM ANALYTICS
--Revenue per room type
--RT2	$560,271,204
--RT3	$462,166,344
--RT4	$376,752,786
--RT1	$309,580,895
SELECT room_category,
       sum(revenue_realized) as Revenue
FROM fact_bookings$ 
GROUP BY room_category
ORDER BY Revenue desc

--Successful bookings by room type
--RT2	49,505
--RT1	38,446
--RT3	30,566
--RT4	16,073
SELECT room_category,
       sum(successful_bookings) as total_bookings
FROM fact_aggregated_bookings$
GROUP BY room_category
ORDER BY total_bookings desc


--Ocupation rate by room type
--RT4	59.22%
--RT1	57.87%
--RT2	57.61%
--RT3	57.58%
SELECT room_category,
       (sum(successful_bookings)/
       sum(capacity)) as occupancy_rate
FROM fact_aggregated_bookings$
GROUP BY room_category
ORDER BY occupancy_rate desc

--Booking percentage by room type
--RT2	22.25%
--RT1	17.55%
--RT3	13.75%
--RT4	 7.49%
SELECT a.room_category,
       sum(a.successful_bookings) 
       /
       count(b.booking_id)as Booking_rate
FROM fact_aggregated_bookings$ a,
     fact_bookings$ b
WHERE a.property_id=b.property_id
GROUP BY a.room_category
ORDER BY Booking_rate desc