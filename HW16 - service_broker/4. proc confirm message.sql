
CREATE PROCEDURE Sales.uspReportForCustomers_ConfirmMessage
AS
BEGIN
	--Receiving Reply Message from the Target.	
	DECLARE @InitiatorReplyDlgHandle UNIQUEIDENTIFIER, --хэндл диалога
			@ReplyReceivedMessage NVARCHAR(1000) 
	
	BEGIN TRAN; 

	--получим сообщение из очереди инициатора
		RECEIVE TOP(1)
			@InitiatorReplyDlgHandle=Conversation_Handle
			,@ReplyReceivedMessage=Message_Body
		FROM dbo.ReportForCustomers_InitiatorQueueWWI; 
		
		END CONVERSATION @InitiatorReplyDlgHandle; --закроем диалог со стороны инициатора
		--оба участника диалога должны завершить его
		--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/end-conversation-transact-sql?view=sql-server-ver15
		
		SELECT @ReplyReceivedMessage AS ReceivedRepliedMessage; --в консоль

	COMMIT TRAN; 
END

