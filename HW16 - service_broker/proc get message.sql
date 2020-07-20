CREATE PROCEDURE Sales.uspReportForCustomers_GetMessage
AS
BEGIN

	DECLARE @TargetDlgHandle UNIQUEIDENTIFIER, --идентификатор диалога
			@Message NVARCHAR(4000),--полученное сообщение
			@MessageType Sysname,--тип полученного сообщения
			@ReplyMessage NVARCHAR(4000),--ответное сообщение
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

	SELECT @Message; --выводим в консоль полученный месседж

	SET @xml = CAST(@Message AS XML); -- получаем xml из мессаджа

	--получаем InvoiceID из xml
	SELECT @CustomerID = R.Iv.value('@CustomerID','INT'),
	       @DateStart = R.Iv.value('@DateStart','DateTime2'),
		   @DateEnd = R.Iv.value('@DateEnd','DateTime2')
	FROM @xml.nodes('/RequestMessage/Cust') as R(Iv);

	--проставим дату в пустое поле для InvoiceID
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
	
	SELECT @Message AS ReceivedRequestMessage, @MessageType; --в лог
	
	-- Confirm and Send a reply
	IF @MessageType=N'//WWI/SB/ReportForCustomers_RequestMessage'
	BEGIN
		SET @ReplyMessage =N'<ReplyMessage> Message received</ReplyMessage>'; 
	
		SEND ON CONVERSATION @TargetDlgHandle
		MESSAGE TYPE
		[//WWI/SB/ReportForCustomers_ReplyMessage]
		(@ReplyMessage);
		END CONVERSATION @TargetDlgHandle;--закроем диалог со стороны таргета
	END 
	
	SELECT @ReplyMessage AS SentReplyMessage; --в лог

	COMMIT TRAN;
END