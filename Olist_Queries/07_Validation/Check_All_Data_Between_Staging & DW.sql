USE Olist_DW;
GO

-- 1. Check Missing Customers (Orders in Staging missing in Dim_Customer)
SELECT 
    COUNT(DISTINCT o.customer_id) AS Missing_Customers_Count
FROM Olist_Staging.dbo.Orders o
LEFT JOIN dbo.Dim_Customer c 
    ON TRIM(o.customer_id) = c.customer_id
WHERE c.Customer_Key IS NULL;
GO

-- 2. Check Missing Sellers (OrderItems in Staging missing in Dim_Seller)
SELECT 
    COUNT(DISTINCT oi.seller_id) AS Missing_Sellers_Count
FROM Olist_Staging.dbo.OrderItems oi
LEFT JOIN dbo.Dim_Seller s 
    ON TRIM(oi.seller_id) = s.seller_id
WHERE s.Seller_Key IS NULL;
GO

-- 3. Check Missing Products (OrderItems in Staging missing in Dim_Product)
SELECT 
    COUNT(DISTINCT oi.product_id) AS Missing_Products_Count
FROM Olist_Staging.dbo.OrderItems oi
LEFT JOIN dbo.Dim_Product p 
    ON TRIM(oi.product_id) = p.product_id
WHERE p.Product_Key IS NULL;
GO

-- 4. Check Missing Product Categories (Products in Staging missing in Dim_Product_Category)
SELECT 
    COUNT(DISTINCT p.product_category_name) AS Missing_Categories_Count
FROM Olist_Staging.dbo.Products p
LEFT JOIN dbo.Dim_Product_Category pc 
    ON TRIM(p.product_category_name) = pc.category_name_pt
WHERE p.product_category_name IS NOT NULL 
  AND pc.Category_Key IS NULL;
GO

-- 5. Check Missing Locations from Customers (Customers in Staging missing in Dim_Location)
SELECT 
    COUNT(DISTINCT c.customer_zip_code_prefix) AS Missing_Customer_Locations_Count
FROM Olist_Staging.dbo.Customer c
LEFT JOIN dbo.Dim_Location l 
    ON c.customer_zip_code_prefix = l.zip_code_prefix
WHERE l.Location_Key IS NULL;
GO

-- 6. Check Missing Locations from Sellers (Sellers in Staging missing in Dim_Location)
SELECT 
    COUNT(DISTINCT s.seller_zip_code_prefix) AS Missing_Seller_Locations_Count
FROM Olist_Staging.dbo.Sellers s
LEFT JOIN dbo.Dim_Location l 
    ON s.seller_zip_code_prefix = l.zip_code_prefix
WHERE l.Location_Key IS NULL;
GO