/* 建表sql
use edw;
drop table if exists fa_cards;
create table `fa_cards` (
    db varchar(20) comment '',
    scardid int comment '关联id',
    scardnum varchar(10) comment '卡片编号',
    sassetnum varchar(37) comment '资产编码',
    sassetname varchar(255) comment '资产名称',
    sdeptnum text comment '部门编码串',
    cdepname varchar(255) comment '',
    stypenum varchar(20) comment '资产类型编码',
    sorgid varchar(10) comment '核算方式编码',
    sorgaddid varchar(10) comment '增加方式编码',
    sorgdisposeid varchar(10) comment '减少方式编码',
    sdisposereason varchar(10) comment '注销原因',
    ssite varchar(50) comment '存放地点',
    llife int comment '可使用月份',
    dstartdate datetime comment '开始使用日期',
    dinputdate datetime comment '录入日期',
    dtransdate datetime comment '变动日期',
    ddisposedate datetime comment '注销日期',
    mon_used bigint comment '',
    dblValue float(13,3) comment '原值',
    dblDecDeprT float(13,3) comment '减少时累计折旧',
    dblBV float(13,3) comment '净残值',
    dblTransInDeprTCard float(13,3) comment '累计折旧转入',
    dblTransOutDeprTCard float(13,3) comment '累计折旧转出',
    lBuildNum int comment '数量',
    dStartDate2 datetime comment '开始日期',
    dEndDate datetime comment '结束日期',
    memReason mediumtext comment '变动原因',
    memRemark mediumtext comment '备注',
    dTransDate2 datetime comment '变动日期',
    lDays int comment '累计天数',
    dblAfterValue float(13,3) comment '变动后原值',
    dblTransValue float(13,3) comment '变动金额',
    sMark varchar(50) comment '标志',
    sys_time datetime comment ''
) engine=innodb default charset=utf8 collate=utf8_bin;
*/



-- 清空固定资产表，并全量插入
truncate table edw.fa_cards;
insert into edw.fa_cards
select a.db
      ,a.scardid
      ,a.scardnum
      ,a.sassetnum
      ,a.sassetname
      ,a.sdeptnum
      ,c.cdepname
      ,a.stypenum
      ,a.sorgid
      ,a.sorgaddid
      ,a.sorgdisposeid
      ,a.sdisposereason
      ,a.ssite
      ,a.llife
      ,a.dstartdate
      ,a.dinputdate
      ,a.dtransdate
      ,a.ddisposedate
      ,a.lusedmonths as mon_used
      ,b.dblValue
      ,b.dblDecDeprT
      ,b.dblBV
      ,b.dbltransindeprtcard
      ,b.dbltransoutdeprtcard
      ,b.lBuildNum
      ,d.dStartDate
      ,d.dEndDate
      ,d.memReason
      ,d.memRemark
      ,d.dTransDate
      ,d.lDays
      ,d.dblAfterValue
      ,d.dblTransValue
      ,d.sMark
      ,localtimestamp() as sys_time 
  from ufdata.fa_cards a
  left join ufdata.fa_cards_detail b
    on a.scardid = b.scardid
   and a.db = b.db
	 and a.sdeptnum = b.sdeptnum
  left join ufdata.department c
    on a.sdeptnum = c.cdepcode
   and a.db = c.db
  left join ufdata.fa_cardssheets d
    on a.sVoucherNum = d.sVoucherNum
   and a.db = d.db
;




