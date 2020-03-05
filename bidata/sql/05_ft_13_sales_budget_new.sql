-- 4_ft_13_sales_budget_new
/*
-- 建表 bidata.ft_13_sales_budget_new
use bidata;
CREATE TABLE `ft_13_sales_budget_new` (
  `cohr` varchar(30) NOT NULL COMMENT '公司',
  `areadirector` varchar(60) DEFAULT NULL COMMENT '区域主管,
  `true_ccuscode` varchar(30) NOT NULL COMMENT '正确客户编码',
  `true_item_code` varchar(60) NOT NULL COMMENT '项目编码',
  `cinvcode` varchar(30) DEFAULT NULL COMMENT '存货编码,
  `business_class` varchar(20) DEFAULT NULL COMMENT '业务类型 ldt 产品 服务',
  `plan_class` varchar(20) DEFAULT NULL COMMENT '计划类型 占点 上量 投放',
  `key_project` varchar(20) DEFAULT NULL COMMENT '是否重点项目',
  `plan_success_rate` float(4,2) DEFAULT NULL COMMENT '预计成功率',
  `ddate` date NOT NULL COMMENT '日期',
  `iquantity_budget` float(13,3) DEFAULT NULL COMMENT '计划发货盒数',
  `inum_budget` float(13,3) DEFAULT NULL COMMENT '计划发货量(人份数)',
  `price` float(13,3) DEFAULT NULL COMMENT '单价',
  `isum_budget` float(13,3) DEFAULT NULL COMMENT '计划收入',
  KEY `edw_x_sales_budget_index_true_ccuscode` (`true_ccuscode`),
  KEY `edw_x_sales_budget_index_true_item_code` (`true_item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='BI预算收入表（调整后）';
 */
 
-- ft_13_sales_budget_new 取部分字段
truncate table bidata.ft_13_sales_budget_new;
insert into bidata.ft_13_sales_budget_new
select 
   cohr
    ,null
	,ifnull(true_ccuscode,"unknowncus")
	,ifnull(true_item_code,"其他")
	,null
	,ifnull(business_class,"产品类")
	,plan_class
	,key_project
    ,0
	,ddate
    ,0
	,round(inum_budget,2)
	,round(price,2)
	,round((isum_budget/1000),2) as isum_budget
from edw.x_sales_budget_18new
where isum_budget != 0 or inum_budget != 0;

insert into bidata.ft_13_sales_budget_new
select 
   cohr
    ,null
	,ifnull(ccuscode,"unknowncus")
	,ifnull(item_code,"其他")
	,cinvcode
	,ifnull(cbustype,"产品类")
	,plan_class
	,key_project
    ,plan_success_rate
	,ddate
    ,0
	,round(inum_person,2)
	,round(iunitcost,2)
	,round((isum_budget/1000),2) as isum_budget
from edw.x_sales_budget_19_new
where isum_budget != 0 or inum_person != 0;

insert into bidata.ft_13_sales_budget_new
select 
   cohr
    ,areadirector
	,ifnull(bi_cuscode,"unknowncus")
	,ifnull(item_code,"其他")
	,cinvcode
	,ifnull(cbustype,"产品类")
	,null
	,null
    ,1
	,ddate
    ,null
	,round(inum_person_new,2)
	,round(isum_budget_new/inum_person_new,2)
	,round((isum_budget_new/1000),2) as isum_budget
from edw.x_sales_budget_20_new
where isum_budget_new != 0 or inum_person_new != 0;
