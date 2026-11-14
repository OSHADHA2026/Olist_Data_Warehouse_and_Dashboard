USE Olist_Staging;
GO


-- COMPREHENSIVE DATA QUALITY CHECKING FOR: [CUSTOMER] TABLE


-- 2. [Uniqueness Profiling]: Check for duplicate customer_id 
-- (customer_id should be 100% unique as it acts as the primary key per order)
SELECT customer_id, COUNT(*) AS Duplicate_Count
FROM dbo.Customer
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO


-- 4. [Completeness Profiling]: Check for hidden empty strings or spaces in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(customer_id)) = '' THEN 1 ELSE 0 END) AS Blank_CustomerID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_unique_id)) = '' THEN 1 ELSE 0 END) AS Blank_UniqueID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_city)) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM(customer_state)) = '' THEN 1 ELSE 0 END) AS Blank_State
FROM dbo.Customer;
GO


-- 5. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT customer_state, LEN(LTRIM(RTRIM(customer_state))) AS State_Length
FROM dbo.Customer
WHERE LEN(LTRIM(RTRIM(customer_state))) <> 2;
GO


-- 6. [Length Constraint Profiling]: Check Minimum and Maximum lengths of ID columns
SELECT 
    MIN(LEN(customer_id)) AS Min_ID_Length, 
    MAX(LEN(customer_id)) AS Max_ID_Length,
    MIN(LEN(customer_unique_id)) AS Min_UniqueID_Length, 
    MAX(LEN(customer_unique_id)) AS Max_UniqueID_Length
FROM dbo.Customer;
GO


-- 7. [Domain & Range Profiling]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Customer
WHERE customer_zip_code_prefix <= 0;
GO