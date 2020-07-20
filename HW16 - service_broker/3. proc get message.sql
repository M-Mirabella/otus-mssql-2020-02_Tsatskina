CREATE PROCEDURE Sales.uspReportForCustomers_GetMessage
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --������������� �������
			@Message NVARCHAR(4000),--���������� ���������
			@MessageType Sysname,--��� ����������� ���������
			@ReplyMessage NVARCHAR(4000),--�������� ���������
			@CustomerID INT,
			@DateStart datetime2,
			@DateEnd datetime2,
			@xml XML; 
	
	BEGIN TRAN; 

	--Receive message from Initiator
	RECEIVE TOP(1)
		@TargetDlgHandle = Conversation_Handle,
		@Message = Message_Body,
		@MessageType = Message_Type_Name
	FROM dbo.ReportForCustomers_TargetQueueWWI; 

	SELECT @Message; --������� � ������� ���������� �������

	SET @xml = CAST(@Message AS XML); -- �������� xml �� ��������

	--�������� InvoiceID �� xml
	SELECT @CustomerID = R.Iv.value('@CustomerID','INT'),
	       @DateStart = R.Iv.value('@DateStart','DateTime2'),
		   @DateEnd = R.Iv.value('@DateEnd','DateTime2')
	FROM @xml.nodes('/RequestMessage/Cust') as R(Iv);

	--��������� ���� � ������ ���� ��� InvoiceID
	    INSERT INTO Sales.ReportForCustomers
		(CustomerID,
		 CustomerName,
		 NumberOfOrders,
		 DateStart,
		 DateEnd)
		SELECT SubQ.CustomerID, SubQ.CustomerName, SubQ.NumberOfOrders, @DateStart, @DateEnd
		FROM (
		SELECT Invoices.CustomerID,
			   Customers.CustomerName,
			   Count(Invoices.OrderID) as NumberOfOrders
		FROM Sales.Invoices
		INNER JOIN Sales.Customers on Customers.CustomerID = Invoices.CustomerID
		WHERE Invoices.CustomerId = @CustomerID and Invoices.InvoiceDate between @DateStart and @DateEnd
		GROUP BY Invoices.CustomerID, Customers.CustomerName) as SubQ;
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --� ���
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/ReportForCustomers_RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReportForCustomers_ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--������� ������ �� ������� �������
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --� ���

	COMMIT TRAN;
END