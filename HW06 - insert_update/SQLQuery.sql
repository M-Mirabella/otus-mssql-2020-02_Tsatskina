--Insert, Update, Merge
--1. ����������� � ���� 5 ������� ��������� insert � ������� Customers ��� Suppliers

declare @p int = 0,
        @s int;

WHILE @p <> 5
BEGIN
  SET @s = NEXT VALUE FOR Sequences.CustomerID
  INSERT INTO [Sales].[Customers]
           ([CustomerID]
           ,[CustomerName]
           ,[BillToCustomerID]
           ,[CustomerCategoryID]
           ,[BuyingGroupID]
           ,[PrimaryContactPersonID]
           ,[AlternateContactPersonID]
           ,[DeliveryMethodID]
           ,[DeliveryCityID]
           ,[PostalCityID]
           ,[CreditLimit]
           ,[AccountOpenedDate]
           ,[StandardDiscountPercentage]
           ,[IsStatementSent]
           ,[IsOnCreditHold]
           ,[PaymentDays]
           ,[PhoneNumber]
           ,[FaxNumber]
           ,[DeliveryRun]
           ,[RunPosition]
           ,[WebsiteURL]
           ,[DeliveryAddressLine1]
           ,[DeliveryAddressLine2]
           ,[DeliveryPostalCode]
           ,[DeliveryLocation]
           ,[PostalAddressLine1]
           ,[PostalAddressLine2]
           ,[PostalPostalCode]
           ,[LastEditedBy])
     OUTPUT inserted.*
     VALUES
           (@s
           ,'Magnit' + CAST(ROUND(RAND(), 3)*1000 as nvarchar(100))
           ,@s
           ,4
           ,1
           ,2013
           ,2014
           ,3
           ,22903
           ,22903
           ,NULL
           ,GETDATE()
           ,0
           ,0
           ,0
           ,7
           ,'(225) 555-0100'
           ,'(225) 555-0101'
           ,''
           ,''
           ,''
           ,''
           ,''
           ,90387
           ,NULL
           ,''
           ,''
           ,1
           ,1)

SET @p += 1
END

select *
from Sales.Customers 
where CustomerName like 'Magnit%'
order by CustomerID

--2. ������� 1 ������ �� Customers, ������� ���� ���� ���������
-- ������� 1. ������� �����-�� �� ����������� �����
delete top (1) from Sales.Customers 
OUTPUT deleted.*
where CustomerName like 'Magnit%'

-- ������� 2. ������� ��������� ����������� ������
delete top (1) from Sales.Customers 
OUTPUT deleted.*
where CustomerID = (Select current_value FROM sys.sequences WHERE name = 'CustomerID')

--3. �������� ���� ������, �� ����������� ����� UPDATE
UPDATE TOP(1) Sales.Customers
SET PhoneNumber = '111222333'
OUTPUT inserted.*
where CustomerName like 'Magnit%'

--4. �������� MERGE, ������� ������� ������ � �������, ���� �� ��� ���, � ������� ���� ��� ��� ����

DECLARE @id int = NEXT VALUE FOR Sequences.CustomerID

