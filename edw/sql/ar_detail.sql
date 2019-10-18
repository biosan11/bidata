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
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--ar_detail建表语句

-- drop table if exists edw.ar_detail;
-- create table if not exists edw.ar_detail (
--  db varchar(20) comment '来源库',
--  Auto_ID int(11) comment '自动编号 ',
--  iPeriod tinyint(4) comment '会计期间 ',
--  cVouchType varchar(10) comment '单据类型编码 ',
--  cVouchSType varchar(2) comment '单据小类 ',
--  cVouchID varchar(30) comment '单据编号 ',
--  dVouchDate date comment '单据日期 ',
--  dRegDate date comment '记账日期 ',
--  cDwCode varchar(20) comment '单位编码 ',
--  true_ccuscode varchar(20) comment '正确客户编码',
--  true_ccusname varchar(120) comment '正确客户名称',
--  iBVid int(11) comment '发票子表标识 ',
--  cCode varchar(15) comment '科目编码 ',
--  csign varchar(2) comment '单据正负标识 ',
--  isignseq tinyint(4) comment '凭证表制单期间 ',
--  ino_id smallint(6) comment '凭证编号 ',
--  cDigest varchar(300) comment '摘要 ',
--  iDAmount float(12,2) comment '借方金额 ',
--  iCAmount float(12,2) comment '贷方金额 ',
--  iDAmount_s float(12,2) comment '借方数量 ',
--  iCAmount_s float(12,2) comment '贷方数量 ',
--  cOrderNo varchar(30) comment '销售订单号 ',
--  cSSCode varchar(3) comment '结算方式编码 ',
--  cProcStyle varchar(10) comment '处理方式 ',
--  cCancelNo varchar(40) comment '处理标识符 ',
--  cPZid varchar(30) comment '凭证线索号 ',
--  bPrePay varchar(20) comment '预收预付标志 ',
--  iFlag tinyint(4) comment '是否正常标志 ',
--  cCoVouchType varchar(10) comment '对应单据类型 ',
--  cCoVouchID varchar(30) comment '对应单据号 ',
--  cDefine2 varchar(20) comment '自定义项2 ',
--  cDefine8 varchar(4) comment '自定义项8 ',
--  cDefine10 varchar(60) comment '自定义项10 ',
--  iVouchAmount float(12,2) comment '单据本币金额 ',
--  iVouchAmount_s float(12,2) comment '单据数量 ',
--  key index_edw_db (db),
--  key index_edw_auto_id (auto_id),
--  key index_edw_cVouchType (cVouchType),
--  key index_edw_cVouchID (cVouchID),
--  key index_edw_cDwCode (cDwCode),
--  key index_edw_true_ccuscode (true_ccuscode)
-- ) engine=innodb default charset=utf8 comment "账款明细表";

-- 全量更新
use edw;

truncate table edw.ar_detail;

-- 新增处理R0对应的产品为空的情况
drop table if exists edw.ap_vouch;
create temporary table edw.ap_vouch as
select a.clink
      ,a.db
      ,a.cvouchid
      ,b.citemcode
      ,c.bi_cinvcode
      ,c.bi_cinvname
  from ufdata.ap_vouch a
  left join (select * from ufdata.ap_vouchs where citemcode is not null group by clink) b
    on a.clink = b.clink
  left join (select * from edw.dic_inventory group by left(db,10),cinvcode) c
    on b.citemcode = c.cinvcode
   and left(b.db,10) = left(c.db,10)
  where b.clink is not null
;

-- 分两部分插入数据

