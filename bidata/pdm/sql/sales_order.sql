------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：sales_order.sql
--目标模型：sales_order
--源    表：ufdata.so_somain,ufdata.so_sodetails,edw.dic_customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/bidata/pdm/py/sales_order.py 1900-01-01
------------------------------------开始处理逻辑------------------------------------------
--订单pdm层加工逻辑
--sales_order建表语句
--create table `sales_order` (
--  `csocode` varchar(30) DEFAULT NULL COMMENT '销售订单号',
--  `autoid` int(11) DEFAULT NULL COMMENT '销售订单子表标识',
--  `id` int(11) DEFAULT NULL COMMENT '主表销售订单主表标识',
--  `db` varchar(20) default null comment '来源数据库',
--  `cohr` varchar(20) default null comment '公司简称',
--  `ddate` datetime DEFAULT NULL COMMENT '单据日期',
--  `cpersoncode` varchar(20) DEFAULT NULL COMMENT '业务员编码',
--  `cdepcode` varchar(12) default null comment '部门编码',
--  `cdepname` varchar(255) DEFAULT NULL comment '部门名称',
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
--  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--  `cstcode` varchar(2) default null comment '销售类型编码',
--  `sys_time` datetime default null comment '数据时间戳',
--   PRIMARY KEY (`autoid`,`db`),
--   key index_sales_order_id  (`id`),
--   key index_sales_order_autoid  (`autoid`),
--   key index_sales_order_db  (`db`)
--) engine=innodb default charset=utf8 COMMENT '销售订单表';


create temporary table pdm.sales_order_pre as 
select a.*
      ,b.type as ccustype
  from edw.sales_order a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 where left(a.sys_time,10) >= '${start_dt}'
  and year(ddate)>=2018;

-- 根据发票表和发货表获取到仓库编码
-- create temporary table pdm.mid_sales_order as 
-- select a.*
--       ,b.cwhcode
--       ,b.cvenabbname
--   from pdm.sales_order_pre a
--   left join (select csocode,cwhcode,cvenabbname from edw.dispatch_order group by csocode union
--              select csocode,cwhcode,cvenabbname from edw.invoice_order group by csocode) b
--     on a.csocode = b.csocode
--  where b.cvenabbname is not null;


-- 创建中间临时表加工item_code
-- drop table if exists pdm.sales_order_item;
create temporary table pdm.sales_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,case when f.true_item_code is null then '请核查'
            else f.plan_class end as plan_class
      ,case when f.true_item_code is null then '请核查'
            else f.key_project end as key_project
   from (select bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;


-- 删除贝康、检测收入
delete from pdm.sales_order_pre where left(true_ccuscode,2) = 'GL';

-- 删除今天更新的数据
delete from pdm.sales_order where concat(id,db) in (select concat(id,db) from  pdm.sales_order_pre);

--插入数据
insert into pdm.sales_order
select a.csocode
      ,a.autoid
      ,a.id
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
      ,a.ddate
      ,a.cpersoncode
      ,a.cdepcode
      ,d.cdepname
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
      ,a.true_itemcode
      ,e.plan_class
      ,e.key_project
      ,a.itaxunitprice
      ,a.iquantity
      ,a.itax
      ,a.isum
      ,a.citemname
      ,e.cinvbrand
      ,a.cstcode
      ,localtimestamp()
  from pdm.sales_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode 
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.sales_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
;




