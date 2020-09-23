
-- 说明: 2020-09-19更新
-- 这个脚本不更新第一层原有数据, 通过临时表更新 (安徽省NIPT数据取CRM填报检测量) 
-- 保留取关键有效字段, 看上去清爽

-- 安徽省NIPT2020年的检测量 取自CRM
drop temporary table if exists edw.x_ccus_delivery_tem0;
create temporary table if not exists edw.x_ccus_delivery_tem0
select
new_province
,new_city
,year_
,item_name
,sum(new_january) as month_1
,sum(new_february) as month_2
,sum(new_march) as month_3
,sum(new_april) as month_4
,sum(new_may) as month_5
,sum(new_june) as month_6
,sum(new_july) as month_7
,sum(new_august) as month_8
,sum(new_september) as month_9
,sum(new_october) as month_10
,sum(new_november) as month_11
,sum(new_december) as month_12
from edw.crm_sale_screenings
where new_province = '安徽省' and item_name ='NIPT' and year_ >= 2020
group by new_city,year_
;

-- 山东省 莱芜市 串联送样检测量 取自CRM
drop temporary table if exists edw.x_ccus_delivery_tem0_sd;
create temporary table if not exists edw.x_ccus_delivery_tem0_sd
select
	new_province
	,new_city
	,year_
	,item_name
	,sum(new_january) as month_1
	,sum(new_february) as month_2
	,sum(new_march) as month_3
	,sum(new_april) as month_4
	,sum(new_may) as month_5
	,sum(new_june) as month_6
	,sum(new_july) as month_7
	,sum(new_august) as month_8
	,sum(new_september) as month_9
	,sum(new_october) as month_10
	,sum(new_november) as month_11
	,sum(new_december) as month_12
	from edw.crm_sale_screenings
where new_province = '山东省' and new_city = '莱芜市' and item_name ='串联试剂' and year_ >= 2019
group by new_city,year_
;

-- 新建临时表抽取第一层 ufdata.x_ccus_delivery 相关字段并清洗
drop temporary table if exists edw.x_ccus_delivery_tem1;
create temporary table if not exists edw.x_ccus_delivery_tem1
select 
	a.province_get
	,a.city_get
	,a.hospital
	,a.city_give
	,a.item_name as item_name_old
	,case when c.item_code is null then '请核查' else c.item_code end  as item_code
	,case when c.level_three is null then '请核查' else c.level_three end  as item_name
	,a.year_
	,a.month_1,a.month_2,a.month_3,a.month_4,a.month_5,a.month_6
	,a.month_7,a.month_8,a.month_9,a.month_10,a.month_11,a.month_12
from ufdata.x_ccus_delivery a
left join (select * from edw.dic_customer group by ccusname) b
on a.hospital = b.ccusname
left join (select * from edw.map_inventory group by item_code) c
on a.item_name = c.level_three
left join (select * from edw.dic_customer group by ccusname) d
on a.collection_hospital = d.ccusname
;

-- 更新安徽省nipt数据, 来源取CRM 
update edw.x_ccus_delivery_tem1 as a
inner join edw.x_ccus_delivery_tem0 as b
on a.province_get = b.new_province and a.city_give = b.new_city and a.item_name = b.item_name and a.year_ = b.year_
set a.month_1 = b.month_1 ,a.month_2 = b.month_2 ,a.month_3 = b.month_3 ,a.month_4 = b.month_4 ,
      a.month_5 = b.month_5 ,a.month_6 = b.month_6 ,a.month_7 = b.month_7 ,a.month_8 = b.month_8,
      a.month_9 = b.month_9 ,a.month_10 = b.month_10 ,a.month_11 = b.month_11 ,a.month_12 = b.month_12
;

-- 更新山东省莱芜市串联试剂数据, 来源取CRM 
update edw.x_ccus_delivery_tem1 as a
inner join edw.x_ccus_delivery_tem0_sd as b
on a.province_get = b.new_province and a.city_give = b.new_city and a.item_name = b.item_name and a.year_ = b.year_
set a.month_1 = b.month_1 ,a.month_2 = b.month_2 ,a.month_3 = b.month_3 ,a.month_4 = b.month_4 ,
      a.month_5 = b.month_5 ,a.month_6 = b.month_6 ,a.month_7 = b.month_7 ,a.month_8 = b.month_8,
      a.month_9 = b.month_9 ,a.month_10 = b.month_10 ,a.month_11 = b.month_11 ,a.month_12 = b.month_12
;


-- 清空数据
truncate table edw.x_ccus_delivery_new;

-- 按月插入数据 
insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-01','-01') as ddate
	,month_1
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-02','-01') as ddate
	,month_2
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-03','-01') as ddate
	,month_3
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-04','-01') as ddate
	,month_4
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-05','-01') as ddate
	,month_5
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-06','-01') as ddate
	,month_6
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-07','-01') as ddate
	,month_7
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-08','-01') as ddate
	,month_8
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-09','-01') as ddate
	,month_9
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-10','-01') as ddate
	,month_10
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-11','-01') as ddate
	,month_11
from edw.x_ccus_delivery_tem1;

insert into edw.x_ccus_delivery_new
select 
	province_get
	,city_get
	,hospital
	,city_give
	,item_name as item_name_old
	,item_code 
	,item_name
	,concat(year_,'-12','-01') as ddate
	,month_12
from edw.x_ccus_delivery_tem1;
