 ------------------------------------程序头部----------------------------------------------
--功能：整合层客户档案
------------------------------------------------------------------------------------------
--程序名称：inventory.sql
--目标模型：inventory
--源    表：ufdata.inventory
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/inventory.python 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--inventory建表语句
--create table `inventory` (
--  `db` varchar(20) NOT NULL DEFAULT '' COMMENT '来源数据库',
--  `cinvcode` varchar(60) DEFAULT NULL comment '存货编码',
--  `cinvname` varchar(255) DEFAULT NULL comment '存货名称',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `cinvstd` varchar(255) DEFAULT NULL comment '规格型号',
--  `cinvdefine8` varchar(120) DEFAULT NULL comment '项目简称',
--  `cinvdefine9` varchar(120) DEFAULT NULL comment '项目详细名称',
--  `cinvdefine13` double DEFAULT NULL comment '人份数',
--  `cinvdefine5` varchar(60) DEFAULT NULL comment '存货自定义项5 ',
--  `cinvccode` varchar(12) DEFAULT NULL comment '存货大类编码 ',
--  `cvencode` varchar(20) DEFAULT NULL comment '供应商编码',
--  `bsale` char(1) DEFAULT NULL comment '是否销售',
--  `dsdate` datetime DEFAULT NULL comment '启用日期',
--  `dedate` datetime DEFAULT NULL comment '停用日期',
--  `cmodifyperson` varchar(20) DEFAULT NULL comment '变更人',
--  `dmodifydate` datetime DEFAULT NULL comment '变日期',
--  `cinvdefine7` varchar(120) DEFAULT NULL comment '项目简称',
--  `end_date` date default null comment '数据时间',
--  `sys_time` datetime default null comment '数据时间戳'
--) engine=innodb default charset=utf8;

--alter table inventory comment '存货档案表';
--新建索引，删除增量数据的时候更快
--create index index_bi_inventory_cinvcode on edw.inventory(cinvcode);
--create index index_bi_inventory_db on edw.inventory(db);


use edw;

create temporary table edw.inventory_pre as
select *
  from ufdata.inventory a
;
-- where left(a.dmodifydate,10) >= '${start_dt}';

-- 防重跑机制
-- delete from edw.inventory where end_date >= '${start_dt}' and end_date < '3000-12-31';

-- 删除今天更新的数据
-- UPDATE edw.inventory set end_date = '${start_dt}' where cinvcode in (select cinvcode from edw.inventory_pre);


truncate table edw.inventory;
insert into edw.inventory
select a.db
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvname end
      ,a.cinvstd
      ,a.cinvdefine8
      ,a.cinvdefine9
      ,a.cinvdefine13
      ,a.cinvdefine5
      ,a.cinvccode
      ,a.cvencode
      ,a.bsale
      ,a.dsdate
      ,a.dedate
      ,a.cmodifyperson
      ,a.dmodifydate
      ,a.cinvdefine7
      ,'3000-12-31'
      ,localtimestamp()
  from edw.inventory_pre a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db not in ('UFDATA_222_2018','UFDATA_222_2019', 'UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018')
;
-- 分批插入
insert into edw.inventory
select a.db
      ,a.cinvcode
      ,a.cinvname
      ,case when b.db is null then '请核查' else b.bi_cinvcode end
      ,case when b.db is null then '请核查' else b.bi_cinvname end
      ,a.cinvstd
      ,a.cinvdefine8
      ,a.cinvdefine9
      ,a.cinvdefine13
      ,a.cinvdefine5
      ,a.cinvccode
      ,a.cvencode
      ,a.bsale
      ,a.dsdate
      ,a.dedate
      ,a.cmodifyperson
      ,a.dmodifydate
      ,a.cinvdefine7
      ,'3000-12-31'
      ,localtimestamp()
  from edw.inventory_pre a
  left join dic_inventory b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
 where a.db in ('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018')
;

-- 根据erp的客户档案来修改我们，map_inventory部分字段
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory_pre group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.specification_type = c.cinvstd
   ,a.start_date = c.dsdate
   ,a.end_date = c.dedate
   ,a.product = c.cinvccode
   ,a.cinvbrand = c.cinvdefine5
   ,a.itax = c.itaxrate
   ,a.latest_cost = c.iinvncost
;