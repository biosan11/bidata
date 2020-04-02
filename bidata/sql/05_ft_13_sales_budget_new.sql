-- 4_ft_13_sales_budget_new
/*
CREATE TABLE `ft_13_sales_budget_new` (
  `cohr` varchar(30) NOT NULL COMMENT '公司',
  `areadirector` varchar(60) DEFAULT NULL,
  `cverifier` varchar(60) DEFAULT NULL,
  `true_ccuscode` varchar(30) NOT NULL COMMENT '正确客户编码',
  `true_item_code` varchar(60) NOT NULL COMMENT '项目编码',
  `cinvcode` varchar(30) DEFAULT NULL,
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

truncate table bidata.ft_13_sales_budget_new;
insert into bidata.ft_13_sales_budget_new
select 
    a.cohr
    ,b.areadirector
    ,b.cverifier
    ,ifnull(a.ccuscode,"unknowncus")
    ,ifnull(a.item_code,"其他")
    ,a.cinvcode
    ,ifnull(a.cbustype,"产品类")
    ,null as plan_class
    ,null as key_project
    ,1 as plan_cuccess_rate
    ,a.ddate
    ,null as iquantity_budget
    ,round(inum_person_new,2) as inum_budget 
    ,round(isum_budget_new/inum_person_new,2) as price 
    ,round((isum_budget_new/1000),2) as isum_budget 
from edw.x_sales_budget_20_new as a 
left join pdm.cusitem_person as b 
on a.ccuscode = b.ccuscode and a.item_code = b.item_code and a.cbustype = b.cbustype 
and a.ddate >= b.start_dt and a.ddate <= b.end_dt;
