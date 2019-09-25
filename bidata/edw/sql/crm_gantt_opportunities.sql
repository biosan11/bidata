
-- crm业务项目
drop table if exists edw.crm_gantt_opportunities_pre;
create temporary table edw.crm_gantt_opportunities_pre as
select
a.opportunityid
,d.new_area
,d.new_province
,d.new_city
,d.new_county
,d.new_num as cuscode
,d.name as cusname
,a.new_project_num
,a.name
,a.new_importance
,case when a.new_type = '3' then '上量' 
      when a.new_type = '1' then '项目入院' 
      else '城市学科建设' end as new_type
,case when a.new_business_type = '100000000' then '产品类'
      when a.new_business_type = '100000001' then 'LDT'
      when a.new_business_type = '100000002' then '服务类'
      else '未知' end as new_business_type
,date_add(a.new_open_date, interval 8 hour) as new_open_date
,b.lastname as ownerid
,a.budgetamount_base
,a.finaldecisiondate
,a.estimatedclosedate
  from ufdata.crm_gantt_opportunities a
  left join ufdata.crm_systemusers b
    on a._ownerid_value = b.ownerid
  left join ufdata.crm_accounts c
    on a._parentaccountid_value = c.accountid
  left join edw.crm_accounts d
    on c.new_num = d.new_num
 where a.statecode = '0'
   and a.stageid is null
 ;

truncate table edw.crm_gantt_opportunities;
insert into edw.crm_gantt_opportunities
select a.opportunityid
      ,a.new_area
      ,a.new_province
      ,a.new_city
      ,a.new_county
      ,a.cuscode
      ,a.cusname
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cusname end as bi_cusname
      ,a.new_project_num
      ,a.name
      ,a.new_importance
      ,a.new_type
      ,a.new_business_type
      ,a.new_open_date
      ,a.ownerid
      ,a.budgetamount_base
      ,a.finaldecisiondate
      ,a.estimatedclosedate
      ,'已开启' as state
      ,'正在进行' as status
      ,localtimestamp() as sys_time
  from edw.crm_gantt_opportunities_pre a
 left join (select * from edw.dic_customer group by ccuscode) c
   on a.cuscode = c.ccuscode
;
