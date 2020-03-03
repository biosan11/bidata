-- 12_dt_14_inventory
/*
-- 建表 bidata.dt_14_inventory
use bidata;
drop table if exists dt_14_inventory;
create table if not exists `dt_14_inventory` (
  `bi_cinvcode` varchar(30) NOT NULL COMMENT '产品标准编码',
  `bi_cinvname` varchar(120) DEFAULT NULL COMMENT '产品标准名称',
  `cinvname_help` varchar(120) DEFAULT NULL COMMENT '产品辅助名称',
  `item_code` varchar(60) NOT NULL COMMENT '项目编码',
  `level_three` varchar(60) DEFAULT NULL COMMENT '三级目录-项目',
  `level_two` varchar(60) DEFAULT NULL COMMENT '二级目录-产品组',
  `level_one` varchar(60) DEFAULT NULL COMMENT '一级目录-产品线',
  `business_class` varchar(10) DEFAULT NULL COMMENT '业务类型',
  `specification_type` varchar(120) DEFAULT NULL COMMENT '规格型号',
  `inum_budget` decimal(30,10) DEFAULT NULL COMMENT '人份',
  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
  `425_item` varchar(120) DEFAULT NULL COMMENT '425项目分类',
  `cinv_key_2020` varchar(120) DEFAULT NULL COMMENT '2020新品要品',
  PRIMARY KEY (`bi_cinvcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='BI产品维度表';

*/
truncate table bidata.dt_14_inventory;
insert into bidata.dt_14_inventory 
select 
    bi_cinvcode
    ,bi_cinvname
    ,cinvname_help
    ,item_code
    ,level_three
    ,level_two
    ,level_one
    ,business_class
    ,specification_type
    ,inum_unit_person
	,cinvbrand
	,425_item
	,cinv_key_2020
from edw.map_inventory;
