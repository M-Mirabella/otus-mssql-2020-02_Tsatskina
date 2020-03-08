-- 1. ��� ������, � ������� � �������� ���� ������� urgent ��� �������� ���������� � Animal
SELECT sti.StockItemID, sti.StockItemName
FROM [Warehouse].[StockItems] sti
WHERE sti.StockItemName like '%urgent%' or sti.StockItemName like 'Animal%';

-- 2.�����������, � ������� �� ���� ������� �� ������ ������
-- (����� ������� ��� ��� ������ ����� ���������, ������ �������� ����� JOIN)
SELECT psup.SupplierID, psup.SupplierName
FROM Purchasing.Suppliers psup
LEFT JOIN Purchasing.PurchaseOrders pord on pord.SupplierID = psup.SupplierID
WHERE pord.PurchaseOrderID is null;

-- �� ��������� � ������� ��� ���:
SELECT psup.SupplierID, psup.SupplierName
FROM Purchasing.Suppliers psup
WHERE not exists (SELECT *
FROM Purchasing.PurchaseOrders pord
WHERE pord.SupplierID = psup.SupplierID);

--3 ������� � ��������� ������, � ������� ���� �������, ������� ��������, � �������� ��������� �������,
/*�������� ����� � ����� ����� ���� ��������� ���� - ������ ����� �� 4 ������, ���� ������ ������ ������ ���� ������,
� ����� ������ ����� 100$ ���� ���������� ������ ������ ����� 20.
�������� ������� ����� ������� � ������������ �������� ��������� ������ 1000 � ��������� ��������� 100 �������.
���������� ������ ���� �� ������ ��������, ����� ����, ���� �������.*/

SELECT datename(month, sord.OrderDate) NameMonth, CEILING(month(sord.OrderDate)/3.00) as QuarterNumber,
CEILING(month(sord.OrderDate)/4.00) as ThirdNumber, sord.OrderDate, wsti.StockItemName, sorlin.Quantity, sorlin.UnitPrice
FROM Sales.Orders sord
INNER JOIN Sales.OrderLines sorlin on sorlin.OrderID = sord.OrderID
INNER JOIN Warehouse.StockItems wsti on wsti.StockItemID = sorlin.StockItemID
WHERE sord.ExpectedDeliveryDate between cast('2014-04-02' as date) and cast('2014-04-30' as date)
and (sorlin.UnitPrice > 100 or sorlin.Quantity > 20);

SELECT datename(month, sord.OrderDate) NameMonth, CEILING(month(sord.OrderDate)/3.00) as QuarterNumber,
CEILING(month(sord.OrderDate)/4.00) as ThirdNumber, sord.OrderDate, wsti.StockItemName, sorlin.Quantity, sorlin.UnitPrice
FROM Sales.Orders sord
INNER JOIN Sales.OrderLines sorlin on sorlin.OrderID = sord.OrderID
INNER JOIN Warehouse.StockItems wsti on wsti.StockItemID = sorlin.StockItemID
WHERE sord.ExpectedDeliveryDate between cast('2014-10-15' as date) and cast('2014-10-30' as date)
and (sorlin.UnitPrice > 100 or sorlin.Quantity > 20)
order by QuarterNumber, ThirdNumber, sord.OrderDate
offset 1000 rows fetch next 100 rows only;

--4 ������ �����������, ������� ���� ��������� �� 2014� ��� � ��������� Road Freight ��� Post,
--�������� �������� ����������, ��� ����������� ���� ������������ �����
SELECT psup.SupplierName, adelm.DeliveryMethodName, pord.ExpectedDeliveryDate, apeop.FullName
FROM Purchasing.PurchaseOrders pord
INNER JOIN Application.DeliveryMethods adelm on adelm.DeliveryMethodID = pord.DeliveryMethodID
INNER JOIN Purchasing.Suppliers psup on psup.SupplierID = pord.SupplierID
INNER JOIN Application.People apeop on apeop.PersonID = pord.ContactPersonID
WHERE pord.ExpectedDeliveryDate between cast('2014-01-01' as date) and cast('2014-12-31' as date) and
adelm.DeliveryMethodName in ('Road Freight', 'Post');

--5 10 ��������� �� ���� ������ � ������ ������� � ������ ����������, ������� ������� �����.
SELECT top 10 scust.CustomerName, sord.OrderDate, apeop.FullName
FROM Sales.Orders sord
INNER JOIN Sales.Customers scust on scust.CustomerID = sord.CustomerID
INNER JOIN Application.People apeop on apeop.PersonID = sord.SalespersonPersonID
order by sord.OrderDate desc

--6 ��� �� � ����� �������� � �� ���������� ��������, ������� �������� ����� Chocolate frogs 250g
SELECT distinct scust.CustomerID, scust.CustomerName, scust.PhoneNumber
FROM Sales.OrderLines sorl
INNER JOIN Sales.Orders sord on sord.OrderID = sorl.OrderID
INNER JOIN Sales.Customers scust on scust.CustomerID = sord.CustomerID
INNER JOIN Warehouse.StockItems wsti on wsti.StockItemID = sorl.StockItemID
WHERE wsti.StockItemName = 'Chocolate frogs 250g'



