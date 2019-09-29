-- 

-- 取2018年及以后数据  不取杭州贝生

create or replace view report.kaoping_05_expenses_act_budget  as 
select 
    "act" as act_budget
    ,year(a.dbill_date) as year_
    ,month(a.dbill_date) as month_
    ,a.name_ehr_id
    ,b.second_dept
    ,b.third_dept
    ,b.fourth_dept
    ,b.fifth_dept
    ,d.second_dept as second_dept_old
    ,d.third_dept as third_dept_old
    ,d.fourth_dept as fourth_dept_old
    ,d.fifth_dept as fifth_dept_old
    ,a.code 
    ,c.ccode_name
    ,c.ccode_name_2
    ,c.ccode_name_3 
    ,sum(a.md) as md
    ,0 as amount_budget
from bidata.ft_81_expenses as a 
left join bidata.dt_21_deptment as b 
on a.name_ehr_id = b.cdept_id_ehr
left join bidata.dt_22_code_account as c 
on a.code = c.code_account
left join bidata.dt_21_deptment_old as d 
on a.name_ehr_id = d.cdept_id_ehr
where year(a.dbill_date) >= 2018
and cohr != "杭州贝生"
group by 
    year(a.dbill_date)
    ,month(a.dbill_date)
    ,a.name_ehr_id
    ,a.code
    
union all 

select 
    "budget" as act_budget
    ,year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,a.cdept_id_ehr
    ,b.second_dept
    ,b.third_dept
    ,b.fourth_dept
    ,b.fifth_dept
    ,d.second_dept as second_dept_old
    ,d.third_dept as third_dept_old
    ,d.fourth_dept as fourth_dept_old
    ,d.fifth_dept as fifth_dept_old
    ,a.u8_code 
    ,c.ccode_name
    ,c.ccode_name_2
    ,c.ccode_name_3 
    ,0 as md 
,sum(a.amount_budget) as amount_budget
from bidata.ft_82_expenses_budget_x as a 
left join bidata.dt_21_deptment as b 
on a.cdept_id_ehr = b.cdept_id_ehr
left join bidata.dt_22_code_account as c 
on a.u8_code = c.code_account
left join bidata.dt_21_deptment_old as d 
on a.cdept_id_ehr = d.cdept_id_ehr
where year(a.ddate) >= 2018
and cohr != "杭州贝生"
group by 
    year(a.ddate)
    ,month(a.ddate)
    ,a.cdept_id_ehr
    ,a.u8_code;


