--Pivot и Cross Apply
--1. Требуется написать запрос, который в результате своего выполнения формирует таблицу следующего вида:
--Название клиента
--МесяцГод Количество покупок

--Клиентов взять с ID 2-6, это все подразделение Tailspin Toys
--имя клиента нужно поменять так чтобы осталось только уточнение
--например исходное Tailspin Toys (Gasport, NY) - вы выводите в имени только Gasport,NY
--дата должна иметь формат dd.mm.yyyy например 25.12.2019

--Например, как должны выглядеть результаты:
--InvoiceMonth Peeples Valley, AZ Medicine Lodge, KS Gasport, NY Sylvanite, MT Jessie, ND
--01.01.2013 3 1 4 2 2
--01.02.2013 7 3 4 2 1

WITH cte_Customers as (
SELECT  TRIM(REPLACE(REPLACE(REPLACE(cust.CustomerName, 'Tailspin Toys', ''), '(',''), ')', '')) Customer,
		CONVERT(nvarchar, DATEFROMPARTS(YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), 1 ), 104) as PurchaseMonth,
		COUNT(*) as QuantityPurchases
FROM Sales.Customers cust
	INNER JOIN Sales.Invoices AS inv
		ON inv.CustomerID = cust.CustomerID
WHERE cust.CustomerID between 2 and 6
GROUP BY cust.CustomerName, DATEFROMPARTS(YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), 1 ))

SELECT *
FROM cte_Customers
PIVOT (SUM(QuantityPurchases)
	FOR Customer IN ([Gasport, NY], [Jessie, ND], [Medicine Lodge, KS], [Peeples Valley, AZ], [Sylvanite, MT])) as PVT
ORDER BY PurchaseMonth

--2. Для всех клиентов с именем, в котором есть Tailspin Toys
--вывести все адреса, которые есть в таблице, в одной колонке

--Пример результатов
--CustomerName AddressLine
--Tailspin Toys (Head Office) Shop 38
--Tailspin Toys (Head Office) 1877 Mittal Road
--Tailspin Toys (Head Office) PO Box 8975
--Tailspin Toys (Head Office) Ribeiroville
--.....

SELECT  UnPvt.CustomerName, UnPvt.AddressLine
FROM Sales.Customers 
UNPIVOT (AddressLine FOR ColNames in (DeliveryAddressLine1,
									 DeliveryAddressLine2,
									 PostalAddressLine1,
									 PostalAddressLine2)) as UnPvt
WHERE CustomerName like 'Tailspin Toys%'

--3. В таблице стран есть поля с кодом страны цифровым и буквенным
--сделайте выборку ИД страны, название, код - чтобы в поле был либо цифровой либо буквенный код
--Пример выдачи

--CountryId CountryName Code
--1 Afghanistan AFG
--1 Afghanistan 4
--3 Albania ALB
--3 Albania 8

WITH cte_tbl as (
SELECT  CountryID,
		CountryName,
		IsoAlpha3Code,
		Cast(IsoNumericCode As nvarchar(3)) as NumericCode
FROM Application.Countries)

SELECT UnPvt.CountryID, UnPvt.CountryName, UnPvt.Code
FROM cte_tbl
UNPIVOT (Code FOR ColNames IN (IsoAlpha3Code, NumericCode)) as UnPvt

--4. Перепишите ДЗ из оконных функций через CROSS APPLY
--Выберите по каждому клиенту 2 самых дорогих товара, которые он покупал
--В результатах должно быть ид клиета, его название, ид товара, цена, дата покупки
SELECT  Customers.CustomerID,
		Customers.CustomerName,
		invl.StockItemID, 
		invl.UnitPrice,
		inv.InvoiceDate
FROM Sales.Customers
CROSS APPLY (SELECT DISTINCT TOP 2 invl.StockItemID, invl.UnitPrice
			 FROM Sales.Invoices as inv
				INNER JOIN Sales.InvoiceLines as invl
					on inv.InvoiceID = invl.InvoiceID
			 WHERE inv.CustomerID = Customers.CustomerID
			 ORDER BY invl.UnitPrice DESC) as ExpensivePurchase
INNER JOiN Sales.Invoices inv
	ON inv.CustomerID = Customers.CustomerID
INNER JOIN Sales.InvoiceLines invl 
	ON invl.StockItemID = ExpensivePurchase.StockItemID and invl.InvoiceID = inv.InvoiceID
ORDER BY CustomerID, StockItemID, InvoiceDate

--5. Code review (опционально). Запрос приложен в материалы Hometask_code_review.sql.
--Что делает запрос?
--Чем можно заменить CROSS APPLY - можно ли использовать другую стратегию выборки\запроса?

-- CROSS APPLY можно заменить на оконнфую функцию ROW_NUMBER(). Для этого часть запроса надо вынести в cte.
-- Видимо запрос используется в системе документооборота и для удаляемых версий документов выбирает
-- предыдущую самую позднюю версию, наверное что бы сделать ее актуальной