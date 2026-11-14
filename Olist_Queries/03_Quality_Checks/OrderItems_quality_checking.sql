use Olist_Staging
GO

-- COMPREHENSIVE DATA QUALITY CHECKING FOR STAGING AREA: [ORDERITEMS] TABLE

-- 1. [Uniqueness Profiling]: Check for duplicate composite keys
SELECT order_id, order_item_id, COUNT(*) AS Duplicate_Count
FROM dbo.OrderItems
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
GO

-- 2. [Completeness Profiling]: Check for empty strings, blanks, and NULLs in ID columns
SELECT 
    SUM(CASE WHEN order_id IS NULL OR TRIM(order_id) = '' THEN 1 ELSE 0 END) AS Missing_OrderID,
    SUM(CASE WHEN order_item_id IS NULL OR TRIM(order_item_id) = '' THEN 1 ELSE 0 END) AS Missing_OrderItemID,
    SUM(CASE WHEN product_id IS NULL OR TRIM(product_id) = '' THEN 1 ELSE 0 END) AS Missing_ProductID,
    SUM(CASE WHEN seller_id IS NULL OR TRIM(seller_id) = '' THEN 1 ELSE 0 END) AS Missing_SellerID,
    SUM(CASE WHEN shipping_limit_date IS NULL THEN 1 ELSE 0 END) AS Missing_ShippingDate,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS Missing_Price,
    SUM(CASE WHEN freight_value IS NULL THEN 1 ELSE 0 END) AS Missing_Freight
FROM dbo.OrderItems;
GO

-- 3. [Format & Conversion Profiling]: Validate data type integrity
SELECT 
    SUM(CASE WHEN TRY_CAST(order_item_id AS INT) IS NULL THEN 1 ELSE 0 END) AS Invalid_OrderItemID_Format,
    SUM(CASE WHEN TRY_CAST(shipping_limit_date AS DATETIME2) IS NULL THEN 1 ELSE 0 END) AS Invalid_ShippingDate_Format
FROM dbo.OrderItems;
GO

-- 4. [Domain Profiling]: Check for invalid negative or zero values
SELECT 
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS Invalid_Zero_Negative_Price,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS Invalid_Negative_Freight
FROM dbo.OrderItems;
GO

-- 5. [Pattern & Hash Key Profiling]: Validate 32-character Hash Key lengths
SELECT 
    SUM(CASE WHEN LEN(TRIM(order_id)) <> 32 THEN 1 ELSE 0 END) AS Invalid_OrderID_Length,
    SUM(CASE WHEN LEN(TRIM(product_id)) <> 32 THEN 1 ELSE 0 END) AS Invalid_ProductID_Length,
    SUM(CASE WHEN LEN(TRIM(seller_id)) <> 32 THEN 1 ELSE 0 END) AS Invalid_SellerID_Length
FROM dbo.OrderItems;
GO

-- 6. [Cross-Column Logic Check]: Freight exceeds item price
SELECT 
    SUM(CASE WHEN freight_value > price THEN 1 ELSE 0 END) AS Freight_Exceeds_Price_Count
FROM dbo.OrderItems;
GO

-- 7. [Cross-Table Referential Integrity]: Check for Orphan OrderItems
SELECT 
    COUNT(DISTINCT oi.seller_id) AS Active_Sellers_In_Orders,
    SUM(CASE WHEN s.seller_id IS NULL THEN 1 ELSE 0 END) AS Orphan_OrderItems_Count
FROM dbo.OrderItems oi
LEFT JOIN dbo.Sellers s ON oi.seller_id = s.seller_id;
GO