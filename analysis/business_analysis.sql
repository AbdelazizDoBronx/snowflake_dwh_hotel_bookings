USE DATABASE DWH_HOTEL_BOOKINGS;


-- KPIS
-- total revenue generated
SELECT SUM(total_amount) AS total_revenue FROM gold.fct_bookings;

-- What is our monthly revenue trend?
SELECT 
    DATE_TRUNC('month', check_in_date) AS mnth,
    ROUND(SUM(total_amount), 2) AS total_amount,
    COUNT(booking_id) AS bookings
FROM gold.fct_bookings
GROUP BY DATE_TRUNC('month', check_out_date)
ORDER BY mnth
;


-- Which 5 properties generate the most revenue?
SELECT
    fb.property_key,
    dp.property_name,
    SUM(fb.total_amount) AS total_amount
FROM gold.fct_bookings fb
LEFT JOIN gold.dim_property dp
ON fb.property_key = dp.property_key
WHERE fb.property_key IS NOT NULL
GROUP BY fb.property_key, dp.property_name
ORDER BY total_amount DESC
LIMIT 5
;

-- How much of our business comes from each booking channel (OLTP, Booking.com, Airbnb, Trip.com)?
SELECT 
    system_source,
    ROUND(DIV0(SUM(total_amount), (SELECT SUM(total_amount) FROM gold.fct_bookings)) * 100, 2) AS sys_source_pct
FROM gold.fct_bookings
GROUP BY system_source
;

-- What is our booking cancellation rate?
-- M1
SELECT  
    status,
    ROUND(DIV0(COUNT(booking_id), (SELECT COUNT(booking_id) FROM gold.fct_bookings WHERE status IS NOT NULL)) * 100, 2) AS cancel_rate
FROM gold.fct_bookings
WHERE status IS NOT NULL AND status = 'Cancelled'
GROUP BY status
;
-- M2
SELECT 
    ROUND(DIV0(SUM(CASE WHEN status = 'Cancelled' THEN 1 ELSE 0 END), COUNT(booking_id)) * 100, 2) AS cancel_rate
FROM gold.fct_bookings
WHERE status IS NOT NULL
;

-- Do promotions increase booking value and length of stay?
WITH base_cte 
AS
(
    SELECT 
        booking_id,
        promotion_key,
        total_amount,
        number_of_nights,
        CASE
        WHEN promotion_key IS NOT NULL THEN 'No Promotion'
        ELSE 'Promotion'
        END AS is_promo
    FROM gold.fct_bookings
    WHERE system_source = 'oltp'
)

SELECT 
    is_promo,
    ROUND(SUM(total_amount), 2) AS total_amount,
    COUNT(booking_id) AS total_bookings,
    ROUND(AVG(number_of_nights), 2) AS avg_stay
FROM base_cte
GROUP BY is_promo
;

