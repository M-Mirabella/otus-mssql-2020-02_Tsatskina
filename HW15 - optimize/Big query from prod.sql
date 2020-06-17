SET STATISTICS io, time on;

declare @d1 datetime = '01.04.2020';
declare @d2 datetime = '30.04.2020'; 
        select sum(f.[����� � ���]) as �����, sum(f.[����� ��� ���]) �����2, 
								
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
			f.���������1, f.���������2, f.����� �������, f.�������, f.��������, dog.�����,
            dog.���� �������������, org.��������, org.������������, dog.[��� ��������] �����������, la.��� ���46,
            case when LTRIM(RTRIM(org.���)) = '' then '��� ���' else org.��� end as ���,
			isnull(sv.��������,dog.[�������-��������]) as ���������,
			case when kdp.��� is null then kd.��� 
					else kdp.���
			end as ������������, 
			isnull(sv.����2,-1) ���������,
			dog.[������-��������] ���������,
			isnull(sv.����������,kl.���) as ����������,
			isnull(klp.��������,kl.��������) as ���������������,
			org.������ as ���������, isNull(dog.���������, '20450509') as ���������                                 
        from stack.calc_contracts_accs(-10,@d1) f
        join stack.������� dog on dog.ROW_ID = f.�������
        join stack.����������� org on org.ROW_ID = dog.����������
		left join (
					stack.�������� sv 	
					inner join Stack.[��������� ���������] kdp on kdp.[row_id] = sv.����2
					inner join Stack.[��������������] klp on klp.[row_id] = sv.��������
					) on dog.[row_id] = sv.[���������-�������]					
					and @d1 between sv.������ and sv.������
					and sv.[����-���������] = 461 --���������������("����������")
    left join stack.�������������� kl on kl.row_id = dog.[�������-��������]
    left join stack.[��������� ���������] kd on kd.row_id = dog.[���������-��������]
    left join stack.[������� ���������] la on la.row_id = f.���46
    where dog.[��� ��������] <> 7 
				--���� ����������� �� ��������� ��������
				--and f.���������1 not in  (` + c���������� + `)
				and f.������� <> 7197 -- ������������������(�������, "�����������") 
group by f.������������, f.���������1, f.���������2, f.�����, f.�������, f.��������, dog.�����,
        dog.����, org.��������, org.������������, dog.[��� ��������], la.���, f.�����, 
        case when LTRIM(RTRIM(org.���)) = '' then '��� ���' else org.��� end, 
        isnull(sv.��������,dog.[�������-��������]),isnull(sv.����2,-1),dog.[������-��������],
		case when kdp.��� is null then kd.��� else kdp.��� end,
		isnull(sv.����������,kl.���),isnull(klp.��������,kl.��������), org.������, isNull(dog.���������, '20450509')
						 
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