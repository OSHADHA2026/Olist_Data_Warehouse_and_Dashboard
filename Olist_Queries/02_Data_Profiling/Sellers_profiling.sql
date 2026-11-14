use Olist_Staging
GO
-- COMPREHENSIVE DATA PROFILING FOR STAGING AREA: [SELLERS] TABLE

-- 1. [Volume Profiling]: Total seller records
SELECT COUNT(*) AS Total_Seller_Records FROM dbo.Sellers;
GO

-- 6. [Cardinality Profiling]: Distinct geographical areas
SELECT 
    COUNT(DISTINCT seller_zip_code_prefix) AS Total_Distinct_Seller_Zips,
    COUNT(DISTINCT seller_city) AS Total_Distinct_Seller_Cities,
    COUNT(DISTINCT seller_state) AS Total_Distinct_Seller_States
FROM dbo.Sellers;
GO

-- 7. [Categorical Profiling]: Top 10 States with highest sellers
SELECT TOP 10 seller_state, COUNT(*) AS Total_Sellers
FROM dbo.Sellers
GROUP BY seller_state
ORDER BY Total_Sellers DESC;
GO

-- 8. [Categorical Profiling]: Top 10 Cities with highest sellers
SELECT TOP 10 seller_city, COUNT(*) AS Total_Sellers
FROM dbo.Sellers
GROUP BY seller_city
ORDER BY Total_Sellers DESC;
GO