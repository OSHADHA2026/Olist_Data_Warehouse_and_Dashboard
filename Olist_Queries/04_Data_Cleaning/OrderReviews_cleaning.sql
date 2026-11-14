USE Olist_Staging;
GO

-- ORDER REVIEWS - DATA CLEANING

-- Remove leading/trailing spaces
UPDATE OrderReviews
SET
    order_id = LTRIM(RTRIM(order_id)),
    review_id = LTRIM(RTRIM(review_id));


-- Convert empty strings to NULL
UPDATE OrderReviews
SET order_id = NULL
WHERE order_id = '';

UPDATE OrderReviews
SET review_id = NULL
WHERE review_id = '';


-- Standardize invalid review scores to NULL
-- Valid review scores are between 1 and 5
UPDATE OrderReviews
SET review_score = NULL
WHERE review_score < 1 OR review_score > 5;


-- Convert blank review comments to NULL
-- Comments are optional fields
UPDATE OrderReviews
SET review_comment_title = NULL
WHERE LTRIM(RTRIM(review_comment_title)) = '';

UPDATE OrderReviews
SET review_comment_message = NULL
WHERE LTRIM(RTRIM(review_comment_message)) = '';


-- Remove leading/trailing spaces from review comments
UPDATE OrderReviews
SET
    review_comment_title = LTRIM(RTRIM(review_comment_title)),
    review_comment_message = LTRIM(RTRIM(review_comment_message));


-- Check duplicate review records
SELECT
    order_id,
    review_id,
    COUNT(*) AS duplicate_count
FROM OrderReviews
GROUP BY order_id, review_id
HAVING COUNT(*) > 1;