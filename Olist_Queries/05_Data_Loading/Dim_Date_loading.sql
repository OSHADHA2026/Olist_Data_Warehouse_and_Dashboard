USE Olist_DW;
GO

-- 1. Populate Dim_Date (2016 to 2018 range for Olist)
DECLARE @StartDate DATE = '2016-01-01';
DECLARE @EndDate DATE = '2018-12-31';

WHILE @StartDate <= @EndDate
BEGIN
    IF NOT EXISTS (SELECT 1 FROM dbo.Dim_Date WHERE Full_Date = @StartDate)
    BEGIN
        INSERT INTO dbo.Dim_Date (Date_Key, Full_Date, Year, Month, Quarter, Day_Of_Week, Month_Name)
        VALUES (
            CAST(FORMAT(@StartDate, 'yyyyMMdd') AS INT),
            @StartDate,
            YEAR(@StartDate),
            MONTH(@StartDate),
            DATEPART(QUARTER, @StartDate),
            DATENAME(WEEKDAY, @StartDate),
            DATENAME(MONTH, @StartDate)
        );
    END
    SET @StartDate = DATEADD(day, 1, @StartDate);
END
GO