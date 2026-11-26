-- grain: each row represent a single booking
-- dim_customer, dim_property, dim_promotion, dim_payment, dim_room, dim_room_types
-- fct_booking

USE DATABASE DWH_HOTEL_BOOKINGS;

-- customer dimension
CREATE OR REPLACE VIEW gold.dim_customer

AS

WITH all_customers AS

(
    SELECT
        'oltp' AS system_source,
        customer_id AS source_customer_id,
        first_name,
        last_name,
        birthdate,
        email,
        phone,
        country,
        created_at
    FROM silver.oltp_customers oc

UNION ALL

SELECT 
        'booking.com',
        booking_id,
        customer_first_name,
        customer_last_name,
        cusstomer_birthday,
        customer_email,
        customer_phone_number,
        customer_country,
        NULL::DATE
    FROM silver.third_party_booking_com

UNION ALL

SELECT
        'airbnb.com',
        bking_id,
        cust_firstname,
        cust_lastname,
        NULL::DATE,
        cust_email,
        NULL::VARCHAR,
        NULL::VARCHAR,
        NULL::DATE
    FROM silver.third_party_airbnb

UNION ALL

SELECT
        'trip.com',
        b_id,
        firstname,
        lastname,
        NULL::DATE,
        email,
        NULL::VARCHAR,
        NULL::VARCHAR,
        NULL::DATE
    FROM silver.third_party_trip
)

SELECT 

    MD5(system_source || source_customer_id) AS customer_key,
    system_source,
    source_customer_id,
    first_name,
    last_name,
    birthdate,
    email,
    phone,
    country,
    created_at    

FROM all_customers 
;





-- dim_property
CREATE OR REPLACE VIEW gold.dim_property 
AS
SELECT
    MD5('property' || property_id) AS property_key,
    property_id,
    name AS property_name,
    city,
    capacity,
    stars
FROM silver.oltp_properties  
;


-- dim_promotion
CREATE OR REPLACE VIEW gold.dim_promotion AS
SELECT
    MD5('promotion' || promotion_id) AS promotion_key,
    promotion_id,
    campaign,
    promotion_code,
    discount_pct,
    valid_from,
    valid_to
FROM silver.oltp_promotions 
;




-- dim_payment
CREATE OR REPLACE VIEW gold.dim_payment AS
SELECT 
    MD5('payment' || booking_id || '') AS payment_key,
    booking_id,
    amount,
    bank_provider,
    status,
    created_at
FROM silver.oltp_payments
;


-- dim_rooms
CREATE OR REPlACE VIEW gold.dim_room AS
SELECT 
    MD5('room' || property_id || room_id) AS room_key,
    property_id,
    room_id,
    room_number,
    room_type_id
FROM silver.oltp_rooms
;


-- dim_room_types
CREATE OR REPLACE VIEW gold.dim_room_types AS
SELECT
    MD5('room_type' || room_type_id) AS room_type_key,
    room_type_id,
    base_cost,
    max_capacity,
    type
FROM silver.oltp_room_types
LIMIT 10
;



-- fct_bookings
CREATE OR REPLACE VIEW gold.fct_bookings 
AS
SELECT
    'oltp' AS system_source,
    booking_id,
    oc.customer_key,
    orm.room_key,
    NULL::VARCHAR AS property_key,
    check_in_date,
    check_out_date,
    number_of_nights,
    status,
    is_full_package,
    dp.promotion_key,
    total_amount
FROM silver.oltp_bookings ob
LEFT JOIN gold.dim_customer oc
ON ob.customer_id = oc.SOURCE_CUSTOMER_ID
LEFT JOIN gold.dim_room orm
ON ob.room_id = orm.room_id
LEFT JOIN gold.dim_promotion dp
ON ob.promotion_id = dp.promotion_id

UNION ALL

SELECT 
    'booking.com',
    booking_id,
    MD5('booking.com' || booking_id) AS customer_key,
    NULL::VARCHAR AS property_key,
    orm.room_key,
    check_in_date,
    check_out_date,
    number_of_nights,
    NULL::VARCHAR,
    NULL::VARCHAR,
    NULL::VARCHAR,
    total_amount
FROM silver.third_party_booking_com tpb
LEFT JOIN gold.dim_room orm
ON tpb.room_number = orm.room_number

UNION ALL

SELECT 
    'airbnb.com',
    bking_id,
    MD5('airbnb' || bking_id),
    gdp.property_key,
    orm.room_key,
    start_date,
    end_date,
    CAST(TRY_TO_DATE(end_date) - TRY_TO_DATE(start_date) AS INTEGER),
    NULL::VARCHAR,
    NULL::VARCHAR,
    NULL::VARCHAR,
    total_amount
FROM silver.third_party_airbnb pab
LEFT JOIN gold.dim_room orm
ON pab.room_number = orm.room_number
LEFT JOIN gold.dim_property gdp
ON pab.property_id = gdp.property_id

UNION ALL

SELECT
    'trip.com',
    b_id,
    MD5('trip.com' || b_id),
    gdp.property_key,
    orm.room_key,
    check_in_date,
    check_out_date,
    CAST(TRY_TO_DATE(check_out_date) - TRY_TO_DATE(check_in_date) AS INTEGER),
    NULL::VARCHAR,
    NULL::VARCHAR,
    NULL::VARCHAR,
    amount_paid 
FROM silver.third_party_trip tpt
LEFT JOIN gold.dim_room orm
ON tpt.room_number = orm.room_number
LEFT JOIN gold.dim_property gdp
ON tpt.property_id = gdp.property_id
;


SELECT * FROM silver.third_party_trip
LIMIT 10;

SELECT * FROM gold.dim_property LIMIT 10;