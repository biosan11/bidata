-- 13_view_report2_sales_cost_budget 

drop table if exists report.financial_sales_cost_budget_19;
create table if not exists report.financial_sales_cost_budget_19
select 
    a.cohr
    ,a.bi_cuscode as ccuscode 
    ,d.province
    ,a.cinvcode
    ,a.ddate
    ,round(a.isum_budget,2) as isum_budget
    ,round(a.inum_person,3) as inum_person
    ,round(b.inum_unit_person,3) as inum_unit_person
    ,ifnull(c.cost_notax,0) as cost_notax  
    ,ifnull(c.cost_notax,"无标准价格") as mark_if_cingcode_cost_exists
    ,round(a.inum_person/inum_unit_person,3) as iquantity
    ,round(ifnull(c.cost_notax,0)*a.inum_person/inum_unit_person,3) as cost 
from edw.x_sales_budget_19 as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode 
left join report.cinvcode_cost as c 
on year(a.ddate) = c.year_ and a.cinvcode = c.cinvcode
left join edw.map_customer as d 
on a.bi_cuscode = d.bi_cuscode
where a.isum_budget != 0 or a.inum_person != 0 or a.isum_budget_pro != 0;

create or replace view report.report2_sales_cost_budget  as 
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
    ,sum(cost)
from report.financial_sales_cost_budget_19
group by cohr,province,year(ddate),month(ddate);

