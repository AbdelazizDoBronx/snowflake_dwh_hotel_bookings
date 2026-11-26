-- Create database dwh that holds the layers
CREATE IF NOT EXISTS DATABASE dwh_hotel_bookings;


-- Create schemas bronze - silver - gold
CREATE SCHEMA dwh_hotel_bookings.bronze;

CREATE SCHEMA dwh_hotel_bookings.silver;

CREATE SCHEMA dwh_hotel_bookings.gold;

USE SCHEMA dwh_hotel_bookings.bronze;

-- Create file to handle csv
CREATE OR REPLACE FILE FORMAT dwh_ff_csv
    TYPE = CSV
    FIELD_DELIMITER = ','
    NULL_IF = ('NULL', 'Null', 'null', ' ','')
    SKIP_HEADER = 1
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
;

-- Create stage to store csv files comming to snowflake
CREATE OR REPLACE STAGE dwh_stg
    FILE_FORMAT = (FORMAT_NAME = dwh_ff_csv)
    COPY_OPTIONS = (ON_ERROR = 'CONTINUE')    
;    




CREATE TABLE IF NOT EXISTS silver.etl_execution_log (
    run_id          VARCHAR,
    procedure_name  VARCHAR,
    status          VARCHAR,
    started_at      TIMESTAMP_LTZ,
    finished_at     TIMESTAMP_LTZ,
    error_code      NUMBER,
    error_state     VARCHAR,
    error_message   VARCHAR
);    

DROP TABLE silver.etl_log;
CREATE TABLE IF NOT EXISTS silver.etl_log
(
    run_id VARCHAR, 
    status VARCHAR, 
    procedure_name VARCHAR, 
    table_name VARCHAR, 
    started_at TIMESTAMP,           
    finished_at TIMESTAMP,
    error_code VARCHAR,
    error_state VARCHAR,
    error_message VARCHAR 
)
;
SELECT * FROM silver.etl_log;