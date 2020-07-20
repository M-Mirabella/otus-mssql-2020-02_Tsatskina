use WideWorldImporters;

SELECT DISTINCT top 10  CustomerID, InvoiceDate
FROM Sales.Invoices

SELECT *
FROM Sales.ReportForCustomers

--Send message
EXEC Sales.uspReportForCustomers_SendMessage
	@CustomerID = 832, @DateStart = '2013-01-01', @DateEnd = '2013-12-01';