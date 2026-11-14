USE Olist_Staging;
GO

-- DATA CLEANING & TRANSFORMATION: dbo.Products

-- 1. Text Normalization: Trim whitespace from product ID and category
UPDATE dbo.Products
SET
    product_id = LTRIM(RTRIM(product_id)),
    product_category_name = LTRIM(RTRIM(product_category_name));
GO

-- 2. Category Imputation: Replace NULL or blank categories with 'Unknown'
UPDATE dbo.Products
SET product_category_name = 'Unknown'
WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = '';
GO

-- 3. Type Cleaning: Nullify non-integer values in product_photos_qty
UPDATE dbo.Products
SET product_photos_qty = NULL
WHERE product_photos_qty IS NOT NULL
  AND TRY_CONVERT(INT, product_photos_qty) IS NULL;
GO

-- 4. Physical Boundaries: Nullify non-positive weights and dimensions
UPDATE dbo.Products
SET product_weight_g = NULL
WHERE product_weight_g <= 0;

UPDATE dbo.Products
SET product_length_cm = NULL
WHERE product_length_cm <= 0;

UPDATE dbo.Products
SET product_height_cm = NULL
WHERE product_height_cm <= 0;

UPDATE dbo.Products
SET product_width_cm = NULL
WHERE product_width_cm <= 0;
GO

-- 5. Post-Transformation Audit: Verify primary keys, categories, and physical attributes
SELECT
    COUNT(*) AS Total_Products,
    SUM(CASE WHEN product_id IS NULL OR LTRIM(RTRIM(product_id)) = '' THEN 1 ELSE 0 END) AS Missing_Product_ID,
    SUM(CASE WHEN product_category_name IS NULL OR LTRIM(RTRIM(product_category_name)) = '' THEN 1 ELSE 0 END) AS Missing_Product_Category,
    SUM(CASE WHEN product_photos_qty IS NOT NULL AND TRY_CONVERT(INT, product_photos_qty) IS NULL THEN 1 ELSE 0 END) AS Invalid_Photos_Qty,
    SUM(CASE WHEN product_weight_g <= 0 THEN 1 ELSE 0 END) AS Invalid_Weight,
    SUM(CASE WHEN product_length_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Length,
    SUM(CASE WHEN product_height_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Height,
    SUM(CASE WHEN product_width_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Width
FROM dbo.Products;
GO

-- 6. Orders Timeline Audit: Verify order sequence anomalies after cleanup
SELECT 
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS Approved_Before_Purchased,
    SUM(CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END) AS Carrier_Before_Approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS Delivered_Before_Carrier 
FROM dbo.Orders;
GO