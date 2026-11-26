# Hotel Bookings Data Warehouse

## Project Overview

A Snowflake data warehouse that consolidates hotel booking data from an internal OLTP system and three third-party channels (Booking.com, Airbnb, Trip.com) into a single analytics-ready model.

The project follows a medallion architecture in the `dwh_hotel_bookings` database:

| Layer | Schema | Purpose |
|---|---|---|
| Bronze | `bronze` | Raw data as received from each source |
| Silver | `silver` | Cleaned and standardized tables, loaded by the `silver_load()` stored procedure |
| Gold | `gold` | Star schema (dimensions and fact view) for reporting |

**Data sources:** OLTP (bookings, customers, promotions, payments, properties, room types, rooms) and three third-party booking tables.

## Requirements

**Data quality (silver layer)**
- Trim all text fields and standardize casing (`INITCAP`, `LOWER`)
- Safely convert dates (`TRY_TO_DATE`) and numbers
- Fix negative, malformed, and outlier amounts
- Standardize payment providers and room number formats
- Swap check-in/check-out dates when reversed, and recompute nights when inconsistent
- Run the full load in one transaction, with success and failure logging in `silver.etl_log`

**Modeling (gold layer)**
- Deterministic surrogate keys using `MD5(source_system || '|' || source_id)`, because third-party sources have no customer ID
- `dim_customer`: union of all four sources, one row per source record (no cross-source matching)
- `dim_property`: built from `oltp_properties`, since all sources share the same property IDs
- `dim_room`: keyed on `property_id | room_number`, the grain every source can compute
- `fct_bookings`: union of all four booking sources, using identical key formulas as the dimensions

## Deliverables

1. **SQL scripts**
   - `silver_load()` stored procedure (cleaning and logging)
   - Gold views: `dim_customer`, `dim_property`, `dim_room`, `fct_bookings`
2. **Business analysis:** 5 SQL queries covering revenue trends, top properties, channel mix, length of stay, cancellations, promotions.
3. **Dashboard:** 2 charts and 3 kpis
   - Monthly revenue trend (line)
   - Top 5 properties by revenue (horizontal bar)