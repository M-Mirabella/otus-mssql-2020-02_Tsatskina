--Оконные функции
--1. Напишите запрос с временной таблицей и перепишите его с табличной переменной. Сравните планы.
--В качестве запроса с временной таблицей и табличной переменной можно взять свой запрос или следующий запрос:
--Сделать расчет суммы продаж нарастающим итогом по месяцам с 2015 года (в рамках одного месяца он будет
--одинаковый, нарастать будет в течение времени выборки)
--Выведите id продажи, название клиента, дату продажи, сумму продажи, сумму нарастающим итогом
--Пример
--Дата продажи Нарастающий итог по месяцу
--2015-01-29 4801725.31
--2015-01-30 4801725.31
--2015-01-31 4801725.31
--2015-02-01 9626342.98
--2015-02-02 9626342.98
--2015-02-03 9626342.98
--Продажи можно взять из таблицы Invoices.
--Нарастающий итог должен быть без оконной функции.

-- 1. Вариант с временной таблицей
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

-- 2. Вариант с табличной переменной
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

-- По поводу планов:
-- Стоимость обоих планов равнозначна 50х50
-- В плане с временной таблице есть параллелизм, то есть запрос выполняется в несколько потоков,
-- во втором нет параллелизма, т.к. с табличной переменной он не может использоваться. В целом планы плохие, тяжелые,
-- запрос выполняется долго. Но по другому у меня не получилось собрать нарастающий итог без оконной функции.

--2. Если вы брали предложенный выше запрос, то сделайте расчет суммы нарастающим итогом с помощью оконной функции.
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

--Сравните 2 варианта запроса - через windows function и без них. Написать какой быстрее выполняется, сравнить по set statistics time on;
-- Без оконной функции запрос у меня выполняялся 2 минуты, 27 сек. С оконной функцией 1 секунда. Статистика:
-- без окна:   CPU time = 137812 ms,  elapsed time = 144999 ms.
-- с окном:    CPU time = 266 ms,  elapsed time = 2254 ms. Что говорит само за себя!

--2. Вывести список 2х самых популярных продуктов (по кол-ву проданных) в каждом месяце за 2016й год (по 2 самых популярных продукта в каждом месяце)

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

--3. Функции одним запросом
--Посчитайте по таблице товаров, в вывод также должен попасть ид товара, название, брэнд и цена
--пронумеруйте записи по названию товара, так чтобы при изменении буквы алфавита нумерация начиналась заново
--посчитайте общее количество товаров и выведете полем в этом же запросе
--посчитайте общее количество товаров в зависимости от первой буквы названия товара
--отобразите следующий id товара исходя из того, что порядок отображения товаров по имени
--предыдущий ид товара с тем же порядком отображения (по имени)
--названия товара 2 строки назад, в случае если предыдущей строки нет нужно вывести "No items"
--сформируйте 30 групп товаров по полю вес товара на 1 шт
--Для этой задачи НЕ нужно писать аналог без аналитических функций

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

--4. По каждому сотруднику выведите последнего клиента, которому сотрудник что-то продал
--В результатах должны быть ид и фамилия сотрудника, ид и название клиента, дата продажи, сумму сделки

-- Получилось два варианта. Как считаете какой вариант лучше? По плану вроде как первый.
-- Но по статистике времени у меня получается что второй
-- Вариант 1
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

-- Вариант 2
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

--5. Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
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

