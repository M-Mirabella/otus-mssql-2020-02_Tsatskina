-- Задание:
--Какие индексы вам нужны
--Думаем какие запросы у вас будут в базе и добавляем для них индексы. Проверяем, что они используются в запросе.

USE Dispatcher
-- 1. Индексы на таблицу Accounts.
-- Поиск ЛС будет по номеру или адресу.

CREATE NONCLUSTERED INDEX IX_Accounts_AccNumber  
ON dbo.Accounts  
    (AccountNumber);

CREATE NONCLUSTERED INDEX IX_Accounts_Address  
ON dbo.Accounts  
    (Address);

-- 2. Индексы на таблицу Requests (таблица заявок)
-- Поиск заявки будет по номеру, или по дате (диапазону дат)
-- В карточке ЛС должна быть возможность посмотреть все заявки по этому ЛС, поэтому индекс по полю AccountID.
-- В приложении при открытии реестра заявок оператору удобно было бы видеть сразу все свои заявки. Поэтому еще индекс на поле Автор.
-- Вообще поиск может быть и по другим полям. Например отобрать заявки по конкретной бригаде или с определенным статусом, категорией.
-- Но столько индексов мне кажется будет уже вредно для производительности.
-- Я думаю, что при росте количества данных и разного функционала будет меняться набор индексов (у нас по крайней мере так).

CREATE NONCLUSTERED INDEX IX_Requests_RequestNumber  
ON dbo.Requests  
    (RequestNumber);

CREATE NONCLUSTERED INDEX IX_Requests_RequestDate  
ON dbo.Requests  
    (RequestDate);

CREATE NONCLUSTERED INDEX IX_Requests_AccountID  
ON dbo.Requests  
    (AccountID);

CREATE NONCLUSTERED INDEX IX_Requests_Autor  
ON dbo.Requests  
    (Autor);

-- Демонстрация использования индексов
-- Включаем план запроса.
SELECT ID
FROM dbo.Accounts
WHERE AccountNumber = 2

SELECT ID
FROM dbo.Accounts
WHERE Address like 'г. Саранск, ул. Ленина %'

SELECT ID
FROM dbo.Requests
WHERE RequestNumber = 50

SELECT ID
FROM dbo.Requests
WHERE RequestDate between '01.05.2020' and GETDATE()

SELECT ID
FROM dbo.Requests
WHERE AccountID = 5

SELECT ID
FROM dbo.Requests
WHERE Autor = 8

