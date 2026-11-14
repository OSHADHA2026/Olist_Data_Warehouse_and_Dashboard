use Olist_Staging
GO

-- COMPREHENSIVE DATA PROFILING FOR STAGING AREA: [ORDERITEMS] TABLE

-- 1. [Volume Profiling]: Total number of records
SELECT COUNT(*) AS Total_OrderItems_Records FROM dbo.OrderItems;
GO

-- 2. [Statistical Profiling]: Price and Freight Value distribution + StdDev
SELECT 
    MIN(price) AS Min_Price, 
    MAX(price) AS Max_Price, 
    AVG(price) AS Avg_Price,
    STDEV(price) AS Price_StdDev,
    MIN(freight_value) AS Min_Freight, 
    MAX(freight_value) AS Max_Freight, 
    AVG(freight_value) AS Avg_Freight,
    STDEV(freight_value) AS Freight_StdDev
FROM dbo.OrderItems;
GO

-- 3. [Temporal Profiling]: Analyze shipping limit dates range
SELECT 
    MIN(shipping_limit_date) AS Earliest_Shipping_Date, 
    MAX(shipping_limit_date) AS Latest_Shipping_Date
FROM dbo.OrderItems;
GO

-- 4. [Cardinality Profiling]: Count distinct entities
SELECT 
    COUNT(DISTINCT order_id) AS Total_Unique_Orders,
    COUNT(DISTINCT product_id) AS Total_Unique_Products_Sold,
    COUNT(DISTINCT seller_id) AS Total_Unique_Active_Sellers
FROM dbo.OrderItems;
GO

-- 5. [Frequency Profiling]: Max items purchased in a single order
SELECT TOP 5 order_id, COUNT(product_id) AS Items_Per_Order
FROM dbo.OrderItems
GROUP BY order_id
ORDER BY Items_Per_Order DESC;
GO

-- 6. [Categorical Profiling]: Top 10 most sold products
SELECT TOP 10 product_id, COUNT(*) AS Total_Quantity_Sold
FROM dbo.OrderItems
GROUP BY product_id
ORDER BY Total_Quantity_Sold DESC;
GO

-- 7. [Categorical Profiling]: Top 10 sellers by order volume
SELECT TOP 10 seller_id, COUNT(order_id) AS Total_Orders_Fulfilled
FROM dbo.OrderItems
GROUP BY seller_id
ORDER BY Total_Orders_Fulfilled DESC;
GO