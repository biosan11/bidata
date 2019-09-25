-- 建表1903更新数据
drop table if exists ufdata.sales_budget_new_1903;
create table if not exists ufdata.sales_budget_new_1903(
    cohr varchar(20) comment '公司',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(60) comment '项目编码',
    cinvcode varchar(60) comment '存货编码',
    inum_person_tem float(13,3) comment '计划发货数量_tem',
    isum_budget_tem float(13,3) comment '计划收入_tem',
    key test_sales_budget_19_new_tem_ccuscode (ccuscode),
    key test_sales_budget_19_new_tem_item_code (item_code),
    key test_sales_budget_19_new_tem_cinvcode (cinvcode)
)engine=innodb default charset=utf8 comment='每月更新计划回收临时表';

-- 导入1903数据（excel表--sales_budget_new_1903.xlsx）

-- 建表1904更新数据
drop table if exists ufdata.sales_budget_new_1904;
create table if not exists ufdata.sales_budget_new_1904(
    cohr varchar(20) comment '公司',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(60) comment '项目编码',
    cinvcode varchar(60) comment '存货编码',
    iquantity_budget_tem float(13,3) comment '计划发货盒数',
    inum_unit_person float(13,3) comment '单位人份数',
    inum_person_tem float(13,3) comment '计划发货数量_tem',
    isum_budget_tem float(13,3) comment '计划收入_tem',
    key test_sales_budget_19_new_tem_ccuscode (ccuscode),
    key test_sales_budget_19_new_tem_item_code (item_code),
    key test_sales_budget_19_new_tem_cinvcode (cinvcode)
)engine=innodb default charset=utf8 comment='每月更新计划回收临时表';
-- 导入1904数据（excel表--sales_budget_new_1904.xlsx）

-- 建表1905更新数据
drop table if exists ufdata.sales_budget_new_1905;
create table if not exists ufdata.sales_budget_new_1905(
    cohr varchar(20) comment '公司',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(60) comment '项目编码',
    cinvcode varchar(60) comment '存货编码',
    iquantity_budget_tem float(13,3) comment '计划发货盒数',
    inum_unit_person float(13,3) comment '单位人份数',
    inum_person_tem float(13,3) comment '计划发货数量_tem',
    isum_budget_tem float(13,3) comment '计划收入_tem',
    key test_sales_budget_19_new_tem_ccuscode (ccuscode),
    key test_sales_budget_19_new_tem_item_code (item_code),
    key test_sales_budget_19_new_tem_cinvcode (cinvcode)
)engine=innodb default charset=utf8 comment='每月更新计划回收临时表';
-- 导入1905数据（excel表--sales_budget_new_1905.xlsx）

-- 建表1906更新数据
drop table if exists ufdata.sales_budget_new_1906;
create table if not exists ufdata.sales_budget_new_1906(
    cohr varchar(20) comment '公司',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(60) comment '项目编码',
    cinvcode varchar(60) comment '存货编码',
    iquantity_budget_tem float(13,3) comment '计划发货盒数',
    inum_unit_person float(13,3) comment '单位人份数',
    inum_person_tem float(13,3) comment '计划发货数量_tem',
    isum_budget_tem float(13,3) comment '计划收入_tem',
    key test_sales_budget_19_new_tem_ccuscode (ccuscode),
    key test_sales_budget_19_new_tem_item_code (item_code),
    key test_sales_budget_19_new_tem_cinvcode (cinvcode)
)engine=innodb default charset=utf8 comment='每月更新计划回收临时表';
-- 导入1906数据（excel表--sales_budget_new_1906.xlsx）