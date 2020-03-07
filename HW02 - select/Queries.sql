-- 1.
select sti.StockItemID, sti.StockItemName
from [Warehouse].[StockItems] sti
where sti.StockItemName like '%urgent%' or sti.StockItemName like 'Animal%';

-- 2.
select psup.SupplierID, psup.SupplierName
from Purchasing.Suppliers psup left join
Purchasing.PurchaseOrders pord on pord.SupplierID = psup.SupplierID
where pord.PurchaseOrderID is null;

-- но привычнее и быстрее вот так:
select psup.SupplierID, psup.SupplierName
from Purchasing.Suppliers psup
where not exists (select *
from Purchasing.PurchaseOrders pord where pord.SupplierID = psup.SupplierID);

--3 
select datename(month, sord.OrderDate) NameMonth, CEILING(month(sord.OrderDate)/3.00) as QuarterNumber,
CEILING(month(sord.OrderDate)/4.00) as ThirdNumber, sord.OrderDate, wsti.StockItemName, sorlin.Quantity, sorlin.UnitPrice
from Sales.Orders sord inner join
Sales.OrderLines sorlin on sorlin.OrderID = sord.OrderID inner join
Warehouse.StockItems wsti on wsti.StockItemID = sorlin.StockItemID
where sord.ExpectedDeliveryDate between cast('2014-04-02' as date) and cast('2014-04-30' as date)
and (sorlin.UnitPrice > 100 or sorlin.Quantity > 20);

select datename(month, sord.OrderDate) NameMonth, CEILING(month(sord.OrderDate)/3.00) as QuarterNumber,
CEILING(month(sord.OrderDate)/4.00) as ThirdNumber, sord.OrderDate, wsti.StockItemName, sorlin.Quantity, sorlin.UnitPrice
from Sales.Orders sord inner join
Sales.OrderLines sorlin on sorlin.OrderID = sord.OrderID inner join
Warehouse.StockItems wsti on wsti.StockItemID = sorlin.StockItemID
where sord.ExpectedDeliveryDate between cast('2014-10-15' as date) and cast('2014-10-30' as date)
and (sorlin.UnitPrice > 100 or sorlin.Quantity > 20)
order by QuarterNumber, ThirdNumber, sord.OrderDate
offset 1000 rows fetch next 100 rows only;

--4
select psup.SupplierName, adelm.DeliveryMethodName, pord.ExpectedDeliveryDate, apeop.FullName
from Purchasing.PurchaseOrders pord inner join
Application.DeliveryMethods adelm on adelm.DeliveryMethodID = pord.DeliveryMethodID inner join
Purchasing.Suppliers psup on psup.SupplierID = pord.SupplierID inner join
Application.People apeop on apeop.PersonID = pord.ContactPersonID
where pord.ExpectedDeliveryDate between cast('2014-01-01' as date) and cast('2014-12-31' as date) and
adelm.DeliveryMethodName in ('Road Freight', 'Post');

--5
select top 10 scust.CustomerName, sord.OrderDate, apeop.FullName
from Sales.Orders sord inner join
Sales.Customers scust on scust.CustomerID = sord.CustomerID inner join
Application.People apeop on apeop.PersonID = sord.SalespersonPersonID
order by sord.OrderDate desc

--6
select distinct scust.CustomerID, scust.CustomerName, scust.PhoneNumber
from Sales.OrderLines sorl inner join
Sales.Orders sord on sord.OrderID = sorl.OrderID inner join
Sales.Customers scust on scust.CustomerID = sord.CustomerID inner join
Warehouse.StockItems wsti on wsti.StockItemID = sorl.StockItemID --inner join
where wsti.StockItemName = 'Chocolate frogs 250g'



