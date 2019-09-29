/*
CREATE TABLE `ft_51_ar_test` (
  `mark_` varchar(5) CHARACTER SET utf8mb4 DEFAULT NULL,
  `balance_ar` double(21,4) DEFAULT NULL,
  `balance_ap` double(21,4) DEFAULT NULL,
  `matchid` varchar(70) DEFAULT NULL,
  `c_id` binary(0) DEFAULT NULL,
  `state` binary(0) DEFAULT NULL,
  `cprocstyle2` varchar(10) DEFAULT NULL,
  `ccovouchtype2` varchar(5) CHARACTER SET utf8mb4 DEFAULT NULL,
  `ar_ap` varchar(20) DEFAULT NULL COMMENT 'arap标记',
  `cohr` varchar(20) DEFAULT NULL COMMENT '公司',
  `db` varchar(20) DEFAULT NULL COMMENT '来源库',
  `cvouchtype` varchar(10) DEFAULT NULL COMMENT '单据类型编码 ',
  `cvouchid` varchar(30) DEFAULT NULL COMMENT '单据编号 ',
  `dvouchdate` date DEFAULT NULL COMMENT '单据日期',
  `dvouchdate2` date DEFAULT NULL COMMENT '单据日期2',
  `dregdate` date DEFAULT NULL COMMENT '记账日期 ',
  `cdwcode` varchar(20) DEFAULT NULL COMMENT '单位编码 ',
  `true_ccuscode` varchar(20) DEFAULT NULL COMMENT '正确客户编码',
  `cinvcode` varchar(20) DEFAULT NULL COMMENT '产品编码',
  `true_cinvcode` varchar(20) DEFAULT NULL COMMENT '正确产品编码',
  `specification_type` varchar(120) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '规格型号',
  `ar_class` varchar(10) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '业务类型',
  `cdigest` varchar(300) DEFAULT NULL COMMENT '摘要 ',
  `idamount` float(12,4) DEFAULT NULL COMMENT '借方金额 ',
  `icamount` float(12,4) DEFAULT NULL COMMENT '贷方金额 ',
  `dvouchdate_ar` date DEFAULT NULL COMMENT '应收日期',
  `dvouchdate_ap` date DEFAULT NULL COMMENT '回款日期',
  `refund_amount` float(12,4) DEFAULT NULL COMMENT '回款金额',
  `cprocstyle` varchar(10) DEFAULT NULL COMMENT '处理方式 ',
  `ccancelno` varchar(40) DEFAULT NULL COMMENT '处理标识符 ',
  `ccovouchtype` varchar(10) DEFAULT NULL COMMENT '对应单据类型 ',
  `ccovouchid` varchar(30) DEFAULT NULL COMMENT '对应单据号 ',
  `aperiod` float(12,2) DEFAULT NULL COMMENT '账期',
  `mark` varchar(20) DEFAULT NULL COMMENT '标记',
  `invoice_amount` float(12,2) DEFAULT NULL COMMENT '开票金额-不含税',
  `iVouchAmount_s` float(12,2) DEFAULT NULL COMMENT '单据数量 '
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
*/
-- 
drop temporary table if exists test.ft_51_ar_test_tem;
create temporary table if not exists test.ft_51_ar_test_tem
select 
    concat(db,cdwcode,ccovouchid) as matchid
    ,null as c_id 
    ,null as state
    ,case
        when cprocstyle in ("26","27","r0") then "ar"
        when cprocstyle in ("48","49") then "ap"
        else cprocstyle
     end as cprocstyle2
    ,case 
        when ccovouchtype in ("26","27","r0") then "ar"
        when ccovouchtype in ("48","49") then "ap"
        else "other"
     end as ccovouchtype2
    ,a.*
from bidata.ft_51_ar as a;

alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_matchid (matchid);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ar_ap (ar_ap);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_cprocstyle2 (cprocstyle2);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ccovouchtype2 (ccovouchtype2);

--
drop temporary table if exists test.ft_51_ar_test_tem01;
create temporary table if not exists test.ft_51_ar_test_tem01
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from bidata.ft_51_ar
where ar_ap = "ap"
and ccovouchtype in ("48","49")
group by db,cdwcode,ccovouchid;

alter table test.ft_51_ar_test_tem01 add index index_ft_51_ar_test_tem01_matchid (matchid);

