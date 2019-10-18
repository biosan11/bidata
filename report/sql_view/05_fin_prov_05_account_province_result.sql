
-- 
create or replace view report.fin_prov_05_account_province_result as 
select 
    b.province
    ,a.date_
    ,year(a.date_) as year_
    ,month(a.date_) as month_
    ,sum(a.balance_opening) as balance_opening
    ,sum(a.idamount_month) as idamount_month
    ,sum(a.icamount_month) as icamount_month
    ,sum(a.balance_closing) as balance_closing 
    ,sum(a.amount_act) as amount_act 
    ,sum(a.amount_plan) as amount_plan 
    ,sum(a.idamount_month_12) as idamount_month_12
    ,sum(a.balance_closing_12) as balance_closing_12 
    ,365*sum(a.balance_closing_12)/sum(a.idamount_month_12)/12 as turnover_days
from report.fin_32_account_ccuscode_result as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
group by b.province,a.date_;