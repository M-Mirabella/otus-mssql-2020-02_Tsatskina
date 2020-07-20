SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
--процедура изначальной отправки запроса в очередь таргета
CREATE PROCEDURE Sales.uspReportForCustomers_SendMessage
	@CustomerId INT,
	@DateStart datetime2,
	@DateEnd datetime2
AS
BEGIN
	SET NOCOUNT ON;

	--Sending a Request Message to the Target	
	DECLARE @InitDlgHandle UNIQUEIDENTIFIER; --open init dialog
	DECLARE @RequestMessage NVARCHAR(4000); --сообщение, которое будем отправлять
	
	BEGIN TRAN --начинаем транзакцию

	--Prepare the Message  !!!auto generate XML
	SELECT @RequestMessage = (SELECT CustomerID, @DateStart as DateStart, @DateEnd as DateEnd
							  FROM Sales.Customers AS Cust
							  WHERE CustomerID = @CustomerID
							  FOR XML AUTO, root('RequestMessage')); 

	--Determine the Initiator Service, Target Service and the Contract 
	BEGIN DIALOG @InitDlgHandle
	FROM SERVICE
	[//WWI/SB/ReportForCustomers_InitiatorService]
	TO SERVICE
	'//WWI/SB/ReportForCustomers_TargetService'
	ON CONTRACT
	[//WWI/SB/ReportForCustomers_Contract]
	WITH ENCRYPTION=OFF; 

	--Send the Message
	SEND ON CONVERSATION @InitDlgHandle 
	MESSAGE TYPE
	[//WWI/SB/ReportForCustomers_RequestMessage]
	(@RequestMessage);
	--SELECT @RequestMessage AS SentRequestMessage;--we can write data to log
	COMMIT TRAN 


END