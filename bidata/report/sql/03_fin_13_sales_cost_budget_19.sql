-- 

truncate table report.fin_13_sales_cost_budget_19;
insert into report.fin_13_sales_cost_budget_19
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
    ,ifnull(c.cost_notax,"无标准价格") as mark_if_cinvcode_cost_exists
    ,round(a.inum_person/inum_unit_person,3) as iquantity
    ,round(ifnull(c.cost_notax,0)*a.inum_person/inum_unit_person,3) as cost_budget 
from edw.x_sales_budget_19 as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode 
left join report.cinvcode_cost as c 
on year(a.ddate) = c.year_ and a.cinvcode = c.cinvcode
left join edw.map_customer as d 
on a.bi_cuscode = d.bi_cuscode
where a.isum_budget != 0 or a.inum_person != 0 or a.isum_budget_pro != 0;

alter table report.fin_13_sales_cost_budget_19 comment '19年成本预算';