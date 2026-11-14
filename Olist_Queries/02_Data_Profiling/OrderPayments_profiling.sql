USE Olist_Staging;
GO


-- 1. CHECK NUMBER OF ROWS IN TABLE

SELECT 'OrderPayments' AS table_name, COUNT(*) AS row_count
FROM OrderPayments;



-- 2. CHECK TABLE STRUCTURE AND DATA TYPES

EXEC sp_help 'OrderPayments';



-- 3. CHECK FOR DUPLICATES

SELECT
    order_id,
    payment_value,
    payment_type,
    payment_installments,
    payment_sequential,
    COUNT(*) AS duplicate_count
FROM OrderPayments
GROUP BY
    order_id,
    payment_value,
    payment_type,
    payment_installments,
    payment_sequential
HAVING COUNT(*) > 1;



-- 4. CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS missing_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS missing_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS missing_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS missing_payment_value
FROM OrderPayments;



-- 5. CHECK EMPTY / BLANK VALUES

SELECT *
FROM OrderPayments
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';


SELECT *
FROM OrderPayments
WHERE payment_type IS NULL
   OR LTRIM(RTRIM(payment_type)) = '';



-- 6. CHECK INVALID VALUES

SELECT *
FROM OrderPayments
WHERE payment_value < 0;


SELECT *
FROM OrderPayments
WHERE payment_installments <= 0;


SELECT *
FROM OrderPayments
WHERE payment_sequential <= 0;


-- 7. CHECK PAYMENT TYPE VALUES

SELECT
    payment_type,
    COUNT(*) AS record_count
FROM OrderPayments
GROUP BY payment_type
ORDER BY record_count DESC;



-- 8. CHECK NUMERIC DATA RANGES

SELECT
    MIN(payment_value) AS minimum_payment_value,
    MAX(payment_value) AS maximum_payment_value,
    AVG(payment_value) AS average_payment_value
FROM OrderPayments;


SELECT
    MIN(payment_installments) AS minimum_installments,
    MAX(payment_installments) AS maximum_installments
FROM OrderPayments;


SELECT
    MIN(payment_sequential) AS minimum_sequential,
    MAX(payment_sequential) AS maximum_sequential
FROM OrderPayments;


-- 9. CHECK REFERENTIAL INTEGRITY / ORPHAN RECORDS

SELECT
    p.order_id
FROM OrderPayments p
LEFT JOIN Orders o
    ON p.order_id = o.order_id
WHERE o.order_id IS NULL;


-- 10. CHECK PAYMENT RECORDS PER ORDER

SELECT
    order_id,
    COUNT(*) AS payment_count
FROM OrderPayments
GROUP BY order_id
HAVING COUNT(*) > 1
ORDER BY payment_count DESC;