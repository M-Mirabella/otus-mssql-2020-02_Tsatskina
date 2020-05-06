--SP � function
--1) �������� ������� ������������ ������� � ���������� ������ �������.
     -- ������� ��������: Read Committed ��� ����. ��� �� ��������� ������� ������.
CREATE FUNCTION dbo.fGreatCustomer()
RETURNS nvarchar(100)
AS
	BEGIN

		DECLARE @CustomerName nvarchar(100);

		WITH cte_maxtransaction AS (
				SELECT TOP 1 CustomerID, TransactionAmount
				FROM Sales.CustomerTransactions
				ORDER BY TransactionAmount DESC
		)

		SELECT @CustomerName = Customers.CustomerName
		FROM cte_maxtransaction
		INNER JOIN Sales.Customers 
			ON Customers.CustomerID = cte_maxtransaction.CustomerID
			
		RETURN @CustomerName;
	END
GO

SELECT dbo.fGreatCustomer()

--2) �������� �������� ��������� � �������� ���������� �ustomerID, ��������� ����� ������� �� ����� �������.
--������������ ������� :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

-- ������� ��������: Read Committed ��� ����. ��� �� ��������� ������� ������.

CREATE PROCEDURE dbo.pCustomerAmount @CustomerID int
AS
	BEGIN
		 SET NOCOUNT ON;  

		 SELECT SUM(InvoiceLines.Quantity*InvoiceLines.UnitPrice) as total
		 FROM Sales.Customers 
		 INNER JOIN Sales.Invoices 
			ON Customers.CustomerID = Invoices.CustomerID
		 INNER JOIN Sales.InvoiceLines 
			ON InvoiceLines.InvoiceID = Invoices.InvoiceID
		 WHERE Customers.CustomerID = @CustomerID

	END
GO

EXECUTE  dbo.pCustomerAmount 5

--3) ������� ���������� ������� � �������� ���������, ���������� � ��� ������� � ������������������ � ������.
-- ������� ��������. ���� ���� ���������� ��� ������ ������� (���������) ����� �������������� �������������
-- ��� ������� "�������� �������", �� ����� ��������� Read Uncommitted. �� ���� ����� ��������������� � �������
-- �����, �� ����� Read Committed
CREATE FUNCTION dbo.fProfitableMonths(@Profit int)
RETURNS Table
AS
	RETURN(
			SELECT  CONVERT(date, FORMAT(inv.InvoiceDate, '01.MM.yyyy')) AS InvoiceMonth,
					SUM(inlines.Quantity*inlines.UnitPrice) TotalSUM
			FROM Sales.InvoiceLines inlines
			INNER JOIN Sales.Invoices inv
				ON inv.InvoiceID = inlines.InvoiceID
			GROUP BY CONVERT(date, FORMAT(inv.InvoiceDate, '01.MM.yyyy'))
			HAVING SUM(inlines.Quantity*inlines.UnitPrice) > @Profit
		  )	
GO

CREATE PROCEDURE dbo.pProfitableMonths(@Profit int)
AS
	BEGIN
		SELECT  CONVERT(date, FORMAT(inv.InvoiceDate, '01.MM.yyyy')) AS InvoiceMonth,
				SUM(inlines.Quantity*inlines.UnitPrice) TotalSUM
		FROM Sales.InvoiceLines inlines
		INNER JOIN Sales.Invoices inv
			ON inv.InvoiceID = inlines.InvoiceID
		GROUP BY CONVERT(date, FORMAT(inv.InvoiceDate, '01.MM.yyyy'))
		HAVING SUM(inlines.Quantity*inlines.UnitPrice) > @Profit
	END	
GO

SELECT *
FROM dbo.fProfitableMonths(500000)

EXEC dbo.pProfitableMonths 500000

-- ������� � ������������������ ���. ����� ����������, ��������� ������ 50�50

--4) �������� ��������� ������� �������� ��� �� ����� ������� ��� ������ ������ result set'� ��� ������������� �����.

 -- ������� ��������: Read Committed ��� ����. ��� �� ��������� ������� ������.

CREATE FUNCTION CustomerPurchases(@CustomerID int)
RETURNS Table
	AS	
	RETURN (
			SELECT  inlines.StockItemID,
					inlines.Description,
					SUM(inlines.Quantity*inlines.UnitPrice) AS TotalSUM,
					SUM(inlines.Quantity) AS TotalQ
			FROM Sales.InvoiceLines inlines
				INNER JOIN Sales.Invoices inv
					ON inv.InvoiceID = inlines.InvoiceID
			WHERE inv.CustomerID = @CustomerID
			GROUP BY inlines.StockItemID, inlines.Description

			)
GO

SELECT  Customers.CustomerID,
		Customers.CustomerName,
		f.*
FROM Sales.Customers
CROSS APPLY CustomerPurchases(Customers.CustomerID) as f
ORDER BY Customers.CustomerID
	
--�� ���� ����������, � �������� ������� ��� ��������������
--5) ����� ������� �������� ����� � ������.
-- �������.

--�����������
--6) ������������ ���� � �� �� ��������� kitchen sink � ���������� ������� ���������� �� ������ � ������� �� ������������ SQL.

--���������� ����� �������.
--7) �������� ������ � ���������� ��� ���� �������, �������\����������\�������� ������ � ����������� ��������� ������� ������ � ������ ������� ��������, ����� ������������ ���� �����, ��� �� ����� ������ ���� ����� �� ����������� � ���� ������ (1-2 �����������)
--8) �������� ����������� � 2� ����� ���������� ������ � ���� ������� � ������ ������� ��������, ��������� ������ � ����� �������, ��������� ����� � ��� �� ������. ��� � ����� ����������, ��� ������ ������.