MERGE Sales.Customers AS target 
	USING (SELECT top 1 CustomerID
	                   ,CustomerName					   
					   ,CustomerCategoryID
					   ,BuyingGroupID
					   ,PrimaryContactPersonID
					   ,AlternateContactPersonID
					   ,DeliveryMethodID
					   ,DeliveryCityID
					   ,PostalCityID
					   ,CreditLimit
					   ,AccountOpenedDate
					   ,StandardDiscountPercentage
					   ,IsStatementSent
					   ,IsOnCreditHold
					   ,PaymentDays
					   ,'888888' as PhoneNumber
					   ,FaxNumber
					   ,DeliveryRun
					   ,RunPosition
					   ,WebsiteURL
					   ,DeliveryAddressLine1
					   ,DeliveryAddressLine2
					   ,DeliveryPostalCode
					   ,DeliveryLocation
					   ,PostalAddressLine1
					   ,PostalAddressLine2
					   ,PostalPostalCode
					   ,LastEditedBy
		   FROM Sales.Customers 
		   WHERE CustomerName like 'Magnit%'
           UNION ALL
		   SELECT @id
		       ,'Perekrestok' + CAST(ROUND(RAND(), 3)*1000 as nvarchar(100))			   
			   ,4
			   ,1
			   ,2013
			   ,2014
			   ,3
			   ,22903
			   ,22903
			   ,NULL
			   ,GETDATE()
			   ,0
			   ,0
			   ,0
			   ,7
			   ,'(225) 555-0100'
			   ,'(225) 555-0101'
			   ,''
			   ,''
			   ,''
			   ,''
			   ,''
			   ,90387
			   ,NULL
			   ,''
			   ,''
			   ,1
			   ,1			 
		) 
		AS source
		ON
	 (target.CustomerName = source.CustomerName) 
	WHEN MATCHED 
		THEN UPDATE SET PhoneNumber = source.PhoneNumber						
	WHEN NOT MATCHED 
		THEN INSERT (   CustomerID
		               ,CustomerName
					   ,BillToCustomerID
					   ,CustomerCategoryID
					   ,BuyingGroupID
					   ,PrimaryContactPersonID
					   ,AlternateContactPersonID
					   ,DeliveryMethodID
					   ,DeliveryCityID
					   ,PostalCityID
					   ,CreditLimit
					   ,AccountOpenedDate
					   ,StandardDiscountPercentage
					   ,IsStatementSent
					   ,IsOnCreditHold
					   ,PaymentDays
					   ,PhoneNumber
					   ,FaxNumber
					   ,DeliveryRun
					   ,RunPosition
					   ,WebsiteURL
					   ,DeliveryAddressLine1
					   ,DeliveryAddressLine2
					   ,DeliveryPostalCode
					   ,DeliveryLocation
					   ,PostalAddressLine1
					   ,PostalAddressLine2
					   ,PostalPostalCode
					   ,LastEditedBy) 
			VALUES (    source.CustomerID
			           ,source.CustomerName
					   ,source.CustomerID
					   ,source.CustomerCategoryID
					   ,source.BuyingGroupID
					   ,source.PrimaryContactPersonID
					   ,source.AlternateContactPersonID
					   ,source.DeliveryMethodID
					   ,source.DeliveryCityID
					   ,source.PostalCityID
					   ,source.CreditLimit
					   ,source.AccountOpenedDate
					   ,source.StandardDiscountPercentage
					   ,source.IsStatementSent
					   ,source.IsOnCreditHold
					   ,source.PaymentDays
					   ,source.PhoneNumber
					   ,source.FaxNumber
					   ,source.DeliveryRun
					   ,source.RunPosition
					   ,source.WebsiteURL
					   ,source.DeliveryAddressLine1
					   ,source.DeliveryAddressLine2
					   ,source.DeliveryPostalCode
					   ,source.DeliveryLocation
					   ,source.PostalAddressLine1
					   ,source.PostalAddressLine2
					   ,source.PostalPostalCode
					   ,source.LastEditedBy) 
	OUTPUT $action, deleted.*, inserted.*;


--5. �������� ������, ������� �������� ������ ����� bcp out � ��������� ����� bulk insert
EXEC sp_configure 'show advanced options', 1;  
GO  
-- To update the currently configured value for advanced options.  
RECONFIGURE;  
GO  
-- To enable the feature.  
EXEC sp_configure 'xp_cmdshell', 1;  
GO  
-- To update the currently configured value for this feature.  
RECONFIGURE;  
GO  

SELECT @@SERVERNAME

exec master..xp_cmdshell 'bcp "[WideWorldImporters].Application.Cities" out  "f:\SQL\BCP\Cities2.txt" -T -w -t$# -S localhost\SQL2017_DEV'

-------
CREATE TABLE [Application].[Cities_BulkDemo](
	[CityID] [int] NOT NULL,
	[CityName] [nvarchar](50) NOT NULL,
	[StateProvinceID] [int] NOT NULL,
	[Location] [geography] NULL,
	[LatestRecordedPopulation] [bigint] NULL,
	[LastEditedBy] [int] NOT NULL,
	[ValidFrom] [datetime2](7)  NOT NULL,
	[ValidTo] [datetime2](7)  NOT NULL)
GO

BULK INSERT [WideWorldImporters].[Application].[Cities_BulkDemo]
   FROM "f:\SQL\BCP\Cities2.txt"
   WITH 
	 (
		BATCHSIZE = 1000, 
		DATAFILETYPE = 'widechar',
		FIELDTERMINATOR = '$#',
		ROWTERMINATOR ='\n',
		KEEPNULLS,
		TABLOCK        
	  );