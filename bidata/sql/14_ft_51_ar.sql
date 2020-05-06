-- 17_ft_51_ar
/*
-- 建表
use bidata;
drop table if exists bidata.ft_51_ar;
create table `ft_51_ar` (
  `ar_ap` varchar(20) comment 'arap标记',
  `cohr` varchar(20) comment '公司',
  `db` varchar(20) character set utf8 default null comment '来源库',
  `cvouchtype` varchar(10) character set utf8 default null comment '单据类型编码 ',
  `cvouchid` varchar(30) character set utf8 default null comment '单据编号 ',
  `dvouchdate` date default null comment '单据日期',
  `dvouchdate2` date default null comment '单据日期2',
  `dregdate` date default null comment '记账日期 ',
  `cdwcode` varchar(20) character set utf8 default null comment '单位编码 ',
  `true_ccuscode` varchar(20) character set utf8 default null comment '正确客户编码',
  `cinvcode` varchar(20) character set utf8 default null comment '产品编码',
  `true_cinvcode` varchar(20) character set utf8 default null comment '正确产品编码',
  `ar_class` varchar(10) collate utf8_bin default null comment '业务类型',
  `cdigest` varchar(300) character set utf8 default null comment '摘要 ',
  `idamount` float(12,4) default null comment '借方金额 ',
  `icamount` float(12,4) default null comment '贷方金额 ',
  `cprocstyle` varchar(10) character set utf8 default null comment '处理方式 ',
  `ccancelno` varchar(40) character set utf8 default null comment '处理标识符 ',
  `ccovouchtype` varchar(10) character set utf8 default null comment '对应单据类型 ',
  `ccovouchid` varchar(30) character set utf8 default null comment '对应单据号 ',
  `aperiod` float(12,2) comment '账期',
  `mark_aperiod` varchar(20) comment'账期标记',
  `mark_cinvcode` varchar(20) comment'取产品编码标记',
  `item_code` varchar(20) comment'项目编码',
  `iVouchAmount_s` float(12,2) DEFAULT NULL COMMENT '单据数量 ',
  `invoice_amount` float(12,2) DEFAULT NULL COMMENT '开票金额-不含税',
  `specification_type` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '规格型号',
  KEY `ft_51_ar_db` (`db`),
  KEY `ft_51_ar_cvouchid` (`cvouchid`),
  KEY `ft_51_ar_cvouchtype` (`cvouchtype`),
  KEY `ft_51_ar_cprocstyle` (`cprocstyle`)
) engine=innodb default charset=utf8 comment '应收回款明细表';
*/

-- 新增临时表 concat（db,cvouchid)
drop temporary table if exists bidata.ar_tem01;
create temporary table if not exists bidata.ar_tem01
select 
    *
    ,concat(db,cvouchid,cdwcode) as matchid
    ,concat(db,ccancelno) as matchid2
from edw.ar_detail
where (idamount != 0 or icamount != 0)
and left(true_ccuscode,2) != "gl";
alter table bidata.ar_tem01 add index index_ar_tem01_matchid (matchid);
alter table bidata.ar_tem01 add index index_ar_tem01_matchid2 (matchid2);


-- 处理日期
drop temporary table if exists bidata.ar_tem03;
create temporary table if not exists bidata.ar_tem03 
select 
    concat(db,ccancelno) as matchid2
    ,max(dvouchdate) as dvouchdate2
from edw.ar_detail 
group by db,ccancelno;
alter table bidata.ar_tem03 add index index_ar_tem03_matchid2 (matchid2);

-- 导入数据 来源pdm层
truncate table bidata.ft_51_ar;
insert into bidata.ft_51_ar
select
case 
    when a.cvouchtype in ("26","27","r0") then "ar"
    when a.cvouchtype in ("48","49") then "ap"
    else "other"
    end as ar_ap
,case 
    when a.db = 'UFDATA_111_2018' then '博圣' 
    when a.db = 'UFDATA_118_2018' then '卓恩'
    when a.db = 'UFDATA_123_2018' then '恩允'
    when a.db = 'UFDATA_168_2018' then '杭州贝生'
    when a.db = 'UFDATA_168_2019' then '杭州贝生'
    when a.db = 'UFDATA_169_2018' then '云鼎'
    when a.db = 'UFDATA_222_2018' then '宝荣'
    when a.db = 'UFDATA_222_2019' then '宝荣'
    when a.db = 'UFDATA_333_2018' then '宁波贝生'
    when a.db = 'UFDATA_588_2018' then '奥博特'
    when a.db = 'UFDATA_588_2019' then '奥博特'
    when a.db = 'UFDATA_666_2018' then '启代'
    when a.db = 'UFDATA_889_2018' then '美博特'
    when a.db = 'UFDATA_889_2019' then '美博特'
    when a.db = 'UFDATA_555_2018' then '贝安云'
    when a.db = 'UFDATA_555_2019' then '贝安云'
    else '请核查'
    end as cohr
,a.db
,a.cvouchtype
,a.cvouchid
,a.dvouchdate
,d.dvouchdate2 as dvouchdate2
,a.dregdate
,a.cdwcode
,a.true_ccuscode
,a.cinvcode
,a.true_cinvcode
,a.ar_class
,a.cdigest
,round(a.idamount/1000,4) as idamount
,round(a.icamount/1000,4) as icamount
,a.cprocstyle
,a.ccancelno
,a.ccovouchtype
,a.ccovouchid
,b.aperiod 
,b.mark_aperiod
,a.mark as mark_cinvcode
,case 
	when a.item_code is null
		then "其他"
	when left(a.item_code,2)="JK"
		then "其他"
	else a.item_code
	end
,a.iVouchAmount_s
,a.invoice_amount
,specification_type
from bidata.ar_tem01 as a 
left join bidata.dt_12_customer_arclass as b
on a.true_ccuscode = b.ccuscode and a.ar_class = b.ar_class 
left join bidata.ar_tem03 as d
on a.matchid2 = d.matchid2
order by a.db,a.cdwcode,a.dvouchdate,a.ccovouchid;



