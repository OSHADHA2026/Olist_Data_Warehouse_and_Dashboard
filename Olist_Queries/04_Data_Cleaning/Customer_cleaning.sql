USE Olist_Staging;
GO

-- [1. CUSTOMER TABLE CLEANING]

/* 
NOTE: Since the profiling results showed 0 invalid zip codes, 0 invalid state lengths, 
and 0 blank values in the Customer table, no DELETE operations are required here. 
We only need to apply Trimming to ensure data quality.
*/

-- 1. Remove leading and trailing spaces from all text columns
UPDATE dbo.Customer
SET customer_id = LTRIM(RTRIM(customer_id)),
    customer_unique_id = LTRIM(RTRIM(customer_unique_id)),
    customer_city = LTRIM(RTRIM(customer_city)),
    customer_state = LTRIM(RTRIM(customer_state));
GO