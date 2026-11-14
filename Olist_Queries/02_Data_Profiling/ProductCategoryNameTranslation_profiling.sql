USE Olist_Staging;
GO


-- 1. CHECK NUMBER OF ROWS IN TABLE

SELECT 'ProductCategoryNameTranslation' AS table_name, COUNT(*) AS row_count
FROM ProductCategoryNameTranslation;



-- 2. CHECK TABLE STRUCTURE AND DATA TYPES

EXEC sp_help 'ProductCategoryNameTranslation';



-- 3. RENAME COLUMNS

--EXEC sp_rename 
--    'ProductCategoryNameTranslation.column1',
--    'product_category_name',
--    'COLUMN';


--EXEC sp_rename 
--    'ProductCategoryNameTranslation.column2',
--    'product_category_name_english',
--    'COLUMN';



-- 4. CHECK FOR DUPLICATES

SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(*) > 1;



-- 5. CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END) AS missing_product_category_name,
    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END) AS missing_product_category_name_english
FROM ProductCategoryNameTranslation;



-- 6. CHECK EMPTY / BLANK VALUES

SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = '';


SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name_english IS NULL
   OR LTRIM(RTRIM(product_category_name_english)) = '';



-- 7. CHECK DATA INCONSISTENCY

SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name <> LTRIM(RTRIM(product_category_name))
   OR product_category_name_english <> LTRIM(RTRIM(product_category_name_english));


SELECT
    product_category_name,
    COUNT(DISTINCT product_category_name_english) AS translation_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(DISTINCT product_category_name_english) > 1;


SELECT
    product_category_name_english,
    COUNT(DISTINCT product_category_name) AS category_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name_english
HAVING COUNT(DISTINCT product_category_name) > 1;