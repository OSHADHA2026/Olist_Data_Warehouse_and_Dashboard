USE Olist_Staging;
GO

-- ORDER PAYMENTS - DATA CLEANING

-- Remove leading/trailing spaces
UPDATE OrderPayments
SET
    order_id = LTRIM(RTRIM(order_id)),
    payment_type = LTRIM(RTRIM(payment_type));


-- Convert empty strings to NULL
UPDATE OrderPayments
SET order_id = NULL
WHERE order_id = '';

UPDATE OrderPayments
SET payment_type = NULL
WHERE payment_type = '';


-- Standardize payment type
-- "not_defined" is converted to "Unknown"
UPDATE OrderPayments
SET payment_type = 'Unknown'
WHERE payment_type = 'not_defined';


-- Standardize invalid payment values
-- Negative payment values are not valid
UPDATE OrderPayments
SET payment_value = NULL
WHERE payment_value < 0;


-- Standardize invalid payment installment values
-- 0 is not a valid installment count
-- The payment record is retained because other attributes are useful
UPDATE OrderPayments
SET payment_installments = NULL
WHERE payment_installments <= 0;


-- Standardize invalid payment sequential values
-- Sequential number should be greater than 0
UPDATE OrderPayments
SET payment_sequential = NULL
WHERE payment_sequential <= 0;


-- Check duplicate payment records
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