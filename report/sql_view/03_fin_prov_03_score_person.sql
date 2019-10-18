
-- 
create or replace view report.fin_prov_03_score_person as 
-- 销售级 收入、预算
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_ 
    ,a.p_sales_spe as person_name
    ,b.position_adjust 
    ,b.jobpost_name
    ,b.employeestatus
    ,a.equipment
    ,c.item_key_score
    ,sum(a.isum) as isum 
    ,sum(a.isum_budget) as isum_budget
    ,0 as amount_act
    ,0 as amount_plan
    ,0 as md 
    ,0 as amount_budget
from fin_12_salesbudget_person_post as a 
left join bidata.dt_15_person_ehr as b 
on a.p_sales_spe = b.name
left join report.auxi_01_map_item_bonus as c 
on a.item_code = c.item_code
where (a.isum != 0 or a.isum_budget !=0)
group by year_,month_,a.p_sales_spe,a.equipment,c.item_key_score

union all 
-- 主管级 收入、预算
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_ 
    ,a.p_sales_sup as person_name
    ,b.position_adjust 
    ,b.jobpost_name
    ,b.employeestatus
    ,a.equipment
    ,c.item_key_score
    ,sum(a.isum) as isum 
    ,sum(a.isum_budget) as isum_budget
    ,0 as amount_act
    ,0 as amount_plan
    ,0 as md 
    ,0 as amount_budget
from fin_12_salesbudget_person_post as a 
left join bidata.dt_15_person_ehr as b 
on a.p_sales_spe = b.name
left join report.auxi_01_map_item_bonus as c 
on a.item_code = c.item_code
where (a.isum != 0 or a.isum_budget !=0)
group by year_,month_,a.p_sales_sup,a.equipment,c.item_key_score

union all 
-- 销售级 回款
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,a.cpersonname as person_name
    ,b.position_adjust 
    ,b.jobpost_name
    ,b.employeestatus
    ,null as equipment
    ,null as item_key_score 
    ,0 as isum
    ,0 as isum_budget
    ,sum(a.amount_act) as amount_act
    ,sum(a.amount_plan) as amount_plan
    ,0 as md 
    ,0 as amount_budget
from bidata.ft_52_ar_plan as a 
left join bidata.dt_15_person_ehr as b 
on a.cpersonname = b.name
where year(a.ddate) = 2019
group by year_,month_,a.cpersonname

union all 
-- 主管级 回款 
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,b.poidempadmin as person_name
    ,c.position_adjust 
    ,c.jobpost_name
    ,c.employeestatus
    ,null as equipment
    ,null as item_key_score 
    ,0 as isum
    ,0 as isum_budget
    ,sum(a.amount_act) as amount_act
    ,sum(a.amount_plan) as amount_plan
    ,0 as md 
    ,0 as amount_budget
from bidata.ft_52_ar_plan as a 
left join bidata.dt_15_person_ehr as b
on a.cpersonname = b.name
left join bidata.dt_15_person_ehr as c
on b.poidempadmin = c.name
where year(a.ddate) = 2019
group by year_,month_,b.poidempadmin

union all 
-- 实际费用 
select 
    year(a.dbill_date) as year_ 
    ,month(a.dbill_date) as month_ 
    ,a.cpersonname as person_name
    ,b.position_adjust 
    ,b.jobpost_name
    ,b.employeestatus
    ,null as equipment
    ,null as item_key_score 
    ,0 as isum
    ,0 as isum_budget
    ,0 as amount_act
    ,0 as amount_plan 
    ,sum(a.md) as md 
    ,0 as amount_budget
from bidata.ft_81_expenses_x as a 
left join bidata.dt_15_person_ehr as b 
on a.cpersonname = b.name
where year(a.dbill_date) = 2019 
group by year_,month_,a.cpersonname

union all 
-- 预算费用
select 
    year(a.ddate) as year_ 
    ,month(a.ddate) as month_ 
    ,a.personname as person_name
    ,b.position_adjust 
    ,b.jobpost_name
    ,b.employeestatus
    ,null as equipment
    ,null as item_key_score 
    ,0 as isum
    ,0 as isum_budget
    ,0 as amount_act
    ,0 as amount_plan 
    ,0 as md 
    ,sum(a.amount_budget) as amount_budget
from bidata.ft_82_expenses_budget_x as a 
left join bidata.dt_15_person_ehr as b 
on a.personname = b.name
where year(a.ddate) = 2019 
group by year_,month_,a.personname
;