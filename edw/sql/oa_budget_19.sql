-- 先得出预算的起始部门
drop table if exists edw.oa_fnabudgetinfo_pre;
create temporary table edw.oa_fnabudgetinfo_pre as
select a.id
      ,a.budgetorganizationid
      ,b.departmentmark as cdepname
      ,b.tlevel
      ,a.remark
      ,a.createdate
      ,a.approverid
      ,a.createrid
      ,a.status
  from ufdata.oa_fnabudgetinfo a
  left join ufdata.oa_hrmdepartment b
    on a.budgetorganizationid = b.id
 where a.organizationtype = 2;



drop table if exists edw.oa_fnabudgetinfo_pre1;
create temporary table edw.oa_fnabudgetinfo_pre1 as
select a.id
      ,a.cdepname as cdepname_lv6
      ,c.departmentmark as cdepname_lv5
      ,d.departmentmark as cdepname_lv4
      ,e.departmentmark as cdepname_lv3
      ,f.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null' as person
      ,a.status
  from edw.oa_fnabudgetinfo_pre a
  left join ufdata.oa_hrmdepartment b
    on a.budgetorganizationid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
  left join ufdata.oa_hrmdepartment e
    on d.supdepid = e.id
  left join ufdata.oa_hrmdepartment f
    on e.supdepid = f.id
 where a.tlevel = 6;

insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,null
      ,a.cdepname as cdepname_lv5
      ,c.departmentmark as cdepname_lv4
      ,d.departmentmark as cdepname_lv3
      ,e.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null' as person
      ,a.status
  from edw.oa_fnabudgetinfo_pre a
  left join ufdata.oa_hrmdepartment b
    on a.budgetorganizationid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
  left join ufdata.oa_hrmdepartment e
    on d.supdepid = e.id
 where a.tlevel = 5;

insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,null
      ,null
      ,a.cdepname as cdepname_lv4
      ,c.departmentmark as cdepname_lv3
      ,d.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null' as person
      ,a.status
  from edw.oa_fnabudgetinfo_pre a
  left join ufdata.oa_hrmdepartment b
    on a.budgetorganizationid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
 where a.tlevel = 4;
 
insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,null
      ,null
      ,null
      ,a.cdepname as cdepname_lv3
      ,c.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null' as person
      ,a.status
  from edw.oa_fnabudgetinfo_pre a
  left join ufdata.oa_hrmdepartment b
    on a.budgetorganizationid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
 where a.tlevel = 3;

insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,null
      ,null
      ,null
      ,null
      ,a.cdepname as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null' as person
      ,a.status
  from edw.oa_fnabudgetinfo_pre a
 where a.tlevel = 2;



insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,null
      ,null
      ,null
      ,null
      ,null
      ,b.subcompanyname as cdepname_lv1
      ,b.subcompanyname
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,'null'
      ,a.status
  from ufdata.oa_fnabudgetinfo a
  left join ufdata.oa_hrmsubcompany b
    on a.budgetorganizationid = b.id
 where a.organizationtype = 0
    or a.organizationtype = 1;

-- 加载人员信息数据
drop table if exists edw.oa_fnabudgetinfo_ren;
create temporary table edw.oa_fnabudgetinfo_ren as
select a.id
      ,a.remark
      ,b.departmentid
      ,c.departmentmark as cdepname
      ,c.tlevel
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,b.lastname as person
      ,a.status
  from ufdata.oa_fnabudgetinfo a
  left join ufdata.oa_hrmresource b
    on a.budgetorganizationid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.departmentid = c.id
 where a.organizationtype = 3
   and c.tlevel is not null;



drop table if exists edw.oa_fnabudgetinfo_ren1;
create temporary table edw.oa_fnabudgetinfo_ren1 as
select a.id
      ,a.cdepname as cdepname_lv6
      ,c.departmentmark as cdepname_lv5
      ,d.departmentmark as cdepname_lv4
      ,e.departmentmark as cdepname_lv3
      ,f.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren a
  left join ufdata.oa_hrmdepartment b
    on a.departmentid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
  left join ufdata.oa_hrmdepartment e
    on d.supdepid = e.id
  left join ufdata.oa_hrmdepartment f
    on e.supdepid = f.id
 where a.tlevel = 6;



