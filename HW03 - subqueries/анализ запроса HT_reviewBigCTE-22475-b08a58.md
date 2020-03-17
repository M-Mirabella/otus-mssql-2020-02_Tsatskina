--В материалах к вебинару есть файл HT_reviewBigCTE.sql
-- - прочтите этот запрос и напишите что он должен вернуть и в чем его смысл, можно если есть идеи по улучшению тоже их включить.

-- Из представления dbo.vwUserFileInActive выбираются файлы из переданной папки, где дата удаления старее переданной даты.
-- Далее для выбранных файлов подбираются правила конкретной организации, высчитывается ДатаУдаленияфайлов для конкретной организации.
-- Возвращаемые поля:
-- Порядковый номер - вычисляется оконной функцией, окно разбивается по UserFileId, сортировка по приоритету правила организации.
-- Дата, до которой можно удялать файлы. От переданной даты отнимается количество дней, месяцев, лет - для конкретной организации.
   Я так понимаю что должно быть задано 1 значение из трех, хотя может быть 1 год, 6 месяцев например
-- Количество дополнительных дней, месяцев, лет хранения файлов для организации (для соответствующего файлу правила)
-- ИД правила, которое выбирается для конкретного файла и организации
-- ИД файла пользователя
-- ИД папки

-- Видимо речь идет о хранилище документов. И данный запрос выбирает файлы из корзины хранилища что бы отобрать те, которые можно удалить окончательно.
-- Что бы понять как улучшить запрос нужно знать размер таблиц, какие есть индексы, что есть в остальном запросе.


WITH cteDeletedDF as
(
SELECT top (@DFBatchSize)
		df.UserFileId,
		@vfId as VirtualFolderId,
		@vfOwnerId as OwnerId,
		df.UserFileVersionId,
		df.FileId,
		df.[Length],
		df.EffectiveDateRemovedUtc as lastDeleteDate,
		@vfFolderId as FolderId
 FROM dbo.vwUserFileInActive df with(nolock)
  WHERE df.[FolderId] = @vfFolderId
	AND df.EffectiveDateRemovedUtc < @maxDFKeepDate
),
cteDeletedDFMatchedRules
as
(
SELECT ROW_NUMBER() over(partition by DF.UserFileId order by T.Priority) rn,
		DATEADD(YEAR, -t.DeletedFileYears,
				DATEADD(MONTH, -t.DeletedFileMonths,
						DATEADD(DAY, -t.DeletedFileDays , @keepDeletedFromDate))) customRuleKeepDate,
		T.DeletedFileDays as customDeletedDays,
		T.DeletedFileMonths as customDeletedMonths,
		T.DeletedFileYears as customDeletedYears,
		T.CustomRuleId,
		dDf.UserFileId,
		dDF.FolderId as FolderId
FROM cteDeletedDF dDF
INNER JOIN dbo.UserFile DF with(nolock)
	on dDF.FolderId = df.FolderId
	 and dDF.UserFileId = Df.UserFileId
LEFT JOIN dbo.UserFileExtension dfe with(nolock)
	on df.[ExtensionId] = dfe.[ExtensionId]
CROSS JOIN #companyCustomRules T
WHERE
  (
	EXISTS
		(
		SELECT TOP 1
				1 as id
		 where T.RuleType = 0
			and T.RuleCondition = 0
			and T.RuleItemFileType = dfe.[FileTypeId]

		 union all

		SELECT TOP 1
				1
		 where T.RuleType = 0
			and T.RuleCondition = 1
			and T.RuleItemFileType <> dfe.[FileTypeId]

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 0
			and DF.Name = T.RuleItemFileMask

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 4
			and DF.Name like  case T.RuleCondition
							  when 4
							  then '%' + T.RuleItemFileMask + '%' --never will be indexed
							  when 3
							  then '%' + T.RuleItemFileMask --never will be indexed
							  when 2
							  then T.RuleItemFileMask + '%' --may be indexed
							 end

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 1
			and T.RuleCondition = 5
			and dbo.RegExMatch(DF.Name, T.RuleItemFileMask) = 1 --never will be indexed

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 2
			and T.RuleCondition = 6
			and DF.[Length] > T.RuleItemFileSize

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 2
			and T.RuleCondition = 7
			and DF.[Length] < T.RuleItemFileSize

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 3
			and T.RuleCondition = 0
			and dDF.VirtualFolderId = T.RuleItemVirtualFolderId

		union all

		SELECT TOP 1
				1
		 where T.RuleType = 3
			and T.RuleCondition = 8
			and T.RuleItemVirtualFolderOwnerId = dDf.OwnerId
		)
  )
)