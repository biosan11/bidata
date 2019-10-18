-- 

-- 声明日期变量 
set @dt = "2019-03-31";

-- 取ft_51_ar 生成应收账龄明细
-- 对单据日期 分区 做出账龄
drop temporary table if exists report.ar_tem00;
create temporary table if not exists report.ar_tem00
select 
    @dt as date_
    ,ar_ap
    ,db
    ,dvouchdate
    ,case 
        when @dt<=date_add(dvouchdate,interval +30  day) then "0-30"
        when @dt<=date_add(dvouchdate,interval +60  day) then "31-60"
        when @dt<=date_add(dvouchdate,interval +90  day) then "61-90"
        when @dt<=date_add(dvouchdate,interval +180 day) then "91-180"
        when @dt<=date_add(dvouchdate,interval +270 day) then "181-270"
        when @dt<=date_add(dvouchdate,interval +365 day) then "271-365"
        when @dt> date_add(dvouchdate,interval +365 day) then "365以上"
        else "qita" end as account_age
    ,dvouchdate2
    ,cdwcode
    ,ar_class 
    ,idamount
    ,icamount
from bidata.ft_51_ar
where db != "UFDATA_666_2018" and ar_class != "健康检测";
alter table report.ar_tem00 add index index_ar_tem00_ar_ap (ar_ap);
alter table report.ar_tem00 add index index_ar_tem00_db (db);

-- 临时表1    bidata.ft_51_ar 取ar idamount求和
drop temporary table if exists report.ar_tem01;
create temporary table if not exists report.ar_tem01
select 
    concat(db,cdwcode,account_age,ar_class) as matchid
    ,db
    ,cdwcode
    ,account_age
    ,ar_class
    ,@dt as date_
    ,sum(idamount) as idamount
from report.ar_tem00
where ar_ap = "ar"
and dvouchdate <= @dt
and dvouchdate2 <= @dt
group by db,cdwcode,account_age,ar_class;
alter table report.ar_tem01 add index index_ar_tem01_matchid (matchid);

-- 临时表2    bidata.ft_51_ar 取ap icamount求和
drop temporary table if exists report.ar_tem02;
create temporary table if not exists report.ar_tem02 
select 
    concat(db,cdwcode,account_age,ar_class) as matchid
    ,db
    ,cdwcode
    ,account_age
    ,ar_class
    ,@dt as date_
    ,-1*sum(icamount) as icamount
from report.ar_tem00
where ar_ap = "ap"
and dvouchdate <= @dt
and dvouchdate2 <= @dt
group by db,cdwcode,account_age,ar_class;
alter table report.ar_tem02 add index index_ar_tem02_matchid (matchid);

-- 临时表3    组合临时表1与临时表2    得到期末应收余额
drop temporary table if exists report.ar_tem03;
create temporary table if not exists report.ar_tem03
select 
    c.matchid
    ,c.db
    ,c.cdwcode 
    ,c.account_age
    ,c.ar_class
    ,c.date_
    ,ifnull(sum(c.idamount),0) as balance_closing
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

-- 输出数据
drop table if exists report.financial_account_detail;
create table if not exists report.financial_account_detail 
select 
    a.db
    ,a.cdwcode
    ,case when e.ccuscode is null then "请核查"
        else e.bi_cuscode end as ccuscode 
    ,b.bi_cusname
    ,b.sales_region
    ,b.province
    ,a.account_age
    ,a.ar_class
    ,a.date_
    ,ifnull(round(a.balance_closing,4),0) as balance_closing
from report.ar_tem03 as a
left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) as e
on a.cdwcode = e.ccuscode
left join edw.map_customer as b 
on e.bi_cuscode = b.bi_cuscode;

-- 输出数据2 6月账龄以上数据，

-- 客户总应收
drop temporary table if exists report.ar_tem04;
create temporary table if not exists report.ar_tem04
select 
    ccuscode
    ,ar_class 
    ,date_
    ,sum(balance_closing) as balance_closing
from report.financial_account_detail 
group by ccuscode,ar_class,date_;

-- 6月账龄以上应收
drop temporary table if exists report.ar_tem05;
create temporary table if not exists report.ar_tem05
select 
    ccuscode
    ,ar_class
    ,date_
    ,sum(balance_closing) as balance_closing_6month
from report.financial_account_detail
where account_age in ("181-270", "271-365", "365以上")
group by ccuscode,ar_class,date_;

drop table if exists report.financial_account_6month;
create table if not exists report.financial_account_6month
select 
    b.bi_cusname
    ,null
    ,a.balance_closing
    ,a.ar_class
    ,c.balance_closing_6month
    ,b.province
    ,a.date_
    ,a.ccuscode
from report.ar_tem04 as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode
left join report.ar_tem05 as c 
on a.ccuscode = c.ccuscode and a.ar_class = c.ar_class and a.date_ = c.date_
where c.balance_closing_6month >1 
order by c.balance_closing_6month desc ;

