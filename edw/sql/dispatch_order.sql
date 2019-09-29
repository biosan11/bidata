------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：dispatch_order.sql
--目标模型：dispatch_order
--源    表：ufdata.dispatchlist,ufdata.dispatchlists,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/dispatch_order.python 2018-11-12 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--dispatch_order建表语句
--create table `dispatch_order` (
--  `db` varchar(20) default null comment '来源数据库',
--  `cdlcode` varchar(30) default null comment '发货退货单号',
--  `dlid` int(11) default null comment '发货退货单主表标识',
--  `csocode` varchar(30) default null comment '销售订单号',
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
--  `ccusperson` varchar(100) default null comment '联系人编码',
--  `ccuspersoncode` varchar(30) default null comment '客户联系人',
--  `cebexpresscode` varchar(50) DEFAULT NULL comment '快递单号',
--  `iebexpresscoid` bigint(20) DEFAULT NULL comment '物流公司ID',
--  `sbvid` int(11) DEFAULT NULL comment '销售发票主表标识',
--  `csbvcode` varchar(255) DEFAULT NULL comment '销售发票号',
--  `cvouchtype` varchar(2) DEFAULT NULL comment '单据类型编码',
--  `isale` int(11) DEFAULT NULL comment '是否先发货',
--  `cdefine3` varchar(20) DEFAULT NULL comment '负责人\区域主管备用',
--  `autoid` int(11) default null comment '发货退货子表标识',
--  `cwhcode` varchar(10) DEFAULT NULL comment '仓库编码',
--  `cvenabbname` varchar(60) DEFAULT NULL comment '供应商名称',
--  `isosid` int(11) DEFAULT NULL comment '销售订单子表标识',
--  `cdefine22` varchar(60) DEFAULT NULL comment '销售产品辅助',
--  `isaleoutid` bigint(20) DEFAULT NULL comment '出库单子表id',
--  `bgift` char(1) DEFAULT NULL comment '是否赠品',
--  `bmpforderclosed` char(1) DEFAULT NULL comment '订单关闭标识',
--  `child_dlid` varchar(30) default null comment '子表发货退货订单号',
--  `cinvcode` varchar(60) default null comment '存货编码',
--  `cinvname` varchar(255) default null comment '存货名称',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `iquantity` decimal(30,10) default null comment '数量',
--  `itaxunitprice` decimal(30,10) default null comment '原币含税单价',
--  `itax` decimal(19,4) default null comment '原币税额',
--  `isum` decimal(19,4) default null comment '原币价税合计',
--  `itaxrate` decimal(30,10) default null comment '税率',
--  `citemcode` varchar(60) default null comment '项目编码',
--  `citem_class` varchar(10) default null comment '项目大类编码',
--  `citemname` varchar(255) default null comment '项目名称',
--  `citem_cname` varchar(20) default null comment '项目大类名称',
--  `ccode` varchar(30) DEFAULT NULL comment '出库单据号',
--  `ccontractid` varchar(64) DEFAULT NULL comment '合同号',
--  `sys_time` datetime default null comment '数据时间戳'
--) engine=innodb default charset=utf8;
--
--alter table dispatch_order COMMENT '发货退货订单表';
--新建索引，删除增量数据的时候更快
--CREATE INDEX index_dispatch_order_dlid ON edw.dispatch_order(dlid);

use edw;
-- 获取主表的增量数据
drop table if exists edw.dispatch_order_pre;

create temporary table edw.dispatch_order_pre as
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
  from ufdata.dispatchlist a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and a.db <> 'UFDATA_889_2019'
   and a.db <> 'UFDATA_555_2018'; 
