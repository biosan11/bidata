-- 16_fin_prov_10_expenses_else.sql
-- 此份数据 不取杭州贝生费用 

truncate table report.fin_prov_10_expense_else;

-- 导入直接费用  部门："技术保障中心","信息中心","供应链中心","400客服部" 注意：这里"博圣其他"的直接费用(ccuscode不为空)不导入 也需要分摊
insert into report.fin_prov_10_expense_else
select 
    ccuscode
    ,y_mon
    ,dept_name
    ,"bs" as cohr
    ,md as cc_md 
    ,0
    ,0
    ,0
    ,0
    ,0
from report.fin_prov_08_expense_ccus 
where cohr != "杭州贝生"
and ccuscode is not null and ccuscode != "请核查"
and dept_name in ("技术保障中心","信息中心","供应链中心","400客服部");

-- 生成一份待分摊的费用明细表 并join 内部结算数据 ft_84_expenses_settlement
-- 间接费用部门（"技术保障中心","信息中心","供应链中心","400客服部"）
drop temporary table if exists report.fin_prov_10_tem01;
create temporary table if not exists report.fin_prov_10_tem01
select 
    a.year_
    ,a.month_
    ,a.dept_name
    ,a.md 
    ,if(a.dept_name = "信息中心",b.xxzx_md,0) as xxzx_md
    ,if(a.dept_name = "技术保障中心",b.jsbz_md,0) as jsbz_md
    ,if(a.dept_name = "技术保障中心",b.wb_md,0) as wb_md
    ,if(a.dept_name = "供应链中心",b.wl_md,0) as wl_md
    ,case 
        when a.dept_name = "信息中心" then a.md - b.xxzx_md
        when a.dept_name = "技术保障中心" then a.md - b.jsbz_md - b.wb_md
        when a.dept_name = "供应链中心" then a.md - b.wl_md 
        else a.md 
    end as md_cut
from 
(
    select 
        cast(left(y_mon,4) as unsigned integer) as year_
        ,cast(right(y_mon,2)as unsigned integer) as month_
        ,dept_name
        ,sum(md) as md 
    from report.fin_prov_08_expense_ccus 
    where cohr != "杭州贝生"
    and (ccuscode is null or ccuscode = "请核查") -- 取出没有直接到客户的费用
    and dept_name in ("技术保障中心","信息中心","供应链中心","400客服部")
    group by y_mon,dept_name
) as a
left join 
(
    select 
        year_
        ,month_
        ,sum(xxzx_md) as xxzx_md
        ,sum(jsbz_md) as jsbz_md
        ,sum(wb_md) as wb_md
        ,sum(wl_md) as wl_md
    from bidata.ft_84_expenses_settlement 
    group by year_,month_
) as b 
on a.year_ = b.year_ and a.month_ = b.month_;

-- report.fin_prov_10_tem01 表中加入 所有 博圣其他 的费用
insert into report.fin_prov_10_tem01
select 
    cast(left(y_mon,4) as unsigned integer) as year_
    ,cast(right(y_mon,2)as unsigned integer) as month_
    ,dept_name
    ,sum(md) as md 
    ,0
    ,0
    ,0
    ,0
    ,sum(md) as md_cut 
from report.fin_prov_08_expense_ccus 
where cohr != "杭州贝生"
and dept_name = "博圣其他"
group by y_mon,dept_name;


-- 技术保障中心费用分摊，  杭州贝生不分摊（分母不计入）
insert into report.fin_prov_10_expense_else
select 
    b.ccuscode 
    ,case 
        when length(a.month_) = 1 then concat(a.year_,"-0",a.month_)
        else concat(a.year_,"-",a.month_)
    end as ymon
    ,a.dept_name
    ,"bs"
    ,0
    ,a.md_cut * ifnull(b.per_allexcepthzbs,1) -- 杭州贝生分母不计入 
    ,0
    ,0
    ,0
    ,0
from report.fin_prov_10_tem01 as a 
left join (select * from report.auxi_01_ccuscode_per where ccuscode != "hzbs") as b 
on a.year_ = b.year_ and a.month_ = b.month_ 
where a.dept_name = "技术保障中心";

-- 除技术保障中心以外的费用分摊  杭州贝生计入  
insert into report.fin_prov_10_expense_else
select 
    b.ccuscode 
    ,case 
        when length(a.month_) = 1 then concat(a.year_,"-0",a.month_)
        else concat(a.year_,"-",a.month_)
    end as ymon
    ,a.dept_name
    ,"bs"
    ,0
    ,a.md_cut * ifnull(b.per_all,1) -- 杭州贝生分母计入 
    ,0
    ,0
    ,0
    ,0
from report.fin_prov_10_tem01 as a 
left join report.auxi_01_ccuscode_per as b 
on a.year_ = b.year_ and a.month_ = b.month_ 
where a.dept_name != "技术保障中心";

-- 导入内部结算费用 
insert into report.fin_prov_10_expense_else
select 
    ccuscode
    ,case 
        when length(month_) = 1 then concat(year_,"-0",month_)
        else concat(year_,"-",month_)
    end as ymon
    ,case 
        when xxzx_md != 0 then "信息中心"
        when jsbz_md != 0 then "技术保障中心"
        when wb_md != 0 then "技术保障中心"
        when wl_md != 0 then "供应链中心"
        else "请核查"
     end as dept_name
    ,"bs"
    ,0
    ,0
    ,xxzx_md
    ,jsbz_md
    ,wb_md
    ,wl_md
from bidata.ft_84_expenses_settlement
where (xxzx_md != 0 or jsbz_md != 0 or wb_md != 0 or wl_md != 0);



/*
insert into report.fin_prov_10_expense_else
select 
    null 
    ,case 
        when length(month_) = 1 then concat(year_,"-0",month_)
        else concat(year_,"-",month_)
    end as ymon
    ,dept_name
    ,"bs"
    ,0
    ,0
    ,md-md_cut
    ,0
    ,0
    ,0
from report.fin_prov_10_tem01;
*/
