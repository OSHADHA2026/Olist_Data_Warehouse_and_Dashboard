USE Olist_Staging;
GO

-- drop staging table if exists
DROP TABLE IF EXISTS ExchangeRate;
GO

-- create staging table for exchange rate
CREATE TABLE ExchangeRate (
    ExchangeDate DATE,
    BRL_to_USD DECIMAL(18, 4)
);
GO

-- load data from json file into staging table
INSERT INTO ExchangeRate (ExchangeDate, BRL_to_USD)
SELECT
    CONVERT(DATE, r.[key], 23),
    CONVERT(DECIMAL(18, 4), JSON_VALUE(r.[value], '$.USD'))
FROM OPENROWSET(BULK 'C:\Olist_Data\BRL_USD.json', SINGLE_CLOB) AS j
CROSS APPLY OPENJSON(j.BulkColumn, '$.rates') AS r;
GO

-- 1. Declare variables for date range
DECLARE @MinDate DATE, @MaxDate DATE;
SELECT 
    @MinDate = MIN(ExchangeDate), 
    @MaxDate = MAX(ExchangeDate) 
FROM ExchangeRate;

-- 2. Generate complete date sequence and fill missing rates, then overwrite the original table
WITH DateSequence AS (
    SELECT @MinDate AS DateValue
    UNION ALL
    SELECT DATEADD(day, 1, DateValue)
    FROM DateSequence
    WHERE DateValue < @MaxDate
),
FilledRates AS (
    SELECT 
        ds.DateValue AS ExchangeDate,
        COALESCE(
            e.BRL_to_USD, 
            (SELECT TOP 1 sub.BRL_to_USD 
             FROM ExchangeRate sub 
             WHERE sub.ExchangeDate < ds.DateValue 
             ORDER BY sub.ExchangeDate DESC)
        ) AS BRL_to_USD
    FROM DateSequence ds
    LEFT JOIN ExchangeRate e ON ds.DateValue = e.ExchangeDate
)
SELECT ExchangeDate, BRL_to_USD
INTO #TempExchangeRate
FROM FilledRates
OPTION (MAXRECURSION 0);
GO

-- 3. Clear original table and insert the fully filled data back
TRUNCATE TABLE ExchangeRate;

INSERT INTO ExchangeRate (ExchangeDate, BRL_to_USD)
SELECT ExchangeDate, BRL_to_USD 
FROM #TempExchangeRate;

DROP TABLE IF EXISTS #TempExchangeRate;
GO