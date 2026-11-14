USE Olist_Staging;
GO


-- 1. CHECK MISSING VALUES

SELECT
    COUNT(*) AS total_rows,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS missing_order_id,
    SUM(CASE WHEN payment_sequential IS NULL THEN 1 ELSE 0 END) AS missing_payment_sequential,
    SUM(CASE WHEN payment_type IS NULL THEN 1 ELSE 0 END) AS missing_payment_type,
    SUM(CASE WHEN payment_installments IS NULL THEN 1 ELSE 0 END) AS missing_payment_installments,
    SUM(CASE WHEN payment_value IS NULL THEN 1 ELSE 0 END) AS missing_payment_value
FROM OrderPayments;



-- 2. CHECK NEGATIVE PAYMENT VALUES

SELECT *
FROM OrderPayments
WHERE payment_value < 0;



-- 3. CHECK INVALID PAYMENT INSTALLMENTS

SELECT *
FROM OrderPayments
WHERE payment_installments <= 0;



-- 4. CHECK INVALID PAYMENT SEQUENTIAL NUMBERS

SELECT *
FROM OrderPayments
WHERE payment_sequential <= 0;



-- 5. CHECK EMPTY / BLANK ORDER IDS

SELECT *
FROM OrderPayments
WHERE order_id IS NULL
   OR LTRIM(RTRIM(order_id)) = '';



-- 6. CHECK EMPTY / BLANK PAYMENT TYPES

SELECT *
FROM OrderPayments
WHERE payment_type IS NULL
   OR LTRIM(RTRIM(payment_type)) = '';



-- 7. CHECK NOT_DEFINED PAYMENT TYPES

SELECT *
FROM OrderPayments
WHERE payment_type = 'not_defined';



-- 8. CHECK PAYMENT TYPE VALUES

SELECT
    payment_type,
    COUNT(*) AS record_count
FROM OrderPayments
GROUP BY payment_type
ORDER BY record_count DESC;



-- 9. CHECK EXACT DUPLICATE PAYMENT RECORDS

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



-- 10. CHECK PAYMENT VALUE RANGE

SELECT
    MIN(payment_value) AS minimum_payment_value,
    MAX(payment_value) AS maximum_payment_value,
    AVG(payment_value) AS average_payment_value
FROM OrderPayments;



-- 11. CHECK PAYMENT INSTALLMENTS RANGE

SELECT
    MIN(payment_installments) AS minimum_installments,
    MAX(payment_installments) AS maximum_installments
FROM OrderPayments;



-- 12. CHECK PAYMENT SEQUENTIAL RANGE

SELECT
    MIN(payment_sequential) AS minimum_sequential,
    MAX(payment_sequential) AS maximum_sequential
FROM OrderPayments;