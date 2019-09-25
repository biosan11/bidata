-- 01_auxi_01_province_per

/*
drop table if exists report.auxi_01_province_per;
create table if not exists report.auxi_01_province_per (
  `year_` int(4) default null,
  `month_` int(2) default null,
  `province_` varchar(60) default null,
  `sales_region` varchar(60) default null,
  `isum_province` double(20,3) default null,
  `isum_salesregion` double(20,3) default null,
  `per_salesregion` double(23,6) default null,
  `isum_dept` double(20,3) default null,
  `per_dept` double(23,6) default null,
  `isum_allexcepthzbs` double(20,3) default null,
  `per_allexcepthzbs` double(23,6) default null,
  `isum_all` double(20,3) default null,
  `per_all` double(23,6) default null
) engine=innodb default charset=utf8 comment '省份收入占比表，费用分摊用'
*/
drop temporary table if exists report.fin_prov_tem01;
create temporary table if not exists report.fin_prov_tem01
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,case 
		when a.cohr = "杭州贝生" then "杭州贝生"
        when b.province is null then a.finnal_ccuscode
        else b.province
	end as province_
    ,case 
		when a.cohr = "杭州贝生" then "杭州贝生"
        when b.province is null then a.finnal_ccuscode
        else b.sales_region
	end as sales_region
    ,case 
		when a.cohr = "杭州贝生" then "杭州贝生"
        when b.province is null then a.finnal_ccuscode
        else b.sales_dept
	end as sales_dept
    ,sum(a.isum) as isum 
from bidata.ft_11_sales as a 
left join edw.map_customer as b 
on a.finnal_ccuscode = b.bi_cuscode 
where year(a.ddate) >=2018
group by year_,month_,province_
having sum(a.isum) != 0 ;

-- 2.各上级大区总收入
drop temporary table if exists report.fin_prov_tem02;
create temporary table if not exists report.fin_prov_tem02
select 
    year_
    ,month_
    ,sales_region 
    ,sum(isum) as isum
from report.fin_prov_tem01 
group by year_,month_,sales_region;

-- 3.销售一部二部总收入
drop temporary table if exists report.fin_prov_tem03;
create temporary table if not exists report.fin_prov_tem03
select 
    year_
    ,month_
    ,sales_dept
    ,sum(isum) as isum
from report.fin_prov_tem01 
group by year_,month_,sales_dept;

-- 4.不含杭州贝生的收入 
drop temporary table if exists report.fin_prov_tem04;
create temporary table if not exists report.fin_prov_tem04
select 
    year_
    ,month_
    ,sum(isum) as isum
from report.fin_prov_tem01 
where province_ != "杭州贝生"
group by year_,month_;

-- 5.含杭州贝生的收入 
drop temporary table if exists report.fin_prov_tem05;
create temporary table if not exists report.fin_prov_tem05
select 
    year_
    ,month_
    ,sum(isum) as isum
from report.fin_prov_tem01 
group by year_,month_;


-- 综合上方1、2、3、4、5 费用分摊用占比（以省份为基础单位）
truncate report.auxi_01_province_per;
insert into report.auxi_01_province_per
select 
    a.year_
    ,a.month_
    ,a.province_
    ,a.sales_region 
    ,a.isum as isum_province
    ,b.isum as isum_salesregion
    ,round(a.isum/b.isum,6) as per_salesregion
    ,c.isum as isum_dept
    ,round(a.isum/c.isum,6) as per_dept
    ,d.isum as isum_allexcepthzbs
    ,round(a.isum/d.isum,6) as per_allexcepthzbs
    ,e.isum as isum_all
    ,round(a.isum/e.isum,6) as per_all
from report.fin_prov_tem01 as a 
left join report.fin_prov_tem02 as b 
on a.year_ = b.year_ and a.month_ = b.month_ and a.sales_region = b.sales_region 
left join report.fin_prov_tem03 as c 
on a.year_ = c.year_ and a.month_ = c.month_ and a.sales_dept = c.sales_dept
left join report.fin_prov_tem04 as d 
on a.year_ = d.year_ and a.month_ = d.month_
left join report.fin_prov_tem05 as e
on a.year_ = e.year_ and a.month_ = e.month_;