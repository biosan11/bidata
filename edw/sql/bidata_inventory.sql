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
--调用方法　python /home/bidata/python/inventory.python 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单BIDATA层加工逻辑
--inventory建表语句
--create table `inventory` (
--  `db` varchar(20) NOT NULL DEFAULT '' COMMENT '来源数据库',
--  `cinvcode` varchar(60) DEFAULT NULL comment '存货编码',
--  `cinvname` varchar(255) DEFAULT NULL comment '存货名称',
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

--alter table invoice comment '存货档案表';
--新建索引，删除增量数据的时候更快
--create index index_bi_inventory_cinvcode on bidata.inventory(cinvcode);
--create index index_bi_inventory_db on bidata.inventory(db);

create temporary table bidata.inventory_pre as
select a.db
      ,a.cinvcode
      ,a.cinvname
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
  from ufdata.inventory a
 where left(a.dmodifydate,10) >= '${start_dt}';

--防重跑机制
delete from bidata.inventory where end_date >= '${start_dt}' and end_date < '3000-12-31';

--删除今天更新的数据
UPDATE bidata.inventory set end_date = '${start_dt}' where cinvcode in (select cinvcode from bidata.inventory_pre);


insert into bidata.inventory
select a.db
      ,a.cinvcode
      ,a.cinvname
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
  from bidata.inventory_pre a;
