/*
功能：
文件路径：
依赖表：
1. 
2. 
*/

/*
-- 建表
use ufdata;
drop table if exists ufdata.x_sales_budget_19_new;
create table if not exists ufdata.x_sales_budget_19_new (
	autoid int primary key auto_increment comment '自动编码',
	cohr varchar(30) comment '公司',
	uniqueid varchar(100) comment '唯一编码',
	type varchar(20) comment '客户类型',
	sales_region varchar(20) comment '销售大区',
	province varchar(60) comment '省份',
	city varchar(60) comment '地级市',
	ccuscode varchar(20) comment '客户编码',
	ccusname varchar(120) comment '客户名称',
	screen_class varchar(20) comment '筛查诊断分类',
	cbustype varchar(60) comment '业务类型',
	equipment varchar(20) comment '是否设备',
	level_one varchar(60) comment '一级目录（产品线）',
	level_two varchar(255) comment '二级目录（产品组）',
	item_code varchar(60) comment '项目明细编码',
	level_three varchar(60) comment '三级目录（项目明细）',
	cinvcode varchar(60) comment '存货编码',
	cinvname varchar(255) comment '存货名称',
	plan_class varchar(20) comment '计划类型',
	key_project varchar(20) comment '重点项目（是/否）',
	plan_complete_dt date comment '计划完成时间',
	plan_success_rate float(4,2) comment '预计成功率',
	iunitcost float(13,3) comment '原币含税单价',
	iquantity_budget_1901 float(13,3) comment '计划发货盒数_1月',
	iquantity_budget_1902 float(13,3) comment '计划发货盒数_2月',
	iquantity_budget_1903 float(13,3) comment '计划发货盒数_3月',
	iquantity_budget_1904 float(13,3) comment '计划发货盒数_4月',
	iquantity_budget_1905 float(13,3) comment '计划发货盒数_5月',
	iquantity_budget_1906 float(13,3) comment '计划发货盒数_6月',
	iquantity_budget_1907 float(13,3) comment '计划发货盒数_7月',
	iquantity_budget_1908 float(13,3) comment '计划发货盒数_8月',
	iquantity_budget_1909 float(13,3) comment '计划发货盒数_9月',
	iquantity_budget_1910 float(13,3) comment '计划发货盒数_10月',
	iquantity_budget_1911 float(13,3) comment '计划发货盒数_11月',
	iquantity_budget_1912 float(13,3) comment '计划发货盒数_12月',
	inum_person_1901 float(13,3) comment '计划发货人份数_1月',
	inum_person_1902 float(13,3) comment '计划发货人份数_2月',
	inum_person_1903 float(13,3) comment '计划发货人份数_3月',
	inum_person_1904 float(13,3) comment '计划发货人份数_4月',
	inum_person_1905 float(13,3) comment '计划发货人份数_5月',
	inum_person_1906 float(13,3) comment '计划发货人份数_6月',
	inum_person_1907 float(13,3) comment '计划发货人份数_7月',
	inum_person_1908 float(13,3) comment '计划发货人份数_8月',
	inum_person_1909 float(13,3) comment '计划发货人份数_9月',
	inum_person_1910 float(13,3) comment '计划发货人份数_10月',
	inum_person_1911 float(13,3) comment '计划发货人份数_11月',
	inum_person_1912 float(13,3) comment '计划发货人份数_12月',
	inum_person_addup_19 float(13,3) comment '销量合计',
	isum_budget_addup_19 float(13,3) comment '销售额合计',
	isum_budget_1901 float(13,3) comment '计划收入1月',
	isum_budget_1902 float(13,3) comment '计划收入2月',
	isum_budget_1903 float(13,3) comment '计划收入3月',
	isum_budget_1904 float(13,3) comment '计划收入4月',
	isum_budget_1905 float(13,3) comment '计划收入5月',
	isum_budget_1906 float(13,3) comment '计划收入6月',
	isum_budget_1907 float(13,3) comment '计划收入7月',
	isum_budget_1908 float(13,3) comment '计划收入8月',
	isum_budget_1909 float(13,3) comment '计划收入9月',
	isum_budget_1910 float(13,3) comment '计划收入10月',
	isum_budget_1911 float(13,3) comment '计划收入11月',
	isum_budget_1912 float(13,3) comment '计划收入12月',
	comment varchar(255) comment '备注',
	key ufdata_x_sales_budget_19_autoid (autoid),
	key ufdata_x_sales_budget_19_uniqueid (uniqueid),
	key ufdata_x_sales_budget_19_ccuscode (ccuscode),
	key ufdata_x_sales_budget_19_item_code (item_code),
	key ufdata_x_sales_budget_19_cinvcode (cinvcode)
) engine=innodb default charset=utf8 comment='19年预算表_更新后';

use bidata;
drop table if exists bidata.sales_budget_adjust;
create table if not exists bidata.sales_budget_adjust (

*/

