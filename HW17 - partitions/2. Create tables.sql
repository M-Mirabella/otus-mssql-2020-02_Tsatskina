--создадим партиционированную таблицу
CREATE TABLE [Sales].[OrderLinesArchive](
	[OrderLineID] [int] NOT NULL,
	[OrderID] [int] NOT NULL,
	[OrderDate] [date] NOT NULL,
	[StockItemID] [int] NOT NULL,
	[Description] [nvarchar](100) NOT NULL,
	[PackageTypeID] [int] NOT NULL,
	[Quantity] [int] NOT NULL,
	[UnitPrice] [decimal](18, 2) NULL,
	[TaxRate] [decimal](18, 3) NOT NULL,
	[PickedQuantity] [int] NOT NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmOrdersArchive]([OrderDate])---в схеме [schmYearPartition] по ключу [InvoiceDate]
GO

--создадим кластерный индекс в той же схеме с тем же ключом
ALTER TABLE [Sales].[OrderLinesArchive] ADD CONSTRAINT PK_Sales_OrderLinesArchive 
PRIMARY KEY CLUSTERED  (OrderDate, OrderId, OrderLineId)
 ON [schmOrdersArchive]([OrderDate]);

--то же самое для второй таблицы
CREATE TABLE [Sales].[OrdersArchive](
    [OrderID] [int] NOT NULL,
	[CustomerID] [int] NOT NULL,
	[SalespersonPersonID] [int] NOT NULL,
	[PickedByPersonID] [int] NULL,
	[ContactPersonID] [int] NOT NULL,
	[BackorderOrderID] [int] NULL,
	[OrderDate] [date] NOT NULL,
	[ExpectedDeliveryDate] [date] NOT NULL,
	[CustomerPurchaseOrderNumber] [nvarchar](20) NULL,
	[IsUndersupplyBackordered] [bit] NOT NULL,
	[Comments] [nvarchar](max) NULL,
	[DeliveryInstructions] [nvarchar](max) NULL,
	[InternalComments] [nvarchar](max) NULL,
	[PickingCompletedWhen] [datetime2](7) NULL,
	[LastEditedBy] [int] NOT NULL,
	[LastEditedWhen] [datetime2](7) NOT NULL,
) ON [schmOrdersArchive]([OrderDate])
GO

ALTER TABLE [Sales].[OrdersArchive] ADD CONSTRAINT PK_Sales_OrdersArchive 
PRIMARY KEY CLUSTERED  (OrderDate, OrderId)
 ON [schmOrdersArchive]([OrderDate]);
