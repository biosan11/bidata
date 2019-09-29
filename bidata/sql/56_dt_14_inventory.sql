-- 12_dt_14_inventory
/*
-- 建表 bidata.dt_14_inventory
use bidata;
drop table if exists dt_14_inventory;
create table if not exists `dt_14_inventory` (
  `bi_cinvcode` varchar(30) not null comment '产品标准编码',
  `bi_cinvname` varchar(120) default null comment '产品标准名称',
  `cinvname_help` varchar(120) default null comment '产品辅助名称',
  `item_code` varchar(60) not null comment '项目编码',
  `level_three` varchar(60) default null comment '三级目录-项目',
  `level_two` varchar(60) default null comment '二级目录-产品组',
  `level_one` varchar(60) default null comment '一级目录-产品线',
  `business_class` varchar(10) default null comment '业务类型',
  `specification_type` varchar(120) default null comment '规格型号',
  `inum_budget` decimal(30,10) default null comment '人份',
  primary key (`bi_cinvcode`)
) engine=innodb default charset=utf8 comment 'BI产品维度表';

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
from edw.map_inventory;