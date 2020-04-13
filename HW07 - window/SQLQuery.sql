--������� �������
--1. �������� ������ � ��������� �������� � ���������� ��� � ��������� ����������. �������� �����.
--� �������� ������� � ��������� �������� � ��������� ���������� ����� ����� ���� ������ ��� ��������� ������:
--������� ������ ����� ������ ����������� ������ �� ������� � 2015 ���� (� ������ ������ ������ �� �����
--����������, ��������� ����� � ������� ������� �������)
--�������� id �������, �������� �������, ���� �������, ����� �������, ����� ����������� ������
--������
--���� ������� ����������� ���� �� ������
--2015-01-29 4801725.31
--2015-01-30 4801725.31
--2015-01-31 4801725.31
--2015-02-01 9626342.98
--2015-02-02 9626342.98
--2015-02-03 9626342.98
--������� ����� ����� �� ������� Invoices.
--����������� ���� ������ ���� ��� ������� �������.

-- 1. ������� � ��������� ��������
DROP TABLE IF EXISTS #InvSums

CREATE TABLE #InvSums(
	InvoiceDate date not null,
	InvSum		int not null
)

INSERT INTO #InvSums
 (InvoiceDate, InvSum)
SELECT DISTINCT inv.InvoiceDate, InvSums.InvSum
FROM Sales.Invoices inv
CROSS APPLY (SELECT SUM(invl.Quantity*invl.UnitPrice) as InvSum
			 FROM Sales.InvoiceLines invl
			 INNER JOIN Sales.Invoices inv_1
				on invl.InvoiceID = inv_1.InvoiceID
			 WHERE DATEFROMPARTS(YEAR(inv_1.InvoiceDate), MONTH(inv_1.InvoiceDate), 1 ) <= DATEFROMPARTS(YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), 1 )
			 ) as InvSums

select  inv.InvoiceID,
		Customers.CustomerName,
		inv.InvoiceDate,
		invl.Quantity*invl.UnitPrice as SaleAmount,
		#InvSums.InvSum As CumulativeAmount
FROM Sales.Invoices inv
	INNER JOIN Sales.Customers
		on Customers.CustomerID = inv.CustomerID
	INNER JOIN Sales.InvoiceLines invl
		on invl.InvoiceID = inv.InvoiceID
	INNER JOIN #InvSums
		on #InvSums.InvoiceDate = inv.InvoiceDate
ORDER BY inv.InvoiceDate

-- 2. ������� � ��������� ����������
DECLARE @InvSums Table 
       (InvoiceDate date not null,
	    InvSum		int not null)

INSERT INTO @InvSums
 (InvoiceDate, InvSum)
SELECT DISTINCT inv.InvoiceDate, InvSums.InvSum
FROM Sales.Invoices inv
CROSS APPLY (SELECT SUM(invl.Quantity*invl.UnitPrice) as InvSum
			 FROM Sales.InvoiceLines invl
			INNER JOIN Sales.Invoices inv_1
				on invl.InvoiceID = inv_1.InvoiceID
			 WHERE DATEFROMPARTS(YEAR(inv_1.InvoiceDate), MONTH(inv_1.InvoiceDate), 1 ) <= DATEFROMPARTS(YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), 1 )
			 ) as InvSums

select  inv.InvoiceID,
		Customers.CustomerName,
		inv.InvoiceDate,
		invl.Quantity*invl.UnitPrice as SaleAmount,
		InvSums.InvSum As CumulativeAmount
FROM Sales.Invoices inv
	INNER JOIN Sales.Customers
		on Customers.CustomerID = inv.CustomerID
	INNER JOIN Sales.InvoiceLines invl
		on invl.InvoiceID = inv.InvoiceID
	INNER JOIN @InvSums as InvSums
		on InvSums.InvoiceDate = inv.InvoiceDate
ORDER BY inv.InvoiceDate

