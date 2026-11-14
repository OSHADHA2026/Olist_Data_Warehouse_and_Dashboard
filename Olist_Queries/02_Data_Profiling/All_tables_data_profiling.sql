USE Olist_Staging;
GO

-- COMPREHENSIVE DATA PROFILING FOR: [CUSTOMER] TABLE

-- 1. [Volume Profiling]: Check the total number of records in the table
SELECT COUNT(*) AS Total_Customer_Records 
FROM dbo.Customer;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate customer_id 
-- (customer_id should be 100% unique as it acts as the primary key per order)
SELECT customer_id, COUNT(*) AS Duplicate_Count
FROM dbo.Customer
GROUP BY customer_id
HAVING COUNT(*) > 1;
GO

-- 3. [Frequency Profiling]: Check for repeat customers using customer_unique_id
-- (A single real-world customer can have multiple customer_ids if they made multiple purchases)
SELECT customer_unique_id, COUNT(*) AS Purchase_Frequency
FROM dbo.Customer
GROUP BY customer_unique_id
HAVING COUNT(*) > 1
ORDER BY Purchase_Frequency DESC;
GO

-- 4. [Completeness Profiling]: Check for hidden empty strings or spaces in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(customer_id)) = '' THEN 1 ELSE 0 END) AS Blank_CustomerID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_unique_id)) = '' THEN 1 ELSE 0 END) AS Blank_UniqueID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_city)) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM(customer_state)) = '' THEN 1 ELSE 0 END) AS Blank_State
FROM dbo.Customer;
GO

-- 5. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT customer_state, LEN(LTRIM(RTRIM(customer_state))) AS State_Length
FROM dbo.Customer
WHERE LEN(LTRIM(RTRIM(customer_state))) <> 2;
GO

-- 6. [Length Constraint Profiling]: Check Minimum and Maximum lengths of ID columns
-- (Olist IDs are typically 32-character MD5 hashes. Deviations imply bad data)
SELECT 
    MIN(LEN(customer_id)) AS Min_ID_Length, 
    MAX(LEN(customer_id)) AS Max_ID_Length,
    MIN(LEN(customer_unique_id)) AS Min_UniqueID_Length, 
    MAX(LEN(customer_unique_id)) AS Max_UniqueID_Length
FROM dbo.Customer;
GO

-- 7. [Domain & Range Profiling]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Customer
WHERE customer_zip_code_prefix <= 0;
GO

-- 8. [Domain & Outlier Profiling]: Identify the minimum and maximum zip codes
SELECT 
    MIN(customer_zip_code_prefix) AS Min_ZipCode, 
    MAX(customer_zip_code_prefix) AS Max_ZipCode
FROM dbo.Customer;
GO

-- 9. [Cardinality Profiling]: Count the distinct number of real entities
SELECT 
    COUNT(DISTINCT customer_unique_id) AS Total_Unique_Real_Customers,
    COUNT(DISTINCT customer_zip_code_prefix) AS Total_Distinct_ZipCodes,
    COUNT(DISTINCT customer_city) AS Total_Distinct_Cities,
    COUNT(DISTINCT customer_state) AS Total_Distinct_States
FROM dbo.Customer;
GO

-- 10. [Categorical Profiling]: Top 10 States with the highest number of customers
SELECT TOP 10 customer_state, COUNT(*) AS Customer_Count
FROM dbo.Customer
GROUP BY customer_state
ORDER BY Customer_Count DESC;
GO

-- 11. [Categorical Profiling]: Top 10 Cities with the highest number of customers
SELECT TOP 10 customer_city, COUNT(*) AS Customer_Count
FROM dbo.Customer
GROUP BY customer_city
ORDER BY Customer_Count DESC;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [GEOLOCATION] TABLE

-- 1. [Volume Profiling]: Check the total number of records in the table
SELECT COUNT(*) AS Total_Geolocation_Records 
FROM dbo.Geolocation;
GO

