
-- 先删除edw层有的类主键
create temporary table ufdata.crm_new_screening_diagnosises_pre as
select * 
  from ufdata.crm_new_screening_diagnosises a
 where a.statecode = '0';

-- delete from edw.crm_screening_diagnosises where screening_diagnosis_id in (select new_name from ufdata.crm_new_screening_diagnosises_pre);

truncate table edw.crm_screening_diagnosises;
insert into edw.crm_screening_diagnosises
select i.new_num
      ,i.name
      ,f.lastname as ownerid
      ,c.name as new_area
      ,b.new_name as new_province
      ,d.new_name as new_city
      ,e.new_name as new_county
      ,a.new_labs
      ,a.new_site
      ,a.new_diagnosisid_organization
      ,a.new_name as screening_diagnosis_id
      ,k.new_name as id
      ,k.new_number_of_reagents
      ,date_add(a.new_start_time, interval 8 hour)
      ,date_add(a.new_finish_time, interval 8 hour)
      ,l.item_name as item_dl
      ,m.item_name as item_xl
      ,n.item_name as item_mx
      ,k.new_biosan
      ,k.new_competitor_number
      ,o.name as jzds_name
      ,case when k._new_testing_organization_value = 'd12b7e3a-356a-e811-80c6-0050569a5e34' then '安致'
            when k._new_testing_organization_value = 'e487b0f9-f454-e811-80cb-005056a0fd6d' then '贝康'
            when k._new_testing_organization_value = '82806821-f554-e811-80cb-005056a0fd6d' then '甄元'
            when k._new_testing_organization_value = 'e687b0f9-f454-e811-80cb-005056a0fd6d' then '华大'
            when k._new_testing_organization_value is null then null
            else '请修改代码' end as testing_organization_three
      ,case when k._new_testing_organization_value is null then '自建'
            else '外送' end as hzfs
      ,k.new_cszh
      ,g.lastname as createdby
      ,a.createdon
      ,h.lastname as modifiedby
      ,j.lastname as modifiedonbehalfby
      ,a.modifiedon
  from ufdata.crm_new_screening_diagnosises_pre a
  left join ufdata.crm_accounts i
    on a.new_account = i.accountid
	left join ufdata.crm_sales_areas b
	  on a.new_province = b.new_siteid
	left join edw.dic_crm c
	  on a.new_area = c.id
	left join ufdata.crm_sales_areas d
	  on a.new_city = d.new_siteid
	left join ufdata.crm_sales_areas e
	  on a.new_county = e.new_siteid
	left join ufdata.crm_systemusers f
	  on a.ownerid = f.ownerid
	left join ufdata.crm_systemusers g
	  on a.createdby = g.ownerid
	left join ufdata.crm_systemusers h
	  on a.modifiedby = h.ownerid
	left join ufdata.crm_systemusers j
	  on a.modifiedonbehalfby = j.ownerid
	left join ufdata.crm_new_screening_subgs k
	  on a.new_screening_diagnosisid = k._new_screening_diagnosis_value
	left join edw.dic_item_crm l
	  on k._new_type1_value = l.item_code
	left join edw.dic_item_crm m
	  on k._new_type2_value = m.item_code
	left join edw.dic_item_crm n
	  on k._new_type3_value = n.item_code
	left join ufdata.crm_competitors o
	  on k._new_competitor_value = o.competitorid
 where k._new_screening_diagnosis_value is not null
   and k.statecode = '0'
;

-- 处理数据，的非部门转岗的数据，部门使用最新一条





