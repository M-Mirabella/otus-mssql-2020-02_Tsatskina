-- 1. Все товары, в которых в название есть пометка urgent или название начинается с Animal
SELECT sti.StockItemID, sti.StockItemName
FROM [Warehouse].[StockItems] sti
WHERE sti.StockItemName like '%urgent%' or sti.StockItemName like 'Animal%';

-- 2.Поставщиков, у которых не было сделано ни одного заказа
-- (потом покажем как это делать через подзапрос, сейчас сделайте через JOIN)
SELECT psup.SupplierID, psup.SupplierName
FROM Purchasing.Suppliers psup
LEFT JOIN Purchasing.PurchaseOrders pord on pord.SupplierID = psup.SupplierID
WHERE pord.PurchaseOrderID is null;

-- но привычнее и быстрее вот так:
SELECT psup.SupplierID, psup.SupplierName
FROM Purchasing.Suppliers psup
WHERE not exists (SELECT *
FROM Purchasing.PurchaseOrders pord
WHERE pord.SupplierID = psup.SupplierID);

--3 Продажи с названием месяца, в котором была продажа, номером квартала, к которому относится продажа,
/*включите также к какой трети года относится дата - каждая треть по 4 месяца, дата забора заказа должна быть задана,
с ценой товара более 100$ либо количество единиц товара более 20.
Добавьте вариант этого запроса с постраничной выборкой пропустив первую 1000 и отобразив следующие 100 записей.
Соритровка должна быть по номеру квартала, трети года, дате продажи.*/

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

--4 Заказы поставщикам, которые были исполнены за 2014й год с доставкой Road Freight или Post,
--добавьте название поставщика, имя контактного лица принимавшего заказ
SELECT psup.SupplierName, adelm.DeliveryMethodName, pord.ExpectedDeliveryDate, apeop.FullName
FROM Purchasing.PurchaseOrders pord
INNER JOIN Application.DeliveryMethods adelm on adelm.DeliveryMethodID = pord.DeliveryMethodID
INNER JOIN Purchasing.Suppliers psup on psup.SupplierID = pord.SupplierID
INNER JOIN Application.People apeop on apeop.PersonID = pord.ContactPersonID
WHERE pord.ExpectedDeliveryDate between cast('2014-01-01' as date) and cast('2014-12-31' as date) and
adelm.DeliveryMethodName in ('Road Freight', 'Post');

--5 10 последних по дате продаж с именем клиента и именем сотрудника, который оформил заказ.
SELECT top 10 scust.CustomerName, sord.OrderDate, apeop.FullName
FROM Sales.Orders sord
INNER JOIN Sales.Customers scust on scust.CustomerID = sord.CustomerID
INNER JOIN Application.People apeop on apeop.PersonID = sord.SalespersonPersonID
order by sord.OrderDate desc

--6 Все ид и имена клиентов и их контактные телефоны, которые покупали товар Chocolate frogs 250g
SELECT distinct scust.CustomerID, scust.CustomerName, scust.PhoneNumber
FROM Sales.OrderLines sorl
INNER JOIN Sales.Orders sord on sord.OrderID = sorl.OrderID
INNER JOIN Sales.Customers scust on scust.CustomerID = sord.CustomerID
INNER JOIN Warehouse.StockItems wsti on wsti.StockItemID = sorl.StockItemID
WHERE wsti.StockItemName = 'Chocolate frogs 250g'



