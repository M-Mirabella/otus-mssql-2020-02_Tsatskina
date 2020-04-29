--XML, JSON � ������������ SQL
--1. ��������� ������ �� ����� StockItems.xml � ������� Warehouse.StockItems.
--������������ ������ � ������� ��������, ������������� �������� ������������ ������ �� ���� StockItemName).
--���� StockItems.xml � ������ ��������.
DROP TABLE IF EXISTS #StockItems
GO

CREATE TABLE #StockItems(
	[StockItemName] nvarchar(100) COLLATE Latin1_General_100_CI_AS,
	[SupplierID] int,
	[UnitPackageID] int,
	[OuterPackageID] int,
	[QuantityPerOuter] int,
	[TypicalWeightPerUnit] decimal(18,3),
	[LeadTimeDays] int,
	[IsChillerStock] bit,
	[TaxRate] decimal(18,3),
	[UnitPrice] decimal(18,2)
	)

DECLARE @docHandle int
DECLARE @x XML
SET @x = ( 
 SELECT * FROM OPENROWSET
  (BULK 'f:\SQL\otus-mssql-2020-02\otus-mssql-2020-02_Tsatskina\HW09 - xml_json\StockItems.xml',
   SINGLE_BLOB)
   as d)

EXEC sp_xml_preparedocument @docHandle OUTPUT, @x

INSERT INTO #StockItems
SELECT *
FROM OPENXML(@docHandle, N'/StockItems/Item', 0)
WITH ( 
	[StockItemName] nvarchar(100)  '@Name',
	[SupplierID] int 'SupplierID',
	[UnitPackageID] int 'Package/UnitPackageID',
	[OuterPackageID] int 'Package/OuterPackageID',
	[QuantityPerOuter] int 'Package/QuantityPerOuter',
	[TypicalWeightPerUnit] decimal(18,3) 'Package/TypicalWeightPerUnit',
	[LeadTimeDays] int 'LeadTimeDays',
	[IsChillerStock] bit 'IsChillerStock',
	[TaxRate] decimal(18,3) 'TaxRate',
	[UnitPrice] decimal(18,2) 'UnitPrice')

EXEC sp_xml_removedocument @docHandle

SELECT *
FROM #StockItems

