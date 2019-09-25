------------------------------------程序头部----------------------------------------------
--功能：人事基础信息表
------------------------------------------------------------------------------------------
--程序名称：ehr_employee_id.sql
--目标模型：ehr_employee_id
--源    表：ufdata.ehr_employee_id
-----------------------------------------------------------------------------------------
--加载周期：线下一次全量清洗
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--    v1.0jiangsh  2018-11-12   开发上线
--调用方法　
------------------------------------开始处理逻辑------------------------------------------

-- 人事基础信息表，保留历史数据
-- 抽取基础表的增量数据,前一天发生变化的数据
create temporary table edw.ehr_employee_id_pre as
select distinct a.userid
,a.name
,case when a.gender = '1' then '女'
  when a.gender = '0' then '男'
  else '保密' end as gender
,b.name as nation
,d.name as politicalstatus
,case when a.marrycategory = 'c4ca4238a0b923820dcc509a6f75849b' then '已婚'
  when a.marrycategory = 'c81e728d9d4c2f636f067f89cc14862c' then '未婚'
  when a.marrycategory = 'eccbc87e4b5ce2fe28308fd9f2a7baf3' then '离异'
  else '保密' end as marrycategory
,a.major
,case when a.educationlevel = '9' then '小学'
  when a.educationlevel = '8' then '初中'
  when a.educationlevel = '3' then '高中'
  when a.educationlevel = '4' then '中技（中专/技校/职高）'
  when a.educationlevel = '5' then '大专'
  when a.educationlevel = '1' then '本科'
  when a.educationlevel = '2' then '硕士研究生'
  when a.educationlevel = '6' then 'mba'
  when a.educationlevel = '7' then '博士研究生'
  when a.educationlevel = '1075021147935830' then '中专'
  else '未知' end as educationlevel
,a.mobilephone
,concat(a.workdateyear,'-',a.workdatemonth,'-',a.workdateday) as workdate -- 起始工作时间
,a.birthday
  from ufdata.ehr_employee_information a
  left join (select id,name from edw.dic_ehr where type = 'nation') b
    on a.nation = b.id
  left join (select id,name from edw.dic_ehr where type = 'politics') d
    on a.politicalstatus = d.id
 where a.stdisdeleted = 'false';



-- 任职记录表的数据整合
drop table if exists edw.employment_record;
create temporary table edw.employment_record as
select * from (
select a.userid
,a.oiddepartment
,a.sys_date
,d.firstlevelorganization
,d.secondlevelorganization
,d.thirdlevelorganization
,d.fourthlevelorganization
,d.fifthlevelorganization
,d.sixthlevelorganization
,e.name as position_name
,f.name as jobpost_name
,a.oidjoblevel
,a.oidjobgrade
,a.entrydate
,a.startdate
,a.stopdate
,g.transitiontype
,a.probation
,c.name as employeestatus
,a.workyeartotal
,a.workyearcompanytotal
,a.probationstartdate
,a.probationstopdate
,a.regularizationdate
,b.name as probationresult
,a.lastworkdate
,a.extlizhireason_107502_632202192
,h.name as poidempadmin
,i.name as poidempreserve2
,a.jobnumber
,a.workyearbefore
,a.workyearcompanybefore
,a.employmenttype
  from ufdata.ehr_employment_record_id a
  left join (select id,name from edw.dic_ehr where type = 'probation') b
    on a.probationresult = b.id
  left join (select id,name from edw.dic_ehr where type = 'status') c
    on a.employeestatus = c.id
  left join ufdata.ehr_organization d
    on a.oiddepartment = d.oid
  left join ufdata.ehr_position e
    on a.oidjobposition = e.oid
  left join ufdata.ehr_jobpost f
    on a.oidjobpost = f.oid
  left join ufdata.ehr_emptransition_type g
    on a.transitiontypeoid = g.oid
  left join (select userid,name from ufdata.ehr_employee_information where stdisdeleted = 'false' group by userid) h
    on a.poidempadmin = h.userid
  left join (select userid,name from ufdata.ehr_employee_information where stdisdeleted = 'false' group by userid) i
    on a.poidempadmin = i.userid
 where a.stdisdeleted = 'false'
 order by sys_date desc) b
;



-- 获取具体的5级信息
create temporary table edw.mid1_ehr_employee_id as
select a.userid
,b.jobnumber
,a.name
,b.poidempadmin
,b.poidempreserve2
,a.gender
,a.major
,a.educationlevel
,a.mobilephone
,a.workdate
,a.birthday
,c.name as first_dept
,d.name as second_dept
,e.name as third_dept
,f.name as fourth_dept
,g.name as fifth_dept
,i.name as sixth_dept
,b.position_name
,b.jobpost_name
,h.name as oidjoblevel
,b.entrydate
,b.startdate
,b.stopdate
,b.transitiontype
,b.probation
,b.employeestatus
,case when b.employmenttype = 'c7a22d7d-e901-4af0-8e86-146c7134e4ec' then '正式'
      when b.employmenttype = 'cca4006e-a8d4-4e94-80c5-b214be7328ae' then '正式2'
      when b.employmenttype = 'e77dc025-491b-442d-83bc-8ecf3c83a96f' then '兼职'
      when b.employmenttype = '6a7a30a8-e3d0-44b5-9e27-abef75b0c471' then '兼职2'
      when b.employmenttype = 'f0c7ae2d-b674-4dad-ab58-8499273fb484' then '兼职3'
      when b.employmenttype = '080d32b6-8450-4621-8ae7-2b8e771ef21b' then '实习'
      when b.employmenttype = '53c1e5f0-00b5-4b19-a836-79524b419d04' then '实习2'
      when b.employmenttype = '56fcd60b-f6d5-4903-8a4d-3c0f016eea31' then '外部'
      when b.employmenttype = 'f924abfe-3b81-49cb-82fc-3a042e22674c' then '试用'
      else '未知' end as employmenttype
,b.probationstartdate
,b.probationstopdate
,b.regularizationdate
,b.probationresult
,b.lastworkdate
,b.extlizhireason_107502_632202192
,b.workyearbefore
,b.workyearcompanybefore
  from edw.ehr_employee_id_pre a 
  left join edw.employment_record b
    on a.userid = b.userid
  left join ufdata.ehr_organization c
    on b.firstlevelorganization = c.oid
  left join ufdata.ehr_organization d
    on b.secondlevelorganization = d.oid
  left join ufdata.ehr_organization e
    on b.thirdlevelorganization = e.oid
  left join ufdata.ehr_organization f
    on b.fourthlevelorganization = f.oid
  left join ufdata.ehr_organization g
    on b.fifthlevelorganization = g.oid
  left join ufdata.ehr_organization i
    on b.sixthlevelorganization = i.oid
  left join ufdata.ehr_joblevel h
    on b.oidjoblevel = h.oid
;


-- 插入数据	
truncate table edw.ehr_employee_id;
insert into edw.ehr_employee_id
select distinct a.*
               ,localtimestamp() as sys_time 
  from edw.mid1_ehr_employee_id a;


delete from edw.ehr_employee_id where employmenttype = '未知' and oidjoblevel is null;
delete from edw.ehr_employee_id where employmenttype = '外部' and lastworkdate is null;
delete from edw.ehr_employee_id where userid = '124741099';
delete from edw.ehr_employee_id where userid = '120421497';
delete from edw.ehr_employee_id where userid = '122762056';