-- 1. 建临时表bidata.salesbudget_tem01 提取客户+项目信息（全）：发票列表(2019)+出库列表(2019)+19年原预算+19年调整后预算
drop temporary table if exists bidata.salesbudget_tem01;
create temporary table if not exists bidata.salesbudget_tem01
select finnal_ccuscode as ccuscode,cinvcode 
from pdm.invoice_order 
where isum != 0
and year(ddate) = 2019
and cohr != "杭州贝生"
union 
select finnal_ccuscode as ccuscode,cinvcode
from pdm.outdepot_order
where iquantity != 0
and year(ddate) = 2019
and cohr != "杭州贝生"
union 
select ccuscode,cinvcode
from ufdata.x_sales_budget_19
where (isum_budget_addup_19 != 0 or inum_person_addup_19 != 0 ) and cohr != "杭州贝生"
union 
select ccuscode,cinvcode
from ufdata.x_sales_budget_19_new
where cohr != "杭州贝生";

alter table bidata.salesbudget_tem01 add index index_salesbudget_tem01_ccuscode (ccuscode);
alter table bidata.salesbudget_tem01 add index index_salesbudget_tem01_cinvcode (cinvcode);

-- 2.1 建临时表bidata.salesbudget_tem02_ 提取19年1-12月实际收入
drop temporary table if exists bidata.salesbudget_tem02_;
create temporary table if not exists bidata.salesbudget_tem02_
select 
ddate
,year(ddate) as year_
,month(ddate) as month_
,finnal_ccuscode as ccuscode
,cinvcode
,isum
from pdm.invoice_order 
where year(ddate) in (2018,2019)
and cohr != "杭州贝生"
and isum != 0;
-- 2.2 建临时表bidata.salesbudget_tem02 将上表数据按ccuscode,cinvcode 分组，并且列取2018-2019 1-12月
drop temporary table if exists bidata.salesbudget_tem02;
create temporary table if not exists bidata.salesbudget_tem02
select
ccuscode 
,cinvcode
,sum(if(year_ = 2018 and month_ = 1,isum,0)) as isum_2018_1
,sum(if(year_ = 2018 and month_ = 2,isum,0)) as isum_2018_2
,sum(if(year_ = 2018 and month_ = 3,isum,0)) as isum_2018_3
,sum(if(year_ = 2018 and month_ = 4,isum,0)) as isum_2018_4
,sum(if(year_ = 2018 and month_ = 5,isum,0)) as isum_2018_5
,sum(if(year_ = 2018 and month_ = 6,isum,0)) as isum_2018_6
,sum(if(year_ = 2018 and month_ = 7,isum,0)) as isum_2018_7
,sum(if(year_ = 2018 and month_ = 8,isum,0)) as isum_2018_8
,sum(if(year_ = 2018 and month_ = 9,isum,0)) as isum_2018_9
,sum(if(year_ = 2018 and month_ = 10,isum,0)) as isum_2018_10
,sum(if(year_ = 2018 and month_ = 11,isum,0)) as isum_2018_11
,sum(if(year_ = 2018 and month_ = 12,isum,0)) as isum_2018_12
,sum(if(year_ = 2019 and month_ = 1,isum,0)) as isum_2019_1
,sum(if(year_ = 2019 and month_ = 2,isum,0)) as isum_2019_2
,sum(if(year_ = 2019 and month_ = 3,isum,0)) as isum_2019_3
,sum(if(year_ = 2019 and month_ = 4,isum,0)) as isum_2019_4
,sum(if(year_ = 2019 and month_ = 5,isum,0)) as isum_2019_5
,sum(if(year_ = 2019 and month_ = 6,isum,0)) as isum_2019_6
,sum(if(year_ = 2019 and month_ = 7,isum,0)) as isum_2019_7
,sum(if(year_ = 2019 and month_ = 8,isum,0)) as isum_2019_8
,sum(if(year_ = 2019 and month_ = 9,isum,0)) as isum_2019_9
,sum(if(year_ = 2019 and month_ = 10,isum,0)) as isum_2019_10
,sum(if(year_ = 2019 and month_ = 11,isum,0)) as isum_2019_11
,sum(if(year_ = 2019 and month_ = 12,isum,0)) as isum_2019_12
from bidata.salesbudget_tem02_
group by ccuscode,cinvcode;
alter table bidata.salesbudget_tem02 add index index_salesbudget_tem02_ccuscode (ccuscode);
alter table bidata.salesbudget_tem02 add index index_salesbudget_tem02_cinvcode (cinvcode);

