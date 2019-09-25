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
--调用方法　python /home/bidata/edw/invoice_order.py 1900-01-01 1900-01-01
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--invoice_order建表语句
--create table `invoice_order` (
--  `db` varchar(20) default null comment '来源数据库',
--  `sbvid` int(11) default null comment '销售发票主表标识',
--  `csbvcode` varchar(30) default null comment '销售发票号',
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
--  `cstcode` varchar(2) default null comment '销售类型编码',
--  `cmaker` varchar(20) default null comment '制单人',
--  `cverifier` varchar(20) default null comment '审核人',
--  `cmodifier` varchar(20) default null comment '修改人',
--  `dcreatesystime` datetime default null comment '制单时间',
--  `dmodifysystime` datetime default null comment '修改时间',
--  `cdepcode` varchar(12) default null comment '部门编码',
--  `cpersoncode` varchar(20) default null comment '业务员编码',
--  `ccusperson` varchar(100) default null comment '联系人编码',
--  `ccuspersoncode` varchar(30) default null comment '客户联系人',
--  `cvouchtype` varchar(2) DEFAULT NULL comment '发票类型',
--  `cdlcode` varchar(255) DEFAULT NULL comment '发货退货单号',
--  `cdefine2` varchar(20) DEFAULT NULL comment '最终客户备用',
--  `cdefine3` varchar(20) DEFAULT NULL comment '负责人\区域主管备用',
--  `autoid` int(11) default null comment '销售订单子表标识',
--  `isaleoutid` bigint(20) DEFAULT NULL comment '出库单子表id',
--  `cbdlcode` varchar(60) DEFAULT NULL comment '发货单号',
--  `isosid` int(11) DEFAULT NULL comment '销售订单子表标识',
--  `idlsid` int(11) DEFAULT NULL comment '发货退货单子表标识',
--  `cdefine22` varchar(60) DEFAULT NULL comment '销售产品辅助',
--  `child_sbvid` varchar(30) default null comment '子表发票订单号',
--  `cinvcode` varchar(60) default null comment '存货编码',
--  `cinvname` varchar(255) default null comment '存货名称',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `cwhcode` varchar(10) DEFAULT NULL comment '仓库编码',
--  `cvenabbname` varchar(60) DEFAULT NULL comment '供应商名称',
--  `iquantity` decimal(30,10) default null comment '数量',
--  `itaxunitprice` decimal(30,10) default null comment '原币含税单价',
--  `itax` decimal(19,4) default null comment '原币税额',
--  `isum` decimal(19,4) default null comment '原币价税合计',
--  `itaxrate` decimal(30,10) default null comment '税率',
--  `citemcode` varchar(60) default null comment '项目编码',
--  `true_itemcode` varchar(60) default null comment '正确项目编码',
--  `citem_class` varchar(10) default null comment '项目大类编码',
--  `citemname` varchar(255) default null comment '项目名称',
--  `citem_cname` varchar(20) default null comment '项目大类名称',
--  `state` varchar(10) COLLATE utf8_bin NOT NULL COMMENT '上游是否删除(有效没有删除)',
--  `sys_time` datetime default null comment '数据时间戳',
--   key index_invoice_order_sbvid  (`sbvid`)
--) engine=innodb default charset=utf8 comment '销售发票表';
--
use edw;
--获取主表的增量数据
drop table if exists edw.invoice_order_pre;

create temporary table edw.invoice_order_pre as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.breturnflag
  from ufdata.salebillvouch a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and a.db <> 'UFDATA_889_2019'
   and a.db <> 'UFDATA_555_2018'; 
-- 针对美博特客户不在同部博圣做出调整,贝安云客户账套完全不一致
--   and a.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

insert into edw.invoice_order_pre
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.bReturnFlag
  from ufdata.salebillvouch a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and left(a.db,10) = left(b.db,10)
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and (a.db = 'UFDATA_889_2019' or a.db = 'UFDATA_555_2018');
--   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


create temporary table edw.mid1_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
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
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.bReturnFlag
  from edw.invoice_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;


create temporary table edw.mid2_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccusname1
      ,case when a.true_finnal_ccusname2 like "个人%" and char_LENGTH(a.true_finnal_ccusname2) > 6 then substr(a.true_finnal_ccusname2,4,char_length(a.true_finnal_ccusname2)-4) else a.true_finnal_ccusname2 end as true_finnal_ccusname2
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.bReturnFlag
  from edw.mid1_invoice_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;


--删除今天更新的数据
delete from edw.invoice_order where concat(db,sbvid) in (select concat(db,sbvid) from  edw.invoice_order_pre);
CREATE INDEX index_mid2_invoice_order_db ON edw.mid2_invoice_order(db);
CREATE INDEX index_mid2_invoice_order_sbvid ON edw.mid2_invoice_order(sbvid);

