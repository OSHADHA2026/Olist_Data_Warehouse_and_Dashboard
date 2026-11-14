USE Olist_DW;
GO

-- 3. Populate Dim_Location
INSERT INTO dbo.Dim_Location (zip_code_prefix, city, state, latitude, longitude)
SELECT DISTINCT 
    geolocation_zip_code_prefix,
    MAX(geolocation_city) AS city,
    MAX(geolocation_state) AS state,
    AVG(geolocation_lat) AS latitude,
    AVG(geolocation_lng) AS longitude
FROM Olist_Staging.dbo.Geolocation
GROUP BY geolocation_zip_code_prefix;
GO