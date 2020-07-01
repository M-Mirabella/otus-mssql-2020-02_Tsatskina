-- Пересмотрела созданные таблицы. 
-- Добавила еще несколько недостающих, прописала внешние ключи
-- Немного поменяла имеющиеся таблицы

USE Dispatcher

DROP TABLE IF EXISTS [TempTable]
GO
DROP TABLE IF EXISTS RequestStatuses
GO
DROP TABLE IF EXISTS PhoneNumbers
GO
DROP TABLE IF EXISTS Requests
GO
DROP TABLE IF EXISTS Categories
GO
DROP TABLE IF EXISTS Statuses
GO
DROP TABLE IF EXISTS Staff
GO
DROP TABLE IF EXISTS Teams
GO
DROP TABLE IF EXISTS Accounts
GO
DROP TABLE IF EXISTS Districts
GO


-- 1. Лицевые счета
CREATE TABLE [Accounts](
	[AccountID] [bigint] IDENTITY(1,1) NOT NULL primary key,	
	[AccountNumber] [bigint] NOT NULL,	
	[Address] [nvarchar](256) NULL,
	[DistrictID] [int] NOT NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Comment] [nvarchar](256) NULL,	
	[E-Mail] [nvarchar](256) NOT NULL
) ON [PRIMARY]
GO

-- 2. Реестр заявок
CREATE TABLE [Requests](
	[RequestID] [bigint] IDENTITY(1,1) NOT NULL primary key,
	[RequestNumber] [bigint] NOT NULL,
	[RequestDate] [datetime2] NOT NULL,
	[AccountID] [bigint] NOT NULL,
	[StatusID] [int] NOT NULL,
	[AutorID]  [int] NOT NULL,
	[TeamID] [int] NOT NULL,
	[CategoryID] [int] NOT NULL,
	[RequestContent] [nvarchar](1000) NOT NULL,
	[ExecuteBefore] [datetime2] NOT NULL
	) ON [PRIMARY]
GO

-- 3. Сотрудники
CREATE TABLE [Staff](
	[StaffID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamID] [int] NULL,
	[INN] [int] NOT NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Position] [nvarchar](256) NOT NULL
	) ON [PRIMARY]
GO

-- 4. Статусы заявок
CREATE TABLE [Statuses](
	[StatusID] [int] IDENTITY(1,1) NOT NULL primary key,
	[StatusName] [nvarchar](50) NOT NULL
	) ON [PRIMARY]
GO

-- 5. Категории заявок
CREATE TABLE [Categories](
	[CategoryID] [int] IDENTITY(1,1) NOT NULL primary key,
	[CategoryName] [nvarchar](100) NOT NULL,
    [ExecutionPeriodInDays] int NOT NULL
	) ON [PRIMARY]
GO

-- 6. Районы (для привязки бригад к адресам)
CREATE TABLE [Districts](
	[DistrictID] [int] IDENTITY(1,1) NOT NULL primary key,
	[DistrictName] [nvarchar](100) NOT NULL
	) ON [PRIMARY]
GO

-- 7. Бригады электромонтеров
CREATE TABLE [Teams](
	[TeamID] [int] IDENTITY(1,1) NOT NULL primary key,
	[TeamName] [nvarchar](100) NOT NULL,
    [DistrictID] int NOT NULL
	) ON [PRIMARY]
GO

-- 8. Статусы заявок
CREATE TABLE [RequestStatuses] (
	[RequestStatusID] bigint IDENTITY(1,1) NOT NULL primary key,
	[RequestID] bigint NOT NULL,
	[StatusID] int NOT NULL,
	[StatusDate] datetime2 NOT NULL,
	[StaffID] int NOT NULL,
	[Comment] nvarchar(256) NOT NULL
	)  ON [PRIMARY]
GO

-- 9. Телефоны
CREATE TABLE [PhoneNumbers] (
	[PhoneNumberID] int IDENTITY(1,1) NOT NULL primary key,
	[AccountID] bigint NOT NULL,
	[StaffID] int NOT NULL,
	[PhoneNumber] nvarchar(25) NOT NULL,
	[Comment] nvarchar(256) NOT NULL 
	)  ON [PRIMARY]
GO

-- 10. Временная таблица для перекачки данных с биллинга
CREATE TABLE [TempTable] (
    [TmpTblId] int NOT NULL identity(1,1) primary key,
	[AccountID] int NOT NULL,
	[AccountNumber] [bigint] NOT NULL,	
	[Address] [varchar](256) NULL,
	[FIO] [varchar](256) NOT NULL,
	[District] [float] NOT NULL,
	[PhoneNumber] [varchar](256) NULL
	)  ON [PRIMARY]
GO

-- Создаем внешние ключи
USE Dispatcher

-- Requests
ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Accounts FOREIGN KEY(AccountID)
REFERENCES Accounts (AccountID)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Statuses FOREIGN KEY(StatusID)
REFERENCES Statuses (StatusID)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Staff FOREIGN KEY(AutorID)
REFERENCES Staff (StaffID)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Teams FOREIGN KEY(TeamID)
REFERENCES Teams (TeamID)

ALTER TABLE Requests ADD CONSTRAINT FK_Requests_Categories FOREIGN KEY(CategoryID)
REFERENCES Categories (CategoryID)

-----
ALTER TABLE Accounts ADD CONSTRAINT FK_Accounts_Districts FOREIGN KEY(DistrictID)
REFERENCES Districts (DistrictID)

-----
ALTER TABLE Staff ADD CONSTRAINT FK_Staff_Teams FOREIGN KEY(TeamID)
REFERENCES Teams (TeamID)

-----
ALTER TABLE Teams ADD CONSTRAINT FK_Teams_Districts FOREIGN KEY(DistrictID)
REFERENCES Districts (DistrictID)

----- RequestStatuses
ALTER TABLE RequestStatuses ADD CONSTRAINT FK_RequestStatuses_Statuses FOREIGN KEY(StatusID)
REFERENCES Statuses (StatusID)

ALTER TABLE RequestStatuses ADD CONSTRAINT FK_RequestStatuses_Requests FOREIGN KEY(RequestID)
REFERENCES Requests (RequestID)

----- PhoneNumbers
ALTER TABLE PhoneNumbers ADD CONSTRAINT FK_PhoneNumbers_Accounts FOREIGN KEY(AccountID)
REFERENCES Accounts (AccountID)

ALTER TABLE PhoneNumbers ADD CONSTRAINT FK_PhoneNumbers_Staff FOREIGN KEY(StaffID)
REFERENCES Staff (StaffID)











