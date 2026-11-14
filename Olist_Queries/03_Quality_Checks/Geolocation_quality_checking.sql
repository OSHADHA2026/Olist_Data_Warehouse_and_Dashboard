USE Olist_Staging;
GO


-- COMPREHENSIVE DATA QUALITY CHECKING FOR: [GEOLOCATION] TABLE


-- 2. [Exact Duplicate Profiling]: Check for completely identical rows
-- (Multiple identical coordinates for the same zip, city, and state)
SELECT 
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state, 
    COUNT(*) AS Duplicate_Count
FROM dbo.Geolocation
GROUP BY 
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state
HAVING COUNT(*) > 1;
GO


-- 3. [Completeness & Format Profiling]: Check for empty strings in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(geolocation_city)) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM(geolocation_state)) = '' THEN 1 ELSE 0 END) AS Blank_State
FROM dbo.Geolocation;
GO


-- 4. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT geolocation_state, LEN(LTRIM(RTRIM(geolocation_state))) AS State_Length
FROM dbo.Geolocation
WHERE LEN(LTRIM(RTRIM(geolocation_state))) <> 2;
GO


-- 5. [Domain Profiling - Numeric]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Geolocation
WHERE geolocation_zip_code_prefix <= 0;
GO


-- 6. [Domain Profiling - Geospatial Global]: Validate Latitude & Longitude standard bounds
SELECT 
    SUM(CASE WHEN geolocation_lat < -90 OR geolocation_lat > 90 THEN 1 ELSE 0 END) AS Invalid_Latitude,
    SUM(CASE WHEN geolocation_lng < -180 OR geolocation_lng > 180 THEN 1 ELSE 0 END) AS Invalid_Longitude
FROM dbo.Geolocation;
GO


-- 7. [Outlier Profiling - Geospatial Brazil]: Identify coordinates outside Brazil's bounding box
SELECT COUNT(*) AS Coordinates_Outside_Brazil
FROM dbo.Geolocation
WHERE geolocation_lat > 5.0 OR geolocation_lat < -33.0
   OR geolocation_lng > -34.0 OR geolocation_lng < -74.0;
GO


-- 9. [Consistency Profiling - Anomaly 1]: One Zip Code mapped to multiple distinct Cities
SELECT geolocation_zip_code_prefix, COUNT(DISTINCT geolocation_city) AS Unique_City_Count
FROM dbo.Geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY Unique_City_Count DESC;
GO


-- 10. [Consistency Profiling - Anomaly 2]: One Zip Code mapped to multiple distinct States
SELECT geolocation_zip_code_prefix, COUNT(DISTINCT geolocation_state) AS Unique_State_Count
FROM dbo.Geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_state) > 1
ORDER BY Unique_State_Count DESC;
GO