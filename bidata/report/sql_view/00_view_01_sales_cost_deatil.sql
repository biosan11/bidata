-- 

create or replace view report.view_01_sales_cost_detail as 
select 
    ddate
    ,db
    ,cohr
    ,csbvcode
    ,ccuscode
    ,ccusname
    ,sales_region
    ,province
    ,city
    ,finnal_ccuscode
    ,finnal_ccusname
    ,cbustype
    ,sales_type
    ,cinvcode
    ,cinvname
    ,item_code
    ,level_three
    ,level_two
    ,level_one
    ,equipment
    ,screen_class
    ,iquantity_adjust
    ,eq_if_launch
    ,itb
    ,itax
    ,isum
    ,cinvname_bzchengben
    ,cost_price_notax
    ,case 
        when eq_if_launch is not null then 0 
        else iquantity_adjust*cost_price_notax
    end as cost
    ,isum-itax as isum_notax 
    ,case 
        when eq_if_launch is not null then isum-itax
        else (isum-itax)-iquantity_adjust*cost_price_notax
    end as profit_gross
from report.fin_11_salesbudget_cost_depre 
where db is not null and isum_budget = 0 ;