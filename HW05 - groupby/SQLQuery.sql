--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
SELECT DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0) AS InvoiceMonth, AVG(inlines.UnitPrice) AS AVG_Price, SUM(inlines.Quantity*inlines.UnitPrice) TotalSUM
FROM Sales.InvoiceLines inlines
INNER JOIN Sales.Invoices inv ON inv.InvoiceID = inlines.InvoiceID
GROUP BY DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0)

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
SELECT DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0) AS InvoiceMonth, SUM(inlines.Quantity*inlines.UnitPrice) TotalSUM
FROM Sales.InvoiceLines inlines
INNER JOIN Sales.Invoices inv ON inv.InvoiceID = inlines.InvoiceID
GROUP BY DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0)
HAVING SUM(inlines.Quantity*inlines.UnitPrice) > 10000

--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
--Группировка должна быть по году и месяцу.
SELECT MIN(inv.InvoiceDate) AS First_Invoice, inlines.Description, SUM(inlines.Quantity*inlines.UnitPrice) AS TotalSUM, SUM(inlines.Quantity) AS TotalQ
FROM Sales.InvoiceLines inlines
INNER JOIN Sales.Invoices inv ON inv.InvoiceID = inlines.InvoiceID
GROUP BY YEAR(inv.InvoiceDate), MONTH(inv.InvoiceDate), inlines.Description
HAVING SUM(inlines.Quantity) < 50

--4. Написать рекурсивный CTE sql запрос и заполнить им временную таблицу и табличную переменную
--Дано :
--CREATE TABLE dbo.MyEmployees
--(
--EmployeeID smallint NOT NULL,
--FirstName nvarchar(30) NOT NULL,
--LastName nvarchar(40) NOT NULL,
--Title nvarchar(50) NOT NULL,
--DeptID smallint NOT NULL,
--ManagerID int NULL,
--CONSTRAINT PK_EmployeeID PRIMARY KEY CLUSTERED (EmployeeID ASC)
--);
--INSERT INTO dbo.MyEmployees VALUES
--(1, N'Ken', N'Sánchez', N'Chief Executive Officer',16,NULL)
--,(273, N'Brian', N'Welcker', N'Vice President of Sales',3,1)
--,(274, N'Stephen', N'Jiang', N'North American Sales Manager',3,273)
--,(275, N'Michael', N'Blythe', N'Sales Representative',3,274)
--,(276, N'Linda', N'Mitchell', N'Sales Representative',3,274)
--,(285, N'Syed', N'Abbas', N'Pacific Sales Manager',3,273)
--,(286, N'Lynn', N'Tsoflias', N'Sales Representative',3,285)
--,(16, N'David',N'Bradley', N'Marketing Manager', 4, 273)
--,(23, N'Mary', N'Gibson', N'Marketing Specialist', 4, 16);

--Результат вывода рекурсивного CTE:
--EmployeeID Name Title EmployeeLevel
--1 Ken Sánchez Chief Executive Officer 1
--273 | Brian Welcker Vice President of Sales 2
--16 | | David Bradley Marketing Manager 3
--23 | | | Mary Gibson Marketing Specialist 4
--274 | | Stephen Jiang North American Sales Manager 3
--276 | | | Linda Mitchell Sales Representative 4
--275 | | | Michael Blythe Sales Representative 4
--285 | | Syed Abbas Pacific Sales Manager 3
--286 | | | Lynn Tsoflias Sales Representative 4

DECLARE @Level int = 1,
       @P nvarchar(max) =  '';

with cte AS (select [EmployeeID], @P as Name, [FirstName], [LastName], [Title], [ManagerID], @Level as LEVEL
             from [dbo].[MyEmployees]
			 WHERE [ManagerID] IS NULL
		     UNION ALL
             select me.[EmployeeID], Name+' | ', me.[FirstName], me.[LastName], me.[Title], me.[ManagerID], LEVEL+1
             from [dbo].[MyEmployees] me
		     INNER JOIN cte rCTE on rCTE.[EmployeeID] = me.[ManagerID])

