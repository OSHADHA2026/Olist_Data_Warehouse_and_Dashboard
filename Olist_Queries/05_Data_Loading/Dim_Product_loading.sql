USE Olist_DW;
GO

-- 7. Populate Dim_Product
INSERT INTO dbo.Dim_Product (product_id, Category_Key, product_weight_g, product_length_cm, product_height_cm, product_width_cm)
SELECT 
    p.product_id,
    c.Category_Key,
    p.product_weight_g,
    p.product_length_cm,
    p.product_height_cm,
    p.product_width_cm
FROM Olist_Staging.dbo.Products p
LEFT JOIN Olist_Staging.dbo.ProductCategoryNameTranslation t ON p.product_category_name = t.product_category_name
LEFT JOIN dbo.Dim_Product_Category c ON t.product_category_name_english = c.category_name_en;
GO