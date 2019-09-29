
-- 加载第二层3000年有效数据

drop table if exists pdm.ehr_employee_id_mid1;
create table pdm.ehr_employee_id_mid1 as
select distinct a.userid
      ,a.jobnumber
      ,a.name
      ,a.poidempadmin
      ,a.poidempreserve2
      ,DATE_FORMAT(FROM_DAYS(TO_DAYS(NOW())-TO_DAYS(a.birthday)), '%Y')+0 AS age
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
  from edw.ehr_employee_id a
 order by entrydate desc
;

-- 定义以下处理过程：
drop procedure if exists pdm.ehr_employee_id;

delimiter $$
create procedure pdm.ehr_employee_id()
begin

-- 处理数据，的非部门转岗的数据，部门使用最新一条
-- 先拉出19年出现过调动情况的数据，这部分不处理
drop table if exists pdm.ehr_employee_id_mid2;
create temporary table pdm.ehr_employee_id_mid2 as
select a.userid
      ,a.first_dept
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
  from pdm.ehr_employee_id_mid1 a
 where TransitionType like '%调动%'
   and startdate >= '2019-01-01'
 group by userid
;

-- 取出所有数据的集合
drop table if exists pdm.ehr_employee_id_mid3;
create temporary table pdm.ehr_employee_id_mid3 as
select a.userid
      ,a.first_dept
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.position_name
  from pdm.ehr_employee_id_mid1 a
 where stopdate >= '9999-12-31'
 group by userid
;

-- 拿出变动情况数据
drop table if exists pdm.ehr_employee_id_mid4;
create temporary table pdm.ehr_employee_id_mid4
SELECT
    @r:= case when @userid=a.userid then @r+1 else 1 end as rownum,
    @userid:=a.userid as userid1,
    a.*
from
    (select * from pdm.ehr_employee_id_mid1 
             where userid in (select userid from pdm.ehr_employee_id_mid2)
             order by userid,startdate) a
   ,(select @r:=0 ,@userid:='') b
;

drop table if exists pdm.ehr_employee_id_mid5;
create temporary table pdm.ehr_employee_id_mid5 as select * from pdm.ehr_employee_id_mid4;


truncate table pdm.ehr_employee_id;
insert into pdm.ehr_employee_id
select a.userid
      ,a.jobnumber
      ,a.name
      ,a.poidempadmin
      ,a.poidempreserve2
      ,a.age
      ,a.gender
      ,a.major
      ,a.educationlevel
      ,a.mobilephone
      ,a.workdate
      ,a.workyeartotal
      ,a.workyearcompanytotal
      ,a.birthday
      ,case when b.userid is null then c.first_dept else a.first_dept end as first_dept
      ,case when b.userid is null then c.second_dept else a.second_dept end as second_dept
      ,case when b.userid is null then c.third_dept else a.third_dept end as third_dept
      ,case when b.userid is null then c.fourth_dept else a.fourth_dept end as fourth_dept
      ,case when b.userid is null then c.fifth_dept else a.fifth_dept end as fifth_dept
      ,case when b.userid is null then c.sixth_dept else a.sixth_dept end as sixth_dept
      ,case when b.userid is null then c.position_name else a.position_name end as position_name
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
  from pdm.ehr_employee_id_mid1 a
  left join pdm.ehr_employee_id_mid2 b
    on a.userid = b.userid
  left join pdm.ehr_employee_id_mid3 c
    on a.userid = c.userid
 where b.userid is null
;

-- 插入变动情况的数据,自关联插入
insert into pdm.ehr_employee_id
select a.userid
      ,a.jobnumber
      ,a.name
      ,a.poidempadmin
      ,a.poidempreserve2
      ,a.age
      ,a.gender
      ,a.major
      ,a.educationlevel
      ,a.mobilephone
      ,a.workdate
      ,a.workyeartotal
      ,a.workyearcompanytotal
      ,a.birthday
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.first_dept else b.first_dept end as first_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.second_dept else b.second_dept end as second_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.third_dept else b.third_dept end as third_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.fourth_dept else b.fourth_dept end as fourth_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.fifth_dept else b.fifth_dept end as fifth_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.sixth_dept else b.sixth_dept end as sixth_dept
      ,case when b.TransitionType like '%调动%' or b.userid is null then a.position_name else b.position_name end as position_name
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
  from pdm.ehr_employee_id_mid4 a
  left join pdm.ehr_employee_id_mid5 b
    on a.userid = b.userid
   and a.rownum = (b.rownum-1)
;
end 
$$
delimiter ;

-- 第一次循环
call pdm.ehr_employee_id();

truncate table pdm.ehr_employee_id_mid1;
insert into pdm.ehr_employee_id_mid1
select *
  from pdm.ehr_employee_id
;

-- 第二次循环
call pdm.ehr_employee_id();

truncate table pdm.ehr_employee_id_mid1;
insert into pdm.ehr_employee_id_mid1
select *
  from pdm.ehr_employee_id
;

-- 第三次循环
call pdm.ehr_employee_id();
drop table if exists pdm.ehr_employee_id_mid1;

-- 根据人事提供的19年离职表，来更新19年离职人员部门架构
update pdm.ehr_employee_id a
 inner join edw.dic_ehr_withdrawn b
    on a.name = b.name
   set a.third_dept = b.third_dept
      ,a.fourth_dept = b.fourth_dept
      ,a.fifth_dept = b.fifth_dept
      ,a.sixth_dept = b.sixth_dept
 where b.type = '1'
;


