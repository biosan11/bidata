-- 9_view_report2_sales 

-- 创建视图 report.report2_sales

create or replace view report.report2_sales as 
select
    -- case
        -- when c.equipment = "是" then "仪器设备"
        -- else c.level_one 
        -- end as level_one_
    -- ,case 
        -- when c.level_three = "CMA" then concat("cma_",a.cbustype)
        -- else c.item_key 
        -- end as item_key_
    case 
        when c.equipment = "是" then "仪器设备"
        when c.level_two = "血清学筛查" then "产前筛查"
        when c.level_two = "传统新筛" then "传统新筛"
        when c.level_two = "串联新筛" then "串联质谱"
        when c.level_three in ("CMA","BoBs") then "分子诊断"
        when c.level_two = "遗传病诊断" then "遗传病诊断"
        else "其他" 
        end as item_report2
    ,case 
        when b.province in ("山东省") then "三区_"
        when b.province in ("江苏省","浙江省","安徽省") then "四区_"
        when b.province in ("福建省") then "五区_"
        when b.province in ("湖南省","湖北省") then "六区_"
        when b.province in ("上海市") then "八区_"
        else "其他"
        end as sales_region_
    ,year(a.ddate)
    ,month(a.ddate)
    ,b.province
    ,c.level_one
    ,c.equipment
    ,c.item_key
    ,a.cbustype
    ,sum(a.isum) as isum 
    ,sum(a.itax) as itax
    ,sum(a.isum) - sum(a.itax) as isum_notax
    ,0 as isum_budget
    ,0 as isum_budget_notax
from bidata.ft_11_sales as a 
left join edw.map_customer as b 
on a.finnal_ccuscode = b.bi_cuscode 
left join edw.map_item as c 
on a.item_code = c.item_code 
where year(a.ddate) = 2019
and a.cohr != "杭州贝生"
group by year(a.ddate),month(a.ddate),b.province,a.item_code
union all 
select 
    -- case
        -- when c.equipment = "是" then "仪器设备"
        -- else c.level_one 
        -- end as level_one_
    -- ,case 
        -- when c.level_three = "CMA" then concat("cma_",a.business_class)
        -- else c.item_key 
        -- end as item_key_ 
    case 
        when c.equipment = "是" then "仪器设备"
        when c.level_two = "血清学筛查" then "产前筛查"
        when c.level_two = "传统新筛" then "传统新筛"
        when c.level_two = "串联新筛" then "串联质谱"
        when c.level_three in ("CMA","BoBs") then "分子诊断"
        when c.level_two = "遗传病诊断" then "遗传病诊断"
        else "其他" 
        end as item_report2
    ,case 
        when b.province in ("山东省") then "三区_"
        when b.province in ("江苏省","浙江省","安徽省") then "四区_"
        when b.province in ("福建省") then "五区_"
        when b.province in ("湖南省","湖北省") then "六区_"
        when b.province in ("上海市") then "八区_"
        else "其他"
        end as sales_region_
    ,year(a.ddate)
    ,month(a.ddate)
    ,b.province
    ,c.level_one
    ,c.equipment
    ,c.item_key
    ,a.business_class
    ,0 as isum
    ,0 as itax
    ,0 as isum_notax
    ,sum(a.isum_budget) as isum_budget
    ,sum(a.isum_budget_notax) as isum_budget_notax 
from bidata.ft_12_sales_budget as a 
left join edw.map_customer as b 
on a.true_ccuscode = b.bi_cuscode 
left join edw.map_item as c 
on a.true_item_code = c.item_code 
where year(a.ddate) = 2019
and a.cohr != "杭州贝生"
group by year(a.ddate),month(a.ddate),b.province,a.true_item_code;