-- 3.1 建临时表bidata.salesbudget_tem03_ 提取19年1-12月实际发货
drop temporary table if exists bidata.salesbudget_tem03_;
create temporary table if not exists bidata.salesbudget_tem03_
select 
ddate
,year(ddate) as year_
,month(ddate) as month_
,finnal_ccuscode as ccuscode
,cinvcode
,inum_person
from pdm.outdepot_order
where year(ddate) in (2018,2019)
and cohr != "杭州贝生"
and inum_person != 0;
-- 3.2 建临时表bidata.salesbudget_tem03 将上表数据按ccuscode,cinvcode 分组，并且列取1-12月
drop temporary table if exists bidata.salesbudget_tem03;
create temporary table if not exists bidata.salesbudget_tem03
select
ccuscode 
,cinvcode
,sum(if(year_ = 2018 and month_ = 1,inum_person,0)) as inum_person_2018_1
,sum(if(year_ = 2018 and month_ = 2,inum_person,0)) as inum_person_2018_2
,sum(if(year_ = 2018 and month_ = 3,inum_person,0)) as inum_person_2018_3
,sum(if(year_ = 2018 and month_ = 4,inum_person,0)) as inum_person_2018_4
,sum(if(year_ = 2018 and month_ = 5,inum_person,0)) as inum_person_2018_5
,sum(if(year_ = 2018 and month_ = 6,inum_person,0)) as inum_person_2018_6
,sum(if(year_ = 2018 and month_ = 7,inum_person,0)) as inum_person_2018_7
,sum(if(year_ = 2018 and month_ = 8,inum_person,0)) as inum_person_2018_8
,sum(if(year_ = 2018 and month_ = 9,inum_person,0)) as inum_person_2018_9
,sum(if(year_ = 2018 and month_ = 10,inum_person,0)) as inum_person_2018_10
,sum(if(year_ = 2018 and month_ = 11,inum_person,0)) as inum_person_2018_11
,sum(if(year_ = 2018 and month_ = 12,inum_person,0)) as inum_person_2018_12
,sum(if(year_ = 2019 and month_ = 1,inum_person,0)) as inum_person_2019_1
,sum(if(year_ = 2019 and month_ = 2,inum_person,0)) as inum_person_2019_2
,sum(if(year_ = 2019 and month_ = 3,inum_person,0)) as inum_person_2019_3
,sum(if(year_ = 2019 and month_ = 4,inum_person,0)) as inum_person_2019_4
,sum(if(year_ = 2019 and month_ = 5,inum_person,0)) as inum_person_2019_5
,sum(if(year_ = 2019 and month_ = 6,inum_person,0)) as inum_person_2019_6
,sum(if(year_ = 2019 and month_ = 7,inum_person,0)) as inum_person_2019_7
,sum(if(year_ = 2019 and month_ = 8,inum_person,0)) as inum_person_2019_8
,sum(if(year_ = 2019 and month_ = 9,inum_person,0)) as inum_person_2019_9
,sum(if(year_ = 2019 and month_ = 10,inum_person,0)) as inum_person_2019_10
,sum(if(year_ = 2019 and month_ = 11,inum_person,0)) as inum_person_2019_11
,sum(if(year_ = 2019 and month_ = 12,inum_person,0)) as inum_person_2019_12
from bidata.salesbudget_tem03_
group by ccuscode,cinvcode;
alter table bidata.salesbudget_tem03 add index index_salesbudget_tem03_ccuscode (ccuscode);
alter table bidata.salesbudget_tem03 add index index_salesbudget_tem03_cinvcode (cinvcode);