-- 1. 客户清洗条件 db ccuscode
create temporary table edw.ar_detail_pre as
select 
	 a.db
	,a.Auto_ID
	,a.iPeriod
	,a.cVouchType
	,a.cVouchSType
	,a.cVouchID
	,a.dVouchDate
	,a.dRegDate
	,a.cDwCode
	,case when b.ccuscode is null then "请核查"
     else b.bi_cuscode end as true_ccuscode 
	,case when b.ccuscode is null then "请核查"
     else b.bi_cusname end as true_ccusname
	,case when a.cVouchType = 'R0' then f.citemcode else a.cinvcode end as cinvcode
	,case when a.cVouchType = 'R0' then f.bi_cinvcode else c.bi_cinvcode end as true_cinvcode
	,case when a.cVouchType = 'R0' then f.bi_cinvname else c.bi_cinvname end as true_cinvname
	,a.iBVid
	,a.cCode
	,a.csign
	,a.isignseq
	,a.ino_id
	,a.cDigest
	,a.iDAmount
	,a.iCAmount
	,a.iDAmount_s
	,a.iCAmount_s
	,a.cOrderNo
	,a.cSSCode
	,a.cProcStyle
	,a.cCancelNo
	,a.cPZid
	,a.bPrePay
	,a.iFlag
	,a.cCoVouchType
	,a.cCoVouchID
	,a.cDefine2
	,a.cDefine8
	,a.cDefine10
	,a.iVouchAmount
	,a.iVouchAmount_s
	,case when a.cVouchType = 'R0' then 'ap_vouch' end mark
	,'11111111111' as item_code
from ufdata.ar_detail as a
left join edw.dic_customer as b
on a.cDwCode = b.ccuscode
and left(a.db,10) = left(b.db,10)
left join (select * from edw.dic_inventory group by cinvcode) c
  on a.cinvcode = c.cinvcode
left join edw.ap_vouch f
  on a.db = f.db
 and a.cVouchID = f.cVouchID
where a.db = 'UFDATA_889_2019' or a.db = 'UFDATA_555_2018';
-- where a.cDwCode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

-- left join (select * from edw.map_inventory group by bi_cinvcode) d
--   on c.bi_cinvcode = d.bi_cinvcode
-- left join (select * from edw.invoice_order group by csbvcode) e
--   on a.cvouchid = e.csbvcode

-- 2.客户清洗条件 ccuscode
insert into edw.ar_detail_pre
select 
	 a.db
	,a.Auto_ID
	,a.iPeriod
	,a.cVouchType
	,a.cVouchSType
	,a.cVouchID
	,a.dVouchDate
	,a.dRegDate
	,a.cDwCode
	,case when b.ccuscode is null then "请核查"
     else b.bi_cuscode end as true_ccuscode 
	,case when b.ccuscode is null then "请核查"
     else b.bi_cusname end as true_ccusname
	,case when a.cVouchType = 'R0' then f.citemcode else a.cinvcode end
	,case when a.cVouchType = 'R0' then f.bi_cinvcode else c.bi_cinvcode end
	,case when a.cVouchType = 'R0' then f.bi_cinvname else c.bi_cinvname end
	,a.iBVid
	,a.cCode
	,a.csign
	,a.isignseq
	,a.ino_id
	,a.cDigest
	,a.iDAmount
	,a.iCAmount
	,a.iDAmount_s
	,a.iCAmount_s
	,a.cOrderNo
	,a.cSSCode
	,a.cProcStyle
	,a.cCancelNo
	,a.cPZid
	,a.bPrePay
	,a.iFlag
	,a.cCoVouchType
	,a.cCoVouchID
	,a.cDefine2
	,a.cDefine8
	,a.cDefine10
	,a.iVouchAmount
	,a.iVouchAmount_s
	,case when a.cVouchType = 'R0' then 'ap_vouch' end mark
	,'11111111111' as item_code
from ufdata.ar_detail as a
left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) as b
on a.cDwCode = b.ccuscode
left join (select * from edw.dic_inventory group by cinvcode) c
  on a.cinvcode = c.cinvcode
left join edw.ap_vouch f
  on a.db = f.db
 and a.cVouchID = f.cVouchID
where a.db <> 'UFDATA_889_2019'
  and a.db <> 'UFDATA_555_2018'; 
-- where a.cDwCode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

-- 处理
delete from edw.ar_detail_pre where db = 'UFDATA_222_2018';
delete from edw.ar_detail_pre where db = 'UFDATA_588_2018';
delete from edw.ar_detail_pre where db = 'UFDATA_168_2018';

-- 建一下索引
CREATE INDEX index_mid2_ar_detail_pre_cVouchID ON edw.ar_detail_pre(cVouchID);
CREATE INDEX index_mid2_ar_detail_pre_db ON edw.ar_detail_pre(db);
CREATE INDEX index_mid2_ar_detail_pre_true_cinvcode ON edw.ar_detail_pre(true_cinvcode);
CREATE INDEX index_mid2_ar_detail_pre_cinvcode ON edw.ar_detail_pre(cinvcode);


