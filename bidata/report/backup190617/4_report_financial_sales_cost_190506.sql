
-- 声明变量
set @dt_start = "2019-01-01";
set @dt_end = "2019-03-31";

-- 导入成本价数据
/*
drop table if exists report.cinvcode_cost;
create table if not exists report.cinvcode_cost(
year_ smallint comment '年份',
cinvcode  varchar(30) comment '产品标准编码',
cinvname varchar(120) comment '产品标准名称',
specification_type varchar(120) comment '规格型号',
cost_notax float(13,3) comment '不含税成本单价',
key report_cinvcode_cost_cinvcode  (cinvcode )
) engine=innodb default charset=utf8 comment='18年标准成本';
*/

-- 取pdm.invoice_order 数据 2018&2019数据
drop table if exists report.financial_sales_cost;
create table if not exists report.financial_sales_cost
select
     a.ddate
    ,a.db
    ,a.cohr
    ,a.ccuscode
    ,b.bi_cusname as ccusname
    ,c.sales_region
    ,c.province
    ,c.city
    ,a.finnal_ccuscode
    ,c.bi_cusname as finnal_ccusname
    ,a.cbustype
    ,a.sales_type
    ,a.cinvcode
    ,d.bi_cinvname
    ,d.item_code 
    ,d.level_three
    ,d.level_two
    ,d.level_one
    ,d.equipment
    ,d.business_class
    ,case 
        when a.db = "UFDATA_889_2018" then a.iquantity
        else if(a.itb = "退补",a.tbquantity,a.iquantity) 
        end as iquantity_adjust
    ,a.itax
    ,a.isum
    ,a.itb
    ,e.cinvname 
    ,e.cost_notax
    ,case 
        when a.sales_type = "固定资产" then 0 
        when a.db = "UFDATA_889_2018" then a.iquantity * e.cost_notax
        when a.itb = "退补" then a.tbquantity * e.cost_notax
        else a.iquantity * e.cost_notax
        end as cost
from pdm.invoice_order as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode    
left join edw.map_customer as c 
on a.finnal_ccuscode = c.bi_cuscode 
left join edw.map_inventory as d 
on a.cinvcode = d.bi_cinvcode
left join report.cinvcode_cost as e 
on a.cinvcode = e.cinvcode and year(a.ddate) = e.year_
where year(a.ddate) >= 2018
and d.item_code != "jk0101";

