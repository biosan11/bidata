


create or replace view report.operation_01_sales_customer as 
select 
    year(ddate) as year_ 
    ,month(ddate) as month_ 
    ,sales_region 
    ,province
    ,city 
    ,finnal_ccuscode as ccuscode 
    ,finnal_ccusname as ccusname 
    ,isum as isum 
    ,itax as itax 
    ,isum - itax as isum_notax 
    ,case 
        when eq_if_launch is not null then 0 
        else iquantity_adjust*cost_price_notax
        end as cost_notax 
    ,amount_depre as amount_depre
    ,0 as md 
from report.fin_11_salesbudget_cost_depre 

union all 

select 
    year(a.dbill_date) as year_ 
    ,month(a.dbill_date) as month_ 
    ,b.sales_region
    ,b.province
    ,b.city
    ,a.ccuscode 
    ,b.bi_cusname 
    ,0 as isum 
    ,0 as itax 
    ,0 as isum_notax 
    ,0 as cost_notax 
    ,0 as amount_depre
    ,md as md
from bidata.ft_81_expenses as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where year(a.dbill_date) >= 2018 
and a.ccuscode is not null
;

create or replace view report.operation_01_sales_customer_pivot as 
select 
    year_
    ,month_
    ,sales_region
    ,province
    ,city
    ,ccuscode
    ,ccusname
    ,sum(isum) as isum
    ,sum(itax) as itax 
    ,sum(isum_notax) as isum_notax
    ,sum(cost_notax) as cost_notax
    ,sum(amount_depre) as amount_depre
    ,sum(md) as md 
from report.operation_01_sales_customer
group by 
year_,month_,ccuscode
;