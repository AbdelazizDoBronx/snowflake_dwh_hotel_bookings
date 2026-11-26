-- setup right database and schema
USE DATABASE DWH_HOTEL_BOOKINGS;
USE SCHEMA bronze;

-- populating tables with data from csv files in stage DWH_STG

COPY INTO oltp_bookings
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/bookings.csv'
;


COPY INTO oltp_customers
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/customers.csv'
;


COPY INTO oltp_payments
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/payments.csv'
;


COPY INTO oltp_promotions
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/promotions.csv'
;


COPY INTO oltp_properties
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/properties.csv'
;


COPY INTO oltp_room_types
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/room_types.csv'
;


COPY INTO oltp_rooms
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/rooms.csv'
;


COPY INTO third_party_booking_com
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/bookingcom.csv'
;


COPY INTO third_party_airbnb
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/airbnb.csv'
;


COPY INTO third_party_trip
    FROM '@"DWH_HOTEL_BOOKINGS"."BRONZE"."DWH_STG"/trip.csv'
;