--
drop temporary table if exists test.ft_51_ar_test_tem02;
create temporary table if not exists test.ft_51_ar_test_tem02
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from bidata.ft_51_ar
where ccovouchtype in ("26","27","r0")
group by db,cdwcode,ccovouchid;

alter table test.ft_51_ar_test_tem02 add index index_ft_51_ar_test_tem02_matchid (matchid);

-- 
drop table if exists test.ft_51_ar_test_pre;
create table if not exists test.ft_51_ar_test_pre
select 
    case 
        when a.ar_ap = "ar" then "qu_ar"
        when a.ar_ap = "ap" and a.ccovouchtype2 = "ar" then "qu_ap"
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0 and a.idamount != 0 then "qu"
        else null 
    end as mark_
    ,case 
        when a.ar_ap = "ar" and a.cprocstyle2 = "ar" and a.ccovouchtype2 = "ar" then c.idamount_-c.icamount_ 
        else 0 
    end as balance_ar
    ,case 
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and a.idamount != 0 then b.icamount_ 
        else 0 
    end as balance_ap
    ,a.matchid
    ,a.c_id
    ,a.state
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.specification_type
    ,a.ar_class
    ,a.cdigest
    ,a.idamount
    ,a.icamount
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark
    ,a.invoice_amount
    ,a.iVouchAmount_s
from test.ft_51_ar_test_tem as a
left join test.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
left join test.ft_51_ar_test_tem02 as c
on a.matchid = c.matchid;

insert into test.ft_51_ar_test_pre
select 
    "qu_in" as mark_
    ,0 as balance_ar
    ,b.icamount_ as balance_ap 
    ,a.matchid
    ,a.c_id
    ,a.state
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.specification_type
    ,a.ar_class
    ,a.cdigest
    ,0 as idamount
    ,0 as icamount
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark
    ,a.invoice_amount
    ,a.iVouchAmount_s
from test.ft_51_ar_test_pre as a 
left join test.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
where mark_ is null 
and a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0 and b.idamount_ = 0;


-- delete from test.ft_51_ar_test_pre where mark_ is null;

-- delete from test.ft_51_ar_test_pre where mark_ = "qu" and balance_ap = 0;

-- 新增应收、回款单据日期以及回款金额
create temporary table test.ft_51_ar_test_pre1 as
select *
  from test.ft_51_ar_test_pre 
 where cprocstyle2 = 'ap'
   and ccovouchtype2 = 'ap'
   and ar_ap = 'ap'
 group by cvouchid,db
;

alter table test.ft_51_ar_test_pre add index index_ft_51_ar_test_pre_cvouchid (cvouchid);
alter table test.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_cvouchid (cvouchid);
alter table test.ft_51_ar_test_pre add index index_ft_51_ar_test_pre_db (db);
alter table test.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_db (db);


truncate table test.ft_51_ar_test;
insert into test.ft_51_ar_test
select a.mark_
      ,a.balance_ar
      ,a.balance_ap
      ,a.matchid
      ,a.c_id
      ,a.state
      ,a.cprocstyle2
      ,a.ccovouchtype2
      ,a.ar_ap
      ,a.cohr
      ,a.db
      ,a.cvouchtype
      ,a.cvouchid
      ,a.dvouchdate
      ,a.dvouchdate2
      ,a.dregdate
      ,a.cdwcode
      ,a.true_ccuscode
      ,a.cinvcode
      ,a.true_cinvcode
      ,a.specification_type
      ,a.ar_class
      ,a.cdigest
      ,a.idamount
      ,a.icamount
      ,case when a.ar_ap = 'ar' then a.dvouchdate else null end
      ,case when a.ar_ap = 'ap' then b.dvouchdate else null end
      ,ifnull(a.balance_ap,0) + ifnull(a.icamount,0)
      ,a.cprocstyle
      ,a.ccancelno
      ,a.ccovouchtype
      ,a.ccovouchid
      ,a.aperiod
      ,a.mark
      ,a.invoice_amount
      ,a.iVouchAmount_s 
  from test.ft_51_ar_test_pre a
  left join test.ft_51_ar_test_pre1 b
    on a.cvouchid = b.cvouchid
   and a.db = b.db
;

drop table if exists test.ft_51_ar_test_pre;