--   and (b.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013") or b.ccuscode is null);


insert into edw.dispatch_order_pre
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
  from ufdata.dispatchlist a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and left(a.db,10) = left(b.db,10)
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and (a.db = 'UFDATA_889_2019' or a.db = 'UFDATA_555_2018');
--   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

create temporary table edw.mid1_dispatch_order as
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
  from edw.dispatch_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;

create temporary table edw.mid2_dispatch_order as
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
  from edw.mid1_dispatch_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;


-- 删除今天更新的数据
delete from edw.dispatch_order where concat(dlid,db) in (select concat(dlid,db) from  edw.dispatch_order_pre);
CREATE INDEX index_mid2_dispatch_order_db ON edw.mid2_dispatch_order(db);
CREATE INDEX index_mid2_dispatch_order_dlid ON edw.mid2_dispatch_order(dlid);

-- 增量数据入库，一条变为多条
create temporary table edw.mid3_dispatch_order as
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,case when c.ccusname is null then "请核查"
       else c.bi_cuscode end as true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,case when c.ccusname is null then "请核查"
       else c.bi_cusname end as true_finnal_ccusname2
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
      ,b.autoid
      ,b.cwhcode
      ,b.cvenabbname
      ,b.isosid
      ,b.cdefine22
      ,b.isaleoutid
      ,b.bgift
      ,b.bmpforderclosed
      ,b.dlid as child_dlid
      ,b.cinvcode
      ,b.cinvname
      ,b.iquantity
      ,b.itaxunitprice
      ,b.itax
      ,b.isum
      ,b.itaxrate
      ,b.citemcode
      ,b.citem_class
      ,b.citemname
      ,b.citem_cname
      ,b.ccode
      ,b.ccontractid
      ,b.cContractTagCode
      ,b.fOutQuantity
      ,b.fretoutqty
      ,b.fretqtywkp
      ,b.fretqtyykp
      ,b.iCorID
      ,b.icoridlsid
      ,b.iRetQuantity
      ,b.iTB
      ,localtimestamp() as sys_time
  from edw.mid2_dispatch_order a
  left join ufdata.dispatchlists b
    on a.dlid = b.dlid
   and a.db = b.db
  left join (select bi_cuscode,ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;


create temporary table edw.mid4_dispatch_order as
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
      ,a.autoid
      ,a.cwhcode
      ,a.cvenabbname
      ,a.isosid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.bgift
      ,a.bmpforderclosed
      ,a.child_dlid
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.ccode
      ,a.ccontractid
      ,a.cContractTagCode
      ,a.fOutQuantity
      ,a.fretoutqty
      ,a.fretqtywkp
      ,a.fretqtyykp
      ,a.iCorID
      ,a.icoridlsid
      ,a.iRetQuantity
      ,a.itb
      ,a.sys_time
 from edw.mid3_dispatch_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db not in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

insert into edw.mid4_dispatch_order
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
      ,a.autoid
      ,a.cwhcode
      ,a.cvenabbname
      ,a.isosid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.bgift
      ,a.bmpforderclosed
      ,a.child_dlid
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.ccode
      ,a.ccontractid
      ,a.cContractTagCode
      ,a.fOutQuantity
      ,a.fretoutqty
      ,a.fretqtywkp
      ,a.fretqtyykp
      ,a.iCorID
      ,a.icoridlsid
      ,a.iRetQuantity
      ,a.itb
      ,a.sys_time
 from edw.mid3_dispatch_order a
  left join dic_inventory b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

insert into edw.dispatch_order
select a.db
      ,a.cdlcode
      ,a.dlid
      ,a.csocode
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cebexpresscode
      ,a.iebexpresscoid
      ,a.sbvid
      ,a.csbvcode
      ,a.cvouchtype
      ,a.isale
      ,a.cdefine3
      ,a.bReturnFlag
      ,a.bsaleoutcreatebill
      ,a.autoid
      ,a.cwhcode
      ,a.cvenabbname
      ,a.isosid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.bgift
      ,a.bmpforderclosed
      ,a.child_dlid
      ,a.cinvcode
      ,a.cinvname
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.item_code end as true_itemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.level_three end as level_three
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.ccode
      ,a.ccontractid
      ,a.cContractTagCode
      ,a.fOutQuantity
      ,a.fretoutqty
      ,a.fretqtywkp
      ,a.fretqtyykp
      ,a.iCorID
      ,a.icoridlsid
      ,a.iRetQuantity
      ,a.itb
      ,'有效'
      ,a.sys_time
  from edw.mid4_dispatch_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;


-- 上游删除的数据第二层打标签
drop table if exists edw.mid5_dispatch_order;
create temporary table edw.mid5_dispatch_order as 
select a.dlid
      ,a.db
  from edw.dispatch_order a
  left join (select * from ufdata.dispatchlist where year(ddate) >= '2018') b
    on a.dlid = b.dlid
   and a.db = b.db
 where b.dlid is null
   and a.db <> 'UFDATA_889_2018'
   and year(a.ddate) >= '2018'
;

update edw.dispatch_order set state = '无效',sys_time = localtimestamp() where concat(db,dlid) in (select concat(db,dlid) from edw.mid5_dispatch_order) ;







