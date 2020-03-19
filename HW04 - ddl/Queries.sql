/*Нужно используя операторы DDL создать:
1. Создать базу данных.
2. 3-4 основные таблицы для своего проекта.
3. Первичные и внешние ключи для всех созданных таблиц.
4. 1-2 индекса на таблицы.
5. Наложите по одному ограничению в каждой таблице на ввод данных.*/

-- 1. Создать базу данных.
CREATE DATABASE [Dispatcher]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = dispatcher, FILENAME = N'f:\SQL\Обучение\Bases\dispatcher.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = dispatcher_log, FILENAME = N'f:\SQL\Обучение\Bases\dispatcher_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
GO

-- 2. 3-4 основные таблицы для своего проекта.
USE Dispatcher
-- Лицевые счета
CREATE TABLE [Accounts](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,	
	[AccountNumber] [bigint] NOT NULL,	
	[Address] [nvarchar](256) NULL,
	[FIO] [nvarchar](256) NULL,
	[Comment] [nvarchar](256) NULL,	
	[PhoneNumber] [nvarchar](100) NULL,
	[E-Mail] [nvarchar](256) NULL
) ON [PRIMARY]
GO

-- Реестр заявок
CREATE TABLE [Requests](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[RequestNumber] [int] NOT NULL,
	[RequestDate] [datetime2] NOT NULL,
	[AccountID] [int] NOT NULL,
	[StatusID] [int] NULL,
	[Autor]  [int] NULL,
	[Performer] [int] NULL,
	[CategoryID] [int] NULL,
	[Content] [nvarchar](1000) NULL
	) ON [PRIMARY]
GO

-- Сотрудники
CREATE TABLE [Staff](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[INN] [int] NOT NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Position] [nvarchar](256) NULL,
	[PhoneNumber] [nvarchar](100) NULL
	) ON [PRIMARY]
GO

-- Статусы заявок
CREATE TABLE [Statuses](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[StatusName] [nvarchar](50) NULL
	) ON [PRIMARY]
GO

-- Категории заявок
CREATE TABLE [Category](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[Category] [nvarchar](100) NULL,
    [ExecutionPeriod] int NULL
	) ON [PRIMARY]
GO

--3. Первичные и внешние ключи для всех созданных таблиц. (Первичные созданы выше)
USE Dispatcher
ALTER TABLE Requests ADD CONSTRAINT FK_r_Accounts FOREIGN KEY(AccountID)
REFERENCES Accounts (id)
ON UPDATE CASCADE
ON DELETE CASCADE

ALTER TABLE Requests ADD CONSTRAINT FK_r_Status FOREIGN KEY(StatusID)
REFERENCES Statuses (id)
ON UPDATE CASCADE

ALTER TABLE Requests ADD CONSTRAINT FK_r_Autor FOREIGN KEY(Autor)
REFERENCES Staff (id)

ALTER TABLE Requests ADD CONSTRAINT FK_r_Performer FOREIGN KEY(Performer)
REFERENCES Staff (id)

ALTER TABLE Requests ADD CONSTRAINT FK_r_Category FOREIGN KEY(CategoryID)
REFERENCES Category (id)
ON UPDATE CASCADE

--4. 1-2 индекса на таблицы.
CREATE INDEX nc_PhoneNumber ON Accounts (PhoneNumber);

CREATE INDEX nc_AccNumber ON Accounts (AccountNumber);

CREATE INDEX nc_RequestNumber_RequestDate ON Requests (RequestNumber, RequestDate);

CREATE INDEX nc_AccountID ON Requests (AccountID);

CREATE INDEX nc_Performer ON Requests (Performer);

CREATE INDEX nc_FIO ON Staff (FIO);

--5. Наложите по одному ограничению в каждой таблице на ввод данных.
ALTER TABLE Accounts 
	ADD CONSTRAINT DF_AccountNumber
		CHECK (AccountNumber > 0);

ALTER TABLE Requests ADD CONSTRAINT DF_StatusID DEFAULT (-1) FOR StatusID;

ALTER TABLE Staff ADD CONSTRAINT DF_INN CHECK (LEN(INN) = 12);

ALTER TABLE Category ADD CONSTRAINT DF_ExecutionPeriod DEFAULT (0) FOR ExecutionPeriod;











