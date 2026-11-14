USE Olist_Staging;
GO

-- DATA CLEANING & TRANSFORMATION: dbo.Orders

-- 1. Date Anomaly Cleanup: Set chronologically invalid timestamps to NULL
UPDATE dbo.Orders
SET order_approved_at = NULL
WHERE order_approved_at < order_purchase_timestamp;

UPDATE dbo.Orders
SET order_delivered_carrier_date = NULL
WHERE order_delivered_carrier_date < order_approved_at;

UPDATE dbo.Orders
SET order_delivered_customer_date = NULL
WHERE order_delivered_customer_date < order_delivered_carrier_date;
GO

-- 2. Text Normalization: Trim whitespace and lowercase status values
UPDATE dbo.Orders
SET
    order_id = LTRIM(RTRIM(order_id)),
    customer_id = LTRIM(RTRIM(customer_id)),
    order_status = LOWER(LTRIM(RTRIM(order_status)));
GO

-- 3. Blank Standardisation: Convert empty string values to NULL
UPDATE dbo.Orders
SET
    order_id = NULLIF(LTRIM(RTRIM(order_id)), ''),
    customer_id = NULLIF(LTRIM(RTRIM(customer_id)), ''),
    order_status = NULLIF(LTRIM(RTRIM(order_status)), '');
GO

-- 4. Post-Transformation Audit: Verify primary keys and string attributes
SELECT
    COUNT(*) AS Total_Orders,
    SUM(CASE WHEN order_id IS NULL THEN 1 ELSE 0 END) AS Missing_Order_ID,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS Missing_Customer_ID,
    SUM(CASE WHEN order_status IS NULL THEN 1 ELSE 0 END) AS Missing_Order_Status
FROM dbo.Orders;
GO

-- 5. Timeline Audit: Confirm resolution of out-of-sequence timestamps
SELECT
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS Approved_Before_Purchased,
    SUM(CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END) AS Carrier_Before_Approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS Delivered_Before_Carrier
FROM dbo.Orders;
GO


-- Check chronological anomalies again.

SELECT
    SUM(CASE
        WHEN order_approved_at < order_purchase_timestamp
        THEN 1 ELSE 0
    END) AS Approved_Before_Purchased,

    SUM(CASE
        WHEN order_delivered_carrier_date < order_approved_at
        THEN 1 ELSE 0
    END) AS Carrier_Before_Approved,

    SUM(CASE
        WHEN order_delivered_customer_date < order_delivered_carrier_date
        THEN 1 ELSE 0
    END) AS Delivered_Before_Carrier

FROM dbo.Orders;
GO