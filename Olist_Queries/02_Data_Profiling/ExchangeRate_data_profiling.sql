USE Olist_Staging;
GO

-- Data profiling and quality checks on the updated table

-- view final summary profile
SELECT 
    COUNT(*) AS TotalRecords,
    MIN(ExchangeDate) AS MinDate,
    MAX(ExchangeDate) AS MaxDate,
    MIN(BRL_to_USD) AS MinRate,
    MAX(BRL_to_USD) AS MaxRate
FROM ExchangeRate;
GO