-- 2. [Exact Duplicate Profiling]: Check for completely identical rows
-- (Multiple identical coordinates for the same zip, city, and state)
SELECT 
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state, 
    COUNT(*) AS Duplicate_Count
FROM dbo.Geolocation
GROUP BY 
    geolocation_zip_code_prefix, 
    geolocation_lat, 
    geolocation_lng, 
    geolocation_city, 
    geolocation_state
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(geolocation_city)) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM(geolocation_state)) = '' THEN 1 ELSE 0 END) AS Blank_State
FROM dbo.Geolocation;
GO

-- 4. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT geolocation_state, LEN(LTRIM(RTRIM(geolocation_state))) AS State_Length
FROM dbo.Geolocation
WHERE LEN(LTRIM(RTRIM(geolocation_state))) <> 2;
GO

-- 5. [Domain Profiling - Numeric]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Geolocation
WHERE geolocation_zip_code_prefix <= 0;
GO

-- 6. [Domain Profiling - Geospatial Global]: Validate Latitude & Longitude standard bounds
-- (Latitude must be between -90 and 90. Longitude must be between -180 and 180)
SELECT 
    SUM(CASE WHEN geolocation_lat < -90 OR geolocation_lat > 90 THEN 1 ELSE 0 END) AS Invalid_Latitude,
    SUM(CASE WHEN geolocation_lng < -180 OR geolocation_lng > 180 THEN 1 ELSE 0 END) AS Invalid_Longitude
FROM dbo.Geolocation;
GO

-- 7. [Outlier Profiling - Geospatial Brazil]: Identify coordinates outside Brazil's bounding box
-- (Brazil bounds roughly - Lat: 5.0 to -33.0, Lng: -34.0 to -74.0)
SELECT COUNT(*) AS Coordinates_Outside_Brazil
FROM dbo.Geolocation
WHERE geolocation_lat > 5.0 OR geolocation_lat < -33.0
   OR geolocation_lng > -34.0 OR geolocation_lng < -74.0;
GO

-- 8. [Cardinality Profiling]: Count the distinct number of geographical entities
SELECT 
    COUNT(DISTINCT geolocation_zip_code_prefix) AS Total_Distinct_ZipCodes,
    COUNT(DISTINCT geolocation_city) AS Total_Distinct_Cities,
    COUNT(DISTINCT geolocation_state) AS Total_Distinct_States
FROM dbo.Geolocation;
GO

-- 9. [Consistency Profiling - Anomaly 1]: One Zip Code mapped to multiple distinct Cities
-- (Identifies spelling mistakes or overlapping postal regions)
SELECT geolocation_zip_code_prefix, COUNT(DISTINCT geolocation_city) AS Unique_City_Count
FROM dbo.Geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_city) > 1
ORDER BY Unique_City_Count DESC;
GO

-- 10. [Consistency Profiling - Anomaly 2]: One Zip Code mapped to multiple distinct States
-- (This should be logically impossible and indicates severe data entry errors)
SELECT geolocation_zip_code_prefix, COUNT(DISTINCT geolocation_state) AS Unique_State_Count
FROM dbo.Geolocation
GROUP BY geolocation_zip_code_prefix
HAVING COUNT(DISTINCT geolocation_state) > 1
ORDER BY Unique_State_Count DESC;
GO

-- 11. [Categorical Profiling]: Top 10 States by number of geolocation points recorded
SELECT TOP 10 geolocation_state, COUNT(*) AS Geo_Point_Count
FROM dbo.Geolocation
GROUP BY geolocation_state
ORDER BY Geo_Point_Count DESC;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [ORDERITEMS] TABLE

