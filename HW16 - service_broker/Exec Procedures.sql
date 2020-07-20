use WideWorldImporters;

SELECT DISTINCT top 10  CustomerID, InvoiceDate
FROM Sales.Invoices

SELECT *
FROM Sales.ReportForCustomers

--Send message
EXEC Sales.uspReportForCustomers_SendMessage
	@CustomerID = 832, @DateStart = '2013-01-01', @DateEnd = '2013-12-01';


----- ��� �������� ������ �������.

--� ����� ������� �������� ���������?
SELECT CAST(message_body AS XML),*
FROM dbo.ReportForCustomers_TargetQueueWWI;

SELECT CAST(message_body AS XML),*
FROM dbo.ReportForCustomers_InitiatorQueueWWI;

--�������� �������, ��� ��� ��������
--Target
EXEC Sales.uspReportForCustomers_GetMessage;

--��������� ������� ������� 00

--Initiator
EXEC Sales.uspReportForCustomers_ConfirmMessage;

-- ��������� ��� ������� Sales.ReportForCustomers �����������:
SELECT *
FROM Sales.ReportForCustomers

--�������������� �������

--������ �� �������� �������� ��������
SELECT conversation_handle, is_initiator, s.name as 'local service', 
far_service, sc.name 'contract', ce.state_desc
FROM sys.conversation_endpoints ce
LEFT JOIN sys.services s
ON ce.service_id = s.service_id
LEFT JOIN sys.service_contracts sc
ON ce.service_contract_id = sc.service_contract_id
ORDER BY conversation_handle;
