-- 26_ft_72_employee_tran

-- 
drop temporary table if exists bidata.employee_tem01;
create temporary table if not exists bidata.employee_tem01
select 
    @i := @i+1 as sort
    ,userid
    ,name
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    ,jobpost_name
    ,oidjoblevel
    ,startdate
    ,entrydate
    ,transitiontype
from pdm.ehr_employee_id as a ,(select @i := 0)as b
where userid in 
	(select userid from pdm.ehr_employee_id 
	where year(startdate) = 2019 and transitiontype in ("部门内调动","公司内部调动","跨公司调动")
	group by userid)
order by userid,startdate desc;
alter table bidata.employee_tem01 add index index_employee_tem01_sort (sort);
alter table bidata.employee_tem01 add index index_employee_tem01_userid (userid);

-- 
drop temporary table if exists bidata.employee_tem02;
create temporary table if not exists bidata.employee_tem02
select 
    @i := @i+1 as sort
    ,userid
    ,name
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    ,jobpost_name
    ,oidjoblevel
    ,startdate
    ,entrydate
    ,transitiontype
from pdm.ehr_employee_id as a ,(select @i := 0)as b
where userid in 
	(select userid from pdm.ehr_employee_id 
	where year(startdate) = 2019 and transitiontype in ("部门内调动","公司内部调动","跨公司调动")
	group by userid)
order by userid,startdate desc;
alter table bidata.employee_tem02 add index index_employee_tem02_sort (sort);
alter table bidata.employee_tem02 add index index_employee_tem02_userid (userid);


-- 
drop temporary table if exists bidata.employee_tem03;
create temporary table if not exists bidata.employee_tem03
select 
    a.userid
    ,a.name
    ,a.first_dept
    ,case 
        when a.first_dept = "浙江博圣生物技术股份有限公司" then "博圣"
        when a.first_dept = "上海恩允实业有限公司" then "恩允"
        when a.first_dept = "南京卓恩生物技术有限公司" then "卓恩"
        when a.first_dept = "宁波贝生医疗器械有限公司" then "宁波贝生"
        when a.first_dept = "湖北奥博特生物技术有限公司" then "奥博特"
        when a.first_dept = "默认组织" then "默认组织"
        when a.first_dept = "杭州启代医疗门诊部有限公司" then "启代"
        when a.first_dept = "杭州贝生医疗器械有限公司" then "杭州贝生"
        when a.first_dept = "杭州宝荣科技有限公司" then "宝荣"
        when a.first_dept = "杭州贝安云科技有限公司" then "贝安云"
        when a.first_dept = "杭州博圣云鼎冷链物流有限公司" then "博圣云鼎"
        when a.first_dept = "四川美博特生物技术有限公司" then "美博特"
        else "其他"
        end as first_dept_cohr
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.sixth_dept
    ,a.position_name
    ,substring_index(a.position_name,"兼",1) as position_name_main
    ,a.jobpost_name
    ,a.oidjoblevel
    ,a.entrydate
    ,a.startdate
    ,a.transitiontype
    ,b.startdate as startdate_tran
    ,b.first_dept as first_dept_tran
    ,case 
        when b.first_dept = "浙江博圣生物技术股份有限公司" then "博圣"
        when b.first_dept = "上海恩允实业有限公司" then "恩允"
        when b.first_dept = "南京卓恩生物技术有限公司" then "卓恩"
        when b.first_dept = "宁波贝生医疗器械有限公司" then "宁波贝生"
        when b.first_dept = "湖北奥博特生物技术有限公司" then "奥博特"
        when b.first_dept = "默认组织" then "默认组织"
        when b.first_dept = "杭州启代医疗门诊部有限公司" then "启代"
        when b.first_dept = "杭州贝生医疗器械有限公司" then "杭州贝生"
        when b.first_dept = "杭州宝荣科技有限公司" then "宝荣"
        when b.first_dept = "杭州贝安云科技有限公司" then "贝安云"
        when b.first_dept = "杭州博圣云鼎冷链物流有限公司" then "博圣云鼎"
        when b.first_dept = "四川美博特生物技术有限公司" then "美博特"
        else "其他"
        end as first_dept_tran_cohr
    ,b.second_dept as second_dept_tran
    ,b.third_dept as third_dept_tran
    ,b.fourth_dept as fourth_dept_tran
    ,b.fifth_dept as fifth_dept_tran
    ,b.sixth_dept as sixth_dept_tran
    ,b.position_name as position_name_tran
    ,substring_index(b.position_name,"兼",1) as position_name_tran_main
    ,b.jobpost_name as jobpost_name_tran
    ,b.oidjoblevel as oidjoblevel_tran
    ,if(a.userid = b.userid,1,0) as mark_userid
    ,if(c.userid is null,0,1) as mark_userid_startdate
from bidata.employee_tem01 as a 
left join bidata.employee_tem02 as b 
on a.sort = b.sort - 1
left join 
    (select 
        userid
        ,startdate 
    from 
    (select 
        userid
        ,startdate 
    from 
    pdm.ehr_employee_id 
    order by userid,startdate desc)as a 
    group by userid) as c 
on a.userid = c.userid and a.startdate = c.startdate;

-- 
truncate table bidata.ft_72_employee_tran;
insert into bidata.ft_72_employee_tran
select 
* 
from bidata.employee_tem03
where mark_userid = 1 and (mark_userid_startdate = 1 or transitiontype is not null);














