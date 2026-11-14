USE Olist_Staging;
GO


-- 1. CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN product_category_name IS NULL THEN 1 ELSE 0 END)
        AS missing_product_category_name,
    SUM(CASE WHEN product_category_name_english IS NULL THEN 1 ELSE 0 END)
        AS missing_product_category_name_english
FROM ProductCategoryNameTranslation;



-- 2. CHECK EMPTY / BLANK PORTUGUESE CATEGORY NAMES

SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name IS NULL
   OR LTRIM(RTRIM(product_category_name)) = '';



-- 3. CHECK EMPTY / BLANK ENGLISH CATEGORY NAMES

SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name_english IS NULL
   OR LTRIM(RTRIM(product_category_name_english)) = '';



-- 4. CHECK DUPLICATE PORTUGUESE CATEGORY NAMES

SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(*) > 1;



-- 5. CHECK DUPLICATE ENGLISH CATEGORY NAMES

SELECT
    product_category_name_english,
    COUNT(*) AS duplicate_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name_english
HAVING COUNT(*) > 1;



-- 6. CHECK LEADING / TRAILING SPACES

SELECT *
FROM ProductCategoryNameTranslation
WHERE product_category_name <> LTRIM(RTRIM(product_category_name))
   OR product_category_name_english <> LTRIM(RTRIM(product_category_name_english));



-- 7. CHECK MULTIPLE ENGLISH TRANSLATIONS

SELECT
    product_category_name,
    COUNT(DISTINCT product_category_name_english) AS translation_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(DISTINCT product_category_name_english) > 1;



-- 8. CHECK MULTIPLE PORTUGUESE CATEGORIES

SELECT
    product_category_name_english,
    COUNT(DISTINCT product_category_name) AS category_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name_english
HAVING COUNT(DISTINCT product_category_name) > 1;