-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2018年以后设备折旧明细表
-- 说明：取自edw层, x_eq_depreciation_19,x_eq_depreciation_20 
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者: Jin
-- 开发日期：20200408
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法：
--  建表脚本
-- drop table if exists report.fin_13_eq_depreciation_base;
-- create table if not exists report.fin_13_eq_depreciation_base(
--     ddate date comment '日期',
--     cohr varchar(20) comment '公司',
--     ccuscode varchar(20) comment '客户编码',
--     ccusname varchar(90) comment '客户名称',
--     sales_dept varchar(30) comment '销售部门',
--     sales_region_new varchar(30) comment '销售区域',
--     province varchar(60) comment '省份',
--     cinvcode varchar(30) comment '产品编码',
--     cinvname varchar(255) comment '产品名称',
--     item_code varchar(30) comment '项目编码',
--     level_three varchar(30) comment '项目明细',
--     level_two varchar(30) comment '产品组',
--     level_one varchar(30) comment '产品线',
--     screen_class varchar(30) comment '筛诊分类',
--     amount_depre decimal(18,4) comment '折旧金额',
-- key report_fin_13_eq_depreciation_base_cohr(cohr),
-- key report_fin_13_eq_depreciation_base_ccuscode(ccuscode),
-- key report_fin_13_eq_depreciation_base_cinvcode(cinvcode)
-- )engine=innodb default charset=utf8 comment='report层设备折旧明细表';
-- 

truncate table report.fin_13_eq_depreciation_base;

-- 导入18年设备折旧明细
-- 1月
insert into report.fin_13_eq_depreciation_base
select
	'2018-01-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_1,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 2月
insert into report.fin_13_eq_depreciation_base
select
	'2018-02-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_2,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 3月
insert into report.fin_13_eq_depreciation_base
select
	'2018-03-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_3,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 4月
insert into report.fin_13_eq_depreciation_base
select
	'2018-04-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_4,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 5月
insert into report.fin_13_eq_depreciation_base
select
	'2018-05-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_5,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 6月
insert into report.fin_13_eq_depreciation_base
select
	'2018-06-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_6,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 7月
insert into report.fin_13_eq_depreciation_base
select
	'2018-07-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_7,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 8月
insert into report.fin_13_eq_depreciation_base
select
	'2018-08-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_8,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 9月
insert into report.fin_13_eq_depreciation_base
select
	'2018-09-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_9,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 10月
insert into report.fin_13_eq_depreciation_base
select
	'2018-10-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_10,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 11月
insert into report.fin_13_eq_depreciation_base
select
	'2018-11-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_11,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
-- 12月
insert into report.fin_13_eq_depreciation_base
select
	'2018-12-01'
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre_12,4) as amount_depre
from edw.x_eq_depreciation_18 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;


-- 导入19年设备折旧明细
insert into report.fin_13_eq_depreciation_base
select
    a.ddate
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre,4) as amount_depre
from edw.x_eq_depreciation_19 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;

-- 导入20年设备折旧明细
insert into report.fin_13_eq_depreciation_base
select
    a.ddate
    ,a.cohr  
    ,a.bi_cuscode as ccuscode 
    ,b.bi_cusname as ccusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.cinvcode 
    ,c.bi_cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.screen_class
    ,round(a.amount_depre,4) as amount_depre
from edw.x_eq_depreciation_20 as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode;
