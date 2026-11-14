use Olist_Staging
GO

-- DATA QUALITY & INTEGRITY CHECKS: dbo.Orders

-- 1. Primary Key Integrity: Verify order_id uniqueness
SELECT order_id, COUNT(*) AS Duplicate_Count
FROM dbo.Orders
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

-- 2. String Completeness: Check for blank/empty text values in mandatory column
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(order_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_id)) = '' THEN 1 ELSE 0 END) AS Blank_CustomerID,
    SUM(CASE WHEN LTRIM(RTRIM(order_status)) = '' THEN 1 ELSE 0 END) AS Blank_Status
FROM dbo.Orders;
GO

-- 3. Date Completeness: Count NULL values across milestone timestamp columns
SELECT 
    SUM(CASE WHEN order_purchase_timestamp IS NULL THEN 1 ELSE 0 END) AS Missing_Purchase_Date,
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS Missing_Approval_Date,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS Missing_Carrier_Date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS Missing_Delivery_Date,
    SUM(CASE WHEN order_estimated_delivery_date IS NULL THEN 1 ELSE 0 END) AS Missing_Estimated_Delivery_Date
FROM dbo.Orders;
GO

-- 4. Business Logic Anomaly: Flags 'delivered' orders that lack a delivery date
SELECT COUNT(*) AS Delivered_Status_Missing_Date
FROM dbo.Orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NULL;
GO

-- 5. Chronological Sequence: Detect out-of-order timestamp anomalies
SELECT 
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS Approved_Before_Purchased,
    SUM(CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END) AS Carrier_Before_Approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS Delivered_Before_Carrier,
    SUM(CASE WHEN order_estimated_delivery_date < order_purchase_timestamp THEN 1 ELSE 0 END) AS Estimated_Before_Purchase
FROM dbo.Orders;
GO