-- 4. 建临时表bidata.salesbudget_tem04 提取19年原计划数据
drop temporary table if exists bidata.salesbudget_tem04;
create temporary table if not exists bidata.salesbudget_tem04
select 
ccuscode
,cinvcode 
,screen_class
,plan_class
,key_project
,iunitcost
,sum(inum_person_1901) as old_inum_person_1901
,sum(inum_person_1902) as old_inum_person_1902
,sum(inum_person_1903) as old_inum_person_1903
,sum(inum_person_1904) as old_inum_person_1904
,sum(inum_person_1905) as old_inum_person_1905
,sum(inum_person_1906) as old_inum_person_1906
,sum(inum_person_1907) as old_inum_person_1907
,sum(inum_person_1908) as old_inum_person_1908
,sum(inum_person_1909) as old_inum_person_1909
,sum(inum_person_1910) as old_inum_person_1910
,sum(inum_person_1911) as old_inum_person_1911
,sum(inum_person_1912) as old_inum_person_1912
,sum(inum_person_addup_19) as old_inum_person_19ttl
,sum(isum_budget_1901) as old_isum_budget_1901
,sum(isum_budget_1902) as old_isum_budget_1902
,sum(isum_budget_1903) as old_isum_budget_1903
,sum(isum_budget_1904) as old_isum_budget_1904
,sum(isum_budget_1905) as old_isum_budget_1905
,sum(isum_budget_1906) as old_isum_budget_1906
,sum(isum_budget_1907) as old_isum_budget_1907
,sum(isum_budget_1908) as old_isum_budget_1908
,sum(isum_budget_1909) as old_isum_budget_1909
,sum(isum_budget_1910) as old_isum_budget_1910
,sum(isum_budget_1911) as old_isum_budget_1911
,sum(isum_budget_1912) as old_isum_budget_1912
,sum(isum_budget_addup_19) as old_isum_budget_19ttl
from ufdata.x_sales_budget_19 
where cohr != "杭州贝生"
group by ccuscode,cinvcode;
alter table bidata.salesbudget_tem04 add index index_salesbudget_tem04_ccuscode (ccuscode);
alter table bidata.salesbudget_tem04 add index index_salesbudget_tem04_cinvcode (cinvcode);




-- 5.建临时表bidata.salesbudget_tem05 提取19年调整后计划数据
drop temporary table if exists bidata.salesbudget_tem05;
create temporary table if not exists bidata.salesbudget_tem05
select 
autoid
,ccuscode
,cinvcode 
,sum(inum_person_1901) as new_inum_person_1901
,sum(inum_person_1902) as new_inum_person_1902
,sum(inum_person_1903) as new_inum_person_1903
,sum(inum_person_1904) as new_inum_person_1904
,sum(inum_person_1905) as new_inum_person_1905
,sum(inum_person_1906) as new_inum_person_1906
,sum(inum_person_1907) as new_inum_person_1907
,sum(inum_person_1908) as new_inum_person_1908
,sum(inum_person_1909) as new_inum_person_1909
,sum(inum_person_1910) as new_inum_person_1910
,sum(inum_person_1911) as new_inum_person_1911
,sum(inum_person_1912) as new_inum_person_1912
,sum(inum_person_addup_19) as new_inum_person_19ttl
,sum(isum_budget_1901) as new_isum_budget_1901
,sum(isum_budget_1902) as new_isum_budget_1902
,sum(isum_budget_1903) as new_isum_budget_1903
,sum(isum_budget_1904) as new_isum_budget_1904
,sum(isum_budget_1905) as new_isum_budget_1905
,sum(isum_budget_1906) as new_isum_budget_1906
,sum(isum_budget_1907) as new_isum_budget_1907
,sum(isum_budget_1908) as new_isum_budget_1908
,sum(isum_budget_1909) as new_isum_budget_1909
,sum(isum_budget_1910) as new_isum_budget_1910
,sum(isum_budget_1911) as new_isum_budget_1911
,sum(isum_budget_1912) as new_isum_budget_1912
,sum(isum_budget_addup_19) as new_isum_budget_19ttl
from ufdata.x_sales_budget_19_new 
where cohr = '博圣体系'
group by ccuscode,cinvcode;
alter table bidata.salesbudget_tem05 add index index_salesbudget_tem05_ccuscode (ccuscode);
alter table bidata.salesbudget_tem05 add index index_salesbudget_tem05_cinvcode (cinvcode);

