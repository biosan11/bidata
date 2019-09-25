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
-- create table `dispatch_order` (
--   `cdlcode` varchar(30) DEFAULT NULL COMMENT '销售订单号',
--   `dlid` int(11) DEFAULT NULL COMMENT '主表销售订单主表标识',
--   `cohr` varchar(20) default null comment '公司简称',
--   `ddate` datetime DEFAULT NULL COMMENT '单据日期',
--   `cdepcode` varchar(12) default null comment '部门编码',
--   `cdepname` varchar(255) DEFAULT NULL comment '部门名称',
--   `sales_region` varchar(20) DEFAULT NULL COMMENT '销售区域',
--   `province` varchar(60) DEFAULT NULL COMMENT '销售省份',
--   `city` varchar(60) DEFAULT NULL COMMENT '销售城市',
--   `ccuscode` varchar(20) default null comment '客户编码',
--   `ccusname` varchar(120) default null comment '客户名称',
--   `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
--   `finnal_ccusname` varchar(60) DEFAULT NULL COMMENT '最终客户名称',
--   `cbustype` varchar(8) DEFAULT NULL COMMENT '业务类型',
--   `cinvcode` varchar(60) default null comment '存货编码',
--   `cinvname` varchar(255) default null comment '存货名称',
--   `itaxunitprice` decimal(30,10) default null comment '原币含税单价',
--   `item_code` varchar(60) DEFAULT NULL COMMENT '正确项目编码',
--   `item_name` varchar(60) DEFAULT NULL COMMENT '正确项目名称',
--   `cstcode` varchar(2) default null comment '销售类型编码',
--   `csocode` varchar(30) DEFAULT NULL COMMENT '销售订单号',
--   `cvouchtype` varchar(2) default null comment '单据类型编码',
--   `isale` int(11) default null comment '是否先发货',
--   `breturnflag` varchar(20) default null comment '退货标志 ',
--   `bsaleoutcreatebill` varchar(20) default null comment '是否出库开票 ',
--   `autoid` int(11) default null comment '发货退货子表标识',
--   `isosid` int(11) default null comment '销售订单子表标识',
--   `cdefine22` varchar(60) default null comment '销售产品辅助',
--   `foutquantity` varchar(64) default null comment '累计出库数量',
--   `itb` varchar(64) default null comment '退补标志 ',
--   `sys_time` datetime default null comment '数据时间戳'
-- ) engine=innodb default charset=utf8;

--alter table dispatch_order COMMENT '发货退货订单表';
--新建索引，删除增量数据的时候更快
--CREATE INDEX index_dispatch_order_dlid ON edw.dispatch_order(dlid);

create temporary table pdm.dispatch_order_pre as 
select *
  from edw.dispatch_order a
 where left(a.sys_time,10) >= '${start_dt}'
  and year(ddate)>=2018;

-- 修复cwhcode部分字段，关联发票表
-- create temporary table pdm.mid_dispatch_order as 
-- select a.*
--       ,case when a.cwhcode is null then b.cwhcode
--      else a.cwhcode end as b_cwhcode
--       ,case when a.cvenabbname is null then b.cvenabbname
--      else a.cvenabbname end as b_cvenabbname
--   from pdm.dispatch_order_pre a
--   left join (select csocode,cwhcode,cvenabbname from edw.invoice_order group by csocode) b
--     on a.csocode = b.csocode;


-- 删除贝康、检测收入
delete from pdm.dispatch_order_pre where left(true_ccuscode,2) = 'GL';

-- 删除今天更新的数据
CREATE INDEX index_dispatch_order_pre_db ON pdm.dispatch_order_pre(db);
CREATE INDEX index_dispatch_order_pre_dlid ON pdm.dispatch_order_pre(dlid);
delete from pdm.dispatch_order where concat(dlid,db) in (select concat(dlid,db) from  pdm.dispatch_order_pre);

-- 插入数据
insert into pdm.dispatch_order
select a.cdlcode
      ,a.dlid
      ,a.db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝莱'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '湖北奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '四川美博特'
            when a.db = 'UFDATA_168_2019' then '杭州贝生'
            when a.db = 'UFDATA_588_2019' then '湖北奥博特'
            when a.db = 'UFDATA_222_2019' then '宝荣'
            when a.db = 'UFDATA_889_2019' then '四川美博特'
            when a.db = 'UFDATA_555_2018' then '贝安云'
            end
      ,a.ddate
      ,a.cdepcode
      ,d.cdepname
      ,b.sales_region
      ,b.province
      ,b.city
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname2 as finnal_ccusname
      ,e.business_class
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.true_itemcode
      ,a.true_itemname
      ,a.cstcode
      ,a.csocode
      ,a.cvouchtype
      ,a.isale
      ,case when a.breturnflag = 'Y' then '是'
          else '否' end
      ,a.bsaleoutcreatebill
      ,a.autoid
      ,a.isosid
      ,a.cdefine22
      ,a.foutquantity
      ,case when a.itb = '1' then '退补'
          else '正常' end
      ,localtimestamp()
  from pdm.dispatch_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join edw.map_inventory e
    on a.bi_cinvcode = e.bi_cinvcode
;


-- 删除上游已经删除的数据
delete from pdm.dispatch_order where concat(db,dlid) in (select concat(db,dlid) from edw.dispatch_order where state = '无效') ;



