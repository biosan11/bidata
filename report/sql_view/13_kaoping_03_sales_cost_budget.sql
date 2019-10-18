create or replace view report.kaoping_03_sales_cost_budget  as 
select 
    case 
        when province in ("山东省") then "三区_"
        when province in ("江苏省","浙江省","安徽省") then "四区_"
        when province in ("福建省") then "五区_"
        when province in ("湖南省","湖北省") then "六区_"
        when province in ("上海市") then "八区_"
        else "其他"
        end as sales_region_
    ,year(ddate)
    ,month(ddate)
    ,sum(cost_budget)
from report.fin_13_sales_cost_budget_19
group by cohr,province,year(ddate),month(ddate);