-- 6.2016,2017年整年收入数据
drop temporary table if exists bidata.salesbudget_tem06;
create temporary table if not exists bidata.salesbudget_tem06
select 
ddate
,year(ddate) as year_
,finnal_ccuscode as ccuscode
,cinvcode
,sum(if(year(ddate)=2016,isum,0)) as isum_2016_ttl
,sum(if(year(ddate)=2017,isum,0)) as isum_2017_ttl
from pdm.invoice_order
where year(ddate) in(2016,2017)
and cohr != "杭州贝生"
group by finnal_ccuscode,cinvcode;
alter table bidata.salesbudget_tem06 add index index_salesbudget_tem06_ccuscode (ccuscode);
alter table bidata.salesbudget_tem06 add index index_salesbudget_tem06_cinvcode (cinvcode);

-- 7 2016,2017年整年发货数据
drop temporary table if exists bidata.salesbudget_tem07;
create temporary table if not exists bidata.salesbudget_tem07
select 
ddate
,year(ddate) as year_
,finnal_ccuscode as ccuscode
,cinvcode
,sum(if(year(ddate)=2016,inum_person,0)) as inum_person_2016_ttl
,sum(if(year(ddate)=2017,inum_person,0)) as inum_person_2017_ttl
from pdm.outdepot_order
where year(ddate) in(2016,2017)
and cohr != "杭州贝生"
group by finnal_ccuscode,cinvcode;
alter table bidata.salesbudget_tem07 add index index_salesbudget_tem07_ccuscode (ccuscode);
alter table bidata.salesbudget_tem07 add index index_salesbudget_tem07_cinvcode (cinvcode);


