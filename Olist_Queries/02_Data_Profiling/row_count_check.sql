USE Olist_Staging
GO

-- 1. Customers Table
SELECT COUNT(*) AS Customers_row_count FROM Customer;

-- 2. Geolocation Table
SELECT COUNT(*) AS Geolocation_row_count FROM Geolocation;

-- 3. OrderItems Table
SELECT COUNT(*) AS OrderItems_row_count FROM OrderItems;

-- 4. OrderPayments Table
SELECT COUNT(*) AS OrderPayments_row_count FROM OrderPayments;

-- 5. OrderReviews Table
SELECT COUNT(*) AS OrderReviews_row_count FROM OrderReviews;

-- 6. Orders Table
SELECT COUNT(*) AS Orders_row_count FROM Orders;

-- 7. Products Table
SELECT COUNT(*) AS Products_row_count FROM Products;

-- 8. Sellers Table
SELECT COUNT(*) AS Sellers_row_count FROM Sellers;

-- 9. Product Category Name Translation Table
SELECT COUNT(*) AS ProductCategoryNameTranslation_row_count FROM ProductCategoryNameTranslation;