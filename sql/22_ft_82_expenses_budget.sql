-- 30_ft_82_expenses_budget(oa_x)

/*
-- 建表 bidata.ft_82_expenses_budget_oa
use bidata;
drop table if exists ft_82_expenses_budget_oa;
create table ft_82_expenses_budget_oa(
    budgetinfoid decimal(30,0) comment '部门预算信息id',
    name_ehr_id varchar(20) comment 'ehr自定义id',
    name_ehr varchar(60) comment '预算部门',
    person varchar(4) comment '预算人',
    name varchar(120) comment 'OA科目名称',
    u8kemubm varchar(120) comment 'u8科目编号',
    cdlx varchar(2) comment '承担类型',
    ddate date comment '',
    amount_budget decimal(18,2) comment '金额',
    key bidata_ft_82_expenses_budget_oa_budgetinfoid (budgetinfoid),
    key bidata_ft_82_expenses_budget_oa_name_ehr_id (name_ehr_id),
    key bidata_ft_82_expenses_budget_oa_u8kemubm (u8kemubm)
) engine=innodb default charset=utf8 comment='bi费用预算表_oa';

-- 建表 bidata.ft_82_expenses_budget_x
use bidata;
drop table if exists ft_82_expenses_budget_x;
create table ft_82_expenses_budget_x(
    cohr varchar(20) comment '公司',
    ddate date comment '日期',
    cdept_name varchar(60) comment '原始部门字段',
    cdept_id_ehr varchar(60) comment 'ehr自定义id',
    u8_code varchar(60) comment 'u8科目编号',
    personname varchar(60) comment '承担人',
    amount_budget float(13,4) comment '费用预算金额',
    key bidata_ft_82_expenses_budget_x_cdept_id_ehr (cdept_id_ehr),
    key bidata_ft_82_expenses_budget_x_u8_code (u8_code)
) engine=innodb default charset=utf8 comment='bi费用预算表_x';
 */
 
 
-- 导入OA预算数据
truncate table bidata.ft_82_expenses_budget_oa;
insert into bidata.ft_82_expenses_budget_oa
select 
    budgetinfoid
    ,name_ehr_id
    ,name_ehr
    ,person
    ,name
    ,u8kemubm
    ,cdlx
    ,budgetperiodslist as ddate
    ,round(budgetaccount,4) as amount_budget
from pdm.oa_budget_19
;

-- 导入线下预算数据
truncate table bidata.ft_82_expenses_budget_x;
insert into bidata.ft_82_expenses_budget_x
select 
    cohr
    ,ddate
    ,cdept_name
    ,cdept_id_ehr
    ,u8_code
    ,personname
    ,amount_budget
from edw.x_expenses_budget_19
;






