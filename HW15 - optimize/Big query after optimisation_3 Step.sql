SET STATISTICS io, time on;

DROP TABLE #FuncTbl 
DROP TABLE #DogsTbl
GO

CREATE TABLE #FuncTbl
		(
		 ����� float(53),
		 �����2 float(53),
		 ����� float(53),
		 ����������� float(53),
		 ��������� varchar(256),
		 ���������1 varchar(256),
		 ���������2 varchar(256),
	     ������� datetime,
		 ������� int,
		 �������� varchar(256),			
		 ���46 int
		)

CREATE INDEX IX_FuncTbl ON #FuncTbl (������� ASC) 
GO

CREATE TABLE #DogsTbl
(  
	������� int,
	����� varchar(256),
	������������� varchar(256),
	�������� varchar(256),
	������������ varchar(1000),
	��� varchar(256),
	����������� int,
	��������� int,				  
	��������� int,
	������������ varchar(256),
	��������� int,
	���������� varchar(256),
	��������������� varchar(256),
	��������� int,
	��������� datetime
)
CREATE INDEX IX_DogsTbl ON #DogsTbl (������� ASC)
GO

declare @d1 datetime = Cast('2020-04-01' as datetime);
declare @d2 datetime = Cast('2020-04-30' as datetime);
declare @dogs varchar(max) = -10;

INSERT INTO #FuncTbl
(�����, �����2,	�����, �����������, ���������, ���������1, ���������2, �������, �������, ��������, ���46)
		SELECT sum(f.[����� � ���]) as �����,
			   sum(f.[����� ��� ���]) �����2, 
								
			--��������� (�� ��������� ������ �� ��������)
			case when f.���������1 in  (2161,2162,2261,2262,7103,7203) then 0
					else sum(f.����� * [���������� � �����])
			end as �����, 
			case when f.���������1 in  (2161,2162,2261,2262,7103,7203) then 0
					else f.�����
			end as �����������, 
								
            case when f.������������ = '��' then ''
					when f.������������ = '����' then ''
					else f.������������ 
			end as ���������, 
			f.���������1,
			f.���������2,
			f.����� �������,
			f.�������,
			f.��������,			
			f.���46                
		FROM stack.calc_contracts_accs(@dogs,@d1) f				
		WHERE f.������� <> 7197
		group by f.������������, f.���������1, f.���������2, f.�����, f.�������, f.��������, f.���46, f.�����      

INSERT INTO #DogsTbl
(	�������, �����, �������������, ��������, ������������, ���, �����������, ���������, ���������, ������������, ���������, ����������,
	���������������, ���������, ���������)
			SELECT f.�������,
			       f.�����,
				   f.���� as �������������,
				   org.��������,
				   org.������������,
			       case when LTRIM(RTRIM(org.���)) = '' then '��� ���' else org.��� end as ���,
				   f.����������� as �����������,
				   isnull(sv.��������, f.�������) as ���������,				  
				   f.������ as ���������,
				   isnull(kdp.���,f.������������) as ������������,
				   isnull(sv.����2,-1) ���������,
				   isnull(sv.����������, f.����������) as ����������,
				   isnull(klp.��������, f.���������������) as ���������������,
				   org.������ as ���������,
				   f.���������
			FROM stack.contracts(@dogs) as f
			INNER JOIN stack.����������� org on org.ROW_ID = f.����������
			LEFT OUTER JOIN stack.�������� sv
				on sv.[���������-�������] = f.������� and sv.[����-���������] = 461 and @d1 between sv.������ and sv.������
			LEFT OUTER join Stack.[��������� ���������] kdp on kdp.[row_id] = sv.����2
			LEFT OUTER join Stack.[��������������] klp on klp.[row_id] = sv.��������		
			WHERE f.����������� <> 7 

select  func.�����,
		func.�����2, 								
		func.�����, 
		func.�����������,								
        func.���������, 
		func.���������1,
		func.���������2,
		func.�������,
		func.�������,
		func.��������,
		dog.�����,
		dog.�������������,
		dog.��������,
		dog.������������,
		dog.�����������,
		la.��� ���46,
		dog.���,	
		dog.���������,
		dog.������������, 
		dog.���������,
		dog.���������,
		dog.����������,
		dog.���������������,
		dog.���������,
		dog.���������     
from  #FuncTbl as func
INNER JOIN #DogsTbl as dog on dog.������� = func.�������
LEFT OUTER join stack.[������� ���������] la on la.row_id = func.���46     
						 
		UNION ALL
		--������� ������ (���� ������ ��������������� �������). �������� �������, ��� �������� ��������
select sum(nm.�����) as �����,
	   sum(nm.�����2) as �����2,
	   sum(nm.���_��) as �����,
	   sum(nm.���_��) as �����������,
       '' ���������,
	   nm.���������1,
	   8050,
	   nm.�������,
	   f.�������,
	   nm.���������1 ��������,
	   dog.�����,
	   dog.���� �������������, 
       org.��������,
       org.������������,
	   dog.[��� ��������] �����������,
	   '' ���46,
	   org.���,
	   9524 ���������,
	   '710' ������������,
	   '16' ���������,
	   -1 ���������,
	   '999' ����������,
       '���������' as ���������������,
	   -1 ���������,
	   '20450509' as ���������
from stack.contracts_factures(@dogs,@d1,@d2) f
join stack.������� dog on dog.ROW_ID = f.�������
join stack.����������� org on org.ROW_ID = dog.����������
join stack.�������� doc on doc.ROW_ID = f.��������
join stack.[������������ �����] nm on nm.[����-������������] = doc.ROW_ID
where ������������ = 35 and f.������� = 7198 --������������������(�������, "�����������")
and doc.���������� Like '���������� �������� �������%'
group by f.�������, nm.���������1, nm.�������, nm.���������1, dog.�����, dog.����, 
	org.��������, org.������������, dog.[��� ��������], org.���