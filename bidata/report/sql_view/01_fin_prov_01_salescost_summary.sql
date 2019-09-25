


create or replace view report.fin_prov_01_salescost_summary as 
select 
    year(ddate) as year_
    ,month (ddate) as month_
    ,province
    ,item_code 
    ,level_one
    ,level_two
    ,level_three
    ,cbustype
    ,equipment
    ,sum(isum_notax)/1000 as isum_notax
    ,sum(cost)/1000 as cost_notax
    ,sum(isum)/1000 as isum 
from report.view_01_sales_cost_detail 
where cohr != "杭州贝生"
group by
    year (ddate)
    ,month (ddate)
    ,province
    ,item_code
    ,cbustype
;