------------------------------------程序头部----------------------------------------------
--功能：人事基础信息表
------------------------------------------------------------------------------------------
--程序名称：ehr_employee.sql
--目标模型：ehr_employee
--源    表：edw.ehr_employee
-----------------------------------------------------------------------------------------
--加载周期：线下一次全量清洗
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　
------------------------------------开始处理逻辑------------------------------------------

truncate table pdm.ehr_employee;
-- 加载第二层3000年有效数据
insert into pdm.ehr_employee
select distinct a.userid
      ,a.jobnumber
      ,a.name
      ,a.address_usual
      ,a.poidempadmin
      ,a.poidempreserve2
      ,DATE_FORMAT(FROM_DAYS(TO_DAYS(NOW())-TO_DAYS(a.birthday)), '%Y')+0 AS ag
      ,a.gender
      ,a.major
      ,a.educationlevel
      ,a.mobilephone
      ,a.workdate
      ,case when a.workdate is null and employeestatus <> '待入职' then CAST(( unix_timestamp( now() ) - unix_timestamp(str_to_date(entrydate, '%Y-%m-%d %H')) ) / 3600 / 24/365 AS DECIMAL ( 3, 1 ) )
       else CAST(( unix_timestamp( now() ) - unix_timestamp(str_to_date(workdate, '%Y-%m-%d %H')) ) / 3600 / 24/365 AS DECIMAL ( 3, 1 ) ) end as workyeartotal
      ,case when employeestatus = '待入职' then 0
       else CAST(( unix_timestamp( now() ) - unix_timestamp(str_to_date(entrydate, '%Y-%m-%d %H')) ) / 3600 / 24/365 AS DECIMAL ( 3, 1 ) ) end  as workyearcompanytotal
      ,a.birthday
      ,a.first_dept
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.position_name
      ,a.jobpost_name
      ,a.oidjoblevel
      ,a.entrydate
      ,a.startdate
      ,a.stopdate
      ,a.TransitionType
      ,a.probation
      ,a.employeestatus
      ,a.employmenttype
      ,a.probationstartdate
      ,a.probationstopdate
      ,a.regularizationdate
      ,a.probationresult
      ,a.lastworkdate
      ,a.extlizhireason_107502_632202192
      ,a.start_dt
      ,a.end_dt
  from edw.ehr_employee a
 where end_dt = '3000-12-31';

-- 根据人事提供的19年离职表，来更新19年离职人员部门架构
update pdm.ehr_employee a
 inner join edw.dic_ehr_withdrawn b
    on a.name = b.name
   set a.third_dept = b.third_dept
      ,a.fourth_dept = b.fourth_dept
      ,a.fifth_dept = b.fifth_dept
      ,a.sixth_dept = b.sixth_dept
 where b.type = '1'
;





