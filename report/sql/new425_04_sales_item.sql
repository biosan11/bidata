
-- report.new425_04_sales_item

-- 处理425项目的销售数据 从2018年开始取数

-- 1. 先生成没有经过集中送样处理的 以省份 地级市为单位的 销售基础数据 
drop table if exists report.new425_04_sales_item;
create table if not exists report.new425_04_sales_item(
	sales_dept varchar(60) comment'销售部门',
	sales_region_new varchar(60) comment'销售区域',
	province varchar(60) comment '省份',
	city varchar(90) comment'地级市',
	item_code varchar(60) comment'项目编码',
	item_name varchar(60) comment'项目名称',
	425_item varchar(60) comment'425项目名称',
	year_ smallint comment'年份',
	month_ smallint comment'月份',
	isum decimal(18,4) comment'销售额',
	mark_delivery varchar(20) comment'集中送样处理标记'
)engine=innodb default charset=utf8 comment='425项目省份地级市';

-- 先生成基础数据 来源 pdm.invoice_order 并且把finnal_ccuscode = multi的处理掉
drop temporary table if exists report.new425_04_sales_item_tem00;
create temporary table if not exists report.new425_04_sales_item_tem00
select 
	cohr
	,ddate
	,if(finnal_ccuscode = 'mulit', ccuscode,finnal_ccuscode) as ccuscode 
	,cinvcode
	,isum
from pdm.invoice_order 
where year(ddate) >= 2018 and item_code != 'JK0101';
alter table report.new425_04_sales_item_tem00 add index(ccuscode),add index(cinvcode);

-- 为了核对数据方便, 这里取所有的数据, 杭州贝生 将sales_dept写为 杭州贝生 
insert into report.new425_04_sales_item
select 
	case 
		when a.cohr = '杭州贝生' then '杭州贝生'
		else b.sales_dept 
	end as sales_dept 
	,b.sales_region_new
	,b.province
	,b.city
	,c.item_code
	,c.level_three as item_name 
	,c.425_item 
	,year(a.ddate) as year_ 
	,month(a.ddate) as month_ 
	,round(sum(a.isum),4) as isum 
	,'原始' as mark_delivery
from report.new425_04_sales_item_tem00 as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
group by a.cohr,b.sales_dept,b.sales_region_new,b.city,c.item_code,c.425_item,year(a.ddate),month(a.ddate);

-- 插入各月份 分摊数据的结果 来源 report.new425_03_delivery_ytd
-- 送样地级市加销售额 
insert into report.new425_04_sales_item
select 
	b.sales_dept 
	,b.sales_region_new
	,b.province
	,a.city_give 
	,a.item_code 
	,a.item_name
	,c.`425_item`
	,a.year_
	,a.month_ 
	,round(a.isum_fentan,4)
	,'送样地市加销售额' as mark_delivery
from report.new425_03_delivery_ytd as a 
left join (select sales_dept,sales_region_new,province,city from edw.map_customer where sales_dept in ('销售一部','销售二部') group by city) as b 
on a.city_give = b.city 
left join (select item_code,`425_item`  from edw.map_inventory where business_class != '租赁类' group by item_code ) as c -- 已经检查, 只有租赁类存在同一项目编码对应不同425项目
on a.item_code = c.item_code
where isum_fentan is not null and isum_fentan != 0;

-- 收样地级市 减销售额 
insert into report.new425_04_sales_item
select 
	b.sales_dept 
	,b.sales_region_new
	,b.province
	,a.city_get
	,a.item_code 
	,a.item_name
	,c.`425_item`
	,a.year_
	,a.month_ 
	,round(a.isum_fentan * -1 ,4)
	,'收样地市减销售额' as mark_delivery
from report.new425_03_delivery_ytd as a 
left join (select sales_dept,sales_region_new,province,city from edw.map_customer where sales_dept in ('销售一部','销售二部') group by city) as b 
on a.city_get = b.city 
left join (select item_code,`425_item`  from edw.map_inventory where business_class != '租赁类' group by item_code ) as c -- 已经检查, 只有租赁类存在同一项目编码对应不同425项目
on a.item_code = c.item_code
where isum_fentan is not null and isum_fentan != 0;
















