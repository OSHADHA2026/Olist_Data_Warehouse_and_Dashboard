USE Olist_Staging;
GO


-- 1. CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN review_id IS NULL THEN 1 ELSE 0 END) AS missing_review_id,
    SUM(CASE WHEN review_score IS NULL THEN 1 ELSE 0 END) AS missing_review_score,
    SUM(CASE WHEN review_comment_title IS NULL THEN 1 ELSE 0 END) AS missing_review_comment_title,
    SUM(CASE WHEN review_comment_message IS NULL THEN 1 ELSE 0 END) AS missing_review_comment_message,
    SUM(CASE WHEN review_creation_date IS NULL THEN 1 ELSE 0 END) AS missing_review_creation_date,
    SUM(CASE WHEN review_answer_timestamp IS NULL THEN 1 ELSE 0 END) AS missing_review_answer_timestamp
FROM OrderReviews;



-- 2. CHECK INVALID REVIEW SCORES

SELECT *
FROM OrderReviews
WHERE review_score < 1
   OR review_score > 5;



-- 3. CHECK EMPTY / BLANK ORDER IDS

SELECT *
FROM OrderReviews
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';



-- 4. CHECK EMPTY / BLANK REVIEW IDS

SELECT *
FROM OrderReviews
WHERE review_id IS NULL
   OR LTRIM(RTRIM(review_id)) = '';



-- 5. CHECK DUPLICATE REVIEW RECORDS

SELECT
    order_id,
    review_id,
    COUNT(*) AS duplicate_count
FROM OrderReviews
GROUP BY
    order_id,
    review_id
HAVING COUNT(*) > 1;



-- 6. CHECK INVALID REVIEW DATE SEQUENCE

SELECT *
FROM OrderReviews
WHERE review_creation_date > review_answer_timestamp;



-- 7. CHECK REVIEW SCORE DATA TYPE

SELECT
    COLUMN_NAME,
    DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'OrderReviews'
  AND COLUMN_NAME = 'review_score';



-- 8. CHECK REVIEW SCORE RANGE

SELECT
    MIN(review_score) AS minimum_review_score,
    MAX(review_score) AS maximum_review_score,
    AVG(CAST(review_score AS DECIMAL(10,2))) AS average_review_score
FROM OrderReviews;