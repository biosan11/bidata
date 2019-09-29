-- 先删除edw层有的类主键
create temporary table edw.crm_gantt_pre as
select * 
  from ufdata.crm_item_gantt a
 where ((left(a.createdon,10) >= '${start_dt}' or left(a.modifiedon,10) >= '${start_dt}'))
   and a.statecode = '0';

delete from edw.crm_gantt where new_sales_planid in (select new_sales_planid from edw.crm_gantt_pre);

create temporary table edw.crm_gantt_pre2 as
select a.new_sales_planid
      ,c.new_num as ccus_code
      ,c.name as ccus_name
      ,case when a.new_years = '1' then '2018' else '2019' end as  new_years
      ,a.new_months
      ,c.new_area
      ,c.new_province
      ,c.new_city
      ,c.new_county
      ,d.new_project_num
      ,d.name as new_project_name
      ,d.new_open_date
      ,case when a.new_type = '3' then '上量' when a.new_type = '1' then '项目入院' else '城市学科建设' end as new_type
      ,case when a.new_business_type = '100000000' then '产品类'
            when a.new_business_type = '100000001' then 'LDT'
            when a.new_business_type = '100000002' then '服务类'
            else '未知' end as new_business_type
      ,e.item_name as item_dl
      ,f.item_name as item_xl
      ,g.item_name as item_mx
      ,case when d.new_opp_statecode = '1' then '正在进行' 
            when d.new_opp_statecode = '2' then '暂停'
            else '未知' end as new_opp_statecode
      ,case when d.new_importance = 'True' then '是' 
            when d.new_importance = 'False' then '否'
            else '未知' end as new_importance
      ,h.lastname as new_audit
      ,i.lastname as ownerid
      ,a.new_to_do
      ,a.new_done
      ,case when a.new_alert = '1' then '正常'
            when a.new_alert = '2' then '推迟'
            when a.new_alert = '3' then '提前'
            else '未知' end as new_alert
      ,case when a.new_point = '100' then '0'
            when a.new_point = '101' then '-1'
            when a.new_point = '102' then '-2'
            when a.new_point = '103' then '-3'
            when a.new_point = '3' then '3'
            when a.new_point = '4' then '3+'
            else '未知' end as new_point
      ,a.new_solution10
      ,a.new_solution1
      ,a.new_progress1
      ,k.lastname as modifiedby
      ,a.createdon
      ,j.lastname as createdby
      ,a.modifiedon
      ,a.statecode
      ,a.statuscode
  from edw.crm_gantt_pre a
  left join ufdata.crm_accounts b
    on a._new_account_value = b.accountid
  left join edw.crm_accounts c
    on b.new_num = c.new_num
  left join ufdata.crm_gantt_opportunities d
    on a._new_opportunity_value = d.opportunityid
	left join edw.dic_item_crm e
	  on d._new_class_value = e.item_code
	left join edw.dic_item_crm f
	  on d._new_category_value = f.item_code
	left join edw.dic_item_crm g
	  on d._new_descrp_value = g.item_code
  left join ufdata.crm_systemusers h
    on a._new_audit_value = h.ownerid
  left join ufdata.crm_systemusers i
    on a._ownerid_value = i.ownerid
  left join ufdata.crm_systemusers j
    on a._modifiedby_value = j.ownerid
  left join ufdata.crm_systemusers k
    on a._createdby_value = k.ownerid
 where d.statecode = '0'
;

insert into edw.crm_gantt
select a.new_sales_planid
      ,a.new_years
      ,a.new_months
      ,a.ccus_code
      ,a.ccus_name
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cusname end as bi_cusname
      ,a.new_area
      ,a.new_province
      ,a.new_city
      ,a.new_county
      ,case when b.level_three is null then '请核查' else b.item_code end as item_code
      ,case when b.level_three is null then '请核查' else b.level_three end as item_name
      ,a.item_dl
      ,a.item_xl
      ,a.item_mx
      ,a.new_open_date
      ,a.new_type
      ,a.new_business_type
      ,a.new_project_num
      ,a.new_project_name
      ,a.new_opp_statecode
      ,a.new_importance
      ,a.new_audit
      ,a.ownerid
      ,a.new_to_do
      ,a.new_done
      ,a.new_alert
      ,a.new_point
      ,a.new_solution10
      ,a.new_solution1
      ,a.new_progress1
      ,a.createdby
      ,a.createdon
      ,a.modifiedby
      ,a.modifiedon
      ,a.statecode
      ,a.statuscode
 from edw.crm_gantt_pre2 a
 left join (select * from edw.map_item group by level_three) b
   on a.item_mx = b.level_three
 left join (select * from edw.dic_customer group by ccuscode) c
   on a.ccus_code = c.ccuscode
;

