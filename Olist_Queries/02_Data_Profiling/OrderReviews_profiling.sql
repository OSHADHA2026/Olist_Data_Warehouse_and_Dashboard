USE Olist_Staging;
GO


-- 1. CHECK NUMBER OF ROWS IN TABLE

SELECT 'OrderReviews' AS table_name, COUNT(*) AS row_count
FROM OrderReviews;



-- 2. CHECK TABLE STRUCTURE AND DATA TYPES

EXEC sp_help 'OrderReviews';



-- 3. CHECK FOR DUPLICATES

SELECT
    review_id,
    COUNT(*) AS duplicate_count
FROM OrderReviews
GROUP BY review_id
HAVING COUNT(*) > 1;


SELECT
    order_id,
    review_id,
    COUNT(*) AS duplicate_count
FROM OrderReviews
GROUP BY
    order_id,
    review_id
HAVING COUNT(*) > 1;



-- 4. CHECK MISSING VALUES

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



-- 5. CHECK EMPTY / BLANK VALUES

SELECT *
FROM OrderReviews
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';


SELECT *
FROM OrderReviews
WHERE review_id IS NULL
   OR LTRIM(RTRIM(review_id)) = '';


SELECT *
FROM OrderReviews
WHERE review_comment_title = ''
   OR review_comment_message = '';



-- 6. CHECK INVALID VALUES

SELECT *
FROM OrderReviews
WHERE review_score < 1
   OR review_score > 5;



-- 7. CHECK NUMERIC DATA RANGES

ALTER TABLE OrderReviews
ALTER COLUMN review_score INT;


SELECT
    MIN(review_score) AS minimum_review_score,
    MAX(review_score) AS maximum_review_score,
    AVG(review_score) AS average_review_score
FROM OrderReviews;



-- 8. CHECK DATE VALIDITY

SELECT *
FROM OrderReviews
WHERE review_creation_date > review_answer_timestamp;


SELECT
    MIN(review_creation_date) AS earliest_review_date,
    MAX(review_creation_date) AS latest_review_date
FROM OrderReviews;


SELECT
    MIN(review_answer_timestamp) AS earliest_answer_timestamp,
    MAX(review_answer_timestamp) AS latest_answer_timestamp
FROM OrderReviews;



-- 9. CHECK REFERENTIAL INTEGRITY / ORPHAN RECORDS

SELECT
    r.order_id
FROM OrderReviews r
LEFT JOIN Orders o
    ON r.order_id = o.order_id
WHERE o.order_id IS NULL;



-- 10. CHECK REVIEW RECORDS PER ORDER

SELECT
    order_id,
    COUNT(*) AS review_count
FROM OrderReviews
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY review_count DESC;