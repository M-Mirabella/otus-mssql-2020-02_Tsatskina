/*����� ��������� ��������� DDL �������:
1. ������� ���� ������.
2. 3-4 �������� ������� ��� ������ �������.
3. ��������� � ������� ����� ��� ���� ��������� ������.
4. 1-2 ������� �� �������.
5. �������� �� ������ ����������� � ������ ������� �� ���� ������.*/

-- 1. ������� ���� ������.
CREATE DATABASE [Dispatcher]
 CONTAINMENT = NONE
 ON  PRIMARY 
( NAME = dispatcher, FILENAME = N'f:\SQL\��������\Bases\dispatcher.mdf' , 
	SIZE = 8MB , 
	MAXSIZE = UNLIMITED, 
	FILEGROWTH = 65536KB )
 LOG ON 
( NAME = dispatcher_log, FILENAME = N'f:\SQL\��������\Bases\dispatcher_log.ldf' , 
	SIZE = 8MB , 
	MAXSIZE = 10GB , 
	FILEGROWTH = 65536KB )
COLLATE Cyrillic_General_CI_AS
GO

-- 2. 3-4 �������� ������� ��� ������ �������.
USE Dispatcher
-- ������� �����
CREATE TABLE [Accounts](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,	
	[AccountNumber] [bigint] NOT NULL,	
	[Address] [nvarchar](256) NULL,
	[DistrictID] [int] NULL,
	[FIO] [nvarchar](256) NULL,
	[Comment] [nvarchar](256) NULL,	
	[PhoneNumber] [nvarchar](100) NULL,
	[E-Mail] [nvarchar](256) NULL
) ON [PRIMARY]
GO

-- ������ ������
CREATE TABLE [Requests](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[RequestNumber] [int] NOT NULL,
	[RequestDate] [datetime2] NOT NULL,
	[AccountID] [int] NOT NULL,
	[StatusID] [int] NULL,
	[Autor]  [int] NULL,
	[TeamID] [int] NULL,
	[CategoryID] [int] NULL,
	[RequestContent] [nvarchar](1000) NULL,
	[ExecuteBefore] [datetime2]
	) ON [PRIMARY]
GO

-- ����������
CREATE TABLE [Staff](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamID] [int] NULL,
	[INN] [int] NOT NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Position] [nvarchar](256) NULL,
	[PhoneNumber] [nvarchar](100) NULL
	) ON [PRIMARY]
GO

-- ������� ������
CREATE TABLE [Statuses](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[StatusName] [nvarchar](50) NULL
	) ON [PRIMARY]
GO

-- ��������� ������
CREATE TABLE [Categories](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[CategoryName] [nvarchar](100) NULL,
    [ExecutionPeriod] int NULL
	) ON [PRIMARY]
GO

-- ������
CREATE TABLE [Districts](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[DistrictName] [nvarchar](100) NULL
	) ON [PRIMARY]
GO

-- ��������� ������
CREATE TABLE [Teams](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamName] [nvarchar](100) NULL,
    [DistrictID] int NULL
	) ON [PRIMARY]
GO

--3. ��������� � ������� ����� ��� ���� ��������� ������. (��������� ������� ����)
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

ALTER TABLE Requests ADD CONSTRAINT FK_r_Team FOREIGN KEY(TeamID)
REFERENCES Teams (id)

ALTER TABLE Requests ADD CONSTRAINT FK_r_Category FOREIGN KEY(CategoryID)
REFERENCES Category (id)
ON UPDATE CASCADE

--4. 1-2 ������� �� �������.
CREATE INDEX nc_PhoneNumber ON Accounts (PhoneNumber);

CREATE INDEX nc_AccNumber ON Accounts (AccountNumber);

CREATE INDEX nc_RequestNumber_RequestDate ON Requests (RequestNumber, RequestDate);

CREATE INDEX nc_AccountID ON Requests (AccountID);

CREATE INDEX nc_Performer ON Requests (Performer);

CREATE INDEX nc_FIO ON Staff (FIO);

--5. �������� �� ������ ����������� � ������ ������� �� ���� ������.
ALTER TABLE Accounts 
	ADD CONSTRAINT DF_AccountNumber
		CHECK (AccountNumber > 0);

ALTER TABLE Requests ADD CONSTRAINT DF_StatusID DEFAULT (-1) FOR StatusID;

ALTER TABLE Staff ADD CONSTRAINT DF_INN CHECK (LEN(INN) = 12);

ALTER TABLE Category ADD CONSTRAINT DF_ExecutionPeriod DEFAULT (0) FOR ExecutionPeriod;











