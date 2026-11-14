USE Olist_Staging;
GO

-- 1. STRUCTURAL COMPLETENESS PROFILING (ORDERS & ORDER ITEMS)
-- Identifies registered orders that have zero physical items associated with them.
SELECT COUNT(o.order_id) AS Empty_Orders_Without_Items
FROM dbo.Orders o
LEFT JOIN dbo.OrderItems oi ON o.order_id = oi.order_id
WHERE oi.order_item_id IS NULL;
GO

-- 2. BUSINESS LOGIC & FINANCIAL ANOMALY PROFILING (ORDERS & PAYMENTS)
-- Identifies canceled orders with recorded payments (requires business/refund validation; not automatically an error).
SELECT 
    o.order_status, 
    COUNT(p.order_id) AS Canceled_But_Paid_Orders, 
    SUM(p.payment_value) AS Total_Amount_To_Refund
FROM dbo.Orders o
INNER JOIN dbo.OrderPayments p ON o.order_id = p.order_id
WHERE o.order_status = 'canceled' AND p.payment_value > 0
GROUP BY o.order_status;
GO

-- 3. CROSS-DIMENSIONAL PERFORMANCE PROFILING (ORDERS & REVIEWS)
-- Shows the review-score distribution among late deliveries (descriptive profiling, not a correlation coefficient).
SELECT 
    r.review_score, 
    COUNT(o.order_id) AS Count_Of_Late_Orders
FROM dbo.Orders o
INNER JOIN dbo.OrderReviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date > o.order_estimated_delivery_date
GROUP BY r.review_score
ORDER BY CAST(r.review_score AS INT) ASC;
GO

-- 4. GEOGRAPHICAL PRICING ANOMALY PROFILING (ITEMS, ORDERS, CUSTOMERS, SELLERS)
-- Checks freight values when buyer and seller are in the same state; high values are potential anomalies for investigation.
SELECT 
    c.customer_state AS Local_State, 
    AVG(oi.freight_value) AS Avg_Local_Freight,
    MAX(oi.freight_value) AS Max_Local_Freight,
    COUNT(oi.order_id) AS Total_Local_Transactions
FROM dbo.OrderItems oi
INNER JOIN dbo.Orders o ON oi.order_id = o.order_id
INNER JOIN dbo.Customer c ON o.customer_id = c.customer_id
INNER JOIN dbo.Sellers s ON oi.seller_id = s.seller_id
WHERE c.customer_state = s.seller_state 
GROUP BY c.customer_state
ORDER BY Max_Local_Freight DESC;
GO

-- 5. REFERENTIAL INTEGRITY PROFILING (ORPHAN RECORDS CHECK)
-- Checks for transactional records that point to non-existent dimension records.
SELECT     
    (SELECT COUNT(*) FROM dbo.Orders o LEFT JOIN dbo.Customer c ON o.customer_id = c.customer_id WHERE c.customer_id IS NULL) AS Orphan_Orders_No_Customer,
    (SELECT COUNT(*) FROM dbo.OrderItems oi LEFT JOIN dbo.Products p ON oi.product_id = p.product_id WHERE p.product_id IS NULL) AS Orphan_Items_No_Product,
    (SELECT COUNT(*) FROM dbo.OrderItems oi LEFT JOIN dbo.Sellers s ON oi.seller_id = s.seller_id WHERE s.seller_id IS NULL) AS Orphan_Items_No_Seller;
GO

-- 6. DATA COMPLETENESS MAPPING (PRODUCTS & TRANSLATIONS)
-- Identifies active product categories that lack an English translation in the lookup table.
SELECT 
    p.product_category_name AS Portuguese_Category, 
    COUNT(p.product_id) AS Total_Products_Affected
FROM dbo.Products p
LEFT JOIN dbo.ProductCategoryNameTranslation t ON p.product_category_name = t.product_category_name
WHERE p.product_category_name IS NOT NULL 
  AND p.product_category_name <> ''
  AND t.product_category_name_english IS NULL
GROUP BY p.product_category_name
ORDER BY Total_Products_Affected DESC;
GO

-- 7. ADDITIONAL REFERENTIAL INTEGRITY PROFILING
-- Completes orphan checks for transactional tables that should reference an existing order.
-- Expected result for each count is 0.
SELECT    
    (SELECT COUNT(*) FROM dbo.OrderPayments p
     LEFT JOIN dbo.Orders o ON p.order_id = o.order_id
     WHERE o.order_id IS NULL) AS Orphan_Payments_No_Order,
    (SELECT COUNT(*) FROM dbo.OrderReviews r
     LEFT JOIN dbo.Orders o ON r.order_id = o.order_id
     WHERE o.order_id IS NULL) AS Orphan_Reviews_No_Order,
    (SELECT COUNT(*) FROM dbo.OrderItems oi
     LEFT JOIN dbo.Orders o ON oi.order_id = o.order_id
     WHERE o.order_id IS NULL) AS Orphan_Items_No_Order;
GO