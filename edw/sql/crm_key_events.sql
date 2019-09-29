
-- crm关键事件表
drop table if exists edw.crm_key_events_pre;
create temporary table edw.crm_key_events_pre as
select a.new_key_eventid
      ,a.new_opp
      ,d.new_area
      ,d.new_province
      ,d.new_city
      ,d.new_county
      ,d.new_num as cuscode
      ,d.name as cusname
      ,f.name
      ,b.lastname as new_contact
      ,a.new_name
      ,a.new_finish_time
      ,a.new_region_trace
      ,a.new_province_trace
      ,e.lastname as ownerid
      ,date_add(a.new_deadline, interval 8 hour) as new_deadline
      ,case when new_status = '1' then '计划'
            when new_status = '2' then '进行中'
            when new_status = '3' then '已完成'
            when new_status = '4' then '延期'
            when new_status = '5' then '未定义'
            when new_status = '6' then '暂停'
            else '未知' end as new_status
      ,date_add(a.new_finish_date, interval 8 hour) as new_finish_date
      ,a.new_deflection
      ,a.new_memo
      ,localtimestamp() as sys_time
  from ufdata.crm_new_key_events a
  left join ufdata.crm_systemusers b
    on a.new_contact = b.ownerid
  left join ufdata.crm_accounts c
    on a.new_kehu = c.accountid
  left join edw.crm_accounts d
    on c.new_num = d.new_num
  left join ufdata.crm_systemusers e
    on a.ownerid = b.ownerid
  left join ufdata.crm_gantt_opportunities f
    on a.new_opp = f.opportunityid
 where a.statecode = '0'
;

-- 客户清洗
drop table if exists edw.crm_key_events_pre2;
create temporary table edw.crm_key_events_pre2 as 
select a.new_key_eventid
      ,a.new_opp
      ,a.new_area
      ,a.new_province
      ,a.new_city
      ,a.new_county
      ,a.cuscode
      ,a.cusname
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.bi_cuscode is null then '请核查' else c.bi_cusname end as bi_cusname
      ,a.name
      ,a.new_contact
      ,a.new_name
      ,a.new_finish_time
      ,a.new_region_trace
      ,a.new_province_trace
      ,a.ownerid
      ,a.new_deadline
      ,a.new_status
      ,a.new_finish_date
      ,a.new_deflection
      ,a.new_memo
      ,a.sys_time
  from edw.crm_key_events_pre a
 left join (select * from edw.dic_customer group by ccuscode) c
   on a.cuscode = c.ccuscode
 where a.cuscode is not null
 order by new_opp,new_deadline
;


truncate table edw.crm_key_events;
insert into edw.crm_key_events
select a.new_key_eventid
      ,@r:= case when @new_opp=a.new_opp then @r+1 else 1 end as rownum
      ,@new_opp:= a.new_opp as new_opp
      ,a.new_area
      ,a.new_province
      ,a.new_city
      ,a.new_county
      ,a.cuscode
      ,a.cusname
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.name
      ,a.new_deadline
      ,a.new_contact
      ,a.new_name
      ,a.new_finish_time
      ,a.new_region_trace
      ,a.new_province_trace
      ,a.ownerid
      ,a.new_status
      ,a.new_finish_date
      ,a.new_deflection
      ,a.new_memo
      ,a.sys_time
  from edw.crm_key_events_pre2 a
      ,(select @r:=0 ,@new_opp:='',@new_deadline:='') b
;