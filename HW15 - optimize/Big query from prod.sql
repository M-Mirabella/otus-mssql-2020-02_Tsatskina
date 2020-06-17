SET STATISTICS io, time on;

declare @d1 datetime = '01.04.2020';
declare @d2 datetime = '30.04.2020'; 
        select sum(f.[сумма с ндс]) as Сумма, sum(f.[сумма без ндс]) Сумма2, 
								
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
			f.Аналитика1, f.Аналитика2, f.Месяц ЗаМесяц, f.Договор, f.номномер, dog.Номер,
            dog.Тема НомерДоговора, org.Название, org.Наименование, dog.[Тип Договора] ВидДоговора, la.Код Код46,
            case when LTRIM(RTRIM(org.ИНН)) = '' then 'Нет ИНН' else org.ИНН end as ИНН,
			isnull(sv.Значение,dog.[отрасль-договоры]) as идОтрасли,
			case when kdp.Код is null then kd.Код 
					else kdp.Код
			end as КатегорияКод, 
			isnull(sv.Знач2,-1) Категория,
			dog.[Бюджет-Договоры] идБюджета,
			isnull(sv.Примечание,kl.Код) as ОтрасльКод,
			isnull(klp.Название,kl.Название) as ОтрасльНазвание,
			org.Бюджет as БюджетОрг, isNull(dog.Окончание, '20450509') as Окончание                                 
        from stack.calc_contracts_accs(-10,@d1) f
        join stack.Договор dog on dog.ROW_ID = f.Договор
        join stack.Организации org on org.ROW_ID = dog.Плательщик
		left join (
					stack.Свойства sv 	
					inner join Stack.[Категории договоров] kdp on kdp.[row_id] = sv.Знач2
					inner join Stack.[классификаторы] klp on klp.[row_id] = sv.Значение
					) on dog.[row_id] = sv.[Параметры-Договор]					
					and @d1 between sv.ДатНач and sv.ДатКнц
					and sv.[Виды-Параметры] = 461 --ДанныеПараметра("ВЫБОРОКВЭД")
    left join stack.классификаторы kl on kl.row_id = dog.[Отрасль-Договоры]
    left join stack.[категории договоров] kd on kd.row_id = dog.[Категория-Договоры]
    left join stack.[лицевых аналитики] la on la.row_id = f.Код46
    where dog.[Тип Договора] <> 7 
				--Если определятся не учитывать мощность
				--and f.Аналитика1 not in  (` + cтрМощность + `)
				and f.Договор <> 7197 -- ПрочитатьКонстанту(пДатНач, "ДОГОВОРАМКД") 
group by f.АналитикаДок, f.Аналитика1, f.Аналитика2, f.Месяц, f.Договор, f.номномер, dog.Номер,
        dog.Тема, org.Название, org.Наименование, dog.[Тип Договора], la.Код, f.Объем, 
        case when LTRIM(RTRIM(org.ИНН)) = '' then 'Нет ИНН' else org.ИНН end, 
        isnull(sv.Значение,dog.[отрасль-договоры]),isnull(sv.Знач2,-1),dog.[Бюджет-Договоры],
		case when kdp.Код is null then kd.Код else kdp.Код end,
		isnull(sv.Примечание,kl.Код),isnull(klp.Название,kl.Название), org.Бюджет, isNull(dog.Окончание, '20450509')
						 
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