-- n. 建临时表bidata.salesbudget_tem 综合合并以上数据
drop temporary table if exists bidata.salesbudget_tem;
create temporary table if not exists bidata.salesbudget_tem
select 
	e.autoid
	,a.ccuscode
	,a.cinvcode
	,d.screen_class
	,d.plan_class
	,d.key_project
	,d.iunitcost
	,b.isum_2018_1
	,b.isum_2018_2
	,b.isum_2018_3
	,b.isum_2018_4
	,b.isum_2018_5
	,b.isum_2018_6
	,b.isum_2018_7
	,b.isum_2018_8
	,b.isum_2018_9
	,b.isum_2018_10
	,b.isum_2018_11
	,b.isum_2018_12
	,b.isum_2018_1+b.isum_2018_2+b.isum_2018_3+b.isum_2018_4+b.isum_2018_5+b.isum_2018_6+
		b.isum_2018_7+b.isum_2018_8+b.isum_2018_9+b.isum_2018_10+b.isum_2018_11+b.isum_2018_12 
		as isum_2018_ttl
	,b.isum_2019_1
	,b.isum_2019_2
	,b.isum_2019_3
	,b.isum_2019_4
	,b.isum_2019_5
	,b.isum_2019_6
	,b.isum_2019_7
	,b.isum_2019_8
	,b.isum_2019_9
	,b.isum_2019_10
	,b.isum_2019_11
	,b.isum_2019_12
	,b.isum_2019_1+b.isum_2019_2+b.isum_2019_3+b.isum_2019_4+b.isum_2019_5+b.isum_2019_6+
		b.isum_2019_7+b.isum_2019_8+b.isum_2019_9+b.isum_2019_10+b.isum_2019_11+b.isum_2019_12 
		as isum_2019_ttl
	,c.inum_person_2018_1
	,c.inum_person_2018_2
	,c.inum_person_2018_3
	,c.inum_person_2018_4
	,c.inum_person_2018_5
	,c.inum_person_2018_6
	,c.inum_person_2018_7
	,c.inum_person_2018_8
	,c.inum_person_2018_9
	,c.inum_person_2018_10
	,c.inum_person_2018_11
	,c.inum_person_2018_12
	,c.inum_person_2018_1+c.inum_person_2018_2+c.inum_person_2018_3+c.inum_person_2018_4+c.inum_person_2018_5+c.inum_person_2018_6+
		c.inum_person_2018_7+c.inum_person_2018_8+c.inum_person_2018_9+c.inum_person_2018_10+c.inum_person_2018_11+c.inum_person_2018_12
		as iquantity_2018_ttl
	,c.inum_person_2019_1
	,c.inum_person_2019_2
	,c.inum_person_2019_3
	,c.inum_person_2019_4
	,c.inum_person_2019_5
	,c.inum_person_2019_6
	,c.inum_person_2019_7
	,c.inum_person_2019_8
	,c.inum_person_2019_9
	,c.inum_person_2019_10
	,c.inum_person_2019_11
	,c.inum_person_2019_12
	,c.inum_person_2019_1+c.inum_person_2019_2+c.inum_person_2019_3+c.inum_person_2019_4+c.inum_person_2019_5+c.inum_person_2019_6+
		c.inum_person_2019_7+c.inum_person_2019_8+c.inum_person_2019_9+c.inum_person_2019_10+c.inum_person_2019_11+c.inum_person_2019_12
		as iquantity_2019_ttl
	,d.old_inum_person_1901
	,d.old_inum_person_1902
	,d.old_inum_person_1903
	,d.old_inum_person_1904
	,d.old_inum_person_1905
	,d.old_inum_person_1906
	,d.old_inum_person_1907
	,d.old_inum_person_1908
	,d.old_inum_person_1909
	,d.old_inum_person_1910
	,d.old_inum_person_1911
	,d.old_inum_person_1912
	,d.old_inum_person_19ttl 
	,d.old_isum_budget_1901
	,d.old_isum_budget_1902
	,d.old_isum_budget_1903
	,d.old_isum_budget_1904
	,d.old_isum_budget_1905
	,d.old_isum_budget_1906
	,d.old_isum_budget_1907
	,d.old_isum_budget_1908
	,d.old_isum_budget_1909
	,d.old_isum_budget_1910
	,d.old_isum_budget_1911
	,d.old_isum_budget_1912
	,d.old_isum_budget_19ttl
	,e.new_inum_person_1901
	,e.new_inum_person_1902
	,e.new_inum_person_1903
	,e.new_inum_person_1904
	,e.new_inum_person_1905
	,e.new_inum_person_1906
	,e.new_inum_person_1907
	,e.new_inum_person_1908
	,e.new_inum_person_1909
	,e.new_inum_person_1910
	,e.new_inum_person_1911
	,e.new_inum_person_1912
	,e.new_inum_person_19ttl
	,e.new_isum_budget_1901
	,e.new_isum_budget_1902
	,e.new_isum_budget_1903
	,e.new_isum_budget_1904
	,e.new_isum_budget_1905
	,e.new_isum_budget_1906
	,e.new_isum_budget_1907
	,e.new_isum_budget_1908
	,e.new_isum_budget_1909
	,e.new_isum_budget_1910
	,e.new_isum_budget_1911
	,e.new_isum_budget_1912
	,e.new_isum_budget_19ttl
	,f.isum_2016_ttl
	,f.isum_2017_ttl
	,g.inum_person_2016_ttl
	,g.inum_person_2017_ttl
