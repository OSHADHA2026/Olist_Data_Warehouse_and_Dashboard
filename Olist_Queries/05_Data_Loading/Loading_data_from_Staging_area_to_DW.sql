-- STEP 2: DATA MIGRATION & POPULATION (ETL PROCESS)
USE Olist_DW;
GO

-- 1. Populate Dim_Date (2016 to 2018 range for Olist)
DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2018-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Dim_Date WHERE Full_Date = @StartDate)
    BEGIN
        INSERT INTO dbo.Dim_Date (Date_Key, Full_Date, Year, Month, Quarter, Day_Of_Week, Month_Name)
        VALUES (
            CAST(FORMAT(@StartDate, 'yyyyMMdd') AS INT),
            @StartDate,
            YEAR(@StartDate),
            MONTH(@StartDate),
            DATEPART(QUARTER, @StartDate),
            DATENAME(WEEKDAY, @StartDate),
            DATENAME(MONTH, @StartDate)
        );
    END
    SET @StartDate = DATEADD(day, 1, @StartDate);
END
GO

-- 2. Populate Dim_ExchangeRate (from Staging linked with Dim_Date)
INSERT INTO dbo.Dim_ExchangeRate (DateKey, ExchangeDate, BRL_to_USD)
SELECT 
    d.Date_Key,
    s.ExchangeDate,
    s.BRL_to_USD
FROM Olist_Staging.dbo.ExchangeRate s
INNER JOIN dbo.Dim_Date d ON s.ExchangeDate = d.Full_Date;
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

-- 4. Populate Dim_Customer
INSERT INTO dbo.Dim_Customer (customer_id, customer_unique_id, Location_Key)
SELECT 
    c.customer_id,
    c.customer_unique_id,
    COALESCE(l.Location_Key, 1)
FROM Olist_Staging.dbo.Customer c
LEFT JOIN dbo.Dim_Location l ON c.customer_zip_code_prefix = l.zip_code_prefix;
GO

-- 5. Populate Dim_Seller
INSERT INTO dbo.Dim_Seller (seller_id, Location_Key)
SELECT DISTINCT
    s.seller_id,
    COALESCE(l.Location_Key, 1)
FROM Olist_Staging.dbo.Sellers s
LEFT JOIN dbo.Dim_Location l ON s.seller_zip_code_prefix = l.zip_code_prefix;
GO

-- 6. Populate Dim_Product_Category
INSERT INTO dbo.Dim_Product_Category (category_name_pt, category_name_en)
SELECT 
    product_category_name,
    product_category_name_english
FROM Olist_Staging.dbo.ProductCategoryNameTranslation;
GO

-- 7. Populate Dim_Product
INSERT INTO dbo.Dim_Product (product_id, Category_Key, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT 
    p.product_id,
    c.Category_Key,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM Olist_Staging.dbo.Products p
LEFT JOIN Olist_Staging.dbo.ProductCategoryNameTranslation t ON p.product_category_name = t.product_category_name
LEFT JOIN dbo.Dim_Product_Category c ON t.product_category_name_english = c.category_name_en;
GO

-- 8. Populate Dim_Order
INSERT INTO dbo.Dim_Order (order_id, order_status)
SELECT DISTINCT 
    order_id,
    order_status
FROM Olist_Staging.dbo.Orders;
GO

-- 9. Populate Fact_Sales
INSERT INTO dbo.Fact_Sales (
    Order_Key,
    Product_Key,
    Seller_Key,
    Customer_Key,
    Purchase_Date_Key,
    Approved_Date_Key,
    Shipped_Date_Key,
    Delivery_Date_Key,
    Estimated_Delivery_Date_Key,
    order_item_id,
    payment_type,
    payment_installments,
    price,
    freight_value,
    total_item_value,
    payment_value,
    review_score
)
SELECT 
    o_key.Order_Key,
    p_key.Product_Key,
    s_key.Seller_Key,
    c_key.Customer_Key,
    CAST(FORMAT(ord.order_purchase_timestamp, 'yyyyMMdd') AS INT) AS Purchase_Date_Key,
    CASE WHEN ord.order_approved_at IS NOT NULL THEN CAST(FORMAT(ord.order_approved_at, 'yyyyMMdd') AS INT) ELSE NULL END,
    CASE WHEN ord.order_delivered_carrier_date IS NOT NULL THEN CAST(FORMAT(ord.order_delivered_carrier_date, 'yyyyMMdd') AS INT) ELSE NULL END,
    CASE WHEN ord.order_delivered_customer_date IS NOT NULL THEN CAST(FORMAT(ord.order_delivered_customer_date, 'yyyyMMdd') AS INT) ELSE NULL END,
    CAST(FORMAT(ord.order_estimated_delivery_date, 'yyyyMMdd') AS INT) AS Estimated_Delivery_Date_Key,
    oi.order_item_id,
    op.payment_type,
    op.payment_installments,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,
    op.payment_value,
    rev.review_score
FROM Olist_Staging.dbo.OrderItems oi
INNER JOIN Olist_Staging.dbo.Orders ord ON oi.order_id = ord.order_id
INNER JOIN dbo.Dim_Order o_key ON ord.order_id = o_key.order_id
INNER JOIN dbo.Dim_Product p_key ON oi.product_id = p_key.product_id
INNER JOIN dbo.Dim_Seller s_key ON oi.seller_id = s_key.seller_id
INNER JOIN dbo.Dim_Customer c_key ON ord.customer_id = c_key.customer_id
LEFT JOIN Olist_Staging.dbo.OrderPayments op ON ord.order_id = op.order_id
LEFT JOIN Olist_Staging.dbo.OrderReviews rev ON ord.order_id = rev.order_id;
GO