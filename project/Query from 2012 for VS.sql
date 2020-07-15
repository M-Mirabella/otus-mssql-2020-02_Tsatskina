DECLARE @d date = GETDATE();
with cte_addr as
(
select LSI.�������, 
       case when ls.��� = 2  then (select ISNULL(��������, '')
                                from stack.[������] where row_id = [�����-������� ����] ) else '' end as [�����],
       case when ls.��� = 3  then ( CONVERT( VARCHAR(10), �����) + ISNULL( �������, '' ) )  else '' end as [���],
       case when ls.��� = 4  then ( ( CASE WHEN ����� != 0 THEN CONVERT( VARCHAR(10), �����) ELSE '' END ) + 
	                                   (CASE WHEN ISNULL(�������,'') != '' THEN ' '+ISNULL(�������,'') ELSE '' END ) )  else '' end as [��������],   
       case when ls.��� = 12 then (select ISNULL(��������,'')
                                                        from stack.[������] where row_id = [�����-������� ����] ) else '' end as [��]
from  stack.[������� ��������] LSI_1 
join stack.[������� ��������] LSI ON LSI.������� = LSI_1.�������
join stack.[������� �����] ls on ls.ROW_ID = LSI.��������
where LSI_1.�������� in (204263) and LSI_1.���������� = 5
),

cte_ls as (
SELECT TOP 15000 ������� as AccountID, Max(��) as City, Max(�����) as Street, Max(���) as House, Max(��������) as Flat
FROM cte_addr 
GROUP BY cte_addr.�������)

SELECT ls.ROW_ID as AccountID,
       ls.����� as AccountNumber, 
	   cte_ls.City,
	   cte_ls.Street,
	   cte_ls.House,
	   cte_ls.Flat,
       kr.��� as FIO,
       sv.��������+1  as District,
       -1 as StaffID,
	   ls.���������� as Comment,
	   REPLACE(REPLACE(tel.�����, '�', ' '), '�', ' ') as PhoneNumber,
       ROW_NUMBER() over(partition BY cte_LS.AccountID ORDER BY cte_LS.AccountID) RowNumber
FROM cte_ls 
INNER JOIN stack.[������� �����] ls
            on ls.ROW_ID = cte_ls.AccountID
INNER JOIN stack.[������� ��������] li_house
            on li_house.������� = ls.ROW_ID
INNER JOIN stack.[�������� �����������] kr
            on kr.ROW_ID = ls.[����-����������]
INNER JOIN stack.�������� sv
            on sv.[����-���������] = li_house.��������
LEFT JOIN stack.�������� tel
            on tel.[����-�������] = cte_LS.AccountID and len(tel.�����)>3
WHERE li_house.����������� = 3
 and sv.[����-���������] = 274 -- �����
		       and @d between sv.������  and sv.������
			   and cte_ls.AccountID = 215560