from bidata.salesbudget_tem01 as a 
left join bidata.salesbudget_tem02 as b
on a.ccuscode = b.ccuscode and a.cinvcode = b.cinvcode
left join bidata.salesbudget_tem03 as c
on a.ccuscode = c.ccuscode and a.cinvcode = c.cinvcode
left join bidata.salesbudget_tem04 as d
on a.ccuscode = d.ccuscode and a.cinvcode = d.cinvcode
left join bidata.salesbudget_tem05 as e
on a.ccuscode = e.ccuscode and a.cinvcode = e.cinvcode
left join bidata.salesbudget_tem06 as f
on a.ccuscode = f.ccuscode and a.cinvcode = f.cinvcode
left join bidata.salesbudget_tem07 as g
on a.ccuscode = g.ccuscode and a.cinvcode = g.cinvcode;
alter table bidata.salesbudget_tem add index index_salesbudget_tem_ccuscode (ccuscode);
alter table bidata.salesbudget_tem add index index_salesbudget_tem_cinvcode (cinvcode);

-- 导入正式表
drop table if exists bidata.sales_budget_adjust_tem;
create table if not exists bidata.sales_budget_adjust_tem
select
e.p_charge
,b.sales_region
,b.province
,b.city
,b.bi_cusname
,c.bi_cinvname
,c.specification_type
,c.inum_unit_person
,c.item_code
,c.level_one
,d.item_key
,c.level_three
,d.equipment
,c.business_class
,a.*
from bidata.salesbudget_tem as a
left join edw.map_customer as b
on a.ccuscode = b.bi_cuscode
left join edw.map_inventory as c
on a.cinvcode = c.bi_cinvcode
left join edw.map_item as d
on c.item_code = d.item_code
left join edw.map_cusitem_person as e
on a.ccuscode = e.ccuscode and c.item_code = e.item_code and c.business_class = e.cbustype;

-- 新增单价，来源每月收上来的新计划单价
update bidata.sales_budget_adjust_tem as a
left join ufdata.sales_budget_19_new_price as b
on a.ccuscode = b.ccuscode and a.cinvcode = b.cinvcode 
set a.iunitcost = b.iunitcost
where a.iunitcost is null;



