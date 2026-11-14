USE Olist_DW;
GO

-- STEP 1: CREATE SCHEMAS FOR THE TWO DATA MARTS
CREATE SCHEMA sales_mart;
GO

CREATE SCHEMA delivery_mart;
GO

-- STEP 2: CREATE SALES & FINANCIAL PERFORMANCE DATA MART VIEW[cite: 1]
CREATE VIEW sales_mart.vw_Sales_Finance_Mart AS
SELECT 
    f.Sales_Key,
    d.Full_Date AS Purchase_Date,
    d.Year,
    d.Month_Name,
    d.Quarter,
    p.product_id,
    c_cat.category_name_en AS Product_Category,
    s.seller_id,
    cust.customer_unique_id,
    f.payment_type,
    f.payment_installments,
    f.price,
    f.freight_value,
    f.total_item_value,
    f.payment_value,
    ex.BRL_to_USD,
    (f.total_item_value * ex.BRL_to_USD) AS Total_Value_USD
FROM dbo.Fact_Sales f
INNER JOIN dbo.Dim_Date d ON f.Purchase_Date_Key = d.Date_Key
INNER JOIN dbo.Dim_Product p ON f.Product_Key = p.Product_Key
LEFT JOIN dbo.Dim_Product_Category c_cat ON p.Category_Key = c_cat.Category_Key
INNER JOIN dbo.Dim_Seller s ON f.Seller_Key = s.Seller_Key
INNER JOIN dbo.Dim_Customer cust ON f.Customer_Key = cust.Customer_Key
LEFT JOIN dbo.Dim_ExchangeRate ex ON f.Purchase_Date_Key = ex.DateKey;
GO

-- STEP 3: CREATE CUSTOMER & DELIVERY ANALYTICS DATA MART VIEW[cite: 1]
CREATE VIEW delivery_mart.vw_Customer_Delivery_Mart AS
SELECT 
    f.Sales_Key,
    o.order_id,
    o.order_status,
    cust_loc.state AS Customer_State,
    cust_loc.city AS Customer_City,
    sell_loc.state AS Seller_State,
    pur_date.Full_Date AS Purchase_Date,
    del_date.Full_Date AS Delivery_Date,
    est_date.Full_Date AS Estimated_Delivery_Date,
    DATEDIFF(day, pur_date.Full_Date, del_date.Full_Date) AS Actual_Delivery_Days,
    CASE 
        WHEN del_date.Full_Date > est_date.Full_Date THEN 1 
        ELSE 0 
    END AS Is_Late_Delivery,
    f.review_score
FROM dbo.Fact_Sales f
INNER JOIN dbo.Dim_Order o ON f.Order_Key = o.Order_Key
INNER JOIN dbo.Dim_Customer cust ON f.Customer_Key = cust.Customer_Key
INNER JOIN dbo.Dim_Location cust_loc ON cust.Location_Key = cust_loc.Location_Key
INNER JOIN dbo.Dim_Seller sell ON f.Seller_Key = sell.Seller_Key
INNER JOIN dbo.Dim_Location sell_loc ON sell.Location_Key = sell_loc.Location_Key
INNER JOIN dbo.Dim_Date pur_date ON f.Purchase_Date_Key = pur_date.Date_Key
LEFT JOIN dbo.Dim_Date del_date ON f.Delivery_Date_Key = del_date.Date_Key
INNER JOIN dbo.Dim_Date est_date ON f.Estimated_Delivery_Date_Key = est_date.Date_Key;
GO

-- STEP 4: CREATE SQL SERVER LOGINS AND USERS FOR SECURITY[cite: 1]
CREATE LOGIN SalesAnalystLogin WITH PASSWORD = '123';
GO

CREATE LOGIN SupplyChainLogin WITH PASSWORD = '123';
GO

CREATE USER SalesAnalystUser FOR LOGIN SalesAnalystLogin;
GO

CREATE USER SupplyChainUser FOR LOGIN SupplyChainLogin;
GO

-- STEP 5: CREATE ROLES AND ASSIGN SPECIFIC PERMISSIONS[cite: 1]

-- 1. Sales & Finance Role Setup
CREATE ROLE SalesFinanceRole;
GO

GRANT SELECT ON OBJECT::sales_mart.vw_Sales_Finance_Mart TO SalesFinanceRole;
GO

ALTER ROLE SalesFinanceRole ADD MEMBER SalesAnalystUser;
GO

-- 2. Supply Chain & Operations Role Setup
CREATE ROLE SupplyChainRole;
GO

GRANT SELECT ON OBJECT::delivery_mart.vw_Customer_Delivery_Mart TO SupplyChainRole;
GO

ALTER ROLE SupplyChainRole ADD MEMBER SupplyChainUser;
GO