insert into edw.oa_fnabudgetinfo_ren1
select a.id
      ,null
      ,a.cdepname as cdepname_lv5
      ,c.departmentmark as cdepname_lv4
      ,d.departmentmark as cdepname_lv3
      ,e.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren a
  left join ufdata.oa_hrmdepartment b
    on a.departmentid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
  left join ufdata.oa_hrmdepartment e
    on d.supdepid = e.id
 where a.tlevel = 5;

insert into edw.oa_fnabudgetinfo_ren1
select a.id
      ,null
      ,null
      ,a.cdepname as cdepname_lv4
      ,c.departmentmark as cdepname_lv3
      ,d.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren a
  left join ufdata.oa_hrmdepartment b
    on a.departmentid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
  left join ufdata.oa_hrmdepartment d
    on c.supdepid = d.id
 where a.tlevel = 4;
 
insert into edw.oa_fnabudgetinfo_ren1
select a.id
      ,null
      ,null
      ,null
      ,a.cdepname as cdepname_lv3
      ,c.departmentmark as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren a
  left join ufdata.oa_hrmdepartment b
    on a.departmentid = b.id
  left join ufdata.oa_hrmdepartment c
    on b.supdepid = c.id
 where a.tlevel = 3;

insert into edw.oa_fnabudgetinfo_ren1
select a.id
      ,null
      ,null
      ,null
      ,null
      ,a.cdepname as cdepname_lv2
      ,'1111111111111111' as cdepname_lv1
      ,a.cdepname as budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren a
 where a.tlevel = 2;





insert into edw.oa_fnabudgetinfo_pre1
select a.id
      ,a.cdepname_lv6
      ,a.cdepname_lv5
      ,a.cdepname_lv4
      ,a.cdepname_lv3
      ,a.cdepname_lv2
      ,a.cdepname_lv1
      ,a.budget_depnam
      ,a.remark
      ,a.createdate
      ,a.createrid
      ,a.approverid
      ,a.person
      ,a.status
  from edw.oa_fnabudgetinfo_ren1 a
;


create index index_oa_fnabudgetinfo_pre_id on edw.oa_fnabudgetinfo_pre1(id);

-- oa_budget_19 清洗 u8kemubm 这个字段的时候 如果 name = 6602人才推荐费  u8kemubm = 66020202  -- 加个注释  2019年5月30日 钉钉与财务池菁确认过
truncate table edw.oa_budget_19;
insert into edw.oa_budget_19
select a.budgetinfoid
      ,case when b.cdepname_lv1 = '1111111111111111' then null
       else b.cdepname_lv1 end as cdepname_lv1
      ,b.cdepname_lv2
      ,b.cdepname_lv3
      ,b.cdepname_lv4
      ,b.cdepname_lv5
      ,b.cdepname_lv6
      ,case when b.person = 'null' then null
       else b.person end as person
      ,b.budget_depnam
      ,null
      ,null
      ,c.name
      ,case when c.name = '6602人才推荐费' then '66020202' else e.u8kemubm end  as u8kemubm
      ,case when d.cdztlx = '0' then  '个人'
       else '部门' end as cdlx
      ,a.budgetperiodslist
      ,a.budgetaccount
      ,b.createdate
      ,case when b.approverid is null then 'crm' else b.approverid end
      ,case when b.createrid = '1' then 'crm' else b.createrid end
      ,a.budgetremark
      ,a.fnaincrement
      ,b.remark
      ,localtimestamp() as sys_time
  from (select * from ufdata.oa_fnabudgetinfodetail where budgetperiods = 21 ) a
  left join edw.oa_fnabudgetinfo_pre1 b
    on a.budgetinfoid  = b.id
  left join ufdata.oa_fnabudgetfeetype c
    on a.budgettypeid = c.id
  left join ufdata.oa_uf_yslxb d
    on c.id = d.yskm
  left join ufdata.oa_uf_u8dykm e
    on c.name = e.kemumc
 where b.status = 1;

