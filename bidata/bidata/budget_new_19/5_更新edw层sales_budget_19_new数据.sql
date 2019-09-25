/*
-- 建表 edw.x_sales_budget_19_new
use edw;
drop table if exists edw.x_sales_budget_19_new;
create table if not exists edw.x_sales_budget_19_new(
	autoid int comment '自动编码',
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
	plan_complete_dt_recount date comment '计划完成时间（重新计算）',
	plan_success_rate float(4,2) comment '预计成功率',
	ddate date comment '日期',
	iquantity_budget float(13,3) comment '计划盒数',
	inum_person float(13,3) comment '计划数量',
	iunitcost float(13,3) comment '原币含税单价',
	isum_budget float(13,3) comment '计划收入',
	key _x_sales_budget_19_new_autoid (autoid),
	key _x_sales_budget_19_new_uniqueid (uniqueid),
	key _x_sales_budget_19_new_ccuscode (ccuscode),
	key _x_sales_budget_19_new_item_code (item_code),
	key _x_sales_budget_19_new_cinvcode (cinvcode)
)engine=innodb default charset=utf8 comment='19年预算表_new';
*/

-- 生成edw.x_sales_budget_19_new

truncate table edw.x_sales_budget_19_new;

-- 1901
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-01-01"
	,iquantity_budget_1901
	,inum_person_1901
	,iunitcost
	,isum_budget_1901
from ufdata.x_sales_budget_19_new;

-- 1902
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-02-01"
	,iquantity_budget_1902
	,inum_person_1902
	,iunitcost
	,isum_budget_1902
from ufdata.x_sales_budget_19_new;

-- 1903
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-03-01"
	,iquantity_budget_1903
	,inum_person_1903
	,iunitcost
	,isum_budget_1903
from ufdata.x_sales_budget_19_new;

-- 1904
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-04-01"
	,iquantity_budget_1904
	,inum_person_1904
	,iunitcost
	,isum_budget_1904
from ufdata.x_sales_budget_19_new;

-- 1905
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-05-01"
	,iquantity_budget_1905
	,inum_person_1905
	,iunitcost
	,isum_budget_1905
from ufdata.x_sales_budget_19_new;

-- 1906
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-06-01"
	,iquantity_budget_1906
	,inum_person_1906
	,iunitcost
	,isum_budget_1906
from ufdata.x_sales_budget_19_new;

-- 1907
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-07-01"
	,iquantity_budget_1907
	,inum_person_1907
	,iunitcost
	,isum_budget_1907
from ufdata.x_sales_budget_19_new;

-- 1908
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-08-01"
	,iquantity_budget_1908
	,inum_person_1908
	,iunitcost
	,isum_budget_1908
from ufdata.x_sales_budget_19_new;

-- 1909
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-09-01"
	,iquantity_budget_1909
	,inum_person_1909
	,iunitcost
	,isum_budget_1909
from ufdata.x_sales_budget_19_new;

-- 1910
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-10-01"
	,iquantity_budget_1910
	,inum_person_1910
	,iunitcost
	,isum_budget_1910
from ufdata.x_sales_budget_19_new;

-- 1911
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-11-01"
	,iquantity_budget_1911
	,inum_person_1911
	,iunitcost
	,isum_budget_1911
from ufdata.x_sales_budget_19_new;

-- 1912
insert into edw.x_sales_budget_19_new
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-12-01"
	,iquantity_budget_1912
	,inum_person_1912
	,iunitcost
	,isum_budget_1912
from ufdata.x_sales_budget_19_new;