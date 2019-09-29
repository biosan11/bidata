-- 11_dt_13_item
/*
-- 建表 bidata.dt_13_item
use bidata;
drop table if exists dt_13_item;
create table if not exists `dt_13_item` (
  `item_code` varchar(60) not null comment '项目编码',
  `level_three` varchar(60) default null comment '三级目录-项目',
  `level_two` varchar(60) default null comment '二级目录-产品组',
  `level_one` varchar(60) default null comment '一级目录-产品线',
  `equipment` varchar(60) default null comment '是否设备',
  `screen_class` varchar(60) default null comment '筛查诊断分类',
  `tn_class` varchar(60) default null comment '3+n类',  
  `item_key` varchar(60) default null comment '重点项目', 
  `item_im` varchar(60) default null comment '主要项目',   
  `nsieve` varchar(60) default null comment '新筛',
  `screen` varchar(60) default null comment '产筛',
  `medical` varchar(60) default null comment '产诊', 
  `analysis` varchar(20) default null comment '分析用',
  `level_one_sort` smallint comment '产线排序',
  `item_key_sort` smallint comment '重点项目（产品）排序',
    primary key (`item_code`)
 ) engine=innodb default charset=utf8 comment 'BI项目维度表';
*/

-- 2.1 bi_item取数据
truncate table bidata.dt_13_item;
insert into bidata.dt_13_item
select 
*
,null
,case 
    when level_one = "产前" then 1
    when level_one = "新生儿" then 2
    when level_one = "服务类" then 3
    else 4 
    end as level_one_sort
,case 
    when item_key = "血清学筛查" then 1
    when item_key = "常规新筛" then 2
    when item_key = "MSMS" then 3
    when item_key = "CMA" then 4
    when item_key = "NIPT" then 5
    when item_key = "代谢病诊断" then 6
    when item_key = "软件" then 7
    when item_key = "NGS" then 8
    when item_key = "CMA设备" then 9
    when item_key = "串联质谱仪" then 10
    when item_key = "CDS5+GSL120(含KM1,KM2)" then 11
    when item_key = "1235+DX6000" then 12
    when item_key = "GSP" then 13
    when item_key = "GCMS设备" then 14
    else 15
    end as item_key_sort
from edw.map_item
group by item_code;

delete from bidata.dt_13_item where item_code = "jk0101";
delete from bidata.dt_13_item where item_code = "SC0101";

-- 2.2 增加一列数据 临时
update bidata.dt_13_item
set analysis = "1"
where level_one in ("产前","新生儿") and equipment = "否" and screen_class in("筛查","诊断") 
and level_two != "遗传病诊断耗材"
and locate("质控",level_three) = 0
and level_three not in ("Free hCGβ（中）","采血卡","采血针","ASQ","条形码");

-- 2.3 新增一行数据 其他
insert into bidata.dt_13_item (item_code,level_three,level_two,level_one,equipment,item_key_sort) 
values("其他","其他","其他","其他","否",15);
