------------------------------------程序头部----------------------------------------------
--功能：客户分摊比例计算，类似YTD；1月是1月销售比例，2月是1，2月销售合计比例
------------------------------------------------------------------------------------------
--程序名称：auxi_01_ccuscode_ytd_per.sql
--目标模型：auxi_01_ccuscode_ytd_per
--源    表：report.fin_11_sales_cost_base
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-02-26
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-02-26   开发上线
--调用方法　sh /home/bidata/report/python/ccus_02_market_price.sh
------------------------------------开始处理逻辑------------------------------------------


-- drop table if exists report.auxi_01_ccuscode_ytd_per;
-- create table if not exists report.auxi_01_ccuscode_ytd_per (
--   `year_` int(4) default null,
--   `month_` int(2) default null,
--   `ccuscode` varchar(60) default null,
--   `province` varchar(60) default null,
--   `sales_region` varchar(60) default null,
--   `sales_dept` varchar(60) default null,
--   `isum_ccuscode` float(14,6) default null,
--   `isum_province` float(14,6) default null,
--   `isum_salesregion` float(14,6) default null,
--   `isum_dept` float(14,6) default null,
--   `isum_allexcepthzbs` float(14,6) default null,
--   `isum_all` float(14,6) default null,
--   `per_province` float(14,6) default null,
--   `per_salesregion` float(14,6) default null,
--   `per_dept` float(14,6) default null,
--   `per_allexcepthzbs` float(14,6) default null,
--   `per_all` float(14,6) default null
-- ) engine=innodb default charset=utf8 comment '客户收入占比表，费用分摊用';

-- 先生成一份基础数据，根据是否杭州贝生，年、月、最终客户编码聚合
drop temporary table if exists report.ccuscode_per_tem00;
create temporary table if not exists report.ccuscode_per_tem00
select 
    year(ddate) as year_
    ,month(ddate) as month_
    ,case 
        when cohr = "杭州贝生" then "hzbs"
        else ccuscode
    end as ccuscode
    ,isum 
from report.fin_11_sales_cost_base;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_year (year_) ;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_month (month_) ;
alter table report.ccuscode_per_tem00 add index index_report_ccuscode_per_tem00_ccuscode (ccuscode) ;

-- 在这里进行处理
-- 倒叙插入12个月的计算
drop temporary table if exists report.ccuscode_per_tem01;
create temporary table if not exists report.ccuscode_per_tem01
select a.year_
      ,12 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 12
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,11 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 11
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,10 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 10
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,9 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 9
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,8 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 8
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,7 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 7
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,6 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 6
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,5 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 5
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,4 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 4
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,3 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 3
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,2 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 2
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

insert into report.ccuscode_per_tem01
select a.year_
      ,1 as month_
      ,case when a.ccuscode = "杭州贝生" then "hzbs" else a.ccuscode end as ccuscode 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.province end as province
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region end as sales_region 
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_dept end as sales_dept
      ,case when a.ccuscode = "杭州贝生" then "hzbs" when b.province is null then a.ccuscode else b.sales_region_new end as sales_region_new
      ,sum(a.isum) as isum 
  from report.ccuscode_per_tem00 as a 
  left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode 
 where year_ >=2018
   and month_ <= 1
 group by year_,a.ccuscode
having sum(a.isum) != 0 
;

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

-- 4.1、销售区域(新)总收入
drop temporary table if exists report.ccuscode_per_tem041;
create temporary table if not exists report.ccuscode_per_tem041
select 
    year_
    ,month_
    ,sales_region_new
    ,sum(isum) as isum
from report.ccuscode_per_tem01 
group by year_,month_,sales_region_new;


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
truncate report.auxi_01_ccuscode_ytd_per;
insert into report.auxi_01_ccuscode_ytd_per
select 
    a.year_
    ,a.month_
    ,a.ccuscode
    ,b.province
    ,c.sales_region
    ,g.sales_region_new
    ,d.sales_dept
    ,a.isum as isum_ccuscode
    ,b.isum as isum_province
    ,c.isum as isum_salesregion
    ,g.isum as isum_salesregionnew
    ,d.isum as isum_dept
    ,e.isum as isum_allexcepthzbs 
    ,f.isum as isum_all 
    ,round(a.isum/b.isum,6) as per_province
    ,round(a.isum/c.isum,6) as per_salesregion
    ,round(a.isum/g.isum,6) as per_salesregionnew
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
left join report.ccuscode_per_tem041 as g
on a.year_ = g.year_ and a.month_ = g.month_ and a.sales_region_new = g.sales_region_new
;


-- 删除大于当月的数据
delete from report.auxi_01_ccuscode_ytd_per where year_	= year(now()) and month_ > month(now());






