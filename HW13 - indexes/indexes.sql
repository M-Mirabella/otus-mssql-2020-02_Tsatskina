-- �������:
--����� ������� ��� �����
--������ ����� ������� � ��� ����� � ���� � ��������� ��� ��� �������. ���������, ��� ��� ������������ � �������.

USE Dispatcher
-- 1. ������� �� ������� Accounts.
-- ����� �� ����� �� ������ ��� ������.

CREATE NONCLUSTERED INDEX IX_Accounts_AccNumber  
ON dbo.Accounts  
    (AccountNumber);

CREATE NONCLUSTERED INDEX IX_Accounts_Address  
ON dbo.Accounts  
    (Address);

-- 2. ������� �� ������� Requests (������� ������)
-- ����� ������ ����� �� ������, ��� �� ���� (��������� ���)
-- � �������� �� ������ ���� ����������� ���������� ��� ������ �� ����� ��, ������� ������ �� ���� AccountID.
-- � ���������� ��� �������� ������� ������ ��������� ������ ���� �� ������ ����� ��� ���� ������. ������� ��� ������ �� ���� �����.
-- ������ ����� ����� ���� � �� ������ �����. �������� �������� ������ �� ���������� ������� ��� � ������������ ��������, ����������.
-- �� ������� �������� ��� ������� ����� ��� ������ ��� ������������������.
-- � �����, ��� ��� ����� ���������� ������ � ������� ����������� ����� �������� ����� �������� (� ��� �� ������� ���� ���).

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

-- ������������ ������������� ��������
-- �������� ���� �������.
SELECT ID
FROM dbo.Accounts
WHERE AccountNumber = 2

SELECT ID
FROM dbo.Accounts
WHERE Address like '�. �������, ��. ������ %'

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

