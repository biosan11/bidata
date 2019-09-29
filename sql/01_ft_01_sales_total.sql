-- 1_ft_01_sales_total
/*
-- 建表 bidata.ft_01_sales_total
use bidata;
drop table if exists bidata.ft_01_sales_total;
create table if not exists bidata.ft_01_sales_total(
`level_one` varchar(60) not null comment '一级目录-产品线',
`month` tinyint not null comment '月份',
`isum_budget_19` float(13,3) default null comment '19年原计划',
`isum_budget_18` float(13,3) default null comment '18年原计划',
`isum_budget_18new` float(13,3) default null comment '18年新计划',
`isum_19` float(13,3) default null comment '19年实际收入',
`isum_18` float(13,3) default null comment '18年实际收入',
`isum_17` float(13,3) default null comment '17年实际收入',
`isum_16` float(13,3) default null comment '16年实际收入',
`isum_15` float(13,3) default null comment '15年实际收入',
`isum_14` float(13,3) default null comment '14年实际收入',
`isum_13` float(13,3) default null comment '13年实际收入',
`isum_12` float(13,3) default null comment '12年实际收入',
`isum_budget_19avg` float(13,3) default null comment '19年原计划avg',
`isum_budget_18avg` float(13,3) default null comment '18年原计划avg',
`isum_budget_18newavg` float(13,3) default null comment '18年新计划avg',
`isum_19avg` float(13,3) default null comment '19年实际收入avg',
`isum_18avg` float(13,3) default null comment '18年实际收入avg',
`isum_17avg` float(13,3) default null comment '17年实际收入avg',
`isum_16avg` float(13,3) default null comment '16年实际收入avg',
`isum_15avg` float(13,3) default null comment '15年实际收入avg',
`isum_14avg` float(13,3) default null comment '14年实际收入avg',
`isum_13avg` float(13,3) default null comment '13年实际收入avg',
`isum_12avg` float(13,3) default null comment '12年实际收入avg',
primary key (`level_one`,`month`)
) engine=innodb default charset=utf8 COMMENT='bi总体收入表（产品线年月）';
 */

use bidata;
-- level_one,month
drop temporary table if exists bidata.pre_001;
create temporary table if not exists bidata.pre_001(
`month` tinyint not null comment '月份');
insert into bidata.pre_001 values(1);
insert into bidata.pre_001 values(2);
insert into bidata.pre_001 values(3);
insert into bidata.pre_001 values(4);
insert into bidata.pre_001 values(5);
insert into bidata.pre_001 values(6);
insert into bidata.pre_001 values(7);
insert into bidata.pre_001 values(8);
insert into bidata.pre_001 values(9);
insert into bidata.pre_001 values(10);
insert into bidata.pre_001 values(11);
insert into bidata.pre_001 values(12);

drop temporary table if exists bidata.pre_002;
create temporary table if not exists bidata.pre_002
select 
	ifnull(b.level_one,"UNDECIDED") as level_one_
from 
	(select cinvcode,ddate from pdm.invoice_order group by cinvcode) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one_;

drop temporary table if exists bidata.pre_003;
create temporary table if not exists bidata.pre_003
select * from bidata.pre_002 left join bidata.pre_001 on 1 = 1;

