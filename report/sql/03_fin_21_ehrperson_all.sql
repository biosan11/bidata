-- 9_report_fin_21_ehrperson_all

-- 设置参数
set @n = 11; -- 19年1月
drop table if exists report.fin_21_ehrperson_all;
create table if not exists report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;

alter table report.fin_21_ehrperson_all comment '19年各月份在职编制内人数_到职位';

-- 19年2月
set @n = 10;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;


-- 19年3月
set @n = 9;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;


-- 19年4月
set @n = 8;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;


-- 19年5月
set @n = 7;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;

-- 19年6月
set @n = 6;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;

-- 19年7月
set @n = 5;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;

-- 19年8月
set @n = 4;
insert into report.fin_21_ehrperson_all
select 
    12-@n as month
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,position_main 
    ,count(userid) as num_person 
from bidata.ft_71_employee_id 
where 
employmenttype in ("正式","兼职") and 
employeestatus in("正式","试用") and 
startdate <= date_add('2019-12-31',interval -@n month) and 
stopdate >= date_add('2019-12-31',interval -@n month)
group by second_dept,third_dept,fourth_dept,fifth_dept,position_main;