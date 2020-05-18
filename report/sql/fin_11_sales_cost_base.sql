-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2018年以后实际收入成本
-- 说明：取自pdm层invoice_order(不含健康检测),匹配标准成本单价,计算标准成本金额
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者:
-- 开发日期：
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 
-- 调用方法　python /home/bidata/edw/invoice_order.py 2019-12-12
-- 建表脚本
-- use report;
-- drop table if exists report.fin_11_sales_cost_base;
-- create table if not exists report.fin_11_sales_cost_base(
--     ddate date comment '自动编码',
--     db varchar(30) comment '来源数据库',
--     cohr varchar(30) comment '公司',
--     csbvcode varchar(30) comment '销售发票号',
--     ccuscode varchar(30) comment '客户编码',
--     ccusname varchar(255) comment '客户名称',
--     sales_dept varchar(30) comment '销售部门',
--     sales_region_new varchar(30) comment '销售区域',
--     province varchar(60) comment '省份',
--     cbustype varchar(30) comment '业务类型',
--     sales_type varchar(30) comment '销售类型',
--     cinvcode varchar(30) comment '产品编码',
--     cinvname varchar(255) comment '产品名称',
--     item_code varchar(30) comment '项目编码',
--     level_three varchar(30) comment '项目明细',
--     level_two varchar(30) comment '产品组',
--     level_one varchar(30) comment '产品线',
--     equipment varchar(30) comment '是否设备',
--     screen_class varchar(30) comment '筛诊分类',
--     iquantity decimal(18,4) comment '数量',
--     tbquantity decimal(18,4) comment '退补数量',
--     itb varchar(30) comment '退补标记',
--     iquantity_adjust decimal(18,4) comment '调整后数量',
--     eq_if_launch varchar(30) comment '是否投放',
--     itaxunitprice decimal(18,4) comment '销售含税单价',
--     itax decimal(18,4) comment '税额',
--     isum decimal(18,4) comment '销售额_含税',
--     isum_notax decimal(18,4) comment '销售额_不含税',
--     if_cost varchar(30) comment '是否有标准成本',
--     cost_price decimal(18,4) comment '标准成本价',
--     cost decimal(18,4) comment '成本金额',
-- key repot_fin_11_sales_cost_base_db (db),
-- key repot_fin_11_sales_cost_base_csbvcode (csbvcode),
-- key repot_fin_11_sales_cost_base_ccuscode (ccuscode),
-- key repot_fin_11_sales_cost_base_cinvcode (cinvcode),
-- key repot_fin_11_sales_cost_base_item_code (item_code)
-- )engine=innodb default charset=utf8 comment='实际收入成本表';

drop table if exists report.invoice_order;
create temporary table report.invoice_order
select *
  from pdm.invoice_order a
 where year(a.ddate) >= 2017
;

CREATE INDEX index_invoice_order_cinvcode ON report.invoice_order(cinvcode);


truncate table report.fin_11_sales_cost_base;
insert into report.fin_11_sales_cost_base
select
     a.ddate
    ,a.db
    ,a.cohr
    ,a.csbvcode
    ,if(a.finnal_ccuscode = "multi" ,a.ccuscode,a.finnal_ccuscode)
    ,null as ccusname
    ,null as sales_dept
    ,null as sales_region_new
    ,null as province
    ,c.business_class as cbustype
    ,a.sales_type
    ,a.cinvcode
    ,c.bi_cinvname as cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.equipment
    ,c.screen_class
    ,a.iquantity
    ,a.tbquantity
    ,a.itb
    ,case 
        when a.db = "UFDATA_889_2018" then ifnull(a.iquantity,0)
        when a.itb = "退补" then ifnull(a.tbquantity,0)
        when a.itb = "1" then ifnull(a.tbquantity,0) 
        else ifnull(a.iquantity,0) 
        end as iquantity_adjust
    ,case 
        when a.sales_type = "固定资产" then "固定资产_线上"
--        when a.cloumn in (select cloumn from report.x_eq_launch) then "固定资产_线下"
        else null 
        end as eq_if_launch
    ,a.itaxunitprice
    ,ifnull(a.itax,0) as itax 
    ,a.isum
    ,a.isum - ifnull(a.itax,0) as isum_notax 
    ,if(d.bi_cinvcode is null ,"无","有") as if_cost
    ,ifnull(d.cost_price,0) as cost_price
    ,case 
        when a.sales_type = "固定资产" then 0
--        when a.cloumn in (select cloumn from report.x_eq_launch) then 0
        when a.db = "UFDATA_889_2018" then ifnull(a.iquantity,0) * ifnull(d.cost_price,0)
        when a.itb = "退补" then ifnull(a.tbquantity,0) * ifnull(d.cost_price,0)
        when a.itb = "1" then ifnull(a.tbquantity,0) * ifnull(d.cost_price,0)
        else ifnull(a.iquantity,0) * ifnull(d.cost_price,0)
    end as cost
  from report.invoice_order as a 
  left join edw.map_inventory as c
    on a.cinvcode = c.bi_cinvcode
  left join (select bi_cinvcode,cost_price from edw.x_cinvcode_cost where year_ = 2019 group by bi_cinvcode) as d
    on a.cinvcode = d.bi_cinvcode
 where c.item_code != "jk0101";

update report.fin_11_sales_cost_base as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
set
    a.ccusname = b.bi_cusname
    ,a.sales_dept = b.sales_dept
    ,a.sales_region_new = b.sales_region_new
    ,a.province = b.province
;

update report.fin_11_sales_cost_base as a 
 inner join edw.x_eq_launch as b 
    on a.cohr = b.cohr
   and a.csbvcode = b.vouchid
   and a.cinvcode = b.cinvcode
   set a.eq_if_launch = '固定资产_线下'
      ,a.cost = 0
 where a.sales_type <> '固定资产'
;


