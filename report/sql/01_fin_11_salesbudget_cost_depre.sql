-- 导入成本价数据
/*
-- 产品标准成本单价
use report;
drop table if exists report.cinvcode_cost;
create table if not exists report.cinvcode_cost(
year_ smallint comment '年份',
cinvcode  varchar(30) comment '产品标准编码',
cinvname varchar(120) comment '产品标准名称',
specification_type varchar(120) comment '规格型号',
cost_notax float(13,3) comment '不含税成本单价',
key report_cinvcode_cost_cinvcode  (cinvcode ),
key report_cinvcode_cost_year  (year_)
) engine=innodb default charset=utf8 comment='18年标准成本';

*/

-- 取pdm.invoice_order 数据 2018&2019数据
truncate table report.fin_11_salesbudget_cost_depre;
insert into report.fin_11_salesbudget_cost_depre
select
     a.ddate
    ,a.db
    ,a.cohr
    ,a.csbvcode
    ,a.ccuscode
    ,b.bi_cusname as ccusname
    ,c.sales_region
    ,c.province
    ,c.city
    ,a.finnal_ccuscode
    ,c.bi_cusname as finnal_ccusname
    ,d.business_class as cbustype
    ,a.sales_type
    ,a.cinvcode
    ,d.bi_cinvname as cinvname
    ,d.item_code 
    ,d.level_three
    ,d.level_two
    ,d.level_one
    ,d.equipment
    ,f.screen_class 
    ,f.uniqueid
    ,f.p_charge
    ,f.p_sales_sup_tec
    ,f.p_sales_spe_tec
    ,f.p_sales_sup_clinic
    ,f.p_sales_spe_clinic
    ,f.per_tec
    ,1-f.per_tec as per_clinic
    ,case 
        when a.db = "UFDATA_889_2018" then a.iquantity
        else if(a.itb = "退补",a.tbquantity,a.iquantity) 
        end as iquantity_adjust
    ,case 
        when a.sales_type = "固定资产" then "固定资产_线上"
        when concat(a.cohr,a.csbvcode,a.cinvcode) in (select concat(cohr,vouchid,cinvcode) from edw.x_eq_launch) then "固定资产_线下"
        else null 
        end as eq_if_launch
    ,a.itb
    ,a.itax
    ,a.isum
    ,e.cinvname as cinvname_bzchengben
    ,e.cost_notax as cost_price_notax
    ,0 as isum_budget
    ,0 as isum_budget_notax
    ,0 as amount_depre
from pdm.invoice_order as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode    
left join edw.map_customer as c 
on a.finnal_ccuscode = c.bi_cuscode 
left join edw.map_inventory as d 
on a.cinvcode = d.bi_cinvcode
left join report.cinvcode_cost as e 
on a.cinvcode = e.cinvcode and year(a.ddate) = e.year_
left join bidata.dt_17_cusitem_person as f
on a.finnal_ccuscode = f.ccuscode and d.item_code = f.item_code and a.cbustype = f.cbustype
and replace(a.ddate,left(a.ddate,4),2019) >= f.ddate_effect and replace(a.ddate,left(a.ddate,4),2019) < f.end_dt
where year(a.ddate) >= 2018
and d.item_code != "jk0101"

union all 
select 
    a.ddate 
    ,null as db 
    ,if(a.cohr = "博圣体系","博圣","杭州贝生") as cohr 
    ,null as csbvcode 
    ,a.true_ccuscode as ccuscode 
    ,c.bi_cusname as ccusname
    ,c.sales_region
    ,c.province
    ,c.city
    ,a.true_ccuscode as finnal_ccuscode 
    ,c.bi_cusname as finnal_ccusname
    ,a.business_class as cbustype 
    ,null as sales_type 
    ,null as cinvcode 
    ,null as cinvname 
    ,a.true_item_code as item_code 
    ,d.level_three
    ,d.level_two
    ,d.level_one
    ,d.equipment
    ,f.screen_class
    ,f.uniqueid
    ,f.p_charge
    ,f.p_sales_sup_tec
    ,f.p_sales_spe_tec
    ,f.p_sales_sup_clinic
    ,f.p_sales_spe_clinic
    ,f.per_tec
    ,1-f.per_tec as per_clinic
    ,null as iquantity_adjust
    ,null as eq_if_launch
    ,null  as itb
    ,0 as itax 
    ,0 as isum
    ,null as cinvname_bzchengben
    ,0 as cost_price_notax
    ,isum_budget * 1000
    ,isum_budget_notax * 1000
    ,0 as amount_depre
