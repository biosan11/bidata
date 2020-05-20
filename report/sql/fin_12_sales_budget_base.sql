-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2019年以后销售计划明细表
-- 说明：取自edw层x_sales_budget_19, x_sales_budget_20 
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者: Jin
-- 开发日期：20200407
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法：
--  建表脚本
-- drop table if exists report.fin_12_sales_budget_base;
-- create table if not exists report.fin_12_sales_budget_base(
--     ddate date comment '日期',
--     cohr varchar(20) comment '公司',
--     ccuscode varchar(20) comment '客户编码',
--     ccusname varchar(90) comment '客户名称',
--     sales_dept varchar(30) comment '销售部门',
--     sales_region_new varchar(30) comment '销售区域',
--     province varchar(60) comment '省份',
--     cbustype varchar(30) comment '业务类型',
--     cinvcode varchar(30) comment '产品编码',
--     cinvname varchar(255) comment '产品名称',
--     item_code varchar(30) comment '项目编码',
--     level_three varchar(30) comment '项目明细',
--     level_two varchar(30) comment '产品组',
--     level_one varchar(30) comment '产品线',
--     equipment varchar(30) comment '是否设备',
--     screen_class varchar(30) comment '筛诊分类',
--     inum_person decimal(18,4) comment '计划发货人份数',
--     isum_budget decimal(18,4) comment '计划含税销售额',
--     isum_budget_notax decimal(18,4) comment '计划不含税销售额',
-- key report_fin_12_sales_budget_base_cohr(cohr),
-- key report_fin_12_sales_budget_base_ccuscode(ccuscode),
-- key report_fin_12_sales_budget_base_cinvcode(cinvcode)
-- )engine=innodb default charset=utf8 comment='report层计划表明细';
-- 

truncate table report.fin_12_sales_budget_base;
-- 导入2019年计划表明细 
insert into report.fin_12_sales_budget_base
select 
    a.ddate 
    ,a.cohr
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,c.business_class as cbustype 
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.equipment
    ,c.screen_class
    ,round(a.inum_person,4) 
    ,round(a.isum_budget,4)
    ,0 as isum_budget_notax 
from edw.x_sales_budget_19 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
where a.inum_person != 0 or a.isum_budget != 0;


-- 加工处理不含税计划销售额
update report.fin_12_sales_budget_base
set isum_budget_notax = round(isum_budget/(1+0.13),4)
where cbustype in("产品类","租赁类","服务类");
update report.fin_12_sales_budget_base
set isum_budget_notax = round(isum_budget/(1+0.06),4)
where cbustype = "ldt";

-- 导入2020年计划表明细
insert into report.fin_12_sales_budget_base
select 
    a.ddate 
    ,a.cohr
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,c.business_class as cbustype 
    ,a.bi_cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.equipment
    ,c.screen_class
    ,round(a.inum_person,4) 
    ,round(a.isum_budget,4)
    ,round(a.isum_budget - (a.isum_budget*a.itaxrate),4)
from edw.x_sales_budget_20 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.bi_cinvcode = c.bi_cinvcode
where a.inum_person != 0 or a.isum_budget != 0;

