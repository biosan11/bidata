
-- 加工crm工单
truncate table edw.crm_new_work_orders;
insert into edw.crm_new_work_orders
select a.new_num
      ,concat(b.new_ccusabbname,a.new_issue_demand) as num_name
      ,new_finishwo
      ,b.new_area
      ,b.new_province
      ,b.name as ccusname -- 这里缺失一个联系人
      ,b.new_grade
      ,c.bi_cinvcode
      ,c.bi_cinvname
      ,i.new_name as new_type_3
      ,date_add(left(a.modifiedon,19), interval 8 hour) as modifiedon
      ,date_add(left(a.new_problem_happen_time,19), interval 8 hour) as problem_happen_time
      ,case when a.new_macover = 'false' then '保外'
            else '保内' end as new_macover
      ,a.new_opinion as opinion
      ,a.new_actual_problem_description as actual_problem_description
      ,d.lastname as assign_superior
      ,date_add(left(a.new_assign_time,19), interval 8 hour) as assign_time
      ,e.lastname as ownerid
      ,f.name as business_nuit
      ,e.title
      ,concat(a.new_working,'个工作日') as working
      ,concat(a.new_estimate_difficulty,'级') as estimate_difficulty
      ,a.new_satisfied
      ,g.lastname as perform_engineer
      ,a.new_skill
      ,date_add(left(a.new_acctime,19), interval 8 hour) as acctime
      ,date_add(left(a.new_assign_record_time,19), interval 8 hour) as assign_record_time
      ,date_add(left(a.new_resolution_time,19), interval 8 hour) as resolution_time
      ,a.new_service_hours
      ,concat(a.new_superior_comment,'星') as superior_comment
      ,a.new_technology_comment
      ,a.new_manager_comment
      ,case when new_return_visit = 'e72f56b2-9e73-e811-80c6-0050569a5e34' then '是'
            else '未知' end as return_visit
      ,h.lastname as return_visit_user
      ,date_add(left(a.new_return_visit_time,19), interval 8 hour) as return_visit_time
      ,case when new_ifclose = 1 then '是'
            when new_ifclose = 2 then '否'
            else '未知' end as new_ifclose
      ,a.new_acknowledgement
      ,a.new_troubleshooting
      ,case when a.new_this_repair = 'False' then '否'
            when a.new_this_repair = 'True' then '是'
            else '未知' end as this_repair
      ,localtimestamp() as sys_time
  from ufdata.crm_new_work_orders a
  left join edw.crm_account_equipments c
    on a.new_account_equipment = c.new_account_equipmentid
  left join edw.crm_accounts b 
    on c.custcode = b.new_num
  left join ufdata.crm_systemusers d
    on a.new_assign_superior = d.ownerid
  left join ufdata.crm_systemusers e
    on a.ownerid = e.ownerid
  left join ufdata.crm_deptment f
    on a.new_business_nuit = f.businessunitid
  left join ufdata.crm_systemusers g
    on a.new_perform_engineer = g.ownerid
  left join ufdata.crm_systemusers h
    on a.new_return_visit_user = h.ownerid
  left join ufdata.crm_new_work_types i 
    on a.new_type_3 = i.new_work_typeid
;









