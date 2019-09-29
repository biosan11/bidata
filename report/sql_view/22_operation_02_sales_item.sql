
create or replace view report.operation_02_sales_item as 
select 
    year(ddate) as year_ 
    ,month(ddate) as month_ 
    ,sales_region 
    ,province
    ,level_one
    ,level_two
    ,item_code
    ,level_three
    ,equipment
    ,cbustype
    ,isum as isum 
    ,itax as itax 
    ,isum - itax as isum_notax 
    ,case 
        when eq_if_launch is not null then 0 
        else iquantity_adjust*cost_price_notax
        end as cost_notax 
    ,amount_depre
from report.fin_11_salesbudget_cost_depre 
where year(ddate) >= 2018 
;



create or replace view report.operation_02_sales_item_pivot as 
select 
    year_ 
    ,month_ 
    ,sales_region 
    ,province
    ,level_one
    ,level_two
    ,item_code
    ,level_three
    ,equipment
    ,cbustype
    ,sum(isum) as isum 
    ,sum(itax) as itax 
    ,sum(isum) - sum(itax) as isum_notax 
    ,sum(cost_notax ) as cost_notax 
    ,sum(amount_depre)
from report.operation_02_sales_item
group by year_,month_,province,item_code,cbustype;