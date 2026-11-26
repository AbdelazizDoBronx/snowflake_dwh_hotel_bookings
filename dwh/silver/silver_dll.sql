USE DATABASE DWH_HOTEL_BOOKINGS;
USE SCHEMA silver;


DROP TABLE IF EXISTS oltp_customers;
CREATE TABLE oltp_customers 
    (
        customer_id VARCHAR(250),
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        birthdate DATE,
        email VARCHAR(50),
        phone VARCHAR(50),
        country VARCHAR(50),
        created_at DATE,
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_bookings;
CREATE TABLE oltp_bookings
    (
        booking_id VARCHAR(250),
        customer_id VARCHAR(250),
        room_id VARCHAR(250),
        number_of_nights INT,
        check_in_date DATE,
        check_out_date DATE,
        status VARCHAR(50) CHECK ( LOWER(status) IN ('confirmed', 'cancelled', 'pending') ),
        is_full_package VARCHAR(10) CHECK ( LOWER(is_full_package) IN ('yes', 'no')),
        promotion_id VARCHAR(250),
        total_amount DECIMAL(10, 2),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_payments;
CREATE TABLE oltp_payments
    (
        payment_id VARCHAR(250),
        booking_id VARCHAR(250),
        amount DECIMAL(10, 2),
        bank_provider VARCHAR(50) CHECK (LOWER(bank_provider) IN ('paypal', 'visa', 'mastercard', 'crypto',         'stripe')),
        status VARCHAR(50) CHECK ( LOWER(status) IN ('complited', 'rejected')),
        created_at DATE,
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_promotions;
CREATE TABLE oltp_promotions
    (
        promotion_id VARCHAR(250),
        promotion_code VARCHAR(50),
        discount_pct INT,
        campaign VARCHAR(50),
        valid_from DATE,
        valid_to DATE,
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_properties;
CREATE TABLE oltp_properties
    (
        property_id VARCHAR(250),
        name VARCHAR(50),
        city VARCHAR(50),
        capacity INT,
        stars INT,
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_room_types;
CREATE TABLE oltp_room_types
    (
        room_type_id VARCHAR(250),
        type VARCHAR(50) CHECK ( LOWER(type) IN ('single', 'double', 'triple', 'suite')),
        max_capacity INT,
        base_cost DECIMAL(10, 2),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS oltp_rooms;
CREATE TABLE oltp_rooms
    (
        room_id VARCHAR(250),
        room_number INT,
        property_id VARCHAR(250),
        room_type_id VARCHAR(250),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;




-- third party websites
-- this sumilates data comming from third party platforms like airbnb.com, booking.com and trip.com
DROP TABLE IF EXISTS third_party_booking_com;
CREATE TABLE third_party_booking_com
    (
        booking_id VARCHAR(250),        
        customer_first_name VARCHAR(50),
        customer_last_name VARCHAR(50),
        cusstomer_birthday DATE,
        customer_country VARCHAR(50),
        customer_email VARCHAR(50),
        customer_phone_number VARCHAR(50),
        check_in_date DATE,
        check_out_date DATE,
        number_of_nights INT,
        payment_provider VARCHAR(50) CHECK (LOWER(payment_provider) IN ('bitcoin', 'mastercard', 'paypal', 'visa', 'stripe')),
        property_id VARCHAR(250),
        room_number INT,
        total_amount DECIMAL(10, 2),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS third_party_airbnb;
CREATE TABLE third_party_airbnb
    (
        bking_id VARCHAR(250),
        cust_firstname VARCHAR(50),
        cust_lastname VARCHAR(50),
        cust_email VARCHAR(50),
        start_date DATE,
        end_date DATE,
        payment_by VARCHAR(50) CHECK (LOWER(payment_by) IN ('bitcoin', 'paypal', 'stripe', 'visa', 'mastercard')),
        property_id VARCHAR(250),
        room_number INT,
        total_amount DECIMAL(10, 2),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;


DROP TABLE IF EXISTS third_party_trip;
CREATE TABLE third_party_trip
    (
        b_id VARCHAR(250),
        firstname VARCHAR(50),
        lastname VARCHAR(50),
        email VARCHAR(50),
        check_in_date DATE,
        check_out_date DATE,
        property_id VARCHAR(250),
        room_number INT,
        amount_paid DECIMAL(10, 2),
        accusation_channel VARCHAR(50) CHECK ( LOWER(accusation_channel) IN ('google ads', 'tiktok', 'facebook', 'instagram', 'youtube')),
        created_at_wh TIMESTAMP_LTZ DEFAULT CURRENT_TIMESTAMP()
    )
;