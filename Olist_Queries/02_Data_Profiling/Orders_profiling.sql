use Olist_Staging
GO

-- DATA PROFILING SCRIPTS: dbo.Orders

-- 1. Volume: Total record count in the orders table
SELECT COUNT(*) AS Total_Order_Records 
FROM dbo.Orders;
GO

-- 2. Status Breakdown: Order count grouped by current fulfillment status
SELECT order_status, COUNT(*) AS Order_Count
FROM dbo.Orders
GROUP BY order_status
ORDER BY Order_Count DESC;
GO

-- 3. Delivery Latency: Min, max, and avg delivery duration (in days)
SELECT 
    AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Avg_Delivery_Days,
    MAX(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Max_Delivery_Days,
    MIN(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Min_Delivery_Days
FROM dbo.Orders
WHERE order_delivered_customer_date IS NOT NULL;
GO

-- 4. SLA Tracking: Count of orders delivered after estimated date
SELECT COUNT(*) AS Total_Late_Deliveries
FROM dbo.Orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;
GO

-- 5. Cardinality: Count of unique active customer IDs
SELECT COUNT(DISTINCT customer_id) AS Unique_Purchasing_Customers
FROM dbo.Orders;
GO