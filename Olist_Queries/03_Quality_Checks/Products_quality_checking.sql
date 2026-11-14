USE Olist_Staging;
GO

-- DATA QUALITY & INTEGRITY CHECKS: dbo.Products

-- 1. Primary Key Integrity: Verify product_id uniqueness
SELECT 
    product_id, 
    COUNT(*) AS Duplicate_Count
FROM dbo.Products
GROUP BY product_id
HAVING COUNT(*) > 1;
GO

-- 2. Text Completeness: Check for blank primary keys and missing categories
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(product_id)) = '' THEN 1 ELSE 0 END) AS Blank_ProductID,
    SUM(CASE WHEN product_category_name IS NULL OR LTRIM(RTRIM(product_category_name)) = '' THEN 1 ELSE 0 END) AS Missing_Category_Name
FROM dbo.Products;
GO

-- 3. Type Validation: Identify non-numeric strings in product_photos_qty column
SELECT 
    product_photos_qty, 
    COUNT(*) AS Occurrences
FROM dbo.Products
WHERE TRY_CONVERT(INT, product_photos_qty) IS NULL 
  AND product_photos_qty IS NOT NULL
GROUP BY product_photos_qty;
GO

-- 4. Physical Boundary Validation: Flag non-positive or NULL weight and dimensions
SELECT 
    SUM(CASE WHEN product_weight_g <= 0 THEN 1 ELSE 0 END) AS Invalid_Weight,
    SUM(CASE WHEN product_length_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Length,
    SUM(CASE WHEN product_height_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Height,
    SUM(CASE WHEN product_width_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Width,
    SUM(CASE WHEN product_weight_g IS NULL THEN 1 ELSE 0 END) AS Missing_Weight,
    SUM(CASE WHEN product_length_cm IS NULL THEN 1 ELSE 0 END) AS Missing_Length,
    SUM(CASE WHEN product_height_cm IS NULL THEN 1 ELSE 0 END) AS Missing_Height,
    SUM(CASE WHEN product_width_cm IS NULL THEN 1 ELSE 0 END) AS Missing_Width
FROM dbo.Products;
GO

-- 5. Content Completeness: Count NULL values across product metadata fields
SELECT 
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS Missing_Name_Length,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS Missing_Description_Length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS Missing_Photos_Qty
FROM dbo.Products;
GO