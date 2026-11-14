USE Olist_DW;
GO

-- 1. Dim_Location (Snowflake normalized table for Geography)
CREATE TABLE [dbo].[Dim_Location](
    [Location_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [zip_code_prefix] [int] NOT NULL,
    [city] [nvarchar](50) NOT NULL,
    [state] [nvarchar](50) NOT NULL,
    [latitude] [float] NOT NULL,
    [longitude] [float] NOT NULL
);
GO

-- 2. Dim_Customer (Linked to Dim_Location)
CREATE TABLE [dbo].[Dim_Customer](
    [Customer_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [customer_id] [nvarchar](50) NOT NULL,
    [customer_unique_id] [nvarchar](50) NOT NULL,
    [Location_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Location]([Location_Key])
);
GO

-- 3. Dim_Seller (Linked to Dim_Location)
CREATE TABLE [dbo].[Dim_Seller](
    [Seller_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [seller_id] [nvarchar](50) NOT NULL,
    [Location_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Location]([Location_Key])
);
GO

-- 4. Dim_Product_Category (Snowflake normalized translation table)
CREATE TABLE [dbo].[Dim_Product_Category](
    [Category_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [category_name_pt] [nvarchar](50) NOT NULL,
    [category_name_en] [nvarchar](50) NOT NULL
);
GO

-- 5. Dim_Product (Linked to Dim_Product_Category)
CREATE TABLE [dbo].[Dim_Product](
    [Product_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [product_id] [nvarchar](50) NOT NULL,
    [Category_Key] [int] NULL FOREIGN KEY REFERENCES [dbo].[Dim_Product_Category]([Category_Key]),
    [product_weight_g] [int] NULL,
    [product_length_cm] [int] NULL,
    [product_height_cm] [int] NULL,
    [product_width_cm] [int] NULL
);
GO

-- 6. Dim_Order
CREATE TABLE [dbo].[Dim_Order](
    [Order_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    [order_id] [nvarchar](50) NOT NULL,
    [order_status] [nvarchar](50) NOT NULL
);
GO

-- 7. Dim_Date (Time Dimension)
CREATE TABLE [dbo].[Dim_Date](
    [Date_Key] [int] PRIMARY KEY, -- Format: YYYYMMDD
    [Full_Date] [date] NOT NULL,
    [Year] [int] NOT NULL,
    [Month] [int] NOT NULL,
    [Quarter] [int] NOT NULL,
    [Day_Of_Week] [nvarchar](15) NOT NULL,
    [Month_Name] [nvarchar](15) NOT NULL
);
GO

-- 8. Dim_ExchangeRate (Snowflake dimension linked to Dim_Date)
CREATE TABLE [dbo].[Dim_ExchangeRate](
    [DateKey] [int] PRIMARY KEY FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),
    [ExchangeDate] [date] NOT NULL,
    [BRL_to_USD] [decimal](18, 4) NOT NULL
);
GO

-- 9. Fact_Sales (Central Fact Table at Order-Item Grain)
CREATE TABLE [dbo].[Fact_Sales](
    [Sales_Key] [int] IDENTITY(1,1) PRIMARY KEY,
    
    -- Foreign Keys to Dimensions
    [Order_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Order]([Order_Key]),
    [Product_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Product]([Product_Key]),
    [Seller_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Seller]([Seller_Key]),
    [Customer_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Customer]([Customer_Key]),
    
    -- Role-playing Date Foreign Keys
    [Purchase_Date_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),
    [Approved_Date_Key] [int] NULL FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),
    [Shipped_Date_Key] [int] NULL FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),
    [Delivery_Date_Key] [int] NULL FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),
    [Estimated_Delivery_Date_Key] [int] NOT NULL FOREIGN KEY REFERENCES [dbo].[Dim_Date]([Date_Key]),

    -- Degenerate Dimensions & Attributes
    [order_item_id] [nvarchar](50) NOT NULL,
    [payment_type] [nvarchar](50) NULL,
    [payment_installments] [int] NULL,

    -- Quantitative Measures
    [price] [float] NOT NULL,
    [freight_value] [float] NOT NULL,
    [total_item_value] [float] NOT NULL,
    [payment_value] [float] NULL,
    [review_score] [int] NULL
);
GO