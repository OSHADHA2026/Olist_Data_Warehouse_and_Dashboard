USE Olist_DW;
GO
-- Step 1: Add new USD currency columns to the core Fact_Sales table
ALTER TABLE Fact_Sales
ADD 
    price_usd DECIMAL(18, 2),
    freight_value_usd DECIMAL(18, 2),
    payment_value_usd DECIMAL(18, 2),
    total_item_value_usd DECIMAL(18, 2);
GO

-- Step 2: Update Fact_Sales columns using the correct base column names from your table
UPDATE f
SET 
    f.price_usd = ROUND(f.price * e.BRL_to_USD, 2),
    f.freight_value_usd = ROUND(f.freight_value * e.BRL_to_USD, 2),
    f.payment_value_usd = ROUND(f.payment_value * e.BRL_to_USD, 2),
    f.total_item_value_usd = ROUND(f.total_item_value * e.BRL_to_USD, 2)
FROM Fact_Sales f
INNER JOIN Dim_ExchangeRate e 
    ON f.Purchase_Date_Key = e.DateKey;
GO

-- Step 3: Drop the obsolete view since we are now using physical columns directly in Fact_Sales
DROP VIEW IF EXISTS vw_Fact_Sales_USD;
GO