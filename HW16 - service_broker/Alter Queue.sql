
-- попробуем сначала отправить сообщения, без связки с процедурами обработки

USE [WideWorldImporters]
GO
/****** Object:  ServiceQueue [InitiatorQueueWWI]    Script Date: 6/5/2019 11:57:47 PM ******/
ALTER QUEUE [dbo].[ReportForCustomers_InitiatorQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF) 
	, ACTIVATION (   STATUS = ON ,
        PROCEDURE_NAME = Sales.uspReportForCustomers_ConfirmMessage, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
ALTER QUEUE [dbo].[ReportForCustomers_TargetQueueWWI] WITH STATUS = ON , RETENTION = OFF , POISON_MESSAGE_HANDLING (STATUS = OFF)
	, ACTIVATION (  STATUS = ON ,
        PROCEDURE_NAME = Sales.uspReportForCustomers_GetMessage, MAX_QUEUE_READERS = 1, EXECUTE AS OWNER) ; 

GO
--https://docs.microsoft.com/ru-ru/sql/t-sql/statements/create-queue-transact-sql?view=sql-server-ver15