update edw.oa_budget_19 set name_oa = '销售一区' where person = '邓志良';
update edw.oa_budget_19 set name_oa = '销售二区' where person = '何珊';
update edw.oa_budget_19 set name_oa = '浙江省区' where person = '乔国付';
update edw.oa_budget_19 set name_oa = '产品推广部' where person = '史勤华';
update edw.oa_budget_19 set name_oa = '战略市场中心' where person = '游英';
update edw.oa_budget_19 set name_oa = '销售部' where person = '张志坚';
update edw.oa_budget_19 set name_oa = '上海技术支持组' where person = '晁建文' and name = '6601业务招待费';
update edw.oa_budget_19 set name_oa = '财务中心' where person = '俞晓';
update edw.oa_budget_19 set name_oa = '行政部' where person = '刘英';

-- update edw.oa_budget_19 as a
-- inner join (select * from edw.ehr_deptment  group by name_oa) as b
-- on a.name_oa = b.name_oa
-- set 
--   a.name_ehr = b.name_ehr
--  ,a.cdepname_lv2 = b.name_lv3
--  ,a.cdepname_lv3 = b.name_lv4
--  ,a.cdepname_lv4 = b.name_lv5
--  ,a.cdepname_lv5 = b.name_lv6
-- ;

-- 第一步,这里是处理部门分级多次计算金额的操作
create temporary table edw.oa_budget_19_11 as 
select * 
  from edw.oa_budget_19
 where cdepname_lv1 is null
   and person is null;

create temporary table edw.oa_budget_19_22 as
select *
  from edw.oa_budget_19_11
where sixth_dept is not null;

delete FROM edw.oa_budget_19 where person is null and CONCAT(name,budgetperiodslist,second_dept,third_dept,fourth_dept,fifth_dept) in (select CONCAT(name,budgetperiodslist,second_dept,third_dept,fourth_dept,fifth_dept) from edw.oa_budget_19_22);


-- 第二步
insert into edw.oa_budget_19_22
select *
  from edw.oa_budget_19_11
where fifth_dept is not null 
  and sixth_dept is null
;

delete FROM edw.oa_budget_19_11 where person is null and  CONCAT(name,budgetperiodslist,second_dept,third_dept,fourth_dept) in (select CONCAT(name,budgetperiodslist,second_dept,third_dept,fourth_dept) from edw.oa_budget_19_22);

-- 第三步
insert into edw.oa_budget_19_22
select *
  from edw.oa_budget_19_11
where fifth_dept is not null 
and sixth_dept is null
and fourth_dept is null
;

delete FROM edw.oa_budget_19_11 where person is null and  CONCAT(name,budgetperiodslist,second_dept,third_dept) in (select CONCAT(name,budgetperiodslist,second_dept,third_dept) from edw.oa_budget_19_22);

-- 第四步
insert into edw.oa_budget_19_22
select *
  from edw.oa_budget_19_11
where fifth_dept is not null 
and sixth_dept is null
and fourth_dept is null
and third_dept is null;

delete FROM edw.oa_budget_19_11 where person is null and  CONCAT(name,budgetperiodslist,second_dept) in (select CONCAT(name,budgetperiodslist,second_dept) from edw.oa_budget_19_22);

-- 第五步
insert into edw.oa_budget_19_22
select *
  from edw.oa_budget_19_11
where second_dept is not null 
and third_dept is null
and fourth_dept is null
and fifth_dept is null
and sixth_dept is null;

-- 处理完上面的数据后，然后导入原来的表
delete from edw.oa_budget_19
 where cdepname_lv1 is null
   and person is null;

insert into edw.oa_budget_19
select a. budgetinfoid
      ,a.cdepname_lv1
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.person
      ,a.name_oa
      ,null
      ,null
      ,a.name
      ,a.u8kemubm
      ,a.cdlx
      ,a.budgetperiodslist
      ,a.budgetaccount
      ,a.createdate
      ,a.approverid
      ,a.createrid
      ,a.budgetremark
      ,a.fnaincrement
      ,a.remark
      ,localtimestamp() as sys_time
  from edw.oa_budget_19_22 a;
  
update edw.oa_budget_19 as a
inner join (select * from edw.dic_deptment where source = 'OA'  group by cdept_name) as b
on a.name_oa = b.cdept_name
set 
  a.name_ehr = b.name_ehr
 ,a.name_ehr_id = b.cdept_id_ehr
 ,a.second_dept = b.second_dept
 ,a.third_dept = b.third_dept
 ,a.fourth_dept = b.fourth_dept
 ,a.fifth_dept = b.fifth_dept
 ,a.sixth_dept = b.sixth_dept
;






