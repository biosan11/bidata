-- ar_balance_closing
/*
-- 建表 report.fin_31_account_ori
use report;
drop table if exists report.fin_31_account_ori;
create table if not exists report.fin_31_account_ori(
    matchid varchar(50) comment 'id_1',
    db varchar(20) default null comment '来源库',
    cohr varchar(20) default null comment '公司',
    cdwcode varchar(20) default null comment '单位编码 ',
    ccuscode varchar(20) default null comment 'BI客户编码',
    date_ date default null comment '期末日期',
    balance_opening float(13,5) comment '期初余额',
    idamount_month float(13,5) comment '本月新增应收' ,
    icamount_month float(13,5) comment '本月回款',
    balance_closing float(13,5) comment '期末余额',
    key report_fin_31_account_ori_ori_db (db),
    key report_fin_31_account_ori_cdwcode (cdwcode)
) engine=innodb default charset=utf8 comment='应收账款及回款';
 */

-- -- 传入参数
-- use report;
-- set @dt = str_to_date('${dt}','%Y-%m-%d');

-- 临时表1    bidata.ft_51_ar 取ar idamount求和
drop temporary table if exists report.ar_tem01;
create temporary table if not exists report.ar_tem01 
select 
    concat(db,cdwcode) as matchid
    ,db
    ,cdwcode
    ,@dt as date_
    ,sum(idamount) as idamount
from bidata.ft_51_ar
where ar_ap = "ar"
and dvouchdate <= date_add(@dt,interval -day(@dt) day)
and dvouchdate2 <= date_add(@dt,interval -day(@dt) day)
and db != "UFDATA_666_2018" 
and ar_class != "健康检测"
group by db,cdwcode;
alter table report.ar_tem01 add index index_ar_tem01_matchid (matchid);

-- 临时表2    bidata.ft_51_ar 取ap icamount求和
drop temporary table if exists report.ar_tem02;
create temporary table if not exists report.ar_tem02 
select 
    concat(db,cdwcode) as matchid
    ,db
    ,cdwcode
    ,@dt as date_
    ,-1*sum(icamount) as icamount
from bidata.ft_51_ar
where ar_ap = "ap"
and dvouchdate <= date_add(@dt,interval -day(@dt) day)
and dvouchdate2 <= date_add(@dt,interval -day(@dt) day)
and db != "UFDATA_666_2018" 
and ar_class != "健康检测"
group by db,cdwcode;
alter table report.ar_tem02 add index index_ar_tem02_matchid (matchid);

-- 临时表3    组合临时表1与临时表2    得到期初应收余额
drop temporary table if exists report.ar_tem03;
create temporary table if not exists report.ar_tem03
select 
    c.matchid
    ,c.db
    ,c.cdwcode 
    ,c.date_
    ,ifnull(sum(c.idamount),0) as balance_opening
from 
    (
    select 
        a.*
    from report.ar_tem01 as a 
    union all 
    select 
        b.*
    from report.ar_tem02 as b
    ) as c 
group by c.matchid;
alter table report.ar_tem03 add index index_ar_tem03_matchid (matchid);

-- 临时表4    bidata.ft_51_ar 取ar idamount求和
drop temporary table if exists report.ar_tem04;
create temporary table if not exists report.ar_tem04
select 
    concat(db,cdwcode) as matchid
    ,db
    ,cdwcode
    ,@dt as date_
    ,sum(idamount) as idamount
from bidata.ft_51_ar
where ar_ap = "ar"
and dvouchdate <= @dt
and dvouchdate2 <= @dt
and db != "UFDATA_666_2018" 
and ar_class != "健康检测"
group by db,cdwcode;
alter table report.ar_tem04 add index index_ar_tem04_matchid (matchid);

-- 临时表5    bidata.ft_51_ar 取ap icamount求和
drop temporary table if exists report.ar_tem05;
create temporary table if not exists report.ar_tem05 
select 
    concat(db,cdwcode) as matchid
    ,db
    ,cdwcode
    ,@dt as date_
    ,-1*sum(icamount) as icamount
