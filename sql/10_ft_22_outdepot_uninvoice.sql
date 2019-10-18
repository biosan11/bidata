-- 6_ft_22_outdepot_uninvoice
/*
-- 建表 bidata.ft_22_outdepot_uninvoice
use bidata;
drop table if exists bidata.ft_22_outdepot_uninvoice;
create table bidata.ft_22_outdepot_uninvoice(
	db varchar(20) comment '来源数据库',
	id int(11) comment '出库单主表标识',
	cDLCode int(11) comment '发货退货单主表标识',
	cBusCode varchar(30) comment '对应业务单号',
	ccode varchar(30) COMMENT '收发单据号',
	ddate datetime comment '单据日期',
	true_ccuscode varchar(20) comment '客户正确编码',
	true_ccusname varchar(120) comment '客户正确名称',
	true_finnal_ccuscode varchar(20) comment '最终客户正确编码',
	true_finnal_ccusname2 varchar(60) comment '最终客户正确名称-原值匹配',
	autoid int(11) comment '出库单子表标识',
	sales_type varchar(60) comment '销售产品辅助',
	bi_cinvcode varchar(60) comment 'bi存货编码',
	bi_cinvname varchar(255) comment 'bi正确存货名称',
	item_code varchar(30) comment '项目编码',
	iquantity float(13,3) comment '数量',
	iunitcost float(13,3) comment '单价',
	iprice float(13,3) comment '金额',
	inum_person float(13,3) comment '人份数',
	true_itemcode varchar(60) comment '正确项目编码',
	fsettleqty float(13,3) comment '已开票数量',
	iunitcost_join float(13,3) comment '预估单价（来源最近一次开票）',
	iquantity_uninvoice float(13,3) comment '未开票数量',
	isum_uninvoice float(13,3) comment '未开票预估金额',
	anomaly_monitor varchar(255) comment '异常监测',
	key bidata_bi_outdepot_invoice_db (db),
	key bidata_bi_outdepot_invoice_id (id),
	key bidata_bi_outdepot_invoice_autoid (autoid),
	key bidata_bi_outdepot_invoice_cBusCode (cBusCode),
	key bidata_bi_outdepot_invoice_true_ccuscode (true_ccuscode),
	key bidata_bi_outdepot_invoice_true_finnal_ccuscode (true_finnal_ccuscode),
	key bidata_bi_outdepot_invoice_bi_cinvcode (bi_cinvcode)
) engine=innodb default charset=utf8 comment='bi出库未开票结果';

drop table if exists bidata.ft_22_outdepot_invoice;
create table bidata.ft_22_outdepot_invoice(
	db varchar(20) comment '来源数据库',
	id int(11) comment '出库单主表标识',
	cDLCode int(11) comment '发货退货单主表标识',
	cBusCode varchar(30) comment '对应业务单号',
	ccode varchar(30) COMMENT '收发单据号',
	ddate datetime comment '单据日期',
	true_ccuscode varchar(20) comment '客户正确编码',
	true_ccusname varchar(120) comment '客户正确名称',
	true_finnal_ccuscode varchar(20) comment '最终客户正确编码',
	true_finnal_ccusname2 varchar(60) comment '最终客户正确名称-原值匹配',
	autoid int(11) comment '出库单子表标识',
	sales_type varchar(60) comment '销售产品辅助',
	bi_cinvcode varchar(60) comment 'bi存货编码',
	bi_cinvname varchar(255) comment 'bi正确存货名称',
	item_code varchar(30) comment '项目编码',
	iquantity float(13,3) comment '数量',
	iunitcost float(13,3) comment '单价',
	iprice float(13,3) comment '金额',
	inum_person float(13,3) comment '人份数',
	true_itemcode varchar(60) comment '正确项目编码',
	fsettleqty float(13,3) comment '已开票数量',
	iunitcost_join float(13,3) comment '预估单价（来源最近一次开票）',
	iquantity_uninvoice float(13,3) comment '未开票数量',
	isum_uninvoice float(13,3) comment '未开票预估金额',
	anomaly_monitor varchar(255) comment '异常监测',
	key bidata_bi_outdepot_invoice_db (db),
	key bidata_bi_outdepot_invoice_id (id),
	key bidata_bi_outdepot_invoice_autoid (autoid),
	key bidata_bi_outdepot_invoice_cBusCode (cBusCode),
	key bidata_bi_outdepot_invoice_true_ccuscode (true_ccuscode),
	key bidata_bi_outdepot_invoice_true_finnal_ccuscode (true_finnal_ccuscode),
	key bidata_bi_outdepot_invoice_bi_cinvcode (bi_cinvcode)
) engine=innodb default charset=utf8 comment='bi出库未开票核对';
*/

