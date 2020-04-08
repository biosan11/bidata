-- 3_ft_12_sales_budget
/*  test
-- 建表 bidata.ft_12_sales_budget
use bidata;
drop table if exists ft_12_sales_budget;
create table `ft_12_sales_budget` (
    `cohr` varchar(30) not null comment '公司',
    `true_ccuscode` varchar(30) not null comment '正确客户编码',
    `true_item_code` varchar(60) not null comment '项目编码',
	`cinvcode` varchar(30) DEFAULT NULL COMMENT '产品编号',
    `business_class` varchar(20) default null comment '业务类型 ldt 产品 服务',
    `plan_class` varchar(20) default null comment '计划类型 占点 上量 投放',
    `key_project` varchar(20) comment '是否重点项目',
    `ddate` date not null comment '日期',
    `inum_budget` float(13,3) default null comment '计划发货量(人份数)',
    `price` float(13,3) default null comment '单价',
    `isum_budget` float(13,3) default null comment '计划收入',
    `isum_budget_pro` float(13,3) default null comment '计划收入_季度占比',
    `isum_budget_notax` float(13,3) default null comment '计划收入_无税金额',
    key `edw_x_sales_budget_index_true_ccuscode` (`true_ccuscode`),
    key `edw_x_sales_budget_index_true_item_code` (`true_item_code`)
) engine=innodb default charset=utf8 comment 'BI收入预算表（未调整）';
 */
 
-- ft_12_sales_budget  取18年预算部分字段
truncate table bidata.ft_12_sales_budget;
insert into bidata.ft_12_sales_budget
select 
   if(cohr= "博圣体系","博圣",cohr)
  ,ifnull(true_ccuscode,"unknowncus")
  ,ifnull(true_item_code,"其他")
  ,null
  ,ifnull(business_class,"产品类")
  ,plan_class
  ,key_project
  ,ddate
  ,round(inum_budget,3)
  ,round(price,3)
  ,round((isum_budget/1000),3) as isum_budget
  ,0
  ,0
  ,null
  ,null
from edw.x_sales_budget_18
where isum_budget != 0 or inum_budget != 0;

-- ft_12_sales_budget 取19年预算部分字段

insert into bidata.ft_12_sales_budget
select 
   if(cohr= "博圣体系","博圣",cohr)
	,ifnull(bi_cuscode,"unknowncus")
	,ifnull(item_code,"其他")
	,cinvcode
	,ifnull(cbustype,"产品类")
	,plan_class
	,key_project
	,ddate
    ,round(inum_person,3)
	,round(iunitcost,3)
	,round((isum_budget/1000),3) as isum_budget
    ,round(isum_budget_pro,3) as isum_budget_pro
    ,0
	,null
	,null
from edw.x_sales_budget_19
where isum_budget != 0 or inum_person != 0 or isum_budget_pro != 0;

-- ft_12_sales_budget 取20年预算部分字段，乘以成功率
insert into bidata.ft_12_sales_budget
select 
   if(cohr= "博圣体系","博圣",cohr)
	,ifnull(bi_cuscode,"unknowncus")
	,ifnull(item_code,"其他")
	,bi_cinvcode
	,ifnull(cbustype,"产品类")
	,plan_class
	,null
	,ddate
    ,round(inum_person,3)
	,round(iunitcost,3)
	,round((isum_budget/1000),3) as isum_budget
    ,0 as isum_budget_pro
    ,0
	,areadirector
	,cverifier
from edw.x_sales_budget_20
where isum_budget != 0 or inum_person != 0;


-- 更改加工不含税金额
-- 200407修改, 修改税率与不含税金额计算公式
update bidata.ft_12_sales_budget 
set isum_budget_notax = round(isum_budget-(isum_budget*0.13),4)
where business_class in("产品类","租赁类","服务类");

update bidata.ft_12_sales_budget 
set isum_budget_notax = round(isum_budget-(isum_budget*0.06),4)
where business_class = "ldt";

-- 20200408修改, 更新计划表中客户项目负责人
UPDATE bidata.ft_12_sales_budget a 
inner JOIN pdm.cusitem_person AS b 
ON a.true_ccuscode = b.ccuscode 
AND a.true_item_code= b.item_code 
AND a.business_class = b.cbustype 
AND (a.ddate BETWEEN b.start_dt AND b.end_dt)
SET a.areadirector = b.areadirector,
a.cverifier = b.cverifier;


