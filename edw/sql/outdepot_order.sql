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
--create table `outdepot_order` (
--  `db` varchar(20) default null comment '来源数据库',
--  `id` int(11) default null comment '出库单主表标识',
--  `cDLCode` int(11) default null comment '发货退货单主表标识',
--  `cBusCode` varchar(30) default null comment '对应业务单号',
--  `ddate` datetime default null comment '单据日期',
--  `ccuscode` varchar(20) default null comment '客户编码',
--  `ccusname` varchar(120) default null comment '客户名称',
--  `true_ccuscode` varchar(20) DEFAULT NULL COMMENT '客户正确编码',
--  `true_ccusname` varchar(120) DEFAULT NULL COMMENT '客户正确名称',
--  `finnal_ccusname` varchar(60) DEFAULT NULL COMMENT '最终客户名称',
--  `true_finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
--  `true_finnal_ccusname1` varchar(60) DEFAULT NULL COMMENT '最终客户正确名称-客户编码匹配',
--  `true_finnal_ccusname2` varchar(60) DEFAULT NULL COMMENT '最终客户正确名称-原值匹配',
--  `cmaker` varchar(20) default null comment '制单人',
--  `cverifier` varchar(20) default null comment '审核人',
--  `cmodifier` varchar(20) default null comment '修改人',
--  `dcreatesystime` datetime default null comment '制单时间',
--  `dmodifysystime` datetime default null comment '修改时间',
--  `cdepcode` varchar(12) default null comment '部门编码',
--  `cstcode` varchar(2) DEFAULT NULL COMMENT '销售类型',
--  `cpersoncode` varchar(20) default null comment '业务员编码',
--  `cwhcode` varchar(10) DEFAULT NULL comment '仓库编码',
--  `ccode` varchar(30) DEFAULT NULL comment '收发单据号',
--  `cebexpresscode` varchar(50) DEFAULT NULL comment '快递单号',
--  `cvouchtype` varchar(2) DEFAULT NULL comment '单据类型编码',
--  `cvencode` varchar(20) DEFAULT NULL comment '供应商编码',
--  `cordercode` varchar(30) DEFAULT NULL comment '采购订单号',
--  `cbillcode` bigint(20) DEFAULT NULL comment '发票主表标识',
--  `cdefine3` varchar(20) DEFAULT NULL comment '负责人\区域主管备用',
--  `autoid` int(11) default null comment '出库单子表标识',
--  `cdefine22` varchar(60) DEFAULT NULL comment '销售产品辅助',
--  `isaleoutid` bigint(20) DEFAULT NULL comment '出库单子表标识',
--  `isodid` varchar(40) DEFAULT NULL comment '销售订单子表ID',
--  `isotype` int(11) DEFAULT NULL comment '订单类型',
--  `csocode` varchar(40) DEFAULT NULL comment '销售订单号',
--  `isbsid` bigint(20) DEFAULT NULL comment '发票子表标识',
--  `coutvouchtype` varchar(2) DEFAULT NULL comment '出库单类型',
--  `cinvouchtype` varchar(2) DEFAULT NULL comment '入库单单类型',
--  `cinvouchcode` varchar(30) DEFAULT NULL comment '对应入库单号',
--  `cvouchcode` bigint(20) DEFAULT NULL comment '对应入库单子表标识',
--  `child_id` varchar(30) default null comment '子表出库单号',
--  `idlsid` bigint(20) DEFAULT NULL comment '发货退货单字表标示',
--  `iorderdid` int(11) DEFAULT NULL comment '订单字表id',
--  `iordercode` varchar(30) DEFAULT NULL comment '订单号',
--  `cinvcode` varchar(60) default null comment '存货编码',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `iquantity` decimal(30,10) default null comment '数量',
--  `iunitcost` decimal(30,10) DEFAULT NULL comment '单价',
--  `iprice` decimal(19,4) DEFAULT NULL comment '金额',
--  `inum_person` decimal(30,10) DEFAULT NULL COMMENT '人份数',
--  `citemcode` varchar(60) default null comment '项目编码',
--  `true_itemcode` varchar(60) default null comment '正确项目编码',
--  `citem_class` varchar(10) default null comment '项目大类编码',
--  `citemname` varchar(255) default null comment '项目名称',
--  `citem_cname` varchar(20) default null comment '项目大类名称',
--  `fsettleqty` decimal(26,9) DEFAULT NULL,
--  `sys_time` datetime default null comment '数据时间戳',
--   key index_outdepot_order_id  (`id`)
--) engine=innodb default charset=utf8 COMMENT '出库单表';


use edw;
-- 获取主表的增量数据
drop table if exists edw.outdepot_order_pre;
create temporary table edw.outdepot_order_pre as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.cdefine2 as ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.chandler as cverifier
      ,a.cmodifyperson as cmodifier
      ,a.dnmaketime as dcreatesystime
      ,a.dnmodifytime as dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
  from ufdata.rdrecord32 a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dnmaketime,10) >= '${start1_dt}' or left(a.dnmodifytime,10) >= '${start1_dt}')
   and a.db <> 'UFDATA_889_2019'
   and a.db <> 'UFDATA_555_2018'; 
-- 针对美博特客户不在同部博圣做出调整
--   and a.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


insert into edw.outdepot_order_pre
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.cdefine2 as ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.chandler as cverifier
      ,a.cmodifyperson as cmodifier
      ,a.dnmaketime as dcreatesystime
      ,a.dnmodifytime as dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
  from ufdata.rdrecord32 a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and left(a.db,10) = left(b.db,10)
 where (left(a.dnmaketime,10) >= '${start1_dt}' or left(a.dnmodifytime,10) >= '${start1_dt}')
   and (a.db = 'UFDATA_889_2019' or a.db = 'UFDATA_555_2018');
--   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


create temporary table edw.mid1_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,case when b.bi_cuscode is null then "请核查"
       else b.finnal_ccusname end as true_finnal_ccusname1
      ,case when a.finnal_ccusname is null then
            case when b.bi_cuscode is null then "请核查"
                 else b.finnal_ccusname end
            else case when c.ccusname is null then a.finnal_ccusname
                 else c.bi_cusname end 
       end  as true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
  from edw.outdepot_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;

create temporary table edw.mid2_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccusname1
      ,case when a.true_finnal_ccusname2 like "个人%" and char_LENGTH(a.true_finnal_ccusname2) > 6 then substr(a.true_finnal_ccusname2,4,char_length(a.true_finnal_ccusname2)-4) else a.true_finnal_ccusname2 end as true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
  from edw.mid1_outdepot_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;

-- 删除今天更新的数据
delete from edw.outdepot_order where concat(db,id) in (select concat(db,id) from  edw.outdepot_order_pre);

CREATE INDEX index_mid2_outdepot_order_id ON edw.mid2_outdepot_order(id);
CREATE INDEX index_mid2_outdepot_order_db ON edw.mid2_outdepot_order(db);

-- 增量数据入库，一条变为多条
create temporary table edw.mid3_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,case when c.ccusname is null then "请核查"
       else c.bi_cuscode end as true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
      ,b.autoid
      ,b.cdefine22
      ,b.isaleoutid
      ,b.isodid
      ,b.isotype
      ,b.csocode
      ,b.isbsid
      ,b.coutvouchtype
      ,b.cinvouchtype
      ,b.cinvouchcode
      ,b.cvouchcode
      ,b.id as child_id
      ,b.idlsid
      ,b.iorderdid
      ,b.iordercode
      ,b.cinvcode
      ,b.iquantity
      ,b.iunitcost
      ,b.iprice
      ,b.citemcode
      ,b.citem_class
      ,b.cname as citemname
      ,b.citemcname as citem_cname
      ,b.fsettleqty
      ,localtimestamp() as sys_time
  from edw.mid2_outdepot_order a
  left join ufdata.rdrecords32 b
    on a.id = b.id
   and a.db = b.db
  left join (select bi_cuscode,ccusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;

create temporary table edw.mid4_outdepot_order as
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.isodid
      ,a.isotype
      ,a.csocode
      ,a.isbsid
      ,a.coutvouchtype
      ,a.cinvouchtype
      ,a.cinvouchcode
      ,a.cvouchcode
      ,a.child_id
      ,a.idlsid
      ,a.iorderdid
      ,a.iordercode
      ,a.cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.sys_time
  from edw.mid3_outdepot_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db not in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

insert into edw.mid4_outdepot_order
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.isodid
      ,a.isotype
      ,a.csocode
      ,a.isbsid
      ,a.coutvouchtype
      ,a.cinvouchtype
      ,a.cinvouchcode
      ,a.cvouchcode
      ,a.child_id
      ,a.idlsid
      ,a.iorderdid
      ,a.iordercode
      ,a.cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.sys_time
  from edw.mid3_outdepot_order a
  left join (select * from dic_inventory group by left(db,10),cinvcode) b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

-- 新增项目正确的，都在第二层处理
insert into edw.outdepot_order
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.isodid
      ,a.isotype
      ,a.csocode
      ,a.isbsid
      ,a.coutvouchtype
      ,a.cinvouchtype
      ,a.cinvouchcode
      ,a.cvouchcode
      ,a.child_id
      ,a.idlsid
      ,a.iorderdid
      ,a.iordercode
      ,a.cinvcode
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,case when (b.inum_unit_person is null or b.inum_unit_person = '' )then iquantity else b.inum_unit_person*iquantity end as inum_person
      ,a.citemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.item_code end as true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,'有效'
      ,a.sys_time
  from edw.mid4_outdepot_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;

-- 修改部分最终客户
update edw.outdepot_order set true_finnal_ccuscode = 'ZD5115002' , true_finnal_ccusname2 = '宜宾市妇幼保健院' where year(ddate) <= 2018 and true_ccuscode = 'DL5115001';

update edw.outdepot_order set true_finnal_ccuscode = 'ZD3706028' , true_finnal_ccusname2 = '烟台毓璜顶医院' where year(ddate) <= 2018 and true_ccuscode = 'DL3706001';
update edw.outdepot_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = '山东大学齐鲁医院' where year(ddate) <= 2018 and true_ccuscode = 'DL3701012';

-- 上游删除的数据第二层打标签
drop table if exists edw.mid5_outdepot_order;
create temporary table edw.mid5_outdepot_order as 
select a.id
      ,a.db
  from edw.outdepot_order a
  left join (select * from ufdata.rdrecord32 where year(ddate) >= '2018') b
    on a.id = b.id
   and a.db = b.db
 where b.id is null
   and a.db <> 'UFDATA_889_2018'
   and year(a.ddate) >= '2018'
;

update edw.outdepot_order set state = '无效',sys_time = localtimestamp() where concat(db,id) in (select concat(db,id) from edw.mid5_outdepot_order) ;

