EXEC sp_configure 'show advanced options', 1
go
RECONFIGURE;
go

EXEC sp_configure 'clr enabled', 1;
EXEC sp_configure 'clr strict security', 0
go

RECONFIGURE;
go

CREATE ASSEMBLY MathDemoAssembly
FROM 'f:\SQL\otus-mssql-2020-02\otus-mssql-2020-02_Tsatskina\HW11 - clr\CLR for SQL Server\CLR for SQL Server\bin\Debug\CLR for SQL Server.dll'
WITH PERMISSION_SET = SAFE

SELECT * FROM sys.assemblies
GO

CREATE FUNCTION dbo.fn_Factorial( @num float )
RETURNS float
AS EXTERNAL NAME [MathDemoAssembly].[CLR_for_SQL_Server.Math].[Factorial];
GO

select dbo.fn_Factorial(5)