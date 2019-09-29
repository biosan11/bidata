-- 11_view_report2_remoney

-- 创建视图 report.report2_remoney

create or replace view report.report2_remoney as 
select 
    case 
        when b.province in ("山东省") then "三区_"
        when b.province in ("江苏省","浙江省","安徽省") then "四区_"
        when b.province in ("福建省") then "五区_"
        when b.province in ("湖南省","湖北省") then "六区_"
        when b.province in ("上海市") then "八区_"
        else "其他"
        end as sales_region_
    ,year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,b.province
    ,sum(a.amount_act) as amount_act 
    ,sum(a.amount_plan) as amount_plan 
from bidata.ft_52_ar_plan as a 
left join edw.map_customer as b 
on a.true_ccuscode = b.bi_cuscode
where year(a.ddate) = 2019 
group by year(a.ddate),month(a.ddate),b.province;