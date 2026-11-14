USE Olist_Staging;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [GEOLOCATION] TABLE


-- 1. [Volume Profiling]: Check the total number of records in the table
SELECT COUNT(*) AS Total_Geolocation_Records 
FROM dbo.Geolocation;
GO


-- 8. [Cardinality Profiling]: Count the distinct number of geographical entities
SELECT 
    COUNT(DISTINCT geolocation_zip_code_prefix) AS Total_Distinct_ZipCodes,
    COUNT(DISTINCT geolocation_city) AS Total_Distinct_Cities,
    COUNT(DISTINCT geolocation_state) AS Total_Distinct_States
FROM dbo.Geolocation;
GO


-- 11. [Categorical Profiling]: Top 10 States by number of geolocation points recorded
SELECT TOP 10 geolocation_state, COUNT(*) AS Geo_Point_Count
FROM dbo.Geolocation
GROUP BY geolocation_state
ORDER BY Geo_Point_Count DESC;
GO