--Подзапросы и CTE
--Для всех заданий где возможно, сделайте 2 варианта запросов:
--1) через вложенный запрос
--2) через WITH (для производных таблиц)

--Напишите запросы:
--1. Выберите сотрудников, которые являются продажниками, и еще не сделали ни одной продажи.
-- Вариант 1:
SELECT FullName
FROM Application.People 
WHERE IsSalesperson = 1 and not exists (SELECT *
FROM Sales.Orders 
WHERE Orders.SalespersonPersonID = People.PersonID);

-- Вариант 2:
WITH SalesPerson as (SELECT DISTINCT SalespersonPersonID
				  FROM Sales.Orders)

SELECT FullName
FROM Application.People
WHERE IsSalesperson = 1 and PersonID not in (SELECT SalespersonPersonID
FROM SalesPerson)

--2. Выберите товары с минимальной ценой (подзапросом), 2 варианта подзапроса.
--Вариант 1:
SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems 
WHERE UnitPrice <= ALL (SELECT UnitPrice
FROM Warehouse.StockItems)

--Вариант 2:
SELECT StockItemID, StockItemName, UnitPrice
FROM Warehouse.StockItems 
WHERE UnitPrice = (SELECT MIN(UnitPrice)
FROM Warehouse.StockItems)

--3. Выберите информацию по клиентам, которые перевели компании 5 максимальных платежей
-- из [Sales].[CustomerTransactions] представьте 3 способа (в том числе с CTE)

--Вариант 1:
SELECT Customers.CustomerID, Customers.CustomerName, MaxTrans.TransactionAmount
FROM Sales.Customers
INNER JOIN (SELECT TOP 5 CustomerTransactions.CustomerID, TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount  DESC) AS MaxTrans on MaxTrans.CustomerID = Customers.CustomerID;

--Вариант 2:
WITH MaxTransactions AS (
SELECT TOP 5 CustomerID, TransactionAmount
FROM Sales.CustomerTransactions
ORDER BY TransactionAmount  DESC)

SELECT Customers.CustomerID, Customers.CustomerName, MaxTransactions.TransactionAmount
FROM Sales.Customers
INNER JOIN MaxTransactions on MaxTransactions.CustomerID = Customers.CustomerID

-- Вариант 3:
SELECT TOP 5 Customers.CustomerID, Customers.CustomerName, CustomerTransactions.TransactionAmount
FROM Sales.Customers 
INNER JOIN Sales.CustomerTransactions ON CustomerTransactions.CustomerID = Customers.CustomerID
ORDER BY CustomerTransactions.TransactionAmount DESC

--4. Выберите города (ид и название), в которые были доставлены товары, входящие в тройку самых дорогих товаров, а также Имя сотрудника, который осуществлял упаковку заказов
--Вариант 1
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

--Вариант 2
SELECT Distinct Cities.CityID, Cities.CityName, (SELECT People.FullName
FROM Application.People WHERE People.PersonID = Invoices.PackedByPersonID) as PackedByPerson
FROM Sales.InvoiceLines 
INNER JOIN Sales.Invoices on Invoices.InvoiceID = InvoiceLines.InvoiceID
INNER JOIN Sales.Customers on Customers.CustomerID = Invoices.CustomerID
INNER JOIN Application.Cities on Cities.CityID = Customers.DeliveryCityID
INNER JOIN  (SELECT top 3 StockItems.StockItemID
FROM  Warehouse.StockItems
order by StockItems.UnitPrice desc) as ExpensiveStockItems on InvoiceLines.StockItemID = ExpensiveStockItems.StockItemID 


--5. Объясните, что делает и оптимизируйте запрос:
--Исходный запрос
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


-- Оптимизированный вариант
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


-- Данный запрос выбирает счета с суммарной стоимостью > 27000 и выбирает сумму забранного заказа
-- (видимо что бы в дальнейшем сравнить и понять есть ли заказы свыше 27000, которые не полностью забрали)

--Приложите план запроса и его анализ, а также ход ваших рассуждений по поводу оптимизации. 
-- План запроса в файле Plan for 5 query.sqlplan
-- Мои рассуждения в файле Мои рассуждения по запросу № 5.docx

--Можно двигаться как в сторону улучшения читабельности запроса (что уже было в материале лекций), так и в сторону упрощения плана\ускорения.