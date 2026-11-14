USE Olist_DW;
GO

SELECT 
    COUNT(*) AS Missing_Exchange_Rates_Count
FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_ExchangeRate e ON f.Purchase_Date_Key = e.DateKey
WHERE e.DateKey IS NULL;

SELECT DISTINCT 
    f.Purchase_Date_Key
FROM dbo.Fact_Sales f
LEFT JOIN dbo.Dim_ExchangeRate e ON f.Purchase_Date_Key = e.DateKey
WHERE e.DateKey IS NULL;
GO

WITH MissingDates AS (
    SELECT DISTINCT f.Purchase_Date_Key
    FROM dbo.Fact_Sales f
    LEFT JOIN dbo.Dim_ExchangeRate e ON f.Purchase_Date_Key = e.DateKey
    WHERE e.DateKey IS NULL
),
FilledRates AS (
    SELECT 
        m.Purchase_Date_Key AS DateKey,
        (SELECT TOP 1 BRL_to_USD 
         FROM dbo.Dim_ExchangeRate e 
         WHERE e.DateKey < m.Purchase_Date_Key 
         ORDER BY e.DateKey DESC) AS BRL_to_USD
    FROM MissingDates m
)
INSERT INTO dbo.Dim_ExchangeRate (DateKey, ExchangeDate, BRL_to_USD)
SELECT 
            DateKey, 
            CAST(CAST(DateKey AS VARCHAR(8)) AS DATE) AS ExchangeDate,
            BRL_to_USD
FROM FilledRates
WHERE BRL_to_USD IS NOT NULL;
GO

UPDATE f
SET 
    f.price_usd = ROUND(f.price * e.BRL_to_USD, 2),
    f.freight_value_usd = ROUND(f.freight_value * e.BRL_to_USD, 2),
    f.payment_value_usd = ROUND(f.payment_value * e.BRL_to_USD, 2),
    f.total_item_value_usd = ROUND(f.total_item_value * e.BRL_to_USD, 2)
FROM Fact_Sales f
CROSS APPLY (
    SELECT TOP 1 er.BRL_to_USD
    FROM Dim_ExchangeRate er
    WHERE er.DateKey <= f.Purchase_Date_Key
    ORDER BY er.DateKey DESC
) e
WHERE f.payment_value_usd IS NULL;
GO