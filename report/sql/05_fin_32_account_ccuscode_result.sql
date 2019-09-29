-- 
-- 计算4个值 期初应收 本月新增应收 本月回款 期末应收 
drop temporary table if exists report.account_tem01;
create temporary table if not exists report.account_tem01 
select 
    a.ccuscode 
    ,a.date_
    ,year(a.date_) as year_
    ,month(a.date_) as month_
    ,sum(balance_opening) as balance_opening 
    ,sum(idamount_month) as idamount_month 
    ,sum(icamount_month) as icamount_month 
    ,sum(balance_closing) as balance_closing 
from report.fin_31_account_ori as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode
where b.province in ("浙江省","江苏省","安徽省","福建省","山东省","湖南省","湖北省","上海市")
and a.date_>="2018-01-01"
and db != "UFDATA_168_2019"
group by a.ccuscode,year(a.date_),month(a.date_);
alter table report.account_tem01 add index index_account_tem01_ccuscode (ccuscode);
alter table report.account_tem01 add index index_account_tem01_year (year_);
alter table report.account_tem01 add index index_account_tem01_month (month_);


-- 计算本月实际回款（回款组） 本月计划回款（回款组） 
drop temporary table if exists report.account_tem02;
create temporary table if not exists report.account_tem02 
select 
    a.true_ccuscode as ccuscode 
    ,a.ddate
    ,year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,sum(amount_act) as amount_act 
    ,sum(amount_plan) as amount_plan 
from edw.x_ar_plan as a 
left join edw.map_customer as b 
on a.true_ccuscode = b.bi_cuscode 
where b.province in ("浙江省","江苏省","安徽省","福建省","山东省","湖南省","湖北省","上海市")
and a.ddate>="2018-01-01"
group by a.true_ccuscode,year(a.ddate),month(a.ddate);
alter table report.account_tem02 add index index_account_tem02_ccuscode (ccuscode);
alter table report.account_tem02 add index index_account_tem02_year (year_);
alter table report.account_tem02 add index index_account_tem02_month (month_);

-- 计算周转天数用  
drop temporary table if exists report.account_tem03;
create temporary table if not exists report.account_tem03 
select 
    a.ccuscode 
    ,a.date_
    ,year(a.date_) as year_
    ,month(a.date_) as month_
    ,sum(balance_opening) as balance_opening 
    ,sum(idamount_month) as idamount_month 
    ,sum(icamount_month) as icamount_month 
    ,sum(balance_closing) as balance_closing 
from report.fin_31_account_ori as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode
where b.province in ("浙江省","江苏省","安徽省","福建省","山东省","湖南省","湖北省","上海市")
group by a.ccuscode,year(a.date_),month(a.date_);
alter table report.account_tem03 add index index_account_tem03_ccuscode (ccuscode);
alter table report.account_tem03 add index index_account_tem03_year (year_);
alter table report.account_tem03 add index index_account_tem03_month (month_);

-- 得到累计12个月合计值
drop temporary table if exists report.account_tem04;
create temporary table  if not exists report.account_tem04
select 
    a.ccuscode
    ,a.date_
    ,year(a.date_) as year_
    ,month(a.date_) as month_
    -- ,sum(b.balance_opening) as balance_opening 
    ,sum(b.idamount_month) as idamount_month_12 
    -- ,sum(b.icamount_month) as icamount_month 
    ,sum(b.balance_closing) as balance_closing_12 
    -- ,365*sum(b.balance_closing)/sum(b.idamount_month)/12 as turnover_days
from report.account_tem01 as a 
left join report.account_tem03 as b 
on a.ccuscode = b.ccuscode 
and b.date_ > date_add(a.date_,interval -12 month) and b.date_ <= a.date_
group by a.ccuscode,a.date_;
alter table report.account_tem04 add index index_account_tem04_ccuscode (ccuscode);
alter table report.account_tem04 add index index_account_tem04_year (year_);
alter table report.account_tem04 add index index_account_tem04_month (month_);


-- 组合以上表 输出结果数据1
truncate table report.fin_32_account_ccuscode_result;
insert into report.fin_32_account_ccuscode_result 
select 
    a.ccuscode 
    ,a.date_
    ,a.balance_opening 
    ,a.idamount_month 
    ,a.icamount_month 
    ,a.balance_closing 
    ,round(b.amount_act/1000,3) as amount_act
    ,round(b.amount_plan/1000,3) as amount_plan 
    ,c.idamount_month_12 
    ,c.balance_closing_12 
from report.account_tem01 as a 
left join report.account_tem02 as b 
on a.ccuscode = b.ccuscode and a.year_ = b.year_ and a.month_ = b.month_
left join report.account_tem04 as c 
on a.ccuscode = c.ccuscode and a.year_ = c.year_ and a.month_ = c.month_;
alter table report.fin_32_account_ccuscode_result comment '七省一市客户应收余额等';