-- 19年收入
drop temporary table if exists bidata.pre_19;
create temporary table if not exists bidata.pre_19
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_19) as isum_19 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_19) as isum_19 
from
	(select cinvcode ,ddate ,sum(isum) as isum_19 from pdm.invoice_order where year(ddate) = 2019 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 18年收入
drop temporary table if exists bidata.pre_18;
create temporary table if not exists bidata.pre_18
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_18) as isum_18 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_18) as isum_18 
from
	(select cinvcode ,ddate ,sum(isum) as isum_18 from pdm.invoice_order where year(ddate) = 2018 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 17年收入
drop temporary table if exists bidata.pre_17;
create temporary table if not exists bidata.pre_17
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_17) as isum_17 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_17) as isum_17 
from
	(select cinvcode ,ddate ,sum(isum) as isum_17 from pdm.invoice_order where year(ddate) = 2017 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 16年收入
drop temporary table if exists bidata.pre_16;
create temporary table if not exists bidata.pre_16
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_16) as isum_16 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_16) as isum_16 
from
	(select cinvcode ,ddate ,sum(isum) as isum_16 from pdm.invoice_order where year(ddate) = 2016 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 15年收入
drop temporary table if exists bidata.pre_15;
create temporary table if not exists bidata.pre_15
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_15) as isum_15 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_15) as isum_15 
from
	(select cinvcode ,ddate ,sum(isum) as isum_15 from pdm.invoice_order where year(ddate) = 2015 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 14年收入
drop temporary table if exists bidata.pre_14;
create temporary table if not exists bidata.pre_14
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_14) as isum_14 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_14) as isum_14 
from
	(select cinvcode ,ddate ,sum(isum) as isum_14 from pdm.invoice_order where year(ddate) = 2014 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 13年收入
drop temporary table if exists bidata.pre_13;
create temporary table if not exists bidata.pre_13
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_13) as isum_13 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_13) as isum_13 
from
	(select cinvcode ,ddate ,sum(isum) as isum_13 from pdm.invoice_order where year(ddate) = 2013 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 12年收入
drop temporary table if exists bidata.pre_12;
create temporary table if not exists bidata.pre_12
select 
	a.level_one as level_one
    ,a.`month` as month
    ,sum(a.isum_12) as isum_12 
from
(
select 
	ifnull(b.level_one,"UNDECIDED") as level_one
	,month(a.ddate) as `month`
	,sum(isum_12) as isum_12 
from
	(select cinvcode ,ddate ,sum(isum) as isum_12 from pdm.invoice_order where year(ddate) = 2012 group by cinvcode,ddate) as a
	left join edw.map_inventory as b
	on a.cinvcode = b.bi_cinvcode
group by level_one,`month`
) as a
group by a.level_one,a.`month`
;

-- 18年原计划
drop temporary table if exists bidata.pre_budget_18;
create temporary table if not exists bidata.pre_budget_18
select 
ifnull(b.level_one,"UNDECIDED") as level_one 
,a.month
,sum(a.isum_budget_18) as isum_budget_18
from 
	(
	select 
	true_item_code
	,month(ddate) as `month`
	,sum(isum_budget) as isum_budget_18 
	from edw.x_sales_budget_18 where year(ddate) = 2018 group by true_item_code,ddate
	) as a
left join edw.map_item as b
	on a.true_item_code = b.item_code
group by b.level_one,a.month;

-- 19年原计划
drop temporary table if exists bidata.pre_budget_19;
create temporary table if not exists bidata.pre_budget_19
select 
ifnull(b.level_one,"UNDECIDED") as level_one 
,a.month
,sum(a.isum_budget_19) as isum_budget_19
from 
	(
	select 
	item_code
	,month(ddate) as `month`
	,sum(isum_budget) as isum_budget_19 
	from edw.x_sales_budget_19 where year(ddate) = 2019 group by item_code,ddate
	) as a
left join edw.map_item as b
	on a.item_code = b.item_code
group by b.level_one,a.month;

-- 18年新计划
drop temporary table if exists bidata.pre_budget_18new;
create temporary table if not exists bidata.pre_budget_18new
select 
ifnull(b.level_one,"UNDECIDED") as level_one 
,a.month
,sum(a.isum_budget_18) as isum_budget_18new
from 
	(
	select 
	true_item_code
	,month(ddate) as `month`
	,sum(isum_budget) as isum_budget_18
	from edw.x_sales_budget_18new group by true_item_code,ddate
	) as a
left join edw.map_item as b
	on a.true_item_code = b.item_code
group by b.level_one,a.month;


-- insert into bidata.ft_01_sales_total
truncate table bidata.ft_01_sales_total;
insert into bidata.ft_01_sales_total (level_one,month,isum_budget_19,isum_budget_18,isum_budget_18new,isum_19,isum_18,isum_17,isum_16,isum_15,isum_14,isum_13,isum_12)
select
	a.level_one_ as level_one
	,a.month as month
	,round((l.isum_budget_19/1000),2)
    ,round((i.isum_budget_18/1000),2)
    ,round((j.isum_budget_18new/1000),2)
	,round((k.isum_19/1000),2)
	,round((b.isum_18/1000),2)
	,round((c.isum_17/1000),2)
	,round((d.isum_16/1000),2)
	,round((e.isum_15/1000),2)
	,round((f.isum_14/1000),2)
	,round((g.isum_13/1000),2)
	,round((h.isum_12/1000),2)
from bidata.pre_003 as a
left join bidata.pre_19 as k
	on a.level_one_ = k.level_one and a.month = k.month
left join bidata.pre_18 as b
	on a.level_one_ = b.level_one and a.month = b.month 
left join bidata.pre_17 as c
	on a.level_one_ = c.level_one and a.month = c.month
left join bidata.pre_16 as d
	on a.level_one_ = d.level_one and a.month = d.month
left join bidata.pre_15 as e
	on a.level_one_ = e.level_one and a.month = e.month
left join bidata.pre_14 as f
	on a.level_one_ = f.level_one and a.month = f.month
left join bidata.pre_13 as g
	on a.level_one_ = g.level_one and a.month = g.month
left join bidata.pre_12 as h
	on a.level_one_ = h.level_one and a.month = h.month
left join bidata.pre_budget_18 as i
	on a.level_one_ = i.level_one and a.month = i.month
left join bidata.pre_budget_18new as j
	on a.level_one_ = j.level_one and a.month = j.month
left join bidata.pre_budget_19 as l
	on a.level_one_ = l.level_one and a.month = l.month
;

-- 将0替换为空
update bidata.ft_01_sales_total set isum_budget_19 = null where isum_budget_19 = 0;
update bidata.ft_01_sales_total set isum_budget_18 = null where isum_budget_18 = 0;
update bidata.ft_01_sales_total set isum_budget_18new = null where isum_budget_18new = 0;



-- 插入平均数
insert into bidata.ft_01_sales_total
select 
level_one
,14
,round(avg(isum_budget_19),2)
,round(avg(isum_budget_18),2)
,round(avg(isum_budget_18new),2)
,null as isum_19
,round(avg(isum_18),2)
,round(avg(isum_17),2)
,round(avg(isum_16),2)
,round(avg(isum_15),2)
,round(avg(isum_14),2)
,round(avg(isum_13),2)
,round(avg(isum_12),2)
,round(avg(isum_budget_19),2)
,round(avg(isum_budget_18),2)
,round(avg(isum_budget_18new),2)
,null as isum_19
,round(avg(isum_18),2)
,round(avg(isum_17),2)
,round(avg(isum_16),2)
,round(avg(isum_15),2)
,round(avg(isum_14),2)
,round(avg(isum_13),2)
,round(avg(isum_12),2)
from bidata.ft_01_sales_total group by level_one;

-- 修改isum_19 平均数
update bidata.ft_01_sales_total as a 
inner join
(
	select 
		level_one
		,sum(isum_19)
		,count(month)
		,sum(isum_19) / count(isum_19) as `avg`
	from bidata.ft_01_sales_total 
	where month <= (select max(month)-1 from bidata.ft_01_sales_total where isum_19 >0 and month <=12)
	group by level_one
) as b
on a.level_one = b.level_one
set 
a.isum_19 = b.avg 
,a.isum_19avg = b.avg
where a.month = 14;



/*
-- 修改isum_18 平均数
update bidata.ft_01_sales_total as a 
inner join
(
	select 
		level_one
		,sum(isum_18)
		,count(month)
		,sum(isum_18) / count(isum_18) as `avg`
	from bidata.ft_01_sales_total 
	where month <= (select max(month)-1 from bidata.ft_01_sales_total where isum_18 >0 and month <=12)
	group by level_one
) as b
on a.level_one = b.level_one
set 
a.isum_18 = b.avg 
,a.isum_18avg = b.avg
where a.month = 14;
*/

delete from bidata.ft_01_sales_total where level_one = "健康检测";