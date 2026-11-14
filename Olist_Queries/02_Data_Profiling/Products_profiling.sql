USE Olist_Staging;
GO

-- DATA PROFILING SCRIPTS: dbo.Products

-- 1. Volume: Total record count in the products table
SELECT COUNT(*) AS Total_Product_Records 
FROM dbo.Products;
GO

-- 2. Physical Dimensions: Summary statistics for product weight and dimensions
SELECT 
    MIN(product_weight_g) AS Min_Weight_g, 
    MAX(product_weight_g) AS Max_Weight_g, 
    AVG(product_weight_g) AS Avg_Weight_g,
    MIN(product_length_cm) AS Min_Length_cm, 
    MAX(product_length_cm) AS Max_Length_cm
FROM dbo.Products;
GO

-- 3. Category Breadth: Top 10 categories by distinct product counts
SELECT TOP 10 
    product_category_name, 
    COUNT(*) AS Total_Products_In_Category
FROM dbo.Products
GROUP BY product_category_name
ORDER BY Total_Products_In_Category DESC;
GO