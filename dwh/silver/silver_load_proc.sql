USE DATABASE dwh_hotel_bookings;
USE SCHEMA silver;

CREATE OR REPLACE PROCEDURE silver_load()
RETURNS VARCHAR
LANGUAGE SQL
EXECUTE AS OWNER
AS
$$
DECLARE
    v_current_table VARCHAR;
    v_run_id VARCHAR DEFAULT UUID_STRING();
    v_started_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP();
    v_error_code VARCHAR;
    v_error_message VARCHAR;
    v_error_state VARCHAR;
    
BEGIN

        BEGIN TRANSACTION;

        v_current_table := 'oltp_bookings';
        DELETE FROM oltp_bookings;
        INSERT INTO oltp_bookings 
        (
            booking_id,
            customer_id,
            room_id,
            number_of_nights,
            check_in_date,
            check_out_date,
            status,
            is_full_package,
            promotion_id,
            total_amount  
        )
        SELECT 
            TRIM(booking_id) AS booking_id,
            TRIM(customer_id) AS customer_id,
            TRIM(room_id) AS room_id,
            ABS(number_of_nights) AS number_of_nights,
            check_in_date,
            check_out_date,
            INITCAP(TRIM(status)) AS status,
            INITCAP(TRIM(is_full_package)) AS is_full_package,
            TRIM(promotion_id) AS promotion_id,
            total_amount
        FROM bronze.oltp_bookings
        ;
     
        
        v_current_table := 'oltp_customers';        
        DELETE FROM oltp_customers;    
        INSERT INTO oltp_customers
        (
            customer_id,
            first_name,
            last_name,
            birthdate,
            email,
            phone,
            country,
            created_at
        )
        SELECT
            TRIM(customer_id) AS customer_id,
            TRIM(first_name) AS first_name, 
            TRIM(last_name) AS last_name,
            TRY_TO_DATE(birthdate) AS birthdate, 
            TRIM(email) AS email,
            TRIM(phone) AS phone,
            TRIM(country) AS country,
            TRY_TO_DATE(created_at) AS created_at
        FROM bronze.oltp_customers
        ;
        
        
        -- oltp_promotions
        v_current_table := 'oltp_promotions';
        DELETE FROM oltp_promotions;    
        INSERT INTO oltp_promotions
        (   
            promotion_id,
            promotion_code,
            discount_pct,
            campaign,
            valid_from,
            valid_to
        )
        SELECT
            TRIM(promotion_id) AS promotion_id,
            TRIM(promotion_code) AS promotion_code,
            CAST(ABS(discount_pct) AS NUMBER) AS discount_pct,
            TRIM(campaign) AS campaign,
            TRY_TO_DATE(VALID_FROM) AS valid_from,
            TRY_TO_DATE(VALID_TO) AS valid_to
        FROM bronze.oltp_promotions
        ;
        
        
        -- oltp_payments
        v_current_table := 'oltp_payments';
        DELETE FROM oltp_payments;    
        INSERT INTO oltp_payments
        (
            payment_id,
            booking_id,
            amount,
            bank_provider,
            status,
            created_at
        )
        SELECT
            TRIM(payment_id) AS payment_id,
            TRIM(booking_id) AS booking_id,
            CAST(amount AS NUMBER) AS amount,
            TRIM(bank_provider) AS bank_provider,
            TRIM(status) AS status,
            TRY_TO_DATE(created_at) AS created_at
        FROM bronze.oltp_payments
        ;
        
        -- oltp_properties
        v_current_table := 'oltp_properties';
        DELETE FROM oltp_properties;    
        INSERT INTO oltp_properties
        (
            property_id,
            name,
            city,
            capacity,
            stars
        )
        SELECT 
            TRIM(property_id) AS property_id,
            TRIM(name) AS name,
            TRIM(city) AS city,
            CAST(TRIM(capacity) AS NUMBER) AS capacity,
            CAST(TRIM(stars) AS NUMBER) AS stars
        FROM bronze.oltp_properties 
        ;
        
        
        -- oltp_room_types
        v_current_table := 'oltp_room_types';
        DELETE FROM oltp_room_types;
        INSERT INTO oltp_room_types
        (
            room_type_id,
            type,
            max_capacity,
            base_cost
        )
        SELECT 
            TRIM(room_type_id) AS room_type_id,
            INITCAP(TRIM(type)) AS type,
            CAST(TRIM(max_capacity) AS NUMBER) AS max_capacity,
            CAST(TRIM(base_cost) AS NUMBER) AS base_cost
        FROM bronze.oltp_room_types
        ;
        
        
        -- oltp_rooms
        v_current_table := 'oltp_rooms';
        DELETE FROM oltp_rooms;
        INSERT INTO oltp_rooms
        (
            room_id,
            room_number,
            property_id,
            room_type_id
        )
        SELECT 
            TRIM(room_id) AS room_id,
            CAST(TRIM(room_number) AS NUMBER) AS room_number,
            TRIM(property_id) AS property_id,
            TRIM(room_type_id) AS room_type_id
        FROM bronze.oltp_rooms
        ;
        
        
        -- third parties tables
        v_current_table := 'third_party_booking_com';
        DELETE FROM third_party_booking_com;
        INSERT INTO third_party_booking_com
        (
            booking_id,
            customer_first_name,
            customer_last_name,
            cusstomer_birthday,
            customer_country,
            customer_email,
            customer_phone_number,
            check_in_date,
            check_out_date,
            number_of_nights,
            payment_provider,
            property_id,
            room_number,
            total_amount
        )
        SELECT 
            TRIM(booking_id) AS booking_id,
            
            TRIM(customer_first_name) AS customer_first_name,
            
            TRIM(customer_last_name) AS customer_last_name,
            
            TRY_TO_DATE(cusstomer_birthday) AS cusstomer_birthday ,
            
            TRIM(customer_country) AS customer_country,
            
            TRIM(customer_email) AS customer_email,
            
            TRIM(customer_phone_number) AS customer_phone_number,
            
            CASE
                WHEN TRY_TO_DATE(check_in_date) > TRY_TO_DATE(check_out_date) THEN TRY_TO_DATE(check_out_date)
                ELSE TRY_TO_DATE(check_in_date)
            END AS check_in_date,
            
            CASE 
                WHEN TRY_TO_DATE(check_in_date) > TRY_TO_DATE(check_out_date) THEN TRY_TO_DATE(check_in_date)
                ELSE TRY_TO_DATE(check_out_date)
            END AS check_out_date,
            
            CASE
                WHEN ABS(TRY_TO_DATE(check_out_date) - TRY_TO_DATE(check_in_date)) != CAST(number_of_nights AS NUMBER)  THEN ABS(TRY_TO_DATE(check_out_date) - TRY_TO_DATE(check_in_date))
                ELSE CAST(number_of_nights AS NUMBER)
            END AS number_of_nights,
            
            CASE
                WHEN payment_provider = 'payp' THEN 'paypal'
                WHEN payment_provider = 'Mastercard' THEN 'mastercard'
                WHEN payment_provider = 'Master' THEN 'mastercard'
                WHEN payment_provider = 'Visa' THEN 'visa'
                WHEN payment_provider = 'Striipe' THEN 'stripe'
                WHEN payment_provider = 'Stripe' THEN 'stripe'
                WHEN payment_provider = 'bit' THEN 'bitcoin'
                WHEN payment_provider = 'Bitcoin' THEN 'bitcoin'
                WHEN payment_provider = 'Paypal' THEN 'bitcoin'
                ELSE TRIM(LOWER(payment_provider))
            END AS payment_provider,
        
            TRIM(property_id) AS property_id,
            
            CAST(TRIM(room_number) AS NUMBER) AS room_number,
            
            CASE
                WHEN total_amount ilike '$%' OR total_amount ilike '%$' THEN CAST(REPLACE(total_amount, '$', '') AS NUMBER)
                WHEN CAST(REPLACE(total_amount, '$', '') AS NUMBER) <0 THEN ABS(CAST(REPLACE(total_amount, '$', '') AS NUMBER)) 
                WHEN CAST(REPLACE(total_amount, '$', '') AS NUMBER) > ((SELECT MEDIAN(CAST(REPLACE(total_amount, '$', '') AS NUMBER)) FROM bronze.third_party_booking_com) * 5) THEN ((SELECT MEDIAN(CAST(REPLACE(total_amount, '$', '') AS NUMBER)) FROM bronze.third_party_booking_com) * 2.5)
                ELSE CAST(total_amount AS NUMBER)
            END AS total_amount
        FROM bronze.third_party_booking_com
        ;
        v_current_table := 'third_party_airbnb';
        
        -- airbnb table
        DELETE FROM third_party_airbnb;
        INSERT INTO third_party_airbnb
        (
            bking_id,
            cust_firstname,
            cust_lastname,
            cust_email,
            start_date,
            end_date,
            payment_by,
            property_id,
            room_number,
            total_amount
        )
        SELECT 
            TRIM(bking_id) AS bking_id,
            TRIM(cust_firstname) AS cust_firstname,
            TRIM(cust_lastname) AS cust_lastname,
            TRIM(cust_email) AS cust_email,
            TRY_TO_DATE(TRIM(start_date)) AS start_date,
            TRY_TO_DATE(TRIM(end_date)) AS end_date,
            TRIM(LOWER(payment_by)) AS payment_by,
            TRIM(property_id) AS property_id,
            CAST(LTRIM(REPLACE(TRIM(room_number), 'room_', ''), '0') AS NUMBER) AS room_number,
            CAST(total_amount AS DECIMAL) AS totat_amount
        FROM bronze.third_party_airbnb
        ;
        v_current_table := 'third_party_trip';
        
        -- trip.com table
        DELETE FROM third_party_trip;
        INSERT INTO third_party_trip
        (
            b_id,
            firstname,
            lastname,
            email,
            check_in_date,
            check_out_date,
            property_id,
            room_number,
            amount_paid,
            accusation_channel
        )
        SELECT 
            TRIM(b_id) AS b_id,
            TRIM(firstname) AS firstname,
            TRIM(lastname) AS lastname,
            TRIM(email) AS email,
            TRY_TO_DATE(TRIM(check_in_date)) AS check_in_date,
            TRY_TO_DATE(TRIM(check_out_date)) AS check_out_date,
            TRIM(property_id) AS property_id,
            LTRIM(REPLACE(TRIM(room_number), 'room_', ''), '0') AS room_number,
            CAST(amount_paid AS NUMBER) AS amount_paid,
            TRIM(accusation_channel) AS accusation_channel
        FROM bronze.third_party_trip
        ;


        -- insert logs
            INSERT INTO silver.etl_log(run_id, status, procedure_name, started_at, finished_at) 
                                VALUES(:v_run_id, 'COMPLETED', 'silver_load', :v_started_at, CURRENT_TIMESTAMP());
    
    COMMIT;
    
    RETURN 'ETL PROC COMPLITED SUCCESSFULLY';


    
    
EXCEPTION

    WHEN OTHER THEN
    
        v_error_code := SQLCODE;
        v_error_message := SQLERRM;
        v_error_state := SQLSTATE;
        
        ROLLBACK;       
        
        INSERT INTO silver.etl_log (run_id, status, procedure_name, table_name, started_at, finished_at, error_code, error_state, error_message)
        VALUES(:v_run_id, 'FAILED', 'silver_load', :v_current_table, :v_started_at, CURRENT_TIMESTAMP(), :v_error_code, :v_error_state, :v_error_message);

        RETURN 'ETL PROC FAILED IN ' || v_current_table || ' Table' ||
               ' error code: ' || v_error_code || ' error_message: '  || v_error_message || 'error_state: '                          || v_error_state;
END;
$$;

CALL silver_load();