-- 1. [Volume Profiling]: Check the total number of records in the table
SELECT COUNT(*) AS Total_OrderItems_Records 
FROM dbo.OrderItems;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate composite keys
-- (A single order can have multiple items, so order_id + order_item_id must be completely unique)
SELECT order_id, order_item_id, COUNT(*) AS Duplicate_Count
FROM dbo.OrderItems
GROUP BY order_id, order_item_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in ID columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(order_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderID,
    SUM(CASE WHEN LTRIM(RTRIM(order_item_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderItemID,
    SUM(CASE WHEN LTRIM(RTRIM(product_id)) = '' THEN 1 ELSE 0 END) AS Blank_ProductID,
    SUM(CASE WHEN LTRIM(RTRIM(seller_id)) = '' THEN 1 ELSE 0 END) AS Blank_SellerID
FROM dbo.OrderItems;
GO

-- 4. [Format Profiling]: Validate data type consistency for order_item_id
-- (Since order_item_id is stored as nvarchar, check if it contains any non-numeric text)
SELECT order_item_id, COUNT(*) AS Occurrences
FROM dbo.OrderItems
WHERE ISNUMERIC(order_item_id) = 0
GROUP BY order_item_id;
GO

-- 5. [Domain & Outlier Profiling - Numeric]: Check for invalid negative or zero values
-- (Price and Freight Value should logically be greater than 0)
SELECT 
    SUM(CASE WHEN price <= 0 THEN 1 ELSE 0 END) AS Invalid_Zero_Negative_Price,
    SUM(CASE WHEN freight_value < 0 THEN 1 ELSE 0 END) AS Invalid_Negative_Freight
FROM dbo.OrderItems;
GO

-- 6. [Statistical Profiling]: Overview of Price and Freight Value distribution
-- (Helps identify massive outliers, e.g., a product priced at a million dollars)
SELECT 
    MIN(price) AS Min_Price, 
    MAX(price) AS Max_Price, 
    AVG(price) AS Avg_Price,
    MIN(freight_value) AS Min_Freight, 
    MAX(freight_value) AS Max_Freight, 
    AVG(freight_value) AS Avg_Freight
FROM dbo.OrderItems;
GO

-- 7. [Temporal / Range Profiling]: Analyze the range of shipping limit dates
-- (Ensures no unrealistic dates exist, e.g., year 1900 or 2050)
SELECT 
    MIN(shipping_limit_date) AS Earliest_Shipping_Date, 
    MAX(shipping_limit_date) AS Latest_Shipping_Date
FROM dbo.OrderItems;
GO

-- 8. [Cardinality Profiling]: Count distinct entities in the transactions
SELECT 
    COUNT(DISTINCT order_id) AS Total_Unique_Orders,
    COUNT(DISTINCT product_id) AS Total_Unique_Products_Sold,
    COUNT(DISTINCT seller_id) AS Total_Unique_Active_Sellers
FROM dbo.OrderItems;
GO

-- 9. [Frequency Profiling]: Find the maximum number of items purchased in a single order
SELECT TOP 5 order_id, COUNT(product_id) AS Items_Per_Order
FROM dbo.OrderItems
GROUP BY order_id
ORDER BY Items_Per_Order DESC;
GO

-- 10. [Categorical Profiling - Best Sellers]: Top 10 most frequently sold products
SELECT TOP 10 product_id, COUNT(*) AS Total_Quantity_Sold
FROM dbo.OrderItems
GROUP BY product_id
ORDER BY Total_Quantity_Sold DESC;
GO

-- 11. [Categorical Profiling - Top Sellers]: Top 10 sellers by order volume
SELECT TOP 10 seller_id, COUNT(order_id) AS Total_Orders_Fulfilled
FROM dbo.OrderItems
GROUP BY seller_id
ORDER BY Total_Orders_Fulfilled DESC;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [ORDERPAYMENTS] TABLE

-- 1. [Volume Profiling]: Check the total number of payment records
SELECT COUNT(*) AS Total_Payment_Records 
FROM dbo.OrderPayments;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate composite keys
-- (A single order can have multiple payment methods, so order_id + payment_sequential must be unique)
SELECT order_id, payment_sequential, COUNT(*) AS Duplicate_Count
FROM dbo.OrderPayments
GROUP BY order_id, payment_sequential
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(order_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderID,
    SUM(CASE WHEN LTRIM(RTRIM(payment_sequential)) = '' THEN 1 ELSE 0 END) AS Blank_Sequential,
    SUM(CASE WHEN LTRIM(RTRIM(payment_type)) = '' THEN 1 ELSE 0 END) AS Blank_PaymentType,
    SUM(CASE WHEN LTRIM(RTRIM(payment_installments)) = '' THEN 1 ELSE 0 END) AS Blank_Installments
FROM dbo.OrderPayments;
GO

-- 4. [Data Type Consistency Profiling]: Validate numeric logic in nvarchar columns
-- (payment_sequential and payment_installments are stored as text but should only contain numbers)
SELECT 
    SUM(CASE WHEN ISNUMERIC(payment_sequential) = 0 THEN 1 ELSE 0 END) AS Non_Numeric_Sequential,
    SUM(CASE WHEN ISNUMERIC(payment_installments) = 0 THEN 1 ELSE 0 END) AS Non_Numeric_Installments
FROM dbo.OrderPayments;
GO

-- 5. [Domain & Outlier Profiling - Financial]: Check for invalid zero or negative payments
-- (A payment value logically cannot be less than or equal to 0)
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_Payments
FROM dbo.OrderPayments
WHERE payment_value <= 0;
GO

-- 6. [Statistical Profiling - Financial]: Overview of payment value distribution
-- (Useful for identifying massive outlier transactions)
SELECT 
    MIN(payment_value) AS Min_Payment, 
    MAX(payment_value) AS Max_Payment, 
    AVG(payment_value) AS Avg_Payment,
    SUM(payment_value) AS Total_Revenue_Recorded
FROM dbo.OrderPayments;
GO

-- 7. [Categorical Profiling]: Distribution of Payment Types
-- (Identifies which payment methods are most popular: Credit Card, Boleto, Voucher, etc.)
SELECT payment_type, COUNT(*) AS Transaction_Count, SUM(payment_value) AS Total_Value
FROM dbo.OrderPayments
GROUP BY payment_type
ORDER BY Transaction_Count DESC;
GO

-- 8. [Categorical & Outlier Profiling]: Analyze payment installments
-- (Identifies the maximum number of installments allowed and checks for unrealistic values like 100 installments)
SELECT payment_installments, COUNT(*) AS Frequency
FROM dbo.OrderPayments
GROUP BY payment_installments
ORDER BY CAST(payment_installments AS INT) DESC;
GO

-- 9. [Cardinality Profiling]: Count the distinct number of unique orders with payment data
SELECT COUNT(DISTINCT order_id) AS Total_Unique_Orders_Paid
FROM dbo.OrderPayments;
GO

-- 10. [Frequency Profiling]: Check for orders that used multiple payment methods
-- (e.g., A customer paying with both a Voucher and a Credit Card for the same order)
SELECT TOP 10 order_id, COUNT(payment_sequential) AS Payment_Methods_Used
FROM dbo.OrderPayments
GROUP BY order_id
HAVING COUNT(payment_sequential) > 1
ORDER BY Payment_Methods_Used DESC;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [ORDERREVIEWS] TABLE

-- 1. [Volume Profiling]: Check the total number of review records
SELECT COUNT(*) AS Total_Review_Records 
FROM dbo.OrderReviews;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate review IDs
-- (Each review_id should ideally be unique)
SELECT review_id, COUNT(*) AS Duplicate_Count
FROM dbo.OrderReviews
GROUP BY review_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in IDs
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(review_id)) = '' THEN 1 ELSE 0 END) AS Blank_ReviewID,
    SUM(CASE WHEN LTRIM(RTRIM(order_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderID
FROM dbo.OrderReviews;
GO

-- 4. [Data Type Consistency Profiling]: Validate numeric logic in nvarchar columns
-- (review_score is stored as nvarchar but should only contain numbers like 1, 2, 3, 4, 5)
SELECT COUNT(*) AS Non_Numeric_Scores
FROM dbo.OrderReviews
WHERE ISNUMERIC(review_score) = 0;
GO

-- 5. [Categorical Profiling]: Distribution of Review Scores
-- (Identifies how many customers gave 5 stars vs 1 star)
SELECT review_score, COUNT(*) AS Score_Count
FROM dbo.OrderReviews
WHERE ISNUMERIC(review_score) = 1
GROUP BY review_score
ORDER BY CAST(review_score AS INT) DESC;
GO

-- 6. [Domain & Outlier Profiling]: Identify out-of-range review scores
-- (Standard review scores should be between 1 and 5. Checks for 0 or > 5)
SELECT COUNT(*) AS Invalid_Out_Of_Range_Scores
FROM dbo.OrderReviews
WHERE ISNUMERIC(review_score) = 1 
  AND (CAST(review_score AS INT) < 1 OR CAST(review_score AS INT) > 5);
GO

-- 7. [Text Content Completeness Profiling]: Analyze customer feedback behavior
-- (Calculates how many reviews have actual written messages/titles vs just a score)
SELECT 
    SUM(CASE WHEN review_comment_title IS NULL OR LTRIM(RTRIM(review_comment_title)) = '' THEN 1 ELSE 0 END) AS Missing_Titles,
    SUM(CASE WHEN review_comment_message IS NULL OR LTRIM(RTRIM(review_comment_message)) = '' THEN 1 ELSE 0 END) AS Missing_Messages,
    SUM(CASE WHEN review_comment_message IS NOT NULL AND LTRIM(RTRIM(review_comment_message)) <> '' THEN 1 ELSE 0 END) AS Written_Feedback_Count
FROM dbo.OrderReviews;
GO

-- 8. [Temporal / Logical Profiling]: Check for illogical timelines
-- (A review cannot logically be answered before it was created)
SELECT COUNT(*) AS Illogical_Review_Dates
FROM dbo.OrderReviews
WHERE review_answer_timestamp < review_creation_date;
GO

-- 9. [Temporal Latency Profiling]: Analyze response/answer times
-- (Calculates the average, minimum, and maximum days taken to answer a review)
SELECT 
    AVG(DATEDIFF(day, review_creation_date, review_answer_timestamp)) AS Avg_Days_To_Answer,
    MAX(DATEDIFF(day, review_creation_date, review_answer_timestamp)) AS Max_Days_To_Answer,
    MIN(DATEDIFF(day, review_creation_date, review_answer_timestamp)) AS Min_Days_To_Answer
FROM dbo.OrderReviews;
GO

-- 10. [Cardinality Profiling]: Check the number of unique orders that received reviews
SELECT COUNT(DISTINCT order_id) AS Unique_Orders_Reviewed
FROM dbo.OrderReviews;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [ORDERS] TABLE

-- 1. [Volume Profiling]: Check the total number of order records
SELECT COUNT(*) AS Total_Order_Records 
FROM dbo.Orders;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate order IDs
-- (order_id must be completely unique in this table as it's the primary key)
SELECT order_id, COUNT(*) AS Duplicate_Count
FROM dbo.Orders
GROUP BY order_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in key text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(order_id)) = '' THEN 1 ELSE 0 END) AS Blank_OrderID,
    SUM(CASE WHEN LTRIM(RTRIM(customer_id)) = '' THEN 1 ELSE 0 END) AS Blank_CustomerID,
    SUM(CASE WHEN LTRIM(RTRIM(order_status)) = '' THEN 1 ELSE 0 END) AS Blank_Status
FROM dbo.Orders;
GO

-- 4. [Completeness Profiling - Dates]: Check for missing milestone dates
-- (Missing dates are expected for canceled/in-transit orders, but good to quantify)
SELECT 
    SUM(CASE WHEN order_approved_at IS NULL THEN 1 ELSE 0 END) AS Missing_Approval_Date,
    SUM(CASE WHEN order_delivered_carrier_date IS NULL THEN 1 ELSE 0 END) AS Missing_Carrier_Date,
    SUM(CASE WHEN order_delivered_customer_date IS NULL THEN 1 ELSE 0 END) AS Missing_Delivery_Date
FROM dbo.Orders;
GO

-- 5. [Categorical Profiling]: Distribution of Order Statuses
-- (Identifies the proportion of delivered, canceled, shipped, and invoiced orders)
SELECT order_status, COUNT(*) AS Order_Count
FROM dbo.Orders
GROUP BY order_status
ORDER BY Order_Count DESC;
GO

-- 6. [Consistency & Logic Profiling - Status Anomaly]: Delivered without a date
-- (Orders marked as 'delivered' MUST logically have a delivery date)
SELECT COUNT(*) AS Delivered_Status_Missing_Date
FROM dbo.Orders
WHERE order_status = 'delivered' 
  AND order_delivered_customer_date IS NULL;
GO

-- 7. [Temporal / Chronological Profiling]: Check for illogical date sequences
-- (An order cannot logically proceed to the next step before completing the previous one)
SELECT 
    SUM(CASE WHEN order_approved_at < order_purchase_timestamp THEN 1 ELSE 0 END) AS Approved_Before_Purchased,
    SUM(CASE WHEN order_delivered_carrier_date < order_approved_at THEN 1 ELSE 0 END) AS Carrier_Before_Approved,
    SUM(CASE WHEN order_delivered_customer_date < order_delivered_carrier_date THEN 1 ELSE 0 END) AS Delivered_Before_Carrier
FROM dbo.Orders;
GO

-- 8. [Temporal Latency Profiling]: Overall Delivery Lead Time
-- (Calculates the average, minimum, and maximum days taken to deliver an order)
SELECT 
    AVG(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Avg_Delivery_Days,
    MAX(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Max_Delivery_Days,
    MIN(DATEDIFF(day, order_purchase_timestamp, order_delivered_customer_date)) AS Min_Delivery_Days
FROM dbo.Orders
WHERE order_delivered_customer_date IS NOT NULL;
GO

-- 9. [Business Logic Profiling]: Identify Late Deliveries
-- (Counts how many orders reached the customer AFTER the estimated delivery date)
SELECT COUNT(*) AS Total_Late_Deliveries
FROM dbo.Orders
WHERE order_delivered_customer_date > order_estimated_delivery_date;
GO

-- 10. [Cardinality Profiling]: Check the number of unique customers who placed orders
SELECT COUNT(DISTINCT customer_id) AS Unique_Purchasing_Customers
FROM dbo.Orders;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [PRODUCTCATEGORYNAMETRANSLATION] TABLE

-- 1. [Volume Profiling]: Check the total number of translation records
SELECT COUNT(*) AS Total_Translation_Records 
FROM dbo.ProductCategoryNameTranslation;
GO

-- 2. [Uniqueness Profiling - Primary Key]: Check for duplicate Portuguese names
-- (product_category_name acts as the primary key. A single Portuguese category should not have multiple conflicting translations)
SELECT product_category_name, COUNT(*) AS Duplicate_PT_Names
FROM dbo.ProductCategoryNameTranslation
GROUP BY product_category_name
HAVING COUNT(*) > 1;
GO

-- 3. [Uniqueness Profiling - Target Value]: Check for duplicate English names
-- (Checks if two completely different Portuguese categories are translated into the exact same English category)
SELECT product_category_name_english, COUNT(*) AS Duplicate_EN_Names
FROM dbo.ProductCategoryNameTranslation
GROUP BY product_category_name_english
HAVING COUNT(*) > 1;
GO

-- 4. [Completeness & Format Profiling]: Check for empty strings or NULLs
-- (Ensures no blank values exist in either the Portuguese or English columns)
SELECT 
    SUM(CASE WHEN product_category_name IS NULL OR LTRIM(RTRIM(product_category_name)) = '' THEN 1 ELSE 0 END) AS Missing_PT_Name,
    SUM(CASE WHEN product_category_name_english IS NULL OR LTRIM(RTRIM(product_category_name_english)) = '' THEN 1 ELSE 0 END) AS Missing_EN_Name
FROM dbo.ProductCategoryNameTranslation;
GO

-- 5. [Length Constraint Profiling]: Analyze the text length of category names
-- (Helps identify anomalies, such as a category name with just 1 letter or excessively long names)
SELECT 
    MIN(LEN(product_category_name)) AS Min_Length_PT, 
    MAX(LEN(product_category_name)) AS Max_Length_PT,
    MIN(LEN(product_category_name_english)) AS Min_Length_EN, 
    MAX(LEN(product_category_name_english)) AS Max_Length_EN
FROM dbo.ProductCategoryNameTranslation;
GO

-- 6. [Data Quality / Pattern Profiling]: Check for leading or trailing spaces
-- (Invisible spaces at the beginning or end of text can cause JOINs to fail in the ETL process)
SELECT 
    SUM(CASE WHEN product_category_name <> LTRIM(RTRIM(product_category_name)) THEN 1 ELSE 0 END) AS PT_Names_With_Spaces,
    SUM(CASE WHEN product_category_name_english <> LTRIM(RTRIM(product_category_name_english)) THEN 1 ELSE 0 END) AS EN_Names_With_Spaces
FROM dbo.ProductCategoryNameTranslation;
GO

-- 7. [Pattern Profiling]: Check for specific string structures (Underscores vs Spaces)
-- (Olist categories usually contain underscores e.g., 'cama_mesa_banho'. This checks the formatting consistency)
SELECT 
    SUM(CASE WHEN product_category_name LIKE '%_%' THEN 1 ELSE 0 END) AS PT_Contains_Underscore,
    SUM(CASE WHEN product_category_name_english LIKE '%_%' THEN 1 ELSE 0 END) AS EN_Contains_Underscore,
    SUM(CASE WHEN product_category_name LIKE '% %' THEN 1 ELSE 0 END) AS PT_Contains_Space,
    SUM(CASE WHEN product_category_name_english LIKE '% %' THEN 1 ELSE 0 END) AS EN_Contains_Space
FROM dbo.ProductCategoryNameTranslation;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [PRODUCTS] TABLE

-- 1. [Volume Profiling]: Check the total number of product records
SELECT COUNT(*) AS Total_Product_Records 
FROM dbo.Products;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate product IDs
-- (product_id is the primary key and must be strictly unique)
SELECT product_id, COUNT(*) AS Duplicate_Count
FROM dbo.Products
GROUP BY product_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in key text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(product_id)) = '' THEN 1 ELSE 0 END) AS Blank_ProductID,
    SUM(CASE WHEN product_category_name IS NULL OR LTRIM(RTRIM(product_category_name)) = '' THEN 1 ELSE 0 END) AS Missing_Category_Name
FROM dbo.Products;
GO

-- 4. [Data Type Consistency Profiling]: Validate numeric logic in nvarchar columns
-- (If product_photos_qty is stored as nvarchar, check if it contains non-numeric text)
SELECT product_photos_qty, COUNT(*) AS Occurrences
FROM dbo.Products
WHERE ISNUMERIC(product_photos_qty) = 0 AND product_photos_qty IS NOT NULL
GROUP BY product_photos_qty;
GO

-- 5. [Domain & Outlier Profiling - Physical Constraints]: Check for zero or negative dimensions
-- (A physical product logically cannot have a weight, length, height, or width of 0 or less)
SELECT 
    SUM(CASE WHEN product_weight_g <= 0 THEN 1 ELSE 0 END) AS Invalid_Weight,
    SUM(CASE WHEN product_length_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Length,
    SUM(CASE WHEN product_height_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Height,
    SUM(CASE WHEN product_width_cm <= 0 THEN 1 ELSE 0 END) AS Invalid_Width
FROM dbo.Products;
GO

-- 6. [Statistical Profiling - Dimensions]: Analyze the distribution of physical properties
-- (Helps identify massive outliers, e.g., a product weighing 10,000 kg which might be a data entry error)
SELECT 
    MIN(product_weight_g) AS Min_Weight_g, 
    MAX(product_weight_g) AS Max_Weight_g, 
    AVG(product_weight_g) AS Avg_Weight_g,
    MIN(product_length_cm) AS Min_Length_cm, 
    MAX(product_length_cm) AS Max_Length_cm
FROM dbo.Products;
GO

-- 7. [Categorical Profiling]: Distribution of Product Categories
-- (Identifies the top 10 categories with the most diverse range of products registered)
SELECT TOP 10 product_category_name, COUNT(*) AS Total_Products_In_Category
FROM dbo.Products
GROUP BY product_category_name
ORDER BY Total_Products_In_Category DESC;
GO

-- 8. [Completeness Profiling - Null Metrics]: Check for missing product descriptions or photos
SELECT 
    SUM(CASE WHEN product_name_lenght IS NULL THEN 1 ELSE 0 END) AS Missing_Name_Length,
    SUM(CASE WHEN product_description_lenght IS NULL THEN 1 ELSE 0 END) AS Missing_Description_Length,
    SUM(CASE WHEN product_photos_qty IS NULL THEN 1 ELSE 0 END) AS Missing_Photos_Qty
FROM dbo.Products;
GO


-- COMPREHENSIVE DATA PROFILING FOR: [SELLERS] TABLE

-- 1. [Volume Profiling]: Check the total number of seller records
SELECT COUNT(*) AS Total_Seller_Records 
FROM dbo.Sellers;
GO

-- 2. [Uniqueness Profiling]: Check for duplicate seller IDs
-- (seller_id acts as the primary key and must be strictly unique)
SELECT seller_id, COUNT(*) AS Duplicate_Count
FROM dbo.Sellers
GROUP BY seller_id
HAVING COUNT(*) > 1;
GO

-- 3. [Completeness & Format Profiling]: Check for empty strings in text columns
SELECT 
    SUM(CASE WHEN LTRIM(RTRIM(seller_id)) = '' THEN 1 ELSE 0 END) AS Blank_SellerID,
    SUM(CASE WHEN LTRIM(RTRIM(seller_city)) = '' THEN 1 ELSE 0 END) AS Blank_City,
    SUM(CASE WHEN LTRIM(RTRIM(seller_state)) = '' THEN 1 ELSE 0 END) AS Blank_State
FROM dbo.Sellers;
GO

-- 4. [Length Constraint Profiling]: Validate state code strictly contains 2 characters
SELECT DISTINCT seller_state, LEN(LTRIM(RTRIM(seller_state))) AS State_Length
FROM dbo.Sellers
WHERE LEN(LTRIM(RTRIM(seller_state))) <> 2;
GO

-- 5. [Domain Profiling - Numeric]: Validate zip codes are positive integers
SELECT COUNT(*) AS Invalid_Zero_Or_Negative_ZipCodes
FROM dbo.Sellers
WHERE seller_zip_code_prefix <= 0;
GO

-- 6. [Cardinality Profiling]: Count the distinct number of geographical areas covered by sellers
SELECT 
    COUNT(DISTINCT seller_zip_code_prefix) AS Total_Distinct_Seller_Zips,
    COUNT(DISTINCT seller_city) AS Total_Distinct_Seller_Cities,
    COUNT(DISTINCT seller_state) AS Total_Distinct_Seller_States
FROM dbo.Sellers;
GO

-- 7. [Categorical Profiling]: Top 10 States with the highest number of registered sellers
-- (Helps identify which regions have the highest supply/merchant presence)
SELECT TOP 10 seller_state, COUNT(*) AS Total_Sellers
FROM dbo.Sellers
GROUP BY seller_state
ORDER BY Total_Sellers DESC;
GO

-- 8. [Categorical Profiling]: Top 10 Cities with the highest number of registered sellers
SELECT TOP 10 seller_city, COUNT(*) AS Total_Sellers
FROM dbo.Sellers
GROUP BY seller_city
ORDER BY Total_Sellers DESC;
GO