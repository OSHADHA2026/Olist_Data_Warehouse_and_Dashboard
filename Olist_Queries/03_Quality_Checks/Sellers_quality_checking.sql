use Olist_Staging
GO

-- COMPREHENSIVE DATA QUALITY CHECKING FOR STAGING AREA: [SELLERS] TABLE

-- 2. [Uniqueness Profiling]: Check for duplicate seller IDs
SELECT seller_id, COUNT(*) AS Duplicate_Count
FROM dbo.Sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness Profiling]: Check for empty strings and NULLs
SELECT 
    SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id) = '' THEN 1 ELSE 0 END) AS Missing_SellerID,
    SUM(CASE WHEN seller_city IS NULL OR TRIM(seller_city) = '' THEN 1 ELSE 0 END) AS Missing_City,
    SUM(CASE WHEN seller_state IS NULL OR TRIM(seller_state) = '' THEN 1 ELSE 0 END) AS Missing_State,
    SUM(CASE WHEN seller_zip_code_prefix IS NULL THEN 1 ELSE 0 END) AS Missing_ZipCode
FROM dbo.Sellers;
GO

-- 4. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT seller_state, LEN(TRIM(seller_state)) AS State_Length
FROM dbo.Sellers
WHERE LEN(TRIM(seller_state)) <> 2;
GO

-- 5. [Domain Profiling]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Sellers
WHERE seller_zip_code_prefix <= 0;
GO

-- 9. [Pattern & Casing Validation]: Digits in city & casing issues
SELECT 
    SUM(CASE WHEN seller_city LIKE '%[0-9]%' THEN 1 ELSE 0 END) AS City_Has_Digits_Error,
    SUM(CASE WHEN seller_state <> UPPER(seller_state) THEN 1 ELSE 0 END) AS State_Casing_Error
FROM dbo.Sellers;
GO

-- 10. [Functional Dependency Check]: Cities associated with multiple states
SELECT seller_city, COUNT(DISTINCT seller_state) AS State_Count
FROM dbo.Sellers
GROUP BY seller_city
HAVING COUNT(DISTINCT seller_state) > 1;
GO