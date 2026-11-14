USE Olist_Staging;
GO

-- check for null values
SELECT 
    'Null Check' AS QualityCheckType,
    COUNT(*) AS InvalidCount
FROM ExchangeRate
WHERE ExchangeDate IS NULL OR BRL_to_USD IS NULL;

-- check for duplicate dates
SELECT 
    ExchangeDate, 
    COUNT(*) AS DuplicateCount
FROM ExchangeRate
GROUP BY ExchangeDate
HAVING COUNT(*) > 1;
GO