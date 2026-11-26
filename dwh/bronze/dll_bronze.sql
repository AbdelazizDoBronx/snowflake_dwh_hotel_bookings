-- script purpose:
--      create bronze tables that will hold raw data
--      it drops tables first then recreates them
--      WARNING : running this scripts will drop tables that already exists.    


-- main data source company website
-- this simulates a full hotel managment database design with differents entities
DROP TABLE IF EXISTS oltp_customers;
CREATE TABLE oltp_customers 
    (
        customer_id VARCHAR(250),
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        birthdate VARCHAR(50),
        email VARCHAR(50),
        phone VARCHAR(50),
        country VARCHAR(50),
        created_at VARCHAR(50)
    )
;


DROP TABLE IF EXISTS oltp_bookings;
CREATE TABLE oltp_bookings
    (
        booking_id VARCHAR(250),
        customer_id VARCHAR(250),
        room_id VARCHAR(250),
        number_of_nights VARCHAR(25),
        check_in_date VARCHAR(50),
        check_out_date VARCHAR(50),
        status VARCHAR(50),
        is_full_package VARCHAR(50),
        promotion_id VARCHAR(250),
        total_amount VARCHAR(250)
    )
;


DROP TABLE IF EXISTS oltp_payments;
CREATE TABLE oltp_payments
    (
        payment_id VARCHAR(250),
        booking_id VARCHAR(250),
        amount VARCHAR(50),
        bank_provider VARCHAR(50),
        status VARCHAR(50),
        created_at VARCHAR(50)
    )
;


DROP TABLE IF EXISTS oltp_promotions;
CREATE TABLE oltp_promotions
    (
        promotion_id VARCHAR(250),
        promotion_code VARCHAR(50),
        discount_pct VARCHAR(50),
        campaign VARCHAR(50),
        valid_from VARCHAR(50),
        valid_to VARCHAR(50)
    )
;


DROP TABLE IF EXISTS oltp_properties;
CREATE TABLE oltp_properties
    (
        property_id VARCHAR(250),
        name VARCHAR(50),
        city VARCHAR(50),
        capacity VARCHAR(50),
        stars VARCHAR(50)
    )
;


DROP TABLE IF EXISTS oltp_room_types;
CREATE TABLE oltp_room_types
    (
        room_type_id VARCHAR(250),
        type VARCHAR(50),
        max_capacity VARCHAR(50),
        base_cost VARCHAR(50)
    )
;


DROP TABLE IF EXISTS oltp_rooms;
CREATE TABLE oltp_rooms
    (
        room_id VARCHAR(250),
        room_number VARCHAR(50),
        property_id VARCHAR(250),
        room_type_id VARCHAR(250)
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
        cusstomer_birthday VARCHAR(50),
        customer_country VARCHAR(50),
        customer_email VARCHAR(50),
        customer_phone_number VARCHAR(50),
        check_in_date VARCHAR(50),
        check_out_date VARCHAR(50),
        number_of_nights VARCHAR(50),
        payment_provider VARCHAR(50),
        property_id VARCHAR(250),
        room_number VARCHAR(50),
        total_amount VARCHAR(50)
    )
;


DROP TABLE IF EXISTS third_party_airbnb;
CREATE TABLE third_party_airbnb
    (
        bking_id VARCHAR(250),
        cust_firstname VARCHAR(50),
        cust_lastname VARCHAR(50),
        cust_email VARCHAR(50),
        start_date VARCHAR(50),
        end_date VARCHAR(50),
        payment_by VARCHAR(50),
        property_id VARCHAR(250),
        room_number VARCHAR(50),
        total_amount VARCHAR(50)
    )
;


DROP TABLE IF EXISTS third_party_trip;
CREATE TABLE third_party_trip
    (
        b_id VARCHAR(250),
        firstname VARCHAR(50),
        lastname VARCHAR(50),
        email VARCHAR(50),
        check_in_date VARCHAR(50),
        check_out_date VARCHAR(50),
        property_id VARCHAR(250),
        room_number VARCHAR(50),
        amount_paid VARCHAR(50),
        accusation_channel VARCHAR(50)
    )
;