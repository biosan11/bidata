-- 12_view_report2_expense_act_budget 

-- 创建视图 report.report2_expense_act_budget 

create or replace view report.report2_expense_act_budget  as 
select 
"act" as act_budget
,year(a.dbill_date) as year_
,month(a.dbill_date) as month_
,a.cdept_id_ehr
,b.second_dept
,b.third_dept
,b.fourth_dept
,b.fifth_dept
,a.code 
,c.ccode_name
,c.ccode_name_2
,c.ccode_name_3 
,sum(a.md) as md
,0 as amount_budget
from bidata.ft_81_expenses_x as a 
left join bidata.dt_21_deptment as b 
on a.cdept_id_ehr = b.cdept_id_ehr
left join bidata.dt_22_code_account as c 
on a.code = c.code_account
group by 
year(a.dbill_date)
,month(a.dbill_date)
,a.cdept_id_ehr
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
group by 
year(a.ddate)
,month(a.ddate)
,a.cdept_id_ehr
,a.u8_code;


