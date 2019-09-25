 ------------------------------------程序头部----------------------------------------------
--功能：整合层客户档案
------------------------------------------------------------------------------------------
--程序名称：customer.sql
--目标模型：customer
--源    表：ufdata.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/bidata/python/customer.python 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单BIDATA层加工逻辑
--customer建表语句
--create table `customer` (
--  `db` varchar(20) NOT NULL DEFAULT '' COMMENT '来源数据库',
--  `ccuscode` varchar(20) DEFAULT NULL comment '客户编码',
--  `ccusname` varchar(98) DEFAULT NULL comment '客户名称',
--  `ccusabbname` varchar(60) DEFAULT NULL comment '客户简称',
--  `ccccode` varchar(12) DEFAULT NULL comment '客户分类编码',
--  `cdccode` varchar(12) DEFAULT NULL comment '地区编码',
--  `ccusdepart` varchar(12) DEFAULT NULL comment '部门编码',
--  `iarmoney` double DEFAULT NULL comment '应收余额',
--  `dlastdate` datetime DEFAULT NULL comment '最后交易日期',
--  `denddate` datetime DEFAULT NULL comment '停用日期',
--  `ccusdefine4` varchar(60) DEFAULT NULL comment '客户自定义项4',
--  `ccusdefine5` varchar(60) DEFAULT NULL comment '客户自定义项5',
--  `dcuscreatedatetime` datetime DEFAULT NULL comment '建档日期',
--  `drecentcontractdate` datetime DEFAULT NULL comment '最近合同时间',
--  `drecentdeliverydate` datetime DEFAULT NULL comment '最近发货时间',
--  `drecentoutbounddate` datetime DEFAULT NULL comment '最近出库时间',
--  `btransflag` char(1) DEFAULT NULL comment '客户标识',
--  `cmodifyperson` varchar(20) DEFAULT NULL comment '变更人',
--  `dmodifydate` datetime DEFAULT NULL comment '变更日期',
--  `end_date` date default null comment '数据时间',
--  `sys_time` datetime default null comment '数据时间戳'
--) engine=innodb default charset=utf8;

--alter table invoice_order comment '客户档案表';
--新建索引，删除增量数据的时候更快
--create index index_bi_customer on bidata.customer(ccuscode);



--抽取增量数据
create temporary table bidata.customer_pre as
select a.db
      ,a.ccuscode
      ,a.ccusname
      ,a.ccusabbname
      ,a.ccccode
      ,a.cdccode
      ,a.ccusdepart
      ,a.iarmoney
      ,a.dlastdate
      ,a.denddate
      ,a.ccusdefine4
      ,a.ccusdefine5
      ,a.dcuscreatedatetime
      ,a.drecentcontractdate
      ,a.drecentdeliverydate
      ,a.drecentoutbounddate
      ,a.btransflag
      ,a.cmodifyperson
      ,a.dmodifydate
      ,localtimestamp()
  from ufdata.customer a
 where left(a.dmodifydate,10) >= '${start_dt}';

--防重跑机制
delete from bidata.customer where end_date >= '${start_dt}' and end_date < '3000-12-31';

--更新历史数据
UPDATE bidata.customer set end_date = '${start_dt}' where ccuscode in (select ccuscode from bidata.customer_pre);

--插入新增数据
insert into bidata.customer
select a.db
      ,a.ccuscode
      ,a.ccusname
      ,a.ccusabbname
      ,a.ccccode
      ,a.cdccode
      ,a.ccusdepart
      ,a.iarmoney
      ,a.dlastdate
      ,a.denddate
      ,a.ccusdefine4
      ,a.ccusdefine5
      ,a.dcuscreatedatetime
      ,a.drecentcontractdate
      ,a.drecentdeliverydate
      ,a.drecentoutbounddate
      ,a.btransflag
      ,a.cmodifyperson
      ,a.dmodifydate
      ,'3000-12-31'
      ,localtimestamp()
  from bidata.customer_pre a;
