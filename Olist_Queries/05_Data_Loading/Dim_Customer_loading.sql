USE Olist_DW;
GO

-- 4. Populate Dim_Customer
INSERT INTO dbo.Dim_Customer (customer_id, customer_unique_id, Location_Key)
SELECT 
    c.customer_id,
    c.customer_unique_id,
    COALESCE(l.Location_Key, 1)
FROM Olist_Staging.dbo.Customer c
LEFT JOIN dbo.Dim_Location l ON c.customer_zip_code_prefix = l.zip_code_prefix;
GO