SELECT EmployeeID, Name, FirstName+' '+LastName+' '+Title, LEVEL
FROM cte

--Опционально: (Сделала так как я поняла задание)
--Написать все эти же запросы, но, если за какой-то месяц не было продаж, то этот месяц тоже должен быть в результате и там должны быть нули.
--1. Посчитать среднюю цену товара, общую сумму продажи по месяцам
DECLARE @StartDate DATETIME2 = '01.01.2013',
        @EndDate DATETIME2 = GETDATE();

with cte_month as (SELECT @StartDate as pMonth
				   UNION ALL
				   SELECT DATEADD(mm,1,pMonth)
				   FROM cte_month
				   where pMonth < @EndDate)

SELECT cte_month.pMonth AS InvoiceMonth, ISNULL(AVG(inlines.UnitPrice), 0) AS AVG_Price, ISNULL(SUM(inlines.Quantity*inlines.UnitPrice),0) TotalSUM
FROM cte_month
LEFT JOIN Sales.Invoices inv ON cte_month.pMonth = DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0) 
LEFT JOIN Sales.InvoiceLines inlines on inv.InvoiceID = inlines.InvoiceID 
GROUP BY cte_month.pMonth
ORDER BY cte_month.pMonth

--2. Отобразить все месяцы, где общая сумма продаж превысила 10 000
DECLARE @StartDate DATETIME2 = '01.01.2013',
        @EndDate DATETIME2 = GETDATE();

with cte_month as (SELECT @StartDate as pMonth
				   UNION ALL
				   SELECT DATEADD(mm,1,pMonth)
				   FROM cte_month
				   where pMonth < @EndDate)

SELECT cte_month.pMonth AS InvoiceMonth, ISNULL(invoice_Sum.TotalSum,0) TotalSUM
FROM cte_month
LEFT JOIN (SELECT SUM(inlines.Quantity*inlines.UnitPrice) as TotalSUM, DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0) as inv_Month
		   FROM Sales.InvoiceLines inlines
		   INNER JOIN Sales.Invoices inv ON inv.InvoiceID = inlines.InvoiceID
		   GROUP BY DATEADD(mm,DATEDIFF(mm,0,inv.InvoiceDate),0)
		   HAVING SUM(inlines.Quantity*inlines.UnitPrice) > 10000 ) as invoice_Sum on invoice_Sum.inv_Month = cte_month.pMonth
ORDER BY cte_month.pMonth

--3. Вывести сумму продаж, дату первой продажи и количество проданного по месяцам, по товарам, продажи которых менее 50 ед в месяц.
--Группировка должна быть по году и месяцу.
SELECT inv.inv_Year, inv.inv_Month, invoice_Sum.First_Invoice AS First_Invoice,
       ISNULL(invoice_Sum.Description, '') as inv_Descr, ISNULL(invoice_Sum.TotalSUM, 0) as TotalSUM, ISNULL(invoice_Sum.TotalQ,0) as TotalQ
FROM (SELECT DISTINCT YEAR(InvoiceDate) as inv_Year, MONTH(InvoiceDate) as inv_Month
      FROM Sales.Invoices) as inv
LEFT JOIN (SELECT YEAR(inv_1.InvoiceDate) as inv1_Year, MONTH(inv_1.InvoiceDate) as Inv1_Month,  MIN(inv_1.InvoiceDate) AS First_Invoice,
           inlines.Description, SUM(inlines.Quantity*inlines.UnitPrice) AS TotalSUM, SUM(inlines.Quantity) AS TotalQ
           FROM Sales.Invoices inv_1 
		   INNER JOIN Sales.InvoiceLines inlines ON inv_1.InvoiceID = inlines.InvoiceID
		   GROUP BY YEAR(inv_1.InvoiceDate), MONTH(inv_1.InvoiceDate), inlines.Description
		   HAVING SUM(inlines.Quantity) < 50 ) as invoice_Sum on invoice_Sum.inv1_Month = inv.inv_Month and invoice_Sum.inv1_Year = inv.inv_Year



