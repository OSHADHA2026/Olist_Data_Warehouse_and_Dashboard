USE Olist_DW;
GO

-- 9. Populate Fact_Sales
INSERT INTO dbo.Fact_Sales (
    Order_Key,
    Product_Key,
    Seller_Key,
    Customer_Key,
    Purchase_Date_Key,
    Approved_Date_Key,
    Shipped_Date_Key,
    Delivery_Date_Key,
    Estimated_Delivery_Date_Key,
    order_item_id,
    payment_type,
    payment_installments,
    price,
    freight_value,
    total_item_value,
    payment_value,
    review_score
)
SELECT 
    o_key.Order_Key,
    p_key.Product_Key,
    s_key.Seller_Key,
    c_key.Customer_Key,
    CAST(FORMAT(ord.order_purchase_timestamp, 'yyyyMMdd') AS INT) AS Purchase_Date_Key,
    CASE WHEN ord.order_approved_at IS NOT NULL THEN CAST(FORMAT(ord.order_approved_at, 'yyyyMMdd') AS INT) ELSE NULL END,
    CASE WHEN ord.order_delivered_carrier_date IS NOT NULL THEN CAST(FORMAT(ord.order_delivered_carrier_date, 'yyyyMMdd') AS INT) ELSE NULL END,
    CASE WHEN ord.order_delivered_customer_date IS NOT NULL THEN CAST(FORMAT(ord.order_delivered_customer_date, 'yyyyMMdd') AS INT) ELSE NULL END,
    CAST(FORMAT(ord.order_estimated_delivery_date, 'yyyyMMdd') AS INT) AS Estimated_Delivery_Date_Key,
    oi.order_item_id,
    op.payment_type,
    op.payment_installments,
    oi.price,
    oi.freight_value,
    (oi.price + oi.freight_value) AS total_item_value,
    op.payment_value,
    rev.review_score
FROM Olist_Staging.dbo.OrderItems oi
INNER JOIN Olist_Staging.dbo.Orders ord ON oi.order_id = ord.order_id
INNER JOIN dbo.Dim_Order o_key ON ord.order_id = o_key.order_id
INNER JOIN dbo.Dim_Product p_key ON oi.product_id = p_key.product_id
INNER JOIN dbo.Dim_Seller s_key ON oi.seller_id = s_key.seller_id
INNER JOIN dbo.Dim_Customer c_key ON ord.customer_id = c_key.customer_id
LEFT JOIN Olist_Staging.dbo.OrderPayments op ON ord.order_id = op.order_id
LEFT JOIN Olist_Staging.dbo.OrderReviews rev ON ord.order_id = rev.order_id;
GO