-- �� ������ ������:
-- ��������� ����� ������ ����������� 50�50
-- � ����� � ��������� ������� ���� �����������, �� ���� ������ ����������� � ��������� �������,
-- �� ������ ��� ������������, �.�. � ��������� ���������� �� �� ����� ��������������. � ����� ����� ������, �������,
-- ������ ����������� �����. �� �� ������� � ���� �� ���������� ������� ����������� ���� ��� ������� �������.

--2. ���� �� ����� ������������ ���� ������, �� �������� ������ ����� ����������� ������ � ������� ������� �������.
--SET STATISTICS TIME ON

select  inv.InvoiceID,
		Customers.CustomerName,
		inv.InvoiceDate,
		invl.Quantity*invl.UnitPrice as SaleAmount,
		SUM(invl.Quantity*invl.UnitPrice) OVER(ORDER BY DATEFROMPARTS(YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), 1 )) As CumulativeAmount
FROM Sales.Invoices inv
	INNER JOIN Sales.Customers
		on Customers.CustomerID = inv.CustomerID
	INNER JOIN Sales.InvoiceLines invl
		on invl.InvoiceID = inv.InvoiceID
ORDER BY inv.InvoiceDate

--�������� 2 �������� ������� - ����� windows function � ��� ���. �������� ����� ������� �����������, �������� �� set statistics time on;
-- ��� ������� ������� ������ � ���� ����������� 2 ������, 27 ���. � ������� �������� 1 �������. ����������:
-- ��� ����:   CPU time = 137812 ms,  elapsed time = 144999 ms.
-- � �����:    CPU time = 266 ms,  elapsed time = 2254 ms. ��� ������� ���� �� ����!

--2. ������� ������ 2� ����� ���������� ��������� (�� ���-�� ���������) � ������ ������ �� 2016� ��� (�� 2 ����� ���������� �������� � ������ ������)

with cte_quantity as (
SELECT  sti.StockItemID,
		sti.StockItemName,
		MONTH(inv.InvoiceDate) as Month_InvDate,
		SUM(invl.Quantity) as Sum_Quantity
FROM Sales.InvoiceLines invl 
	INNER JOIN Sales.Invoices inv
		on inv.InvoiceID = invl.InvoiceID
	INNER JOIN Warehouse.StockItems sti
		on sti.StockItemID = invl.StockItemID
GROUP BY sti.StockItemID, sti.StockItemName, MONTH(inv.InvoiceDate)
)

SELECT *
FROM (SELECT StockItemID, StockItemName, Month_InvDate, Sum_Quantity, 
		ROW_NUMBER() OVER (PARTITION BY Month_InvDate ORDER BY Sum_Quantity DESC) as Quantity_Rank
	  FROM cte_quantity) as tbl
WHERE Quantity_Rank <= 2

--3. ������� ����� ��������
--���������� �� ������� �������, � ����� ����� ������ ������� �� ������, ��������, ����� � ����
--������������ ������ �� �������� ������, ��� ����� ��� ��������� ����� �������� ��������� ���������� ������
--���������� ����� ���������� ������� � �������� ����� � ���� �� �������
--���������� ����� ���������� ������� � ����������� �� ������ ����� �������� ������
--���������� ��������� id ������ ������ �� ����, ��� ������� ����������� ������� �� �����
--���������� �� ������ � ��� �� �������� ����������� (�� �����)
--�������� ������ 2 ������ �����, � ������ ���� ���������� ������ ��� ����� ������� "No items"
--����������� 30 ����� ������� �� ���� ��� ������ �� 1 ��
--��� ���� ������ �� ����� ������ ������ ��� ������������� �������

SELECT  sti.StockItemID,
		sti.StockItemName,
		sti.Brand,
		sti.UnitPrice,
		LEFT(sti.StockItemName, 1),
		ROW_NUMBER() OVER(PARTITION BY LEFT(sti.StockItemName, 1) ORDER BY sti.StockItemName) as rNumber,
		COUNT(*) OVER() as TotalCount, COUNT(*) OVER(PARTITION BY LEFT(sti.StockItemName, 1)) as CountByLetter,
		LEAD(sti.StockItemID) OVER(ORDER BY sti.StockItemName) as NextID,
		LAG(sti.StockItemID) OVER(ORDER BY sti.StockItemName) as PrevID,
		LAG(sti.StockItemName, 2, 'No items') OVER(ORDER BY sti.StockItemName) as PrevStItName,
		NTILE(30) OVER(ORDER BY sti.TypicalWeightPerUnit) as Groups
FROM Warehouse.StockItems sti
ORDER BY sti.StockItemName

--4. �� ������� ���������� �������� ���������� �������, �������� ��������� ���-�� ������
--� ����������� ������ ���� �� � ������� ����������, �� � �������� �������, ���� �������, ����� ������

-- ���������� ��� ��������. ��� �������� ����� ������� �����? �� ����� ����� ��� ������.
-- �� �� ���������� ������� � ���� ���������� ��� ������
-- ������� 1
WITH cte_tbl as (
SELECT  People.PersonID,
		People.FullName,
		Customers.CustomerID,
		Customers.CustomerName,
		inv.InvoiceDate,
		(SELECT SUM(Invl.Quantity*Invl.UnitPrice) 
			FROM Sales.InvoiceLines Invl
		 WHERE Invl.InvoiceID = inv.InvoiceID) as SaleAmount,
		ROW_NUMBER() OVER(PARTITION BY People.PersonID ORDER BY inv.InvoiceID DESC) AS rNumber
FROM Sales.Invoices inv
	INNER JOIN Application.People
		on People.PersonID = inv.SalespersonPersonID
	INNER JOIN Sales.Customers
		on Customers.CustomerID = inv.CustomerID)

SELECT *
FROM cte_tbl
WHERE rNumber = 1
ORDER BY PersonID

-- ������� 2
WITH inv as (
SELECT DISTINCT LAST_VALUE(InvoiceId) OVER(PARTITION BY SalespersonPersonID
			                               ORDER BY InvoiceId
										   ROWS BETWEEN CURRENT ROW AND UNBOUNDED FOLLOWING) as MaxID
FROM Sales.Invoices)

SELECT  People.PersonID,
		People.FullName,
		Customers.CustomerID,
		Customers.CustomerName,
		Invoices.InvoiceDate,
		(SELECT SUM(Invl.Quantity*Invl.UnitPrice) 
		 FROM Sales.InvoiceLines Invl
		 WHERE Invl.InvoiceID = Invoices.InvoiceID) as SaleAmount
FROM inv
	INNER JOIN Sales.Invoices
		on Invoices.InvoiceID = inv.MaxID
	INNER JOIN Application.People
		on People.PersonID = Invoices.SalespersonPersonID
	INNER JOIN Sales.Customers
		on Customers.CustomerID = Invoices.CustomerID
ORDER BY People.PersonID

--5. �������� �� ������� ������� 2 ����� ������� ������, ������� �� �������
--� ����������� ������ ���� �� ������, ��� ��������, �� ������, ����, ���� �������
WITH cte_tbl as (
SELECT DISTINCT Customers.CustomerID,
				Customers.CustomerName,
				invl.StockItemID, 
				invl.UnitPrice,
				inv.InvoiceDate,
				DENSE_RANK() OVER(PARTITION BY Customers.CustomerID ORDER BY invl.UnitPrice DESC) as rRank
FROM Sales.Invoices inv
	INNER JOIN Sales.InvoiceLines invl
		on inv.InvoiceID = invl.InvoiceID
	INNER JOIN Sales.Customers
		on Customers.CustomerID = inv.CustomerID)

SELECT *
FROM cte_tbl
WHERE rRank <= 2
ORDER BY CustomerID, StockItemID, InvoiceDate