MERGE Warehouse.StockItems AS Target
	USING (SELECT	StockItemName,
					SupplierID,
					UnitPackageID,
					OuterPackageID,
					QuantityPerOuter,
					TypicalWeightPerUnit,
					LeadTimeDays,
					IsChillerStock,
					TaxRate,
					UnitPrice
			FROM #StockItems) AS Source
	ON Target.StockItemName = Source.StockItemName
	WHEN MATCHED
		THEN UPDATE SET SupplierID = Source.SupplierID,
						UnitPackageID = Source.UnitPackageID,
						OuterPackageID = Source.OuterPackageID,
						QuantityPerOuter = Source.QuantityPerOuter,
						TypicalWeightPerUnit = Source.TypicalWeightPerUnit,
						LeadTimeDays = Source.LeadTimeDays,
						IsChillerStock = Source.IsChillerStock,
						TaxRate = Source.TaxRate,
						UnitPrice = Source.UnitPrice
	WHEN NOT MATCHED
		THEN INSERT (StockItemName,
					SupplierID,
					UnitPackageID,
					OuterPackageID,
					QuantityPerOuter,
					TypicalWeightPerUnit,
					LeadTimeDays,
					IsChillerStock,
					TaxRate,
					UnitPrice,
					LastEditedBy)
			VALUES (Source.StockItemName,
					Source.SupplierID,
					Source.UnitPackageID,
					Source.OuterPackageID,
					Source.QuantityPerOuter,
					Source.TypicalWeightPerUnit,
					Source.LeadTimeDays,
					Source.IsChillerStock,
					Source.TaxRate,
					Source.UnitPrice,
					1)
	OUTPUT $action, deleted.*, inserted.*;

--2. ��������� ������ �� ������� StockItems � ����� �� xml-����, ��� StockItems.xml

--<Item Name="&quot;The Gu&quot; red shirt XML tag t-shirt (Black) 3XXL">
--    <SupplierID>4</SupplierID>
--    <Package>
--      <UnitPackageID>7</UnitPackageID>
--      <OuterPackageID>6</OuterPackageID>
--      <QuantityPerOuter>12</QuantityPerOuter>
--      <TypicalWeightPerUnit>0.400</TypicalWeightPerUnit>
--    </Package>
--    <LeadTimeDays>7</LeadTimeDays>
--    <IsChillerStock>0</IsChillerStock>
--    <TaxRate>20.000</TaxRate>
--    <UnitPrice>18.000000</UnitPrice>
--  </Item> 

DROP TABLE IF EXISTS XML_Tbl

CREATE TABLE XML_Tbl ( xml_col xml )

DECLARE @XML_TABLE as XML = (
SELECT  StockItemName as [@Name],
		SupplierID,
		UnitPackageID as [Package/UnitPackageID],
		OuterPackageID as [Package/OuterPackageID],
		QuantityPerOuter as [Package/QuantityPerOuter],
		TypicalWeightPerUnit as [Package/TypicalWeightPerUnit],
		LeadTimeDays,
		IsChillerStock,
		TaxRate,
		UnitPrice
FROM Warehouse.StockItems 
FOR XML PATH ('Item'), ROOT('Stockitems'), ELEMENTS
)

INSERT INTO XML_Tbl
SELECT @XML_TABLE

SELECT *
FROM XML_Tbl


exec master..xp_cmdshell 'bcp "XML_Tbl" out "f:\SQL\otus-mssql-2020-02\otus-mssql-2020-02_Tsatskina\HW09 - xml_json\StockItems_Ts1.xml" -N  -T -d WideWorldImporters -S localhost\SQL2017_DEV'

DROP TABLE IF EXISTS XML_Tbl

--���������� � �������� 1, 2:
--* ���� � ��������� � ���� ����� ��������, �� ����� ������� ������ SELECT c ����������� � ���� XML.
--* ���� � ��� � ������� ������������ �������/������ � XML, �� ������ ����� ���� XML � ���� �������.
--* ���� � ���� XML ��� ����� ������, �� ������ ����� ����� �������� ������ � ������������� �� � �������.

--3. � ������� Warehouse.StockItems � ������� CustomFields ���� ������ � JSON.
--�������� SELECT ��� ������:
--- StockItemID
--- StockItemName
--- CountryOfManufacture (�� CustomFields)
--- FirstTag (�� ���� CustomFields, ������ �������� �� ������� Tags)

SELECT  StockItemID,
		StockItemName,
		CountryOfManufacture = JSON_VALUE(CustomFields, '$.CountryOfManufacture'),
		FirstTag = JSON_VALUE(CustomFields, '$.Tags[0]')
FROM Warehouse.StockItems

--4. ����� � StockItems ������, ��� ���� ��� "Vintage".
--�������:
--- StockItemID
--- StockItemName
--- (�����������) ��� ���� (�� CustomFields) ����� ������� � ����� ����

SELECT  StockItemID,
		StockItemName,
		CustomFields		
FROM Warehouse.StockItems
OUTER APPLY OPENJSON(CustomFields, '$.Tags') as j
WHERE j.value = 'Vintage'

--���� ������ � ���� CustomFields, � �� � Tags.
--������ �������� ����� ������� ������ � JSON.
--��� ������ ������������ ���������, ������������ LIKE ���������.

--������ ���� � ����� ����:
--... where ... = 'Vintage'

--��� ������� �� �����:
--... where ... Tags like '%Vintage%'
--... where ... CustomFields like '%Vintage%'

--5. ����� ������������ PIVOT.
--�� ������� �� ������� ���������� CROSS APPLY, PIVOT, CUBE�.
--��������� �������� ������, ������� � ���������� ������ ���������� ��������� ������� ���������� ����:
--�������� �������
--�������� ���������� �������

--����� �������� ������, ������� ����� ������������ ���������� ��� ���� ��������.
--��� ������� ��������� ��������� �� CustomerName.
--���� ������ ����� ������ dd.mm.yyyy �������� 25.12.2019

DECLARE @Query as nvarchar(max)
DECLARE @f as nvarchar(20) = QUOTENAME('01.MM.yyyy', '''')
DECLARE @str as nvarchar(max)

SET @str =(
    SELECT QUOTENAME(FORMAT(inv.InvoiceDate, '01.MM.yyyy'), '[]') + ', ' as 'data()'
	FROM Sales.Invoices AS inv	
	GROUP BY FORMAT(inv.InvoiceDate,'01.MM.yyyy')
	ORDER BY FORMAT(inv.InvoiceDate, '01.MM.yyyy')
	FOR XML PATH(''));

SET @str = SUBSTRING ( @str, 0, LEN(@str))

Set @Query = N'WITH cte_Customers as (
				SELECT cust.CustomerName,
					   FORMAT(inv.InvoiceDate, ' + @f + ') as PurchaseDate,
					   COUNT(*) as QuantityPurchases
				FROM Sales.Customers cust
					INNER JOIN Sales.Invoices AS inv
						ON inv.CustomerID = cust.CustomerID
				GROUP BY cust.CustomerName, FORMAT(inv.InvoiceDate, ' + @f + '))

				SELECT *
				FROM cte_Customers
				PIVOT (SUM(QuantityPurchases)
				FOR PurchaseDate IN ('+@str+')) as PVT				
				ORDER BY CustomerName';

EXECUTE sp_executesql @Query


