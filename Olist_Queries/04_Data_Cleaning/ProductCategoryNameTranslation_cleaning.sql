USE Olist_Staging;
GO

-- 3. PRODUCT CATEGORY NAME TRANSLATION

-- Remove leading/trailing spaces
UPDATE ProductCategoryNameTranslation
SET
    product_category_name = LTRIM(RTRIM(product_category_name)),
    product_category_name_english = LTRIM(RTRIM(product_category_name_english));


-- Convert empty strings to NULL
UPDATE ProductCategoryNameTranslation
SET product_category_name = NULL
WHERE product_category_name = '';

UPDATE ProductCategoryNameTranslation
SET product_category_name_english = NULL
WHERE product_category_name_english = '';


-- Check duplicate Portuguese category names
SELECT
    product_category_name,
    COUNT(*) AS duplicate_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(*) > 1;


-- Check whether one Portuguese category has
-- multiple English translations
SELECT
    product_category_name,
    COUNT(DISTINCT product_category_name_english) AS translation_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(DISTINCT product_category_name_english) > 1;


-- Check whether one English category has
-- multiple Portuguese categories
SELECT
    product_category_name_english,
    COUNT(DISTINCT product_category_name) AS category_count
FROM ProductCategoryNameTranslation
GROUP BY product_category_name_english
HAVING COUNT(DISTINCT product_category_name) > 1;
