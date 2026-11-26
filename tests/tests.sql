USE DATABASE DWH_HOTEL_BOOKINGS;
USE SCHEMA bronze;

-- oltp_bookings table
-- verify pk duplication
SELECT booking_id, COUNT(booking_id) 
FROM bronze.oltp_bookings
GROUP BY booking_id
HAVING COUNT(booking_id) > 1
;
-- verify time travel problem end date < start date
SELECT * 
FROM bronze.oltp_bookings
WHERE check_in_date > check_out_date
;

-- oltp_customers table
-- verify pk duplication
SELECT
    customer_id,
    COUNT(customer_id)
FROM bronze.oltp_customers
GROUP BY customer_id
HAVING COUNT(customer_id) > 1
;
-- verify email duplication
SELECT
    email,
    COUNT(customer_id)
FROM bronze.oltp_customers
GROUP BY email
HAVING COUNT(customer_id) > 1
;


-- oltp_promotions
-- verify pk duplication
SELECT
    promotion_id,
    COUNT(promotion_id)
FROM bronze.oltp_promotions
GROUP BY promotion_id
HAVING COUNT(promotion_id) > 1
;
-- verify time travel problem start date > end
SELECT *
FROM bronze.oltp_promotions
WHERE valid_from > valid_to
LIMIT 10
;

-- oltp_payments
-- verify pk duplication
SELECT payment_id, COUNT(payment_id)
FROM oltp_payments
GROUP BY payment_id
HAVING COUNT(payment_id) > 1
;
-- verify amount (outliers/invalid)
SELECT * 
FROM oltp_payments
WHERE amount <= 0 OR amount > ((SELECT AVG(amount) FROM oltp_payments) * 5)
;
-- verify bank_provider values consestency
SELECT DISTINCT bank_provider 
FROM oltp_payments
;
-- verify status values consetency
SELECT DISTINCT status 
FROM oltp_payments
;
-- verify created_at 
SELECT *
FROM oltp_payments
WHERE created_at IS NULL
;



-- oltp_properties
-- verify pk duplication
SELECT
    property_id,
    COUNT(property_id)
FROM bronze.oltp_properties
GROUP BY 1
HAVING count(*) > 1
;
-- verify null names or names with random white spaces
SELECT * 
FROM bronze.oltp_properties
WHERE name != TRIM(name) OR name IS NULL
;
-- verify names with inconsistencies
SELECT DISTINCT name
FROM oltp_properties
;
-- verify city values
SELECT *
FROM oltp_properties
WHERE city != TRIM(city) OR city IS NULL
;
-- verify capacity
SELECT *
FROM oltp_properties
WHERE capacity IS NULL OR capacity <= 0 OR capacity >= ((SELECT AVG(capacity) FROM oltp_properties) * 5)
;
-- verify stars
SELECT *
FROM oltp_properties
WHERE stars IS NULL OR stars <= 0 OR stars > 5
;

-- oltp_room_types
-- verify pk duplication
SELECT
    room_type_id,
    COUNT(room_type_id) AS count
FROM bronze.oltp_room_types
GROUP BY 1
HAVING COUNT(room_type_id) > 1
;


-- oltp_rooms
-- verify pk duplication
SELECT
    room_id,
    COUNT(room_id)
FROM oltp_rooms
GROUP BY room_id
HAVING COUNT(room_id) > 1
;
-- verify room_number (outliers/invalid values/nulls)
SELECT *
FROM oltp_rooms
WHERE room_number IS NULL OR room_number in ('', ' ') OR room_number <= 0
;
 


-- third party data

-- booking.com
-- verify pk duplication
SELECT
    booking_id,
    COUNT(booking_id)
FROM third_party_booking_com
GROUP BY 1
HAVING COUNT(booking_id) > 1
;
-- 0 rows returned (no duplicated rows found)

-- verify customer_birthday (nulls/invalid)
SELECT *
FROM third_party_booking_com
WHERE cusstomer_birthday IS NULL OR cusstomer_birthday IN ('', ' ') OR TRY_TO_DATE(cusstomer_birthday) >= CURRENT_DATE()
;
-- zero rows returned

-- verify customer_country (value inconesitensies/nulls)
SELECT *
FROM third_party_booking_com
WHERE customer_country IS NULL OR customer_country IN ('', ' ') OR customer_country != TRIM(customer_country)
;
-- zero rows returned

-- verify emails (nulls/invalid)
SELECT *
FROM third_party_booking_com
WHERE customer_email != TRIM(customer_email) OR customer_email IN ('', ' ', NULL) OR customer_email NOT like '%@%.%'
;
-- zero rows returned

-- verify check_in_date / check_out_date (invalid/nulls/time travel)
SELECT *
FROM third_party_booking_com
WHERE 
    TRY_TO_DATE(check_in_date) > TRY_TO_DATE(check_out_date) 
    OR check_in_date IS NULL 
    OR check_out_date IS NULL 
-- 11,244 rows returned with time travel problem check_in_date > check_out_date (i assumed that two columns got switched by mistake, so my solution     is to switch the two columns values)
-- zero rows returned as nulls
;

-- verify number_of_nights (nulls/invalid) illogic (number_of_nights) > check_out_date - check_in_date 
SELECT *
FROM third_party_booking_com
WHERE 
-- number_of_nights IS NULL 
   -- number_of_nights IN ('', ' ') 
    -- CAST(number_of_nights AS NUMBER) <= 0 
    (TRY_TO_DATE(check_out_date) - TRY_TO_DATE(check_in_date)) != CAST(number_of_nights AS NUMBER)
;
-- zero rows returned as nulls OR empty values ''/' '
-- zero rows returned as negative values
-- 11,244 rows returned as illogic values (number_of_nights > check_out_date - check_in_date)
-- solution is calculating  check_out_date - check_in_date as number_of_nights on rows those rows

-- verify payment_provider (nulls/inconsistencies/invalid)
SELECT DISTINCT payment_provider
FROM third_party_booking_com
;
-- must fix inconsistencies e.g: payp -> paypal

-- verify room_number
SELECT *
FROM third_party_booking_com
WHERE room_number IS NULL OR CAST(room_number AS NUMBER) <= 0; 
-- zero rows returned

-- verify total_amount (outliers/invalid/nulls)
SELECT *
FROM third_party_booking_com
WHERE 
    -- total_amount IS NULL 
    -- CAST(REPLACE(total_amount, '$', '') AS NUMBER) <= 0 
     -- CAST(REPLACE(total_amount, '$', '') AS NUMBER) >= ((SELECT AVG(REPLACE(total_amount, '$', '')) FROM third_party_booking_com) * 3)
     total_amount ilike '$%' OR total_amount ilike '%$'
;
-- 3,308 rows returned as negative values -> solution: replaced with absolute values of those rows
-- 6,885 rows returned as outliers >= avg(total_amount) * 3 -> solution: replaced with median
-- 3,748 rows returned as invalid values with $ sign e.g: $57.32 -> solution: remove the $ sign



SELECT
    TOTAL_AMOUNT,
    NTILE(4) OVER(ORDER BY CAST(REPLACE(total_amount, '$', '') AS NUMBER)) AS qrt
FROM third_party_booking_com
WHERE CAST(REPLACE(total_amount, '$', '') AS NUMBER) >= 192000
ORDER BY qrt DESC
;

SELECT MAX(CAST(REPLACE(total_amount, '$', '') AS NUMBER)) FROM third_party_booking_com;

SELECT DISTINCT payment_provider FROM third_party_booking_com;