drop table if exists bidata.sales_budget_adjust;
create table if not exists bidata.sales_budget_adjust
select 
	case
		when province = "湖北省" then 1
		when province = "湖南省" then 1
		when province = "浙江省" then 1
		when province = "江苏省" then 1
		when province = "山东省" then 1
		when province = "安徽省" then 1
		when province = "福建省" then 1
		when province = "上海市" then 1
		else 0
	end as province_
	,p_charge
	,sales_region
	,province
    ,city
	,bi_cusname
	,level_three
	,bi_cinvname
	,iunitcost
	,business_class
	,screen_class
	,equipment
	,level_one
	,item_key
	,plan_class
	,ccuscode
	,item_code
	,cinvcode
	,isum_2018_ttl
	,isum_2019_ttl
	,old_isum_budget_19ttl
    ,inum_person_2018_1
    ,inum_person_2019_1
    ,old_inum_person_1901
    ,new_inum_person_1901
    ,iunitcost*old_inum_person_1901 as isum_old_iquantity_1901
    ,iunitcost*new_inum_person_1901 as isum_new_iquantity_1901
    ,isum_2018_1
    ,isum_2019_1
    ,old_isum_budget_1901
    ,new_isum_budget_1901
    ,inum_person_2018_2
    ,inum_person_2019_2
    ,old_inum_person_1902
    ,new_inum_person_1902
    ,iunitcost*old_inum_person_1902 as isum_old_iquantity_1902
    ,iunitcost*new_inum_person_1902 as isum_new_iquantity_1902
    ,isum_2018_2
    ,isum_2019_2
    ,old_isum_budget_1902
    ,new_isum_budget_1902
    ,inum_person_2018_3
    ,inum_person_2019_3
    ,old_inum_person_1903
    ,new_inum_person_1903
    ,iunitcost*old_inum_person_1903 as isum_old_iquantity_1903
    ,iunitcost*new_inum_person_1903 as isum_new_iquantity_1903
    ,isum_2018_3
    ,isum_2019_3
    ,old_isum_budget_1903
    ,new_isum_budget_1903
    ,inum_person_2018_4
    ,inum_person_2019_4
    ,old_inum_person_1904
    ,new_inum_person_1904
    ,iunitcost*old_inum_person_1904 as isum_old_iquantity_1904
    ,iunitcost*new_inum_person_1904 as isum_new_iquantity_1904
    ,isum_2018_4
    ,isum_2019_4
    ,old_isum_budget_1904
    ,new_isum_budget_1904
    ,inum_person_2018_5
    ,inum_person_2019_5
    ,old_inum_person_1905
    ,new_inum_person_1905
    ,iunitcost*old_inum_person_1905 as isum_old_iquantity_1905
    ,iunitcost*new_inum_person_1905 as isum_new_iquantity_1905
    ,isum_2018_5
    ,isum_2019_5
    ,old_isum_budget_1905
    ,new_isum_budget_1905
    ,inum_person_2018_6
    ,inum_person_2019_6
    ,old_inum_person_1906
    ,new_inum_person_1906
    ,iunitcost*old_inum_person_1906 as isum_old_iquantity_1906
    ,iunitcost*new_inum_person_1906 as isum_new_iquantity_1906
    ,isum_2018_6
    ,isum_2019_6
    ,old_isum_budget_1906
    ,new_isum_budget_1906
    ,inum_person_2018_7
    ,inum_person_2019_7
    ,old_inum_person_1907
    ,new_inum_person_1907
    ,iunitcost*old_inum_person_1907 as isum_old_iquantity_1907
    ,iunitcost*new_inum_person_1907 as isum_new_iquantity_1907
    ,isum_2018_7
    ,isum_2019_7
    ,old_isum_budget_1907
    ,new_isum_budget_1907
    ,inum_person_2018_8
    ,inum_person_2019_8
    ,old_inum_person_1908
    ,new_inum_person_1908
    ,iunitcost*old_inum_person_1908 as isum_old_iquantity_1908
    ,iunitcost*new_inum_person_1908 as isum_new_iquantity_1908
    ,isum_2018_8
    ,isum_2019_8
    ,old_isum_budget_1908
    ,new_isum_budget_1908
    ,inum_person_2018_9
    ,inum_person_2019_9
    ,old_inum_person_1909
    ,new_inum_person_1909
    ,iunitcost*old_inum_person_1909 as isum_old_iquantity_1909
    ,iunitcost*new_inum_person_1909 as isum_new_iquantity_1909
    ,isum_2018_9
    ,isum_2019_9
    ,old_isum_budget_1909
    ,new_isum_budget_1909
    ,inum_person_2018_10
    ,inum_person_2019_10
    ,old_inum_person_1910
    ,new_inum_person_1910
    ,iunitcost*old_inum_person_1910 as isum_old_iquantity_1910
    ,iunitcost*new_inum_person_1910 as isum_new_iquantity_1910
    ,isum_2018_10
    ,isum_2019_10
    ,old_isum_budget_1910
    ,new_isum_budget_1910
    ,inum_person_2018_11
    ,inum_person_2019_11
    ,old_inum_person_1911
    ,new_inum_person_1911
    ,iunitcost*old_inum_person_1911 as isum_old_iquantity_1911
    ,iunitcost*new_inum_person_1911 as isum_new_iquantity_1911
    ,isum_2018_11
    ,isum_2019_11
    ,old_isum_budget_1911
    ,new_isum_budget_1911
    ,inum_person_2018_12
    ,inum_person_2019_12
    ,old_inum_person_1912
    ,new_inum_person_1912
    ,iunitcost*old_inum_person_1912 as isum_old_iquantity_1912
    ,iunitcost*new_inum_person_1912 as isum_new_iquantity_1912
    ,isum_2018_12
    ,isum_2019_12
    ,old_isum_budget_1912
    ,new_isum_budget_1912
from bidata.sales_budget_adjust_tem
order by sales_region,province,city,bi_cusname,level_one,item_key,level_three;


-- 删除健康检测部分
delete from bidata.sales_budget_adjust where item_code = "jk0101";