-- 跟新R0相关能关联到发票的数据
update edw.ar_detail_pre a
 inner join (select * from edw.invoice_order group by csbvcode,left(db,10)) b
    on a.cVouchID = b.csbvcode
   and left(a.db,10) = left(b.db,10)
   set a.cinvcode = b.cinvcode
      ,a.true_cinvcode = b.bi_cinvcode
      ,a.true_cinvname = b.bi_cinvname
      ,a.mark = 'invoice'
 where a.cVouchType = 'R0'
   and a.cinvcode is null
	 and a.dVouchDate >= '2018-01-01'
;

-- 跟新项目编号，后期添加不修改原始代码
update edw.ar_detail_pre a
 inner join (select * from edw.map_inventory group by bi_cinvcode) b
    on a.true_cinvcode = b.bi_cinvcode
   set a.item_code = b.item_code
;

-- 最后在关联发票去ar_class字段
insert into edw.ar_detail
select a.db
      ,a.Auto_ID
      ,a.iPeriod
      ,a.cVouchType
      ,a.cVouchSType
      ,a.cVouchID
      ,a.dVouchDate
      ,a.dRegDate
      ,a.cDwCode
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.cinvcode
      ,a.true_cinvcode
      ,a.true_cinvname
	    ,case
       when a.cinvcode = "JC0100001" then "检测"  -- 科研服务
       when a.cinvcode = "05001" then "启代医疗服务" -- 启代医疗服务
       when d.level_one = "健康检测" then "健康检测"
       when left(c.bi_cinvcode,2) = "yq" then "设备"
       when left(c.bi_cinvcode,2) = "jc" then "检测"
       when a.cinvcode is not null then "试剂"
       when a.cdefine8 = "检测服务" then "检测"
       when a.cdefine8 in("设备","仪器") then "设备"
       when a.cdefine8 in("其他","试剂") then "试剂"
       when a.cDigest like "%试剂%" then "试剂"
       when a.cDigest like "%检测%" then "检测"
       when a.cDigest like "%仪器%" then "设备"
       when a.cDigest like "%设备%" then "设备"
       else "试剂" end
      ,a.iBVid
      ,a.cCode
      ,a.csign
      ,a.isignseq
      ,a.ino_id
      ,a.cDigest
      ,a.iDAmount
      ,a.iCAmount
      ,a.iDAmount_s
      ,a.iCAmount_s
      ,a.cOrderNo
      ,a.cSSCode
      ,a.cProcStyle
      ,a.cCancelNo
      ,a.cPZid
      ,a.bPrePay
      ,a.iFlag
      ,a.cCoVouchType
      ,a.cCoVouchID
      ,a.cDefine2
      ,a.cDefine8
      ,a.cDefine10
      ,a.iVouchAmount
      ,a.iVouchAmount_s
	    ,case when e.csbvcode is not null then a.iDAmount/(1+e.itaxrate/100)
	          else (case when a.cDefine8 = '检测服务' then a.iDAmount/(1+6/100) 
	                     when a.cDefine8 <> '检测服务' and dVouchDate < '2018-05-01' then a.iDAmount/(1+17/100) 
	                     else a.iDAmount/(1+16/100) end)
	        end as invoice_amount
	    ,d.specification_type
      ,a.mark
      ,case when a.item_code = '11111111111' then null else a.item_code end 
      ,localtimestamp() as sys_time
  from edw.ar_detail_pre a
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
  left join (select * from edw.invoice_order group by csbvcode,left(db,10)) e
    on a.cvouchid = e.csbvcode
   and left(a.db,10) = left(e.db,10)
;

-- 去除末尾的“-”
-- update edw.ar_detail
-- set cCoVouchID = left(cCoVouchID,char_length(cCoVouchID)-1)
-- where right(cCoVouchID,1) = '-';
-- 
-- 
-- update edw.ar_detail
-- set cvouchid = left(cvouchid,char_length(cvouchid)-1)
-- where right(cvouchid,1) = '-';

