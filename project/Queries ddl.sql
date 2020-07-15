-- Пересмотрела созданные таблицы. 
-- Добавила еще несколько недостающих, прописала внешние ключи
-- Немного поменяла имеющиеся таблицы

USE Dispatcher

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
	[AccountID] [bigint] NOT NULL primary key,	
	[AccountNumber] [bigint] NOT NULL,	
	[City] [nvarchar](100) NULL,
	[Street] [nvarchar](100) NULL,
	[House] [nvarchar](25) NULL,
	[Flat] [nvarchar](25) NULL,
	[DistrictID] [int] NULL,
	[FIO] [nvarchar](256) NOT NULL,
	[Comment] [nvarchar](256) NULL,	
	[E-Mail] [nvarchar](256) NULL
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
	[AccountID] bigint NULL,
	[StaffID] int NULL,
	[PhoneNumber] nvarchar(25) NOT NULL,
	[Comment] nvarchar(256) NULL 
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

-- Создаем Индексы
USE Dispatcher

CREATE INDEX nc_Accounts_AccountNumber ON dbo.Accounts (AccountNumber);
CREATE INDEX nc_Accounts_Address       ON dbo.Accounts (Street, House, Flat, City);


CREATE INDEX nc_PhoneNumbers_AccountID   ON dbo.PhoneNumbers (AccountID) INCLUDE (PhoneNumber);
CREATE INDEX nc_PhoneNumbers_PhoneNumber ON dbo.PhoneNumbers (PhoneNumber) INCLUDE (AccountID);
CREATE INDEX nc_PhoneNumbers_StaffID     ON dbo.PhoneNumbers (StaffID) INCLUDE (PhoneNumber);

CREATE INDEX nc_Requests_AccountID     ON dbo.Requests (AccountID);
CREATE INDEX nc_Requests_RequestNumber ON dbo.Requests (RequestNumber);
CREATE INDEX nc_Requests_RequestDate   ON dbo.Requests (RequestDate);
CREATE INDEX nc_Requests_AutorID       ON dbo.Requests (AutorID);

CREATE INDEX nc_RequestStatuses_RequestID ON dbo.RequestStatuses (RequestID);

















