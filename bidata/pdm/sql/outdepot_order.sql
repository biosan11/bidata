 ------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：outdepot_order.sql
--目标模型：outdepot_order
--源    表：ufdata.rdrecord32,ufdata.rdrecords32,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/outdepot_order.python 2018-11-12 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--outdepot_order建表语句
-- create table `outdepot_order` (
--  `id` int(11) default null comment '出库单主表标识',
--  `autoid` int(11) DEFAULT NULL COMMENT '出库单子表标识',
--  `db` varchar(20) default null comment '来源数据库',
--  `cohr` varchar(20) default null comment '公司简称',
--  `ddate` datetime DEFAULT NULL COMMENT '单据日期',
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
--  `iunitcost` decimal(30,10) default null comment '原币含税单价',
--  `iquantity` decimal(30,10) DEFAULT NULL COMMENT '数量',
--  `isum` decimal(19,4) DEFAULT NULL COMMENT '原币价税合计',
--  `inum_person` decimal(30,10) DEFAULT NULL COMMENT '人份数',
--  `item_code` varchar(60) default null comment '项目编码',
--  `plan_type` varchar(255) default null comment '计划类型:占点、保点、上量、增项',
--  `key_points` varchar(20) default null comment '是否重点',
--  `citemname` varchar(255) default null comment '项目名称',
--  `cvenabbname` varchar(60) DEFAULT NULL comment '供应商名称',
--  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--  `cstcode` varchar(2) default null comment '销售类型编码',
--  `fsettleqty` decimal(26,9) DEFAULT NULL comment '已经开票数量',
--  `sys_time` datetime default null comment '数据时间戳',
--   PRIMARY KEY (`db`,`autoid`),
--   key index_outdepot_order_id  (`id`),
--   key index_outdepot_order_autoid  (`autoid`),
--   key index_outdepot_order_db  (`db`)
-- ) engine=innodb default charset=utf8 COMMENT '出库单表';
-- CREATE INDEX index_dispatch_order_finnal_ccuscode ON pdm.outdepot_order(finnal_ccuscode);
-- CREATE INDEX index_dispatch_order_cinvcode ON pdm.outdepot_order(cinvcode);
-- CREATE INDEX index_dispatch_order_item_code ON pdm.outdepot_order(item_code);


create temporary table pdm.outdepot_order_pre as 
select a.*
      ,b.type as ccustype
  from edw.outdepot_order a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 where left(a.sys_time,10) >= '${start_dt}'
  and year(ddate)>=2018
  and state = '有效';

-- 删除贝康、检测收入
delete from pdm.outdepot_order_pre where left(true_ccuscode,2) = 'GL';
delete from pdm.outdepot_order_pre where left(bi_cinvcode,2) = 'JC';

-- 删除今天更新的数据
CREATE INDEX index_outdepot_order_pre_db ON pdm.outdepot_order_pre(db);
CREATE INDEX index_outdepot_order_pre_autoid ON pdm.outdepot_order_pre(autoid);
delete from pdm.outdepot_order where concat(db,autoid) in (select concat(db,autoid) from  pdm.outdepot_order_pre);

-- 创建中间临时表加工item_code
create temporary table pdm.outdepot_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,f.plan_class
      ,f.key_project
   from (select bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;


--  插入数据
insert into pdm.outdepot_order
select a.id
      ,a.autoid
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
      ,a.ccode
      ,a.ddate
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
      ,md5(a.iunitcost)
      ,a.iquantity
      ,md5(a.iprice)
      ,a.inum_person
      ,f.item_code
      ,e.plan_class
      ,e.key_project
      ,f.level_three
      ,null
      ,e.cinvbrand
      ,a.cstcode
      ,a.fsettleqty
      ,localtimestamp()
  from pdm.outdepot_order_pre a
  left join edw.map_customer b
    on a.true_finnal_ccuscode = b.bi_cuscode 
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.outdepot_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) f
    on a.bi_cinvcode = f.bi_cinvcode
;


-- 删除上游已经删除的数据
delete from pdm.outdepot_order where concat(db,id) in (select concat(db,id) from edw.outdepot_order where state = '无效') ;

