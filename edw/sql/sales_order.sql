------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：sales_order.sql
--目标模型：sales_order
--源    表：ufdata.so_somain,ufdata.so_sodetails,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh sales_order
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--sales_order建表语句
--create table `sales_order` (
--  `db` varchar(20) DEFAULT NULL COMMENT '来源数据库',
--  `csocode` varchar(30) DEFAULT NULL COMMENT '销售订单号',
--  `id` int(11) DEFAULT NULL COMMENT '主表销售订单主表标识',
--  `ddate` datetime DEFAULT NULL COMMENT '单据日期',
--  `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编码',
--  `ccusname` varchar(120) DEFAULT NULL COMMENT '客户名称',
--  `true_ccuscode` varchar(20) DEFAULT NULL COMMENT '客户正确编码',
--  `true_ccusname` varchar(120) DEFAULT NULL COMMENT '客户正确名称',
--  `finnal_ccusname` varchar(60) DEFAULT NULL COMMENT '最终客户名称',
--  `true_finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
--  `true_finnal_ccusname1` varchar(60) DEFAULT NULL COMMENT '最终客户正确名称-客户编码匹配',
--  `true_finnal_ccusname2` varchar(60) DEFAULT NULL COMMENT '最终客户正确名称-原值匹配',
--  `cmaker` varchar(20) DEFAULT NULL COMMENT '制单人',
--  `cverifier` varchar(20) DEFAULT NULL COMMENT '审核人',
--  `cmodifier` varchar(20) DEFAULT NULL COMMENT '修改人',
--  `dcreatesystime` datetime DEFAULT NULL COMMENT '制单时间',
--  `dmodifysystime` datetime DEFAULT NULL COMMENT '修改时间',
--  `cdepcode` varchar(12) DEFAULT NULL COMMENT '部门编码',
--  `cstcode` varchar(2) DEFAULT NULL COMMENT '销售类型',
--  `cpersoncode` varchar(20) DEFAULT NULL COMMENT '业务员编码',
--  `ccusperson` varchar(100) DEFAULT NULL COMMENT '联系人编码',
--  `ccuspersoncode` varchar(30) DEFAULT NULL COMMENT '客户联系人',
--  `cdefine2` varchar(20) DEFAULT NULL COMMENT '最终客户备用',
--  `cdefine3` varchar(20) DEFAULT NULL comment '负责人\区域主管备用',
--  `autoid` int(11) DEFAULT NULL COMMENT '销售订单子表标识',
--  `cdefine22` varchar(60) DEFAULT NULL comment '销售产品辅助',
--  `child_csocode` varchar(30) DEFAULT NULL COMMENT '子表销售订单号',
--  `cinvcode` varchar(60) DEFAULT NULL COMMENT '存货编码',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `iquantity` decimal(30,10) DEFAULT NULL COMMENT '数量',
--  `itaxunitprice` decimal(30,10) DEFAULT NULL COMMENT '原币含税单价',
--  `itax` decimal(19,4) DEFAULT NULL COMMENT '原币税额',
--  `isum` decimal(19,4) DEFAULT NULL COMMENT '原币价税合计',
--  `itaxrate` decimal(30,10) DEFAULT NULL COMMENT '税率',
--  `citemcode` varchar(60) DEFAULT NULL COMMENT '项目编码',
--  `true_itemcode` varchar(60) default null comment '正确项目编码',
--  `citem_class` varchar(10) DEFAULT NULL COMMENT '项目大类编码',
--  `citemname` varchar(255) DEFAULT NULL COMMENT '项目名称',
--  `citem_cname` varchar(20) DEFAULT NULL COMMENT '项目大类名称',
--  `sys_time` datetime DEFAULT NULL COMMENT '数据时间戳',
--   key index_sales_order_id  (`id`)
--) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT '销售订单表';


use edw;
--获取主表的增量数据,修改客户名称
drop table if exists edw.sales_order_pre;
create temporary table edw.sales_order_pre as
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
  from ufdata.so_somain a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and a.db <> 'UFDATA_889_2019'
   and a.db <> 'UFDATA_555_2018'; 

--   and a.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


insert into edw.sales_order_pre
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
  from ufdata.so_somain a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and left(a.db,10) = left(b.db,10)
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start1_dt}')
   and (a.db = 'UFDATA_889_2019' or a.db = 'UFDATA_555_2018');

--   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


--最终客户名称判断,给出两种判断值
drop table if exists edw.mid1_sales_order;
create temporary table edw.mid1_sales_order as
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
  from edw.sales_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;

create temporary table edw.mid2_sales_order as
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
  from edw.mid1_sales_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;

--删除今天更新的数据
delete from edw.sales_order where concat(id,db) in (select concat(id,db) from edw.sales_order_pre);
CREATE INDEX index_mid2_sales_order_db ON edw.mid2_sales_order(db);
CREATE INDEX index_mid2_sales_order_id ON edw.mid2_sales_order(id);


--增量数据入库，一条变为多条
create temporary table edw.mid3_sales_order as
select a.db
      ,a.csocode
      ,a.id
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
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cdefine2
      ,a.cdefine3
      ,b.autoid
      ,b.cdefine22
      ,b.csocode as child_csocode
      ,b.cinvcode
      ,b.iquantity
      ,b.itaxunitprice
      ,b.itax
      ,b.isum
      ,b.itaxrate
      ,b.citemcode
      ,b.citem_class
      ,b.citemname
      ,b.citem_cname
      ,b.isosid
      ,localtimestamp() as sys_time
  from edw.mid2_sales_order a
  left join ufdata.so_sodetails b
    on a.id = b.id
   and a.db = b.db
  left join (select bi_cuscode,ccusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;

--插入新增数据，并清洗bi_cinvcode，bi_cinvname
create temporary table edw.mid4_sales_order as
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.child_csocode
      ,a.cinvcode
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
      ,a.isosid
      ,a.sys_time
  from edw.mid3_sales_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db not in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;

insert into edw.mid4_sales_order
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.child_csocode
      ,a.cinvcode
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
      ,a.isosid
      ,a.sys_time
  from edw.mid3_sales_order a
  left join dic_inventory b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018','UFDATA_555_2018')
;


insert into edw.sales_order
select a.db
      ,a.csocode
      ,a.id
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
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.child_csocode
      ,a.cinvcode
      ,a.bi_cinvcode
      ,a.bi_cinvname
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
      ,'有效'
      ,a.isosid
      ,a.sys_time
  from edw.mid4_sales_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;

-- 上游删除的数据第二层打标签
create temporary table edw.mid5_sales_order as 
select a.csocode
      ,a.db
  from edw.sales_order a
  left join (select * from ufdata.so_somain where year(ddate) > '2018') b
    on a.csocode = b.csocode
   and a.db = b.db
 where b.csocode is null
   and a.db <> 'UFDATA_889_2018'
   and year(a.ddate) > '2018'
;

update edw.sales_order set state = '无效',sys_time = localtimestamp() where concat(db,csocode) in (select concat(db,csocode) from edw.mid5_sales_order) ;

delete from ufdata.so_sodetails where autoid = '48568';


