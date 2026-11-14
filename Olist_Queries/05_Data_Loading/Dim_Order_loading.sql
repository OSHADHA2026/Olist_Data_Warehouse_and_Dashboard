USE Olist_DW;
GO

-- 8. Populate Dim_Order
INSERT INTO dbo.Dim_Order (order_id, order_status)
SELECT DISTINCT 
    order_id,
    order_status
FROM Olist_Staging.dbo.Orders;
GO