--增量数据入库，一条变为多条
create temporary table edw.mid3_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
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
      ,a.true_finnal_ccusname2
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,b.autoid
      ,b.isaleoutid
      ,b.cbdlcode
      ,b.isosid
      ,b.idlsid
      ,b.cdefine22
      ,b.sbvid as child_sbvid
      ,b.cinvcode
      ,b.cinvname
      ,b.cwhcode
      ,b.cvenabbname
      ,b.iquantity
      ,b.itaxunitprice
      ,b.itax
      ,b.isum
      ,b.itaxrate
      ,b.citemcode
      ,b.citem_class
      ,b.citemname
      ,b.citem_cname
      ,b.itb
      ,a.bReturnFlag
      ,b.tbquantity
      ,localtimestamp() as sys_time
  from edw.mid2_invoice_order a
  left join ufdata.salebillvouchs b
    on a.sbvid = b.sbvid
   and a.db = b.db
  left join (select bi_cuscode,ccusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;

create temporary table edw.mid4_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
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
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.isaleoutid
      ,a.cbdlcode
      ,a.isosid
      ,a.idlsid
      ,a.cdefine22
      ,a.child_sbvid
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.sys_time
      ,a.itb
      ,a.bReturnFlag
      ,a.tbquantity
  from edw.mid3_invoice_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from edw.dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db not in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

insert into edw.mid4_invoice_order
select a.db
      ,a.sbvid
      ,a.csbvcode
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
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.isaleoutid
      ,a.cbdlcode
      ,a.isosid
      ,a.idlsid
      ,a.cdefine22
      ,a.child_sbvid
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.sys_time
      ,a.itb
      ,a.bReturnFlag
      ,a.tbquantity
  from edw.mid3_invoice_order a
  left join edw.dic_inventory b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

--清洗项目编码
insert into edw.invoice_order
select distinct a.db
      ,a.sbvid
      ,a.csbvcode
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
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.isaleoutid
      ,a.cbdlcode
      ,a.isosid
      ,a.idlsid
      ,a.cdefine22
      ,a.child_sbvid
      ,a.cinvcode
      ,a.cinvname
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.item_code end as true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,b.specification_type
      ,b.cinvbrand
      ,a.itb
      ,a.bReturnFlag
      ,'有效'
      ,a.tbquantity
      ,a.sys_time
  from edw.mid4_invoice_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;
--备份是否需要，现阶段不考虑，后期是否接入备份

-- s上游删除的数据第二层打标签
create temporary table edw.mid5_invoice_order as 
select a.sbvid
      ,a.db
  from edw.invoice_order a
  left join (select * from ufdata.salebillvouch where year(ddate) > '2018') b
    on a.sbvid = b.sbvid
   and a.db = b.db
 where b.sbvid is null
   and a.db <> 'UFDATA_889_2018'
   and year(a.ddate) > '2018'
;

update edw.invoice_order set state = '无效',sys_time = localtimestamp() where concat(db,sbvid) in (select concat(db,sbvid) from edw.mid5_invoice_order) ;





--数据修复
update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , finnal_ccusname = '个人（宜昌市妇幼保健院）' , true_finnal_ccusname2 = '宜昌市妇幼保健院'  where db = 'UFDATA_111_2018' and autoid = '1000015839';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , finnal_ccusname = '威海市妇女儿童医院（威海市妇幼保健院）' , true_finnal_ccusname2 = '威海市妇女儿童医院（威海市妇幼保健院）'  where db = 'UFDATA_111_2018' and autoid = '1000014395';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , finnal_ccusname = '威海市妇女儿童医院（威海市妇幼保健院）' , true_finnal_ccusname2 = '威海市妇女儿童医院（威海市妇幼保健院）'  where db = 'UFDATA_111_2018' and autoid = '1000014396';
update edw.invoice_order set true_finnal_ccuscode = 'ZD4210002'  , true_finnal_ccusname2 = '荆州市妇幼保健院（荆州市妇女儿童医院）'  where db = 'UFDATA_588_2018' and autoid = '1000000387';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3508004'  , true_finnal_ccusname2 = '龙岩市妇幼保健院'  where db = 'UFDATA_111_2018' and autoid = '1000032187';
-- db为889（美博特）、客户名称为”其他-个人检测"的，将客户和最终客户都修改为”个人（四川省妇幼保健院）"
update edw.invoice_order 
set true_finnal_ccuscode = 'ZD5101015' 
, true_finnal_ccusname2 = '四川省妇幼保健院'
,true_ccuscode = 'GR5101003'
,true_ccusname = '个人（四川省妇幼保健院）'
where db = 'UFDATA_889_2018'
  and ccusname = '其他-个人检测';

UPDATE edw.invoice_order
SET true_finnal_ccuscode = 'ZD3710003' 
WHERE
  cinvcode IN ( 'SJ01002', 'SJ01003', 'SJ01008', 'SJ01010', 'SJ01010' ) 
  AND sbvid IN ( '1000003443', '1000003442' );
  
UPDATE edw.invoice_order
SET bi_cinvname= '科研服务' ,bi_cinvcode= 'JC0100001'
WHERE sbvid ='1000011433' ;

-- 最终客户跟新，根据dic_finnal_cust表来维护
update edw.invoice_order s
  join (select * from edw.dic_finnal_cust where tab_name = 'invoice_order') c
    on s.db = c.db
   and s.sbvid = c.id
   set s.true_finnal_ccuscode = c.new_finnal_code,
       s.true_finnal_ccusname2 = c.new_finnal_name
;

-- 财务调账，王涛提供
update edw.invoice_order
   set isum = 0
 where db = 'UFDATA_588_2019'
   and autoid in (
'1000000078'
,'1000000083'
,'1000000080'
,'1000000086'
,'1000000082'
,'1000000084'
,'1000000081'
,'1000000085'
,'1000000079'
,'1000000087'
);


