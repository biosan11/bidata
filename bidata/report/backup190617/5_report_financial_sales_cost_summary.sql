
-- 省区财务绩效模板用_2
-- 声明变量
set @dt_start = "2019-01-01";
set @dt_end = "2019-03-31";

drop temporary table if exists report.tem001;
create temporary table if not exists report.tem001
select 
    province
    ,item_code
    ,cbustype
from report.financial_sales_cost
group by province,item_code,cbustype;
alter table report.tem001 add index index_tem001_province (province);
alter table report.tem001 add index index_tem001_item_code (item_code);
alter table report.tem001 add index index_tem001_cbustype (cbustype);

-- 取2019年数据
drop temporary table if exists report.tem002;
create temporary table if not exists report.tem002
select 
    @dt_start as dt_start
    ,@dt_end as dt_end
    ,province
    ,item_code
    ,cbustype
    ,sum(isum) as isum_19
    ,sum(itax) as itax_19
    ,sum(cost) as cost_19
from report.financial_sales_cost
where ddate >= @dt_start and ddate <= @dt_end 
group by province,item_code,cbustype;
alter table report.tem002 add index index_tem002_province (province);
alter table report.tem002 add index index_tem002_item_code (item_code);
alter table report.tem002 add index index_tem002_cbustype (cbustype);

-- 取2018年数据
drop temporary table if exists report.tem003;
create temporary table if not exists report.tem003
select 
    @dt_start as dt_start
    ,@dt_end as dt_end
    ,province
    ,item_code
    ,cbustype
    ,sum(isum) as isum_18
    ,sum(itax) as itax_18
    ,sum(cost) as cost_18
from report.financial_sales_cost
where ddate >= date_add(@dt_start,interval -1 year) and ddate <= date_add(@dt_end,interval -1 year)
group by province,item_code,cbustype;
alter table report.tem003 add index index_tem003_province (province);
alter table report.tem003 add index index_tem003_item_code (item_code);
alter table report.tem003 add index index_tem003_cbustype (cbustype);

-- 合并以上表格 
drop table if exists report.financial_sales_cost_summary;
create table if not exists report.financial_sales_cost_summary
select 
    b.dt_start
    ,b.dt_end
    ,a.province
    ,a.item_code
    ,d.level_one
    ,d.level_two
    ,d.level_three
    ,a.cbustype
    ,d.equipment
    ,(b.isum_19 - b.itax_19)/1000 as isum_notax_19
    ,b.cost_19/1000 as cost_notax_19
    ,(c.isum_18 - c.itax_18)/1000 as isum_notax_18
    ,c.cost_18/1000 as cost_notax_18
from report.tem001 as a 
left join report.tem002 as b 
on a.province = b.province and a.item_code = b.item_code and a.cbustype = b.cbustype
left join report.tem003 as c 
on a.province = c.province and a.item_code = c.item_code and a.cbustype = c.cbustype
left join edw.map_item as d 
on a.item_code = d.item_code;





