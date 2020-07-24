
-- edw.x_data_tables

truncate table tracking.x_data_tables;
insert into tracking.x_data_tables(data_module,data_content,dept_provide,person_provide,freq,timeliness,day,comment,address_table,db,comment_2)
select * from ufdata.x_data_tables;

-- 获取各数据最新日期

-- x_sales_bk 
drop temporary table if exists tracking.tables_tem00;
create temporary table if not exists tracking.tables_tem00
select 
	db
	,comment
	,max(ddate) as date_new
from ufdata.x_sales_bk 
group by db,comment;

update tracking.x_data_tables as a 
inner join tracking.tables_tem00 as b 
on a.db = b.db and a.comment_2 = b.comment 
set a.date_new = b.date_new;

-- x_ldt_list
drop temporary table if exists tracking.tables_tem01;
create temporary table if not exists tracking.tables_tem01
select 
	max(ddate) as date_new
from ufdata.x_ldt_list
;

drop temporary table if exists tracking.tables_tem02;
create temporary table if not exists tracking.tables_tem02
select 
	'未确认版' as if_comfirm
	,max(ddate) as date_new
from ufdata.x_ldt_list
where comment != '确认版';

update tracking.x_data_tables as a 
inner join tracking.tables_tem01 as b 
set a.date_new = b.date_new, a.if_comfirm = '确认版'
where a.address_table = 'ufdata.x_ldt_lsit'
;

update tracking.x_data_tables as a 
inner join tracking.tables_tem02 as b 
on a.date_new = b.date_new
set a.if_comfirm = b.if_comfirm
where a.address_table = 'ufdata.x_ldt_lsit'
;

-- x_sales_hzbs 
drop temporary table if exists tracking.tables_tem03;
create temporary table if not exists tracking.tables_tem03
select 
	max(ddate) as date_new
from ufdata.x_sales_hzbs 
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem03 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_sales_hzbs'
;

-- x_sales_budget_20_new
drop temporary table if exists tracking.tables_tem04;
create temporary table if not exists tracking.tables_tem04
select 
	max(ddate) as date_new
from ufdata.x_sales_budget_20_new 
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem04 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_sales_budget_20_new'
;

-- ufdata.x_cusitem_person_20
drop temporary table if exists tracking.tables_tem05;
create temporary table if not exists tracking.tables_tem05
select 
	max(comfirm_dt) as date_new
from ufdata.x_cusitem_person_20
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem05 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_cusitem_person_20'
;

-- ufdata.x_eq_depreciation_20
drop temporary table if exists tracking.tables_tem06;
create temporary table if not exists tracking.tables_tem06
select 
	max(ddate) as date_new
from edw.x_eq_depreciation_20
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem06 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_eq_depreciation_20'
;

-- ufdata.x_insure_cover
drop temporary table if exists tracking.tables_tem07;
create temporary table if not exists tracking.tables_tem07
select 
	max(ddate) as date_new
from ufdata.x_insure_cover
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem07 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_insure_cover'
;

-- ufdata.x_insure_indemnity
drop temporary table if exists tracking.tables_tem08;
create temporary table if not exists tracking.tables_tem08
select 
	max(report_date) as date_new
from ufdata.x_insure_indemnity
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem08 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_insure_indemnity'
;

-- ufdata.x_account_fy
drop temporary table if exists tracking.tables_tem09;
create temporary table if not exists tracking.tables_tem09
select 
	max(dbill_date) as date_new
from ufdata.x_account_fy
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem09 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_account_fy'
;


-- ufdata.x_account_fy
drop temporary table if exists tracking.tables_tem10_;
create temporary table if not exists tracking.tables_tem10_
select 
	str_to_date(concat(left(y_mon,4),'-',right(y_mon,2),'-01'),'%Y-%m-%d') as ddate
from edw.x_account_sy
;
drop temporary table if exists tracking.tables_tem10;
create temporary table if not exists tracking.tables_tem10
select 
	max(ddate) as date_new
from tracking.tables_tem10_
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem10 as b 
set a.date_new = b.date_new
where a.address_table = 'ufdata.x_account_sy'
;

-- ufdata.x_ar_plan
drop temporary table if exists tracking.tables_tem11;
create temporary table if not exists tracking.tables_tem11
select 
	max(ddate) as date_new
from ufdata.x_ar_plan
;

drop temporary table if exists tracking.tables_tem11_;
create temporary table if not exists tracking.tables_tem11_
select 
	'最新只有计划' as if_comfirm
	,max(ddate) as date_new
from ufdata.x_ar_plan
where comment != '计划'
;

update tracking.x_data_tables as a 
inner join tracking.tables_tem11 as b 
set a.date_new = b.date_new, a.if_comfirm = "计划与实际"
where a.address_table = 'ufdata.x_ar_plan'
;
update tracking.x_data_tables as a 
inner join tracking.tables_tem11_ as b 
on a.date_new = b.date_new
set a.if_comfirm = b.if_comfirm
where a.address_table = 'ufdata.x_ar_plan'
;



