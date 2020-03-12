--���������� � CTE
--��� ���� ������� ��� ��������, �������� 2 �������� ��������:
--1) ����� ��������� ������
--2) ����� WITH (��� ����������� ������)

--�������� �������:
--1. �������� �����������, ������� �������� ������������, � ��� �� ������� �� ����� �������.
-- ������� 1:
SELECT FullName
FROM Application.People 
WHERE IsSalesperson = 1 and not exists (SELECT *
FROM Sales.Orders 
WHERE Orders.SalespersonPersonID = People.PersonID);

-- ������� 2:
WITH SalesPerson as (SELECT DISTINCT SalespersonPersonID
				  FROM Sales.Orders)

SELECT FullName
FROM Application.People
WHERE IsSalesperson = 1 and PersonID not in (SELECT SalespersonPersonID
FROM SalesPerson)

--2. �������� ������ � ����������� ����� (�����������), 2 �������� ����������.
--������� 1:
SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems 
WHERE UnitPrice <= ALL (SELECT UnitPrice
FROM Warehouse.StockItems)

--������� 2:
SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems 
WHERE UnitPrice = (SELECT MIN(UnitPrice)
FROM Warehouse.StockItems)

--3. �������� ���������� �� ��������, ������� �������� �������� 5 ������������ ��������
-- �� [Sales].[CustomerTransactions] ����������� 3 ������� (� ��� ����� � CTE)

--������� 1:
SELECT Customers.CustomerID, Customers.CustomerName, MaxTrans.TransactionAmount
FROM Sales.Customers
INNER JOIN (SELECT TOP 5 CustomerTransactions.CustomerID, TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount  DESC) AS MaxTrans on MaxTrans.CustomerID = Customers.CustomerID;

--������� 2:
WITH MaxTransactions AS (
SELECT TOP 5 CustomerID, TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount  DESC)

SELECT Customers.CustomerID, Customers.CustomerName, MaxTransactions.TransactionAmount
FROM Sales.Customers
INNER JOIN MaxTransactions on MaxTransactions.CustomerID = Customers.CustomerID

-- ������� 3:
SELECT TOP 5 Customers.CustomerID, Customers.CustomerName, CustomerTransactions.TransactionAmount
FROM Sales.Customers 
INNER JOIN Sales.CustomerTransactions ON CustomerTransactions.CustomerID = Customers.CustomerID
ORDER BY CustomerTransactions.TransactionAmount DESC

--4. �������� ������ (�� � ��������), � ������� ���� ���������� ������, �������� � ������ ����� ������� �������, � ����� ��� ����������, ������� ����������� �������� �������
--������� 1
;with ExpensiveStockItems as (SELECT top 3 StockItems.StockItemID
FROM  Warehouse.StockItems
order by StockItems.UnitPrice desc)

SELECT Distinct Cities.CityID, Cities.CityName, (SELECT People.FullName
FROM Application.People WHERE People.PersonID = Invoices.PackedByPersonID) as PackedByPerson
FROM ExpensiveStockItems
INNER JOIN Sales.InvoiceLines on InvoiceLines.StockItemID = ExpensiveStockItems.StockItemID 
INNER JOIN Sales.Invoices on Invoices.InvoiceID = InvoiceLines.InvoiceID
INNER JOIN Sales.Customers on Customers.CustomerID = Invoices.CustomerID
INNER JOIN Application.Cities on Cities.CityID = Customers.DeliveryCityID

--������� 2
SELECT Distinct Cities.CityID, Cities.CityName, (SELECT People.FullName
FROM Application.People WHERE People.PersonID = Invoices.PackedByPersonID) as PackedByPerson
FROM Sales.InvoiceLines 
INNER JOIN Sales.Invoices on Invoices.InvoiceID = InvoiceLines.InvoiceID
INNER JOIN Sales.Customers on Customers.CustomerID = Invoices.CustomerID
INNER JOIN Application.Cities on Cities.CityID = Customers.DeliveryCityID
INNER JOIN  (SELECT top 3 StockItems.StockItemID
FROM  Warehouse.StockItems
order by StockItems.UnitPrice desc) as ExpensiveStockItems on InvoiceLines.StockItemID = ExpensiveStockItems.StockItemID 


--5. ���������, ��� ������ � ������������� ������:
--�������� ������
SELECT
Invoices.InvoiceID,
Invoices.InvoiceDate,
(SELECT People.FullName
FROM Application.People
WHERE People.PersonID = Invoices.SalespersonPersonID
) AS SalesPersonName,
SalesTotals.TotalSumm AS TotalSummByInvoice,
(SELECT SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice)
FROM Sales.OrderLines
WHERE OrderLines.OrderId = (SELECT Orders.OrderId
FROM Sales.Orders
WHERE Orders.PickingCompletedWhen IS NOT NULL
AND Orders.OrderId = Invoices.OrderId)
) AS TotalSummForPickedItems
FROM Sales.Invoices
JOIN
(SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
FROM Sales.InvoiceLines
GROUP BY InvoiceId
HAVING SUM(Quantity*UnitPrice) > 27000) AS SalesTotals
ON Invoices.InvoiceID = SalesTotals.InvoiceID
ORDER BY TotalSumm DESC


-- ���������������� �������
;WITH CTESalesTotals as (SELECT InvoiceId, SUM(Quantity*UnitPrice) AS TotalSumm
						 FROM Sales.InvoiceLines
						 GROUP BY InvoiceId
						 HAVING SUM(Quantity*UnitPrice) > 27000),

CTEInvoices as (SELECT Invoices.InvoiceID, Invoices.InvoiceDate, Invoices.SalespersonPersonID, Invoices.OrderID,
				CTESalesTotals.TotalSumm
				FROM Sales.Invoices
				JOIN CTESalesTotals on Invoices.InvoiceID = CTESalesTotals.InvoiceID),

CTETotalSummForPickedItems as (SELECT CTEInvoices.InvoiceID, SUM(OrderLines.PickedQuantity*OrderLines.UnitPrice) as TotalSummForPickedItems
								FROM Sales.OrderLines Join
								CTEInvoices on OrderLines.OrderID = CTEInvoices.OrderID
								WHERE EXISTS (SELECT *
								FROM Sales.Orders
								WHERE Orders.OrderID = OrderLines.OrderID and Orders.PickingCompletedWhen IS NOT NULL)
								GROUP BY CTEInvoices.InvoiceID)

SELECT
CTEInvoices.InvoiceID,
CTEInvoices.InvoiceDate,
People.FullName AS SalesPersonName,
CTEInvoices.TotalSumm AS TotalSummByInvoice,
TotalSummForPickedItems
FROM CTEInvoices
JOIN Application.People on People.PersonID = CTEInvoices.SalespersonPersonID 
JOIN CTETotalSummForPickedItems on CTETotalSummForPickedItems.InvoiceID = CTEInvoices.InvoiceID
ORDER BY CTEInvoices.TotalSumm DESC


-- ������ ������ �������� ����� � ��������� ���������� > 27000 � �������� ����� ���������� ������
-- (������ ��� �� � ���������� �������� � ������ ���� �� ������ ����� 27000, ������� �� ��������� �������)

--��������� ���� ������� � ��� ������, � ����� ��� ����� ����������� �� ������ �����������. 
-- ���� ������� � ����� Plan for 5 query.sqlplan
-- ��� ����������� � ����� ��� ����������� �� ������� � 5.docx

--����� ��������� ��� � ������� ��������� ������������� ������� (��� ��� ���� � ��������� ������), ��� � � ������� ��������� �����\���������.