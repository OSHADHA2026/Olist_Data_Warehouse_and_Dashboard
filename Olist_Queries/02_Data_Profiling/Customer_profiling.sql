USE Olist_Staging;
GO

-- COMPREHENSIVE DATA PROFILING FOR: [CUSTOMER] TABLE


-- 1. [Volume Profiling]: Check the total number of records in the table
SELECT COUNT(*) AS Total_Customer_Records 
FROM dbo.Customer;
GO


-- 3. [Frequency Profiling]: Check for repeat customers using customer_unique_id
-- (A single real-world customer can have multiple customer_ids if they made multiple purchases)
SELECT customer_unique_id, COUNT(*) AS Purchase_Frequency
FROM dbo.Customer
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY Purchase_Frequency DESC;
GO


-- 8. [Domain & Outlier Profiling]: Identify the minimum and maximum zip codes
SELECT 
    MIN(customer_zip_code_prefix) AS Min_ZipCode, 
    MAX(customer_zip_code_prefix) AS Max_ZipCode
FROM dbo.Customer;
GO


-- 9. [Cardinality Profiling]: Count the distinct number of real entities
SELECT 
    COUNT(DISTINCT customer_unique_id) AS Total_Unique_Real_Customers,
    COUNT(DISTINCT customer_zip_code_prefix) AS Total_Distinct_ZipCodes,
    COUNT(DISTINCT customer_city) AS Total_Distinct_Cities,
    COUNT(DISTINCT customer_state) AS Total_Distinct_States
FROM dbo.Customer;
GO


-- 10. [Categorical Profiling]: Top 10 States with the highest number of customers
SELECT TOP 10 customer_state, COUNT(*) AS Customer_Count
FROM dbo.Customer
GROUP BY customer_state
ORDER BY Customer_Count DESC;
GO


-- 11. [Categorical Profiling]: Top 10 Cities with the highest number of customers
SELECT TOP 10 customer_city, COUNT(*) AS Customer_Count
FROM dbo.Customer
GROUP BY customer_city
ORDER BY Customer_Count DESC;
GO