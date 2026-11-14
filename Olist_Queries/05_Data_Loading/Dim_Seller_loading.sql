USE Olist_DW;
GO

-- 5. Populate Dim_Seller
INSERT INTO dbo.Dim_Seller (seller_id, Location_Key)
SELECT DISTINCT
    s.seller_id,
    COALESCE(l.Location_Key, 1)
FROM Olist_Staging.dbo.Sellers s
LEFT JOIN dbo.Dim_Location l ON s.seller_zip_code_prefix = l.zip_code_prefix;
GO