use bidata;
-- 最近一次开票单价
drop temporary table if exists bidata.bi_cusinvprice_pre;
create temporary table if not exists bidata.bi_cusinvprice_pre
select a.* ,b.itaxunitprice
from
(
select
	ccuscode
	,cinvcode
	,max(ddate) as date
from pdm.invoice_order 
where cbustype != "ldt"
and itaxunitprice >0
group by ccuscode,cinvcode
) as a 
left join 
(
select 
	ccuscode
	,cinvcode
	,ddate as date
	,avg(itaxunitprice) as itaxunitprice
from pdm.invoice_order
where cbustype != "ldt"
group by ccuscode,cinvcode,ddate
) as b
on a.ccuscode = b.ccuscode and a.cinvcode = b.cinvcode and a.date = b.date;

-- bidata.bi_cusinvprice_pre 增加索引
alter table bidata.bi_cusinvprice_pre add index index_bidata_bi_cusinvprice_pre_ccuscode (`ccuscode`);
alter table bidata.bi_cusinvprice_pre add index index_bidata_bi_cusinvprice_pre_cinvcode (`cinvcode`);

-- 生成bi_outdepot_invoice 年数据
truncate table bidata.ft_22_outdepot_invoice;
insert into bidata.ft_22_outdepot_invoice
select 
	a.db
	,a.id
	,a.cDLCode
	,a.cBusCode
	,a.ccode
	,a.ddate
	,a.true_ccuscode
	,a.true_ccusname
	,a.true_finnal_ccuscode
	,a.true_finnal_ccusname2
	,a.autoid
	,a.cdefine22
	,a.bi_cinvcode
	,a.bi_cinvname
	,ifnull(c.item_code,"其他")
	,round(a.iquantity,3)
	,null -- ,round(a.iunitcost,2)
	,round(a.iprice,3)
	,round(a.inum_person,3)
	,a.true_itemcode
	,round(ifnull(a.fsettleqty,0),3)
	,round(b.itaxunitprice,3)
	,round((a.iquantity-ifnull(a.fsettleqty,0)),3) as  iquantity_uninvoice
	,round(((a.iquantity-ifnull(a.fsettleqty,0))*b.itaxunitprice),3) as isum_uninvoice
	,null
from edw.outdepot_order as a 
left join bidata.bi_cusinvprice_pre as b
on a.true_ccuscode = b.ccuscode and a.bi_cinvcode = b.cinvcode
left join (select bi_cinvcode,item_code from edw.map_inventory group by bi_cinvcode) as c
on a.bi_cinvcode = c.bi_cinvcode;

-- 生成ft_22_outdepot_uninvoice
truncate table bidata.ft_22_outdepot_uninvoice;
insert into bidata.ft_22_outdepot_uninvoice
select 
	 db
	,id
	,cDLCode
	,cBusCode
	,ccode
	,ddate
	,true_ccuscode
	,true_ccusname
	,true_finnal_ccuscode
	,true_finnal_ccusname2
	,autoid
	,sales_type
	,bi_cinvcode
	,bi_cinvname
	,ifnull(item_code,"其他")
	,round(iquantity,2)
	,round(iunitcost,2)
	,round(iprice,2)
	,round(inum_person,2)
	,true_itemcode
	,round(fsettleqty,2)
	,round(iunitcost_join,2)
	,round(iquantity_uninvoice,2)
	,round(isum_uninvoice,2)
	,anomaly_monitor
from bidata.ft_22_outdepot_invoice 
where (fsettleqty is null or iquantity_uninvoice >0)
and left(true_ccuscode,2) != "GL";

 