DECLARE @d date = GETDATE();
with cte_addr as
(
select LSI.Потомок, 
       case when ls.Тип = 2  then (select ISNULL(Название, '')
                                from stack.[Города] where row_id = [Улица-Лицевой счет] ) else '' end as [Улица],
       case when ls.Тип = 3  then ( CONVERT( VARCHAR(10), Номер) + ISNULL( Фамилия, '' ) )  else '' end as [Дом],
       case when ls.Тип = 4  then ( ( CASE WHEN Номер != 0 THEN CONVERT( VARCHAR(10), Номер) ELSE '' END ) + 
	                                   (CASE WHEN ISNULL(Фамилия,'') != '' THEN ' '+ISNULL(Фамилия,'') ELSE '' END ) )  else '' end as [Квартира],   
       case when ls.Тип = 12 then (select ISNULL(Название,'')
                                                        from stack.[Города] where row_id = [Улица-Лицевой счет] ) else '' end as [НП]
from  stack.[Лицевые иерархия] LSI_1 
join stack.[Лицевые иерархия] LSI ON LSI.Потомок = LSI_1.Потомок
join stack.[Лицевые счета] ls on ls.ROW_ID = LSI.Родитель
where LSI_1.родитель in (204263) and LSI_1.ПотомокТип = 5
),

cte_ls as (
SELECT TOP 15000 Потомок as AccountID, Max(НП) as City, Max(Улица) as Street, Max(Дом) as House, Max(Квартира) as Flat
FROM cte_addr 
GROUP BY cte_addr.Потомок)

SELECT ls.ROW_ID as AccountID,
       ls.Номер as AccountNumber, 
	   cte_ls.City,
	   cte_ls.Street,
	   cte_ls.House,
	   cte_ls.Flat,
       kr.ФИО as FIO,
       sv.Значение+1  as District,
       -1 as StaffID,
	   ls.Примечание as Comment,
	   REPLACE(REPLACE(tel.Номер, 'д', ' '), 'м', ' ') as PhoneNumber,
       ROW_NUMBER() over(partition BY cte_LS.AccountID ORDER BY cte_LS.AccountID) RowNumber
FROM cte_ls 
INNER JOIN stack.[Лицевые счета] ls
            on ls.ROW_ID = cte_ls.AccountID
INNER JOIN stack.[Лицевые иерархия] li_house
            on li_house.Потомок = ls.ROW_ID
INNER JOIN stack.[Карточки регистрации] kr
            on kr.ROW_ID = ls.[Счет-Наниматель]
INNER JOIN stack.Свойства sv
            on sv.[Счет-Параметры] = li_house.Родитель
LEFT JOIN stack.Телефоны tel
            on tel.[Счет-Телефон] = cte_LS.AccountID and len(tel.Номер)>3
WHERE li_house.РодительТип = 3
 and sv.[Виды-Параметры] = 274 -- Район
		       and @d between sv.ДатНач  and sv.ДатКнц
			   and cte_ls.AccountID = 215560




