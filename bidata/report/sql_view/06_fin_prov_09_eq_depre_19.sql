
create or replace view report.fin_prov_09_eq_depre_19 as  
select 
    a.cohr
    ,year(a.ddate) as year_ 
    ,month(a.ddate) as month_
    ,b.province 
    ,sum(a.amount_depre)/1000 as amount_depre 
from bidata.ft_83_eq_depreciation_19 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode
group by a.cohr,year_,month_,b.province;