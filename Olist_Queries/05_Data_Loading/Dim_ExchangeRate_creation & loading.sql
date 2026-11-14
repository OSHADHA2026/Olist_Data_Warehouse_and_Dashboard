USE Olist_DW;
GO

-- 2. Create the new dimension table for Exchange Rates
IF OBJECT_ID('dbo.Dim_ExchangeRate', 'U') IS NOT NULL 
    DROP TABLE dbo.Dim_ExchangeRate;
GO

CREATE TABLE dbo.Dim_ExchangeRate (
    DateKey INT PRIMARY KEY,
    ExchangeDate DATE,
    BRL_to_USD FLOAT
);
GO

-- Read the JSON file and load data into the new dimension table
DECLARE @JSON NVARCHAR(MAX);
SELECT @JSON = BulkColumn
FROM OPENROWSET(BULK 'C:\Olist_Data\BRL_USD.json', SINGLE_CLOB) AS j;

INSERT INTO dbo.Dim_ExchangeRate (DateKey, ExchangeDate, BRL_to_USD)
SELECT 
    CAST(REPLACE([key], '-', '') AS INT) AS DateKey,
    CAST([key] AS DATE) AS ExchangeDate,
    CAST(JSON_VALUE([value], '$.USD') AS FLOAT) AS BRL_to_USD
FROM OPENJSON(@JSON, '$.rates');
GO

-- Create a View to calculate USD values dynamically without altering Fact_Sales table
CREATE OR ALTER VIEW vw_Fact_Sales_USD AS
SELECT 
    -- Newly added Keys
    f.Sales_Key,

    -- Existing Keys
    f.Order_Key,
    f.Product_Key,
    f.Seller_Key,
    f.Customer_Key,
    f.Purchase_Date_Key,
    f.Approved_Date_Key,
    f.Shipped_Date_Key,
    f.Delivery_Date_Key,
    
    -- Newly added Delivery Date Key
    f.Estimated_Delivery_Date_Key,
    
    -- General order details
    f.order_item_id,
    
    -- Newly added payment and review details
    f.payment_type,
    f.payment_installments,
    f.review_score,

    -- Original currency values in BRL (Brazilian Real)
    f.price AS price_brl,
    f.freight_value AS freight_value_brl,
    f.total_item_value AS total_item_value_brl,
    f.payment_value AS payment_value_brl,
    
    -- Exchange rate for the given purchase date
    e.BRL_to_USD,
    
    -- Dynamically calculated USD values
    CAST(f.price * e.BRL_to_USD AS DECIMAL(18,2)) AS price_usd,
    CAST(f.freight_value * e.BRL_to_USD AS DECIMAL(18,2)) AS freight_value_usd,
    CAST(f.total_item_value * e.BRL_to_USD AS DECIMAL(18,2)) AS total_item_value_usd,
    CAST(f.payment_value * e.BRL_to_USD AS DECIMAL(18,2)) AS payment_value_usd

FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_ExchangeRate e 
    ON f.Purchase_Date_Key = e.DateKey;
GO