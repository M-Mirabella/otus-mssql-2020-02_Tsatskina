-- Пересмотрела созданные таблицы. 
-- Добавила еще несколько недостающих, прописала внешние ключи
-- Немного поменяла имеющиеся таблицы

USE Dispatcher

DROP TABLE IF EXISTS Requests
GO
DROP TABLE IF EXISTS Categories
GO
DROP TABLE IF EXISTS Statuses
GO
DROP TABLE IF EXISTS Teams
GO
DROP TABLE IF EXISTS Staff
GO
DROP TABLE IF EXISTS Districts
GO
DROP TABLE IF EXISTS Accounts
GO

-- 1. Лицевые счета
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

-- 2. Реестр заявок
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

-- 3. Сотрудники
CREATE TABLE [Staff](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamID] [int] NULL,
	[INN] [int] NOT NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Position] [nvarchar](256) NULL,
	[PhoneNumber] [nvarchar](100) NULL
	) ON [PRIMARY]
GO

-- 4. Статусы заявок
CREATE TABLE [Statuses](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[StatusName] [nvarchar](50) NULL
	) ON [PRIMARY]
GO

-- 5. Категории заявок
CREATE TABLE [Categories](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[CategoryName] [nvarchar](100) NULL,
    [ExecutionPeriod] int NULL
	) ON [PRIMARY]
GO

-- 6. Районы (для привязки бригад к адресам)
CREATE TABLE [Districts](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[DistrictName] [nvarchar](100) NULL
	) ON [PRIMARY]
GO

-- 7. Бригады электромонтеров
CREATE TABLE [Teams](
	[ID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamName] [nvarchar](100) NULL,
    [DistrictID] int NULL
	) ON [PRIMARY]
GO

-- Создаем внешние ключи
USE Dispatcher

-- Requests
ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Accounts FOREIGN KEY(AccountID)
REFERENCES Accounts (id)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Statuses FOREIGN KEY(StatusID)
REFERENCES Statuses (id)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Staff FOREIGN KEY(Autor)
REFERENCES Staff (id)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Teams FOREIGN KEY(TeamID)
REFERENCES Teams (id)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Categories FOREIGN KEY(CategoryID)
REFERENCES Categories (id)

-----
ALTER TABLE Accounts ADD CONSTRAINT FK_Accounts_Districts FOREIGN KEY(DistrictID)
REFERENCES Districts (id)

-----
ALTER TABLE Staff ADD CONSTRAINT FK_Staff_Teams FOREIGN KEY(TeamID)
REFERENCES Teams (id)

-----
ALTER TABLE Teams ADD CONSTRAINT FK_Teams_Districts FOREIGN KEY(DistrictID)
REFERENCES Districts (id)











