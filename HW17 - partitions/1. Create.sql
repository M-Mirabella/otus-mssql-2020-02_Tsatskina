use WideWorldImporters;
--создаем наши секционированные таблицы
DROP TABLE IF EXISTS [Sales].OrdersArchive;
DROP TABLE IF EXISTS [Sales].OrderLinesArchive;

--SELECT * INTO Sales.OrdersArchive
--FROM Sales.Orders;

--SELECT * INTO Sales.OrderLinesArchive 
--FROM Sales.OrderLines;

--создадим файловую группу
ALTER DATABASE [WideWorldImporters] ADD FILEGROUP [Archive]
GO

--добавляем файл БД
ALTER DATABASE [WideWorldImporters] ADD FILE 
( NAME = N'Archive', FILENAME = N'F:\SQL\Обучение\Bases\Archive.ndf' , 
SIZE = 2097152KB , FILEGROWTH = 65536KB ) TO FILEGROUP [Archive]
GO


--создаем функцию партиционирования - по умолчанию left!!
CREATE PARTITION FUNCTION [ufnOrdersArchive](DATE) AS RANGE RIGHT FOR VALUES
('20120101','20130101','20140101','20150101','20160101', '20170101',
 '20180101', '20190101', '20200101', '20210101');																																																									
GO

CREATE PARTITION SCHEME [schmOrdersArchive] AS PARTITION [ufnOrdersArchive] 
ALL TO ([Archive])
GO
