--DROP PROCEDURE dbo.uspSearchAccountByAddress

CREATE PROCEDURE dbo.uspSearchAccountByAddress(@City nvarchar(100) = '', @Street nvarchar(100) = '', @House nvarchar(25) = '', @flat nvarchar(25) = '')
AS BEGIN

	SET NOCOUNT ON;  

	SELECT acc.AccountID,
	       acc.AccountNumber,
		   acc.FIO,
		   acc.City,
		   acc.Street,
		   acc.House,
		   acc.Flat,
		   ISNULL(acc.[E-Mail], '') as [E-Mail],
		   ISNULL(dist.DistrictName, 'Не указан район') as DistrictName,
	       ISNULL(Phn.PhoneNumber,'') as PhoneNumber
	FROM dbo.Accounts as acc
	LEFT JOIN dbo.Districts as dist
					on dist.DistrictID = acc.DistrictID 
	OUTER APPLY (SELECT STRING_AGG(PhoneNumber, ';') as PhoneNumber
			   FROM dbo.PhoneNumbers as Phn
			 WHERE Phn.AccountID = acc.AccountID) as Phn
	WHERE  acc.Street like @Street+'%' and 
	       acc.House  like @House + '%' and
		   acc.Flat   like @flat+'%' and
		   acc.City   like @City + '%'

	END