from bidata.ft_51_ar
where ar_ap = "ap"
and dvouchdate <= @dt
and dvouchdate2 <= @dt
and db != "UFDATA_666_2018" 
and ar_class != "健康检测"
group by db,cdwcode;
alter table report.ar_tem05 add index index_ar_tem05_matchid (matchid);

-- 临时表6    组合临时表4与临时表4    得到期末应收余额
drop temporary table if exists report.ar_tem06;
create temporary table if not exists report.ar_tem06
select 
    c.matchid
    ,c.db
    ,c.cdwcode 
    ,c.date_
    ,ifnull(sum(c.idamount),0) as balance_closing
from 
    (
    select 
        a.*
    from report.ar_tem04 as a 
    union all 
    select 
        b.*
    from report.ar_tem05 as b
    ) as c 
group by c.matchid;
alter table report.ar_tem06 add index index_ar_tem06_matchid (matchid);

-- 临时表7    bidata.ft_51_ar 取ar idamount求和    得到本月新增应收
drop temporary table if exists report.ar_tem07;
create temporary table if not exists report.ar_tem07 
select 
    concat(db,cdwcode) as matchid
    ,db
    ,cdwcode
    ,@dt as date_
    ,ifnull(sum(idamount),0) as idamount_month
from bidata.ft_51_ar
where ar_ap = "ar"
and cprocstyle != "9n"
and dvouchdate > date_add(@dt,interval -day(@dt) day)
and dvouchdate <= @dt
and db != "UFDATA_666_2018" 
and ar_class != "健康检测"
group by db,cdwcode;
alter table report.ar_tem07 add index index_ar_tem07_matchid (matchid);


-- 临时表8    关联上面临时表3 临时表6 临时表7
drop temporary table if exists report.ar_tem08;
create temporary table if not exists report.ar_tem08 
select 
    matchid 
    ,db
    ,cdwcode
    ,date_
from report.ar_tem03 
union 
select 
    matchid 
    ,db
    ,cdwcode
    ,date_
from report.ar_tem06
union 
select 
    matchid 
    ,db
    ,cdwcode
    ,date_
from report.ar_tem07;
alter table report.ar_tem08 add index index_ar_tem08_matchid (matchid);


-- 导入数据 并清洗ccuscode
insert into report.fin_31_account_ori
select 
    a.matchid
    ,a.db
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
        end
    ,a.cdwcode
    ,case when e.ccuscode is null then "请核查"
        else e.bi_cuscode end as ccuscode 
    ,a.date_
    ,ifnull(round(b.balance_opening,4),0)
    ,ifnull(round(d.idamount_month,4),0)
    ,ifnull(round(b.balance_opening,4),0)+ifnull(round(d.idamount_month,4),0)-ifnull(round(c.balance_closing,4),0)
    ,ifnull(round(c.balance_closing,4),0)
from 
report.ar_tem08 as a 
left join report.ar_tem03 as b
on a.matchid = b.matchid 
left join report.ar_tem06 as c
on a.matchid = c.matchid 
left join report.ar_tem07 as d
on a.matchid = d.matchid
left join edw.dic_customer as e
on a.cdwcode = e.ccuscode and a.db = e.db
where a.cdwcode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

insert into report.fin_31_account_ori
select 
    a.matchid
    ,a.db
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
        end
    ,a.cdwcode
    ,case when e.ccuscode is null then "请核查"
        else e.bi_cuscode end as ccuscode 
    ,a.date_
    ,ifnull(round(b.balance_opening,4),0)
    ,ifnull(round(d.idamount_month,4),0)
    ,ifnull(round(b.balance_opening,4),0)+ifnull(round(d.idamount_month,4),0)-ifnull(round(c.balance_closing,4),0)
    ,ifnull(round(c.balance_closing,4),0)
from 
report.ar_tem08 as a 
left join report.ar_tem03 as b
on a.matchid = b.matchid 
left join report.ar_tem06 as c
on a.matchid = c.matchid 
left join report.ar_tem07 as d
on a.matchid = d.matchid
left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) as e
on a.cdwcode = e.ccuscode 
where a.cdwcode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");
