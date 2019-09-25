------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：invoice_order.sql
--目标模型：invoice_order
--源    表：ufdata.salebillvouch,ufdata.salebillvouchs,edw.customer
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
--订单pdm层加工逻辑
--invoice_order建表语句
-- create table `invoice_order` (
--  `sbvid` int(11) default null comment '销售发票主表标识',
--  `autoid` int(11) DEFAULT NULL COMMENT '销售订单子表标识',
--  `ddate` datetime default null comment '单据日期',
--  `db` varchar(20) default null comment '来源数据库',
--  `cohr` varchar(20) default null comment '公司简称',
--  `cwhcode` varchar(10) DEFAULT NULL comment '仓库编码',
--  `cwhname` varchar(20) DEFAULT NULL comment '仓库名称',
--  `cdepcode` varchar(12) default null comment '部门编码',
--  `cdepname` varchar(255) DEFAULT NULL comment '部门名称',
--  `cpersoncode` varchar(20) DEFAULT NULL COMMENT '业务员编码',
--  `sales_region` varchar(20) DEFAULT NULL COMMENT '销售区域',
--  `province` varchar(60) DEFAULT NULL COMMENT '销售省份',
--  `city` varchar(60) DEFAULT NULL COMMENT '销售城市',
--  `ccustype` varchar(10) DEFAULT NULL COMMENT '客户类型',
--  `ccuscode` varchar(20) default null comment '客户编码',
--  `ccusname` varchar(120) default null comment '客户名称',
--  `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
--  `finnal_ccusname` varchar(60) DEFAULT NULL COMMENT '最终客户名称',
--  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
--  `sales_type` varchar(60) DEFAULT NULL COMMENT '产品销售类型-销售、赠送、配套、其他',
--  `cinvcode` varchar(60) default null comment '存货编码',
--  `cinvname` varchar(255) default null comment '存货名称',
--  `item_code` varchar(60) default null comment '项目编码',
--  `plan_type` varchar(255) default null comment '计划类型:占点、保点、上量、增项',
--  `key_points` varchar(20) default null comment '是否重点',
--  `itaxunitprice` decimal(30,10) default null comment '原币含税单价',
--  `iquantity` decimal(30,10) DEFAULT NULL COMMENT '数量',
--  `itax` decimal(19,4) DEFAULT NULL COMMENT '原币税额',
--  `isum` decimal(19,4) DEFAULT NULL COMMENT '原币价税合计',
--  `citemname` varchar(255) default null comment '项目名称',
--  `cvenabbname` varchar(60) DEFAULT NULL comment '供应商名称',
--  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--  `cstcode` varchar(2) default null comment '销售类型编码',
--  `sys_time` datetime default null comment '数据时间戳',
--   PRIMARY KEY (`autoid`,`db`),
--   key index_invoice_order_sbvid  (`sbvid`),
--   key index_invoice_order_autoid  (`autoid`),
--   key index_invoice_order_db  (`db`)
-- ) engine=innodb default charset=utf8 comment '销售发票表';

-- 抽取增量
create temporary table pdm.invoice_order_pre as 
select a.*
      ,b.type as ccustype
  from edw.invoice_order a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 where left(a.sys_time,10) >= '${start_dt}'
  and year(ddate)>=2018;
  
-- 删除贝康、检测收入
delete from pdm.invoice_order_pre where left(true_ccuscode,2) = 'GL';
delete from pdm.invoice_order_pre where true_ccuscode = 'DL1101002' and cinvcode = 'QT00004';

-- 删除客户是关联公司的订单 type = '关联公司'
-- delete from pdm.invoice_order_pre where ccustype = '关联公司';


-- 删除今天更新的数据
--delete from pdm.invoice_order where sbvid in (select sbvid from  pdm.invoice_order_pre);
delete from pdm.invoice_order where concat(db,autoid) in (select concat(db,autoid) from  pdm.invoice_order_pre);


--创建中间临时表加工item_code
-- drop table if exists pdm.invoice_order_item;
create temporary table pdm.invoice_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,e.specification_type
      ,f.plan_class
      ,f.key_project
   from (select specification_type,bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;


insert into pdm.invoice_order
select a.sbvid
      ,a.autoid
      ,a.ddate
      ,a.db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '杭州贝生'
            when a.db = 'UFDATA_168_2019' then '杭州贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝荣'
            when a.db = 'UFDATA_222_2019' then '宝荣'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '奥博特'
            when a.db = 'UFDATA_588_2019' then '奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '美博特'
            when a.db = 'UFDATA_889_2019' then '美博特'
            when a.db = 'UFDATA_555_2018' then '贝安云'
            end
      ,a.csbvcode
      ,a.csocode
      ,a.cwhcode
      ,c.cwhname
      ,a.cdepcode
      ,d.cdepname
      ,a.cpersoncode
      ,b.sales_region
      ,b.province
      ,b.city
      ,a.ccustype
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname2 as finnal_ccusname
      ,e.business_class
      ,a.cdefine22
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,f.item_code
      ,e.plan_class
      ,e.key_project
      ,a.itaxunitprice
      ,a.iquantity
      ,a.itax
      ,a.isum
      ,f.level_three
      ,e.cinvbrand
      ,a.cvenabbname
      ,a.cstcode
      ,e.specification_type
      ,case when a.itb = '1' then '退补'
          else '正常' end
      ,case when a.breturnflag = 'Y' then '是'
          else '否' end
      ,a.tbquantity
      ,localtimestamp()
  from pdm.invoice_order_pre a
  left join edw.map_customer b
    on a.true_finnal_ccuscode = b.bi_cuscode 
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select bi_cinvcode,plan_class,specification_type,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) f
    on a.bi_cinvcode = f.bi_cinvcode
;

-- 删除上游已经删除的数据
delete from pdm.invoice_order where concat(db,sbvid) in (select concat(db,sbvid) from edw.invoice_order where state = '无效') ;