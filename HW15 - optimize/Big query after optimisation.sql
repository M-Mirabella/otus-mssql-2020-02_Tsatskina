SET STATISTICS io, time on;

declare @d1 datetime = Cast('2020-04-01' as datetime);
declare @d2 datetime = Cast('2020-04-30' as datetime); 

DROP TABLE IF EXISTS #TmpTbl1
CREATE TABLE @TmpTbl1 (
				 ����� float(53),
				 �����2 float(53),
				 ����� float(53),
				 ����������� float(53),
				 ��������� nvarchar(15),
				 ���������1,
			f.���������2,
			f.����� �������,
			f.�������,
			f.��������)
)

        select sum(f.[����� � ���]) as �����,
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
			dog.�����,
            dog.���� �������������,
			org.��������,
			org.������������,
			dog.[��� ��������] �����������,
			la.��� ���46,
            case when LTRIM(RTRIM(org.���)) = '' then '��� ���' else org.��� end as ���,
			isnull(sv.��������, dog.[�������-��������]) as ���������,
			isnull(sv.������������, kd.���) as ������������, 
			isnull(sv.����2,-1) ���������,
			dog.[������-��������] ���������,
			isnull(sv.����������, kl.���) as ����������,
			isnull(sv.���������������, kl.��������) as ���������������,
			org.������ as ���������,
			isNull(dog.���������, '20450509') as ���������                                 
        from stack.calc_contracts_accs(-10,@d1) f
        inner join stack.������� dog on dog.ROW_ID = f.�������
        inner join stack.����������� org on org.ROW_ID = dog.����������
		OUTER APPLY (
					Select sv.����������, sv.����2, sv.��������, kdp.��� as ������������, klp.�������� as ���������������
					FROM stack.�������� sv
					inner join Stack.[��������� ���������] kdp on kdp.[row_id] = sv.����2
					inner join Stack.[��������������] klp on klp.[row_id] = sv.��������
					Where sv.[���������-�������] = dog.[row_id]					
					and @d1 between sv.������ and sv.������
					and sv.[����-���������] = 461) sv  --���������������("����������")
    left join stack.�������������� kl on kl.row_id = dog.[�������-��������]
    left join stack.[��������� ���������] kd on kd.row_id = dog.[���������-��������]
    left join stack.[������� ���������] la on la.row_id = f.���46
    where dog.[��� ��������] <> 7 
      and f.������� <> 7197 -- ������������������(�������, "�����������") 
group by f.������������, f.���������1, f.���������2, f.�����, f.�������, f.��������, dog.�����,
        dog.����, org.��������, org.������������, dog.[��� ��������], la.���, f.�����, 
        case when LTRIM(RTRIM(org.���)) = '' then '��� ���' else org.��� end, 
        isnull(sv.��������,dog.[�������-��������]),isnull(sv.����2,-1),dog.[������-��������],
		isnull(sv.������������, kd.���),
		isnull(sv.����������,kl.���),isnull(sv.���������������, kl.��������), org.������, isNull(dog.���������, '20450509')
						 
		UNION ALL
		--������� ������ (���� ������ ��������������� �������). �������� �������, ��� �������� ��������
		select sum(nm.�����) as �����, sum(nm.�����2) as �����2, sum(nm.���_��) as �����, sum(nm.���_��) as �����������,
		'' ���������,nm.���������1, 8050, nm.�������, f.�������, nm.���������1 ��������, dog.�����, dog.���� �������������, 
		org.��������, org.������������, dog.[��� ��������] �����������,'' ���46, org.���, 9524 ���������, '710' ������������, '16' ���������, -1 ���������, '999' ����������,
		'���������' as ���������������, -1 ���������,'20450509' as ���������
        from stack.contracts_factures(-10,@d1,@d2) f
		join stack.������� dog on dog.ROW_ID = f.�������
		join stack.����������� org on org.ROW_ID = dog.����������
		join stack.�������� doc on doc.ROW_ID = f.��������
		join stack.[������������ �����] nm on nm.[����-������������] = doc.ROW_ID
    where ������������ = 35 and f.������� = 7198 --������������������(�������, "�����������")
		and doc.���������� Like '���������� �������� �������%'
    group by f.�������, nm.���������1, nm.�������, nm.���������1, dog.�����, dog.����, 
			org.��������, org.������������, dog.[��� ��������], org.���