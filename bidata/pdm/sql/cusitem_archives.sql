------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：cusitem_archives.sql
--目标模型：cusitem_archives
--源    表：pdm.outdepot_order,pdm.invoice_order
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------

-- CREATE TABLE `cusitem_archives` (
--  `ccuscode` varchar(20) default null comment '客户编码',
--  `ccusname` varchar(120) default null comment '客户名称',
--  `item_code` varchar(60) default null comment '项目编码',
--  `citemname` varchar(255) default null comment '项目名称',
--  `type` varchar(60) DEFAULT NULL COMMENT '销售类型',
--  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
--  `plan_start_dt` date default null comment '产品计划启用时间',
--  `bidding_dt` date default null comment '中标日期',
--  `contract_dt` date default null comment '合同日期',
--  `first_consign_dt` date default null comment '初次发货日期',
--  `last_consign_dt` date default null comment '最后一次发货日期',
--  `iquantity_addup` int DEFAULT NULL COMMENT '累计发货数',
--  `install_dt`date default null comment '装机时间',
--  `first_invoice_dt` date default null comment '初次开票日期',
--  `first_invoice_price_dt` date default null comment '初次开票日期(单价大于0)',
--  `last_invoice_dt` date default null comment '最后一次开票日期',
--  `isum_addup` decimal(18,4) DEFAULT NULL COMMENT '累计开票金额',
--  `product_start_dt` date default null comment '产品启用日期',
--  `product_end_dt` date default null comment '产品停用日期',
--  `end_date` date default null comment '确认丢单日期',
--  `end_date_status` date default null comment '确认日期说明',
--  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--  `competitor` varchar(20) DEFAULT NULL COMMENT '是否竞争对手',
--  `cohr` varchar(20) default null comment '公司（客户供应商）',
--  KEY `cusitem_archives_ccuscode` (`ccuscode`),
--  KEY `cusitem_archives_``item_code` (`item_code`)
-- ) engine=innodb default charset=utf8 comment '客户产品档案';


-- 发货、外送、收入、装机数据整合，增加预算里的数据
-- 收入需要处理有价格的数据
truncate table pdm.cusitem_archives;
create temporary table pdm.mid1_cusitem_archives as
select a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.citemname
      ,a.type
      ,a.cbustype
      ,min(a.plan_start_dt) as plan_start_dt
      ,null as bidding_dt
      ,null as contract_dt
      ,min(a.first_consign_dt) as first_consign_dt
      ,max(a.last_consign_dt) as last_consign_dt
      ,sum(a.iquantity_addup) as iquantity_addup
      ,min(a.install_dt) as install_dt
      ,min(a.first_invoice_dt) as first_invoice_dt
      ,min(a.first_invoice_price_dt) as first_invoice_price_dt
      ,max(a.last_invoice_dt) as last_invoice_dt
      ,sum(a.isum_addup) as isum_addup
      ,min(a.product_start_dt) as product_start_dt
      ,max(a.product_end_dt) as product_end_dt
      ,null as end_date
      ,a.cinvbrand
      ,a.competitor
      ,a.cohr
  from pdm.cuspro_archives a
 group by a.ccuscode,a.item_code,a.cbustype;

insert into pdm.cusitem_archives
select a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.citemname
      ,a.type
      ,a.cbustype
      ,a.plan_start_dt
      ,a.bidding_dt
      ,a.contract_dt
      ,a.first_consign_dt
      ,a.last_consign_dt
      ,a.iquantity_addup
      ,a.install_dt
      ,a.first_invoice_dt
      ,a.first_invoice_price_dt
      ,a.last_invoice_dt
      ,a.isum_addup
      ,a.product_start_dt
      ,a.product_end_dt
      ,b.end_date
      ,b.status_class
      ,a.cinvbrand
      ,a.competitor
      ,a.cohr
  from pdm.mid1_cusitem_archives a
  left join ufdata.x_cusitem_enddate b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and a.cbustype = b.cbustype;

-- 预算数据的插入处理
-- create temporary table pdm.mid2_cusitem_archives as
-- select true_ccuscode as ccuscode
--        ,true_ccusname as ccusname
--        ,true_item_code as item_code
--        ,true_item_name as item_name
--        ,business_class as cbustype
--        ,min(ddate) as plan_start_dt
--        ,null      as first_consign_dt
--        ,null      as last_consign_dt 
--        ,null      as install_dt      
--        ,null      as first_invoice_dt
--        ,null      as last_invoice_dt 
--        ,null      as product_start_dt
--        ,null      as product_end_dt  
--        ,null      as cinvbrand       
--       ,'否'       as competitor      
--       ,'博圣公司' as cohr            
--   from edw.x_sales_budget_18
--  where inum_budget > 0
--  group by true_ccuscode,true_item_code,business_class
-- ;
-- 
-- -- 插入新增数据，增加预算数据
-- insert into pdm.cusitem_archives
-- select ccuscode
--       ,ccusname
--       ,item_code
--       ,citemname
--       ,cbustype
--       ,plan_start_dt
--       ,first_consign_dt
--       ,last_consign_dt
--       ,install_dt
--       ,first_invoice_dt
--       ,last_invoice_dt
--       ,product_start_dt
--       ,product_end_dt
--       ,cinvbrand
--       ,competitor
--       ,cohr 
--   from pdm.mid1_cusitem_archives;
-- 
-- insert into pdm.cusitem_archives
-- select ccuscode
--       ,ccusname
--       ,item_code
--       ,item_name
--       ,cbustype
--       ,plan_start_dt
--       ,first_consign_dt
--       ,last_consign_dt
--       ,install_dt
--       ,first_invoice_dt
--       ,last_invoice_dt
--       ,product_start_dt
--       ,product_end_dt
--       ,cinvbrand
--       ,competitor
--       ,cohr 
--   from pdm.mid2_cusitem_archives a
--  where not exists(select 1 from pdm.mid1_cusitem_archives b
--                           where a.ccuscode = b.ccuscode
--                             and a.item_code = b.item_code
--                             and a.cbustype = b.cbustype)
-- ;
-- 
