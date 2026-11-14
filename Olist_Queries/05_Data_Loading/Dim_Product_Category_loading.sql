USE Olist_DW;
GO

-- 6. Populate Dim_Product_Category
INSERT INTO dbo.Dim_Product_Category (category_name_pt, category_name_en)
SELECT 
    product_category_name,
    product_category_name_english
FROM Olist_Staging.dbo.ProductCategoryNameTranslation;
GO