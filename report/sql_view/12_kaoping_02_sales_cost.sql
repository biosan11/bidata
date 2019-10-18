-- 

-- 

create or replace view report.kaoping_02_sales_cost as 
select 
    case 
        when province in ("山东省") then "三区_"
        when province in ("江苏省","浙江省","安徽省") then "四区_"
        when province in ("福建省") then "五区_"
        when province in ("湖南省","湖北省") then "六区_"
        when province in ("上海市") then "八区_"
        else "其他"
        end as sales_region_
    ,year(ddate) as year_
    ,month(ddate) as month_
    ,province
    ,sum(isum) as isum 
    ,sum(itax) as itax 
    ,sum(isum) - sum(itax) as isum_notax
    ,sum(cost) as cost 
from report.view_01_sales_cost_detail 
where cohr != "杭州贝生" and year(ddate) = 2019 
group by year(ddate),month(ddate),province;