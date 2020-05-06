--SP и function
--1) Написать функцию возвращающую Клиента с наибольшей суммой покупки.
     -- Уровень изоляции: Read Committed или выше. Что бы исключить грязное чтение.
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

--2) Написать хранимую процедуру с входящим параметром СustomerID, выводящую сумму покупки по этому клиенту.
--Использовать таблицы :
--Sales.Customers
--Sales.Invoices
--Sales.InvoiceLines

-- Уровень изоляции: Read Committed или выше. Что бы исключить грязное чтение.

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

--3) Создать одинаковую функцию и хранимую процедуру, посмотреть в чем разница в производительности и почему.
-- Уровень изоляции. Если быть уверенными что данная функция (процедура) будет использоваться исключительно
-- для анализа "закрытых месяцев", то можно поставить Read Uncommitted. Но если будет анализироваться и текущий
-- месяц, то тогда Read Committed
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

-- Разницы в производительности нет. Планы идентичные, стоимость планов 50х50

--4) Создайте табличную функцию покажите как ее можно вызвать для каждой строки result set'а без использования цикла.

 -- Уровень изоляции: Read Committed или выше. Что бы исключить грязное чтение.

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
	
--Во всех процедурах, в описании укажите для преподавателям
--5) какой уровень изоляции нужен и почему.
-- указала.

--Опционально
--6) Переписываем одну и ту же процедуру kitchen sink с множеством входных параметров по поиску в заказах на динамический SQL.

--Сравниваем планы запроса.
--7) Напишите запрос в транзакции где есть выборка, вставка\добавление\удаление данных и параллельно запускаем выборку данных в разных уровнях изоляции, нужно предоставить мини отчет, что на каком уровне было видно со скриншотами и ваши выводы (1-2 предложение)
--8) Сделайте параллельно в 2х окнах добавление данных в одну таблицу с разным уровнем изоляции, изменение данных в одной таблице, изменение одной и той же строки. Что в итоге получилось, что нового узнали.