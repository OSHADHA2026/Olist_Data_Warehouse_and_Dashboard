USE Olist_Staging;
GO

-- TARGETED DATA CLEANING IN STAGING AREA (Based on Profiling Results)

-- [1. GEOLOCATION TABLE CLEANING]

-- 1. Delete the 302 rows with invalid coordinates outside Brazil identified during profiling
DELETE FROM dbo.Geolocation
WHERE geolocation_lat > 5.0 OR geolocation_lat < -33.0
   OR geolocation_lng > -34.0 OR geolocation_lng < -74.0;
GO

-- 2. Remove leading and trailing spaces from text columns to ensure consistency
UPDATE dbo.Geolocation
SET geolocation_city = LTRIM(RTRIM(geolocation_city)),
    geolocation_state = LTRIM(RTRIM(geolocation_state));
GO