from bidata.ft_12_sales_budget as a 
left join edw.map_customer as c 
on a.true_ccuscode = c.bi_cuscode 
left join edw.map_item as d 
on a.true_item_code = d.item_code 
left join bidata.dt_17_cusitem_person as f
on a.true_ccuscode = f.ccuscode and a.true_item_code = f.item_code and a.business_class = f.cbustype
and replace(a.ddate,left(a.ddate,4),2019) >= f.ddate_effect and replace(a.ddate,left(a.ddate,4),2019) < f.end_dt
where a.isum_budget != 0 

union all 
select 
    a.ddate
    ,null as db 
    ,a.cohr 
    ,null as csbvcode 
    ,a.bi_cuscode as ccuscode 
    ,c.bi_cusname as ccusname
    ,c.sales_region
    ,c.province
    ,c.city
    ,a.bi_cuscode as finnal_ccuscode 
    ,c.bi_cusname as finnal_ccusname
    ,"产品类" as cbustype 
    ,null as sales_type 
    ,null as cinvcode 
    ,null as cinvname 
    ,a.item_code 
    ,d.level_three
    ,d.level_two
    ,d.level_one
    ,d.equipment
    ,f.screen_class
    ,f.uniqueid
    ,f.p_charge
    ,f.p_sales_sup_tec
    ,f.p_sales_spe_tec
    ,f.p_sales_sup_clinic
    ,f.p_sales_spe_clinic
    ,f.per_tec
    ,1-f.per_tec as per_clinic
    ,null as iquantity_adjust
    ,null as eq_if_launch
    ,null  as itb
    ,0 as itax 
    ,0 as isum
    ,null as cinvname_bzchengben
    ,0 as cost_price_notax
    ,0 as isum_budget 
    ,0 as isum_budget_notax 
    ,amount_depre 
from bidata.ft_83_eq_depreciation_19 as a 
left join edw.map_customer as c 
on a.bi_cuscode = c.bi_cuscode 
left join edw.map_item as d 
on a.item_code = d.item_code 
left join bidata.dt_17_cusitem_person as f
on a.bi_cuscode = f.ccuscode and a.item_code = f.item_code and f.cbustype = "产品类"
and replace(a.ddate,left(a.ddate,4),2019) >= f.ddate_effect and replace(a.ddate,left(a.ddate,4),2019) < f.end_dt
;

-- alter table report.fin_11_salesbudget_cost_depre comment '收入实际、收入预算、成本、折旧明细数据（加入客户项目人）';
-- alter table report.fin_11_salesbudget_cost_depre add index index_fin_11_salesbudget_cost_depre_db (db);
-- alter table report.fin_11_salesbudget_cost_depre add index index_fin_11_salesbudget_cost_depre_cohr (cohr);
-- alter table report.fin_11_salesbudget_cost_depre add index index_fin_11_salesbudget_cost_depre_province (province);
-- alter table report.fin_11_salesbudget_cost_depre add index index_fin_11_salesbudget_cost_depre_finnal_ccuscode (finnal_ccuscode);
-- alter table report.fin_11_salesbudget_cost_depre add index index_fin_11_salesbudget_cost_depre_item_code (item_code);
;

-- 更新 report.financial_sales_cost 中 
update report.fin_11_salesbudget_cost_depre
set iquantity_adjust = 0
where iquantity_adjust is null ;
update report.fin_11_salesbudget_cost_depre
set isum = 0
where isum is null ;
update report.fin_11_salesbudget_cost_depre
set itax = 0 
where itax is null;
update report.fin_11_salesbudget_cost_depre
set cost_price_notax = 0 
where cost_price_notax is null;
update report.fin_11_salesbudget_cost_depre
set isum_budget = 0 
where isum_budget is null;
update report.fin_11_salesbudget_cost_depre
set isum_budget_notax = 0 
where isum_budget_notax is null;
update report.fin_11_salesbudget_cost_depre
set amount_depre = 0 
where amount_depre is null;

