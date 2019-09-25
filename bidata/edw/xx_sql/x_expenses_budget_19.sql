
-- 19年公司预算表
-- 科目自己整合一下
drop table if exists edw.code;
create table edw.code as
select ccode,ccode_name
  from ufdata.code
 where db = 'UFDATA_111_2018'
   and iyear = "2019"
;

insert into edw.code values('640110','人员成本');

-- 插入数据
truncate table edw.x_expenses_budget_19;
insert into edw.x_expenses_budget_19
select a.cohr
      ,a.ddate
      ,a.cdept_name
      ,a.dept_1_ori
      ,a.dept_2_ori
      ,a.dept_3_ori
      ,b.cdept_id_ehr
      ,b.name_ehr
      ,b.second_dept
      ,b.third_dept
      ,b.fourth_dept
      ,b.fifth_dept
      ,b.sixth_dept
      ,a.ccusname_ori
      ,case when a.ccusname_ori is not null and e.ccusname is null then '请核查' else e.bi_cuscode end as bi_cuscode
      ,case when a.ccusname_ori is not null and e.ccusname is null then '请核查' else e.bi_cusname end as bi_cusname
      ,a.u8_code
      ,c.ccode_name as true_code_lv1
      ,d.ccode_name as true_code_lv2
      ,a.codename_ori_1
      ,a.codename_ori_2
      ,a.personname
      ,a.amount_budget
      ,a.meeting_name
      ,a.meeting_class
      ,a.remarks
  from ufdata.x_expenses_budget_19 a
  left join (select * from edw.dic_deptment group by cdept_name) b
    on a.cdept_name = b.cdept_name
  left join (select ccode,ccode_name from edw.code group by ccode) c
    on a.u8_code = c.ccode  
  left join (select ccode,ccode_name from edw.code group by ccode) d
    on SUBSTRING(a.u8_code,1,6) = d.ccode
  left join (select * from edw.dic_customer group by ccusname) e
    on a.ccusname_ori = e.ccusname
;

drop table if exists edw.code;
