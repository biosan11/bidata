-- 01_auxi_01_ccuscode_per

/*
drop table if exists report.auxi_01_ccuscode_per;
create table if not exists report.auxi_01_ccuscode_per (
  `year_` int(4) default null,
  `month_` int(2) default null,
  `ccuscode` varchar(60) default null,
  `province` varchar(60) default null,
  `sales_region` varchar(60) default null,
  `sales_dept` varchar(60) default null,
  `isum_ccuscode` float(14,6) default null,
  `isum_province` float(14,6) default null,
  `isum_salesregion` float(14,6) default null,
  `isum_dept` float(14,6) default null,
  `isum_allexcepthzbs` float(14,6) default null,
  `isum_all` float(14,6) default null,
  `per_province` float(14,6) default null,
  `per_salesregion` float(14,6) default null,
  `per_dept` float(14,6) default null,
  `per_allexcepthzbs` float(14,6) default null,
  `per_all` float(14,6) default null
) engine=innodb default charset=utf8 comment '客户收入占比表，费用分摊用';
*/

-- 先生成一份基础数据，根据是否杭州贝生，年、月、最终客户编码聚合
drop temporary table if exists report.ccuscode_per_tem00;
create temporary table if not exists report.ccuscode_per_tem00
select 
    year(ddate) as year_
    ,month(ddate) as month_
    ,case 
        when cohr = "杭州贝生" then "hzbs"
        else finnal_ccuscode
    end as ccuscode
    ,isum 
from bidata.ft_11_sales;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_year (year_) ;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_month (month_) ;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_ccuscode (ccuscode) ;

drop temporary table if exists report.ccuscode_per_tem01;
create temporary table if not exists report.ccuscode_per_tem01
select 
    a.year_
    ,a.month_
    ,case 
        when a.ccuscode = "杭州贝生" then "hzbs"
        else a.ccuscode
    end as ccuscode 
    ,case 
        when a.ccuscode = "杭州贝生" then "hzbs"
        when b.province is null then a.ccuscode
        else b.province
	end as province
    ,case 
        when a.ccuscode = "杭州贝生" then "hzbs"
        when b.province is null then a.ccuscode
        else b.sales_region
	end as sales_region 
    ,case 
        when a.ccuscode = "杭州贝生" then "hzbs"
        when b.province is null then a.ccuscode
        else b.sales_dept
	end as sales_dept
    ,sum(a.isum) as isum 
from report.ccuscode_per_tem00 as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where year_ >=2018
group by year_,month_,a.ccuscode
having sum(a.isum) != 0 ;

-- 2.各上级省份总收入
drop temporary table if exists report.ccuscode_per_tem02;
create temporary table if not exists report.ccuscode_per_tem02
select 
    year_
    ,month_
    ,province 
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
group by year_,month_,province;

-- 3.各上级大区总收入
drop temporary table if exists report.ccuscode_per_tem03;
create temporary table if not exists report.ccuscode_per_tem03
select 
    year_
    ,month_
    ,sales_region 
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
group by year_,month_,sales_region;

-- 4.销售一部二部总收入
drop temporary table if exists report.ccuscode_per_tem04;
create temporary table if not exists report.ccuscode_per_tem04
select 
    year_
    ,month_
    ,sales_dept
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
group by year_,month_,sales_dept;

-- 5.不含杭州贝生的收入 
drop temporary table if exists report.ccuscode_per_tem05;
create temporary table if not exists report.ccuscode_per_tem05
select 
    year_
    ,month_
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
where province != "hzbs"
group by year_,month_;

-- 6.含杭州贝生的收入 
drop temporary table if exists report.ccuscode_per_tem06;
create temporary table if not exists report.ccuscode_per_tem06
select 
    year_
    ,month_
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
group by year_,month_;

-- 综合上方1、2、3、4、5、6 费用分摊用占比（以客户为基础单位）
truncate report.auxi_01_ccuscode_per;
insert into report.auxi_01_ccuscode_per
select 
    a.year_
    ,a.month_
    ,a.ccuscode
    ,b.province
    ,c.sales_region
    ,d.sales_dept
    ,a.isum as isum_ccuscode
    ,b.isum as isum_province
    ,c.isum as isum_salesregion
    ,d.isum as isum_dept
    ,e.isum as isum_allexcepthzbs 
    ,f.isum as isum_all 
    ,round(a.isum/b.isum,6) as per_province
    ,round(a.isum/c.isum,6) as per_salesregion
    ,round(a.isum/d.isum,6) as per_dept
    ,round(a.isum/e.isum,6) as per_allexcepthzbs
    ,round(a.isum/f.isum,6) as per_all
from report.ccuscode_per_tem01 as a 
left join report.ccuscode_per_tem02 as b 
on a.year_ = b.year_ and a.month_ = b.month_ and a.province = b.province 
left join report.ccuscode_per_tem03 as c 
on a.year_ = c.year_ and a.month_ = c.month_ and a.sales_region = c.sales_region
left join report.ccuscode_per_tem04 as d 
on a.year_ = d.year_ and a.month_ = d.month_ and a.sales_dept = d.sales_dept
left join report.ccuscode_per_tem05 as e
on a.year_ = e.year_ and a.month_ = e.month_
left join report.ccuscode_per_tem06 as f
on a.year_ = f.year_ and a.month_ = f.month_
;









