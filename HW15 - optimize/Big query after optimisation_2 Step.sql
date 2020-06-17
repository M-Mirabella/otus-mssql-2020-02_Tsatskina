SET STATISTICS io, time on;

declare @d1 datetime = Cast('2020-04-01' as datetime);
declare @d2 datetime = Cast('2020-04-30' as datetime);
declare @dogs varchar(max) = -10;

WITH CTE_func as (
		SELECT sum(f.[сумма с ндс]) as Сумма,
			   sum(f.[сумма без ндс]) Сумма2, 
								
			--Шишлонова (Не учитывать объемы по мощности)
			case when f.Аналитика1 in  (2161,2162,2261,2262,7103,7203) then 0
					else sum(f.Объем * [включается в объем])
			end as Объем, 
			case when f.Аналитика1 in  (2161,2162,2261,2262,7103,7203) then 0
					else f.Объем
			end as ПолныйОбъем, 
								
            case when f.АналитикаДок = 'ЭЭ' then ''
					when f.АналитикаДок = 'ДОЛГ' then ''
					else f.АналитикаДок 
			end as Аналитика, 
			f.Аналитика1,
			f.Аналитика2,
			f.Месяц ЗаМесяц,
			f.Договор,
			f.номномер,			
			f.Код46                
		FROM stack.calc_contracts_accs(@dogs,@d1) f				
		WHERE f.Договор <> 7197
		group by f.АналитикаДок, f.Аналитика1, f.Аналитика2, f.Месяц, f.Договор, f.номномер, f.Код46, f.Объем        
),

CTE_dog as (
			SELECT f.Договор,
			       f.Номер,
				   f.Тема as НомерДоговора,
				   org.Название,
				   org.Наименование,
			       case when LTRIM(RTRIM(org.ИНН)) = '' then 'Нет ИНН' else org.ИНН end as ИНН,
				   f.ТипДоговора as ВидДоговора,
				   isnull(sv.Значение, f.Отрасль) as идОтрасли,				  
				   f.Бюджет as идБюджета,
				   isnull(kdp.Код,f.КатегорияКод) as КатегорияКод,
				   isnull(sv.Знач2,-1) Категория,
				   isnull(sv.Примечание, f.ОтрасльКод) as ОтрасльКод,
				   isnull(klp.Название, f.ОтрасльНазвание) as ОтрасльНазвание,
				   org.Бюджет as БюджетОрг,
				   f.Окончание
			FROM stack.contracts(@dogs) as f
			INNER JOIN stack.Организации org on org.ROW_ID = f.Плательщик
			LEFT OUTER JOIN stack.Свойства sv
				on sv.[Параметры-Договор] = f.Договор and sv.[Виды-Параметры] = 461 and @d1 between sv.ДатНач and sv.ДатКнц
			LEFT OUTER join Stack.[Категории договоров] kdp on kdp.[row_id] = sv.Знач2
			LEFT OUTER join Stack.[классификаторы] klp on klp.[row_id] = sv.Значение		
			WHERE f.ТипДоговора <> 7 
)

select  CTE_func.Сумма,
		CTE_func.Сумма2, 								
		CTE_func.Объем, 
		CTE_func.ПолныйОбъем,								
        CTE_func.Аналитика, 
		CTE_func.Аналитика1,
		CTE_func.Аналитика2,
		CTE_func.ЗаМесяц,
		CTE_func.Договор,
		CTE_func.номномер,
		CTE_dog.Номер,
		CTE_dog.НомерДоговора,
		CTE_dog.Название,
		CTE_dog.Наименование,
		CTE_dog.ВидДоговора,
		la.Код Код46,
		CTE_dog.ИНН,		
		CTE_dog.КатегорияКод, 
		CTE_dog.Категория,
		CTE_dog.идБюджета,
		CTE_dog.ОтрасльКод,
		CTE_dog.ОтрасльНазвание,
		CTE_dog.БюджетОрг,
		CTE_dog.Окончание     
from CTE_func
INNER JOIN CTE_dog  on CTE_dog.Договор = CTE_func.Договор
LEFT OUTER join stack.[лицевых аналитики] la on la.row_id = CTE_func.Код46     


						 
		UNION ALL
		--частный сектор (если выбран соответствующий договор). Работает быстрее, чем собирать отдельно
		select sum(nm.Сумма) as Сумма, sum(nm.Сумма2) as Сумма2, sum(nm.Кол_во) as Объем, sum(nm.Кол_во) as ПолныйОбъем,
		'' Аналитика,nm.Аналитика1, 8050, nm.ЗаМесяц, f.Договор, nm.Аналитика1 номномер, dog.Номер, dog.Тема НомерДоговора, 
		org.Название, org.Наименование, dog.[Тип Договора] ВидДоговора,'' Код46, org.ИНН, 9524 идОтрасли, '710' КатегорияКод, '16' Категория, -1 идБюджета, '999' ОтрасльКод,
		'НАСЕЛЕНИЕ' as ОтрасльНазвание, -1 БюджетОрг,'20450509' as Окончание
        from stack.contracts_factures(-10,@d1,@d2) f
		join stack.Договор dog on dog.ROW_ID = f.Договор
		join stack.Организации org on org.ROW_ID = dog.Плательщик
		join stack.Документ doc on doc.ROW_ID = f.Документ
		join stack.[Наименования счета] nm on nm.[Счет-Наименования] = doc.ROW_ID
    where ТипДокумента = 35 and f.Договор = 7198 --ПрочитатьКонстанту(пДатНач, "ДОГОВОРАИПУ")
		and doc.Примечание Like 'Начисление частного сектора%'
    group by f.Договор, nm.Аналитика1, nm.ЗаМесяц, nm.Аналитика1, dog.Номер, dog.Тема, 
			org.Название, org.Наименование, dog.[Тип Договора], org.ИНН