CREATE TABLE Sales.ReportForCustomers
(CustomerID int not null,
 CustomerName nvarchar(100) not null,
 NumberOfOrders int not null,
 DateStart datetime2 not null,
 DateEnd datetime2 not null)

 -------------
 CREATE MESSAGE TYPE
[//WWI/SB/ReportForCustomers_RequestMessage]
VALIDATION=WELL_FORMED_XML;
-- For Reply
CREATE MESSAGE TYPE
[//WWI/SB/ReportForCustomers_ReplyMessage]
VALIDATION=WELL_FORMED_XML; 

GO;
--create contract
CREATE CONTRACT [//WWI/SB/ReportForCustomers_Contract]
      ([//WWI/SB/ReportForCustomers_RequestMessage]
         SENT BY INITIATOR,
       [//WWI/SB/ReportForCustomers_ReplyMessage]
         SENT BY TARGET
      );
GO

--создаем очередь
CREATE QUEUE ReportForCustomers_TargetQueueWWI;

--создаем сервис обслуживающий очередь
CREATE SERVICE [//WWI/SB/ReportForCustomers_TargetService]
       ON QUEUE ReportForCustomers_TargetQueueWWI
       ([//WWI/SB/ReportForCustomers_Contract]);
GO

CREATE QUEUE ReportForCustomers_InitiatorQueueWWI;

CREATE SERVICE [//WWI/SB/ReportForCustomers_InitiatorService]
       ON QUEUE ReportForCustomers_InitiatorQueueWWI
       ([//WWI/SB/ReportForCustomers_Contract]);
GO
