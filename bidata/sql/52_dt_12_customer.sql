-- 10_dt_12_customer
/*
-- 建表 bidata.dt_12_customer
use bidata;
drop table if exists dt_12_customer;
create table if not exists `dt_12_customer` (
    bi_cuscode varchar(30) comment '标准编码，主键',
    bi_cusname varchar(120) comment '标准名称',
    type varchar(10) comment '销售类型',
    sales_region varchar(20) comment '销售区域',
    province varchar(60) comment '销售省份',
    city varchar(60) comment '销售城市',
    technical_sales varchar(10) comment '技术销售',
    academic_sales varchar(10) comment '学术销售',
    cdefine001 varchar(10) comment '待定字段',
    ccusgrade varchar(60) comment '客户等级',
    cus_type varchar(60) comment '客户企业类型',
    ccus_Hierarchy varchar(60) comment '客户层级',
    Hospital_grade varchar(60) comment '医院等级',
    cus_nature varchar(60) comment '客户性质',
    Credit_rating varchar(60) comment '资信等级',
    nsieve_mechanism varchar(60) comment '新筛机构',
    screen_mechanism varchar(60) comment '产筛机构',
    medical_mechanism varchar(60) comment '产诊机构',
    license_plate varchar(60) comment 'pcr牌照（分子）',
    primary key (`bi_cuscode`)
)engine=innodb default charset=utf8 comment 'BI客户维度表';
*/

-- 1. bi_customer取数据
drop temporary table if exists bidata.bi_customer_pre;
-- 1.1 取ft_11_sales去重客户
create temporary table if not exists bidata.bi_customer_pre
select ccuscode from bidata.ft_11_sales group by ccuscode;
-- 1.2 取ft_11_sales去重最终客户
insert into bidata.bi_customer_pre
select finnal_ccuscode as ccuscode from bidata.ft_11_sales group by finnal_ccuscode;
-- 1.3 取ft_12_sales_budget去重客户
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_12_sales_budget group by true_ccuscode;
-- 1.4 取ft_13_sales_budget_new去重客户
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_13_sales_budget_new group by true_ccuscode;
-- 1.5 取ft_21_outdepot去重客户
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_21_outdepot group by ccuscode;
-- 1.6 取ft_21_outdepot去重最终客户
insert into bidata.bi_customer_pre
select finnal_ccuscode from bidata.ft_21_outdepot group by finnal_ccuscode;
-- 1.7 取ft_31_checklist去重客户
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_31_checklist group by ccuscode;

-- 1.8 资质客户
-- 新筛nsieve_mechanism
insert into bidata.bi_customer_pre
select bi_cuscode from edw.map_customer where nsieve_mechanism = "是";
-- 产诊medical_mechanism
insert into bidata.bi_customer_pre
select bi_cuscode from edw.map_customer where medical_mechanism = "是";
-- 产筛screen_mechanism
insert into bidata.bi_customer_pre
select bi_cuscode from edw.map_customer where screen_mechanism = "是";

-- 1.9 发货未开票客户（非最终客户）
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_22_outdepot_uninvoice group by true_ccuscode;

-- 2.0 客户项目占有数据
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_41_cusitem_occupy group by ccuscode;

-- 2.1 应收部分ft_51_ar
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_51_ar group by true_ccuscode;

-- 2.2 收入成本
-- insert into bidata.bi_customer_pre
-- select finnal_ccuscode_invoice from report.financial_sales_cost group by finnal_ccuscode_invoice;

-- 2.3 实际&计划回款
insert into bidata.bi_customer_pre
select true_ccuscode from edw.x_ar_plan group by true_ccuscode;

-- 2.4 药监系统发货数据
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_26_outdepot_yj group by ccuscode;

update bidata.bi_customer_pre
set ccuscode = replace(replace(ccuscode,char(13),""),char(10),"");

-- 2.5 保险等内部结算 
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_84_expenses_settlement group by ccuscode;

-- 2.6 费用数据
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_81_expenses group by ccuscode;

-- 1.* 生成bi_customer
truncate table bidata.dt_12_customer;
insert into bidata.dt_12_customer
select
   ifnull(b.bi_cuscode,ifnull(a.ccuscode,"其他")) as ccuscode
  ,ifnull(b.bi_cusname,"其他")
  ,ifnull(b.type,"其他")
  ,ifnull(b.sales_region,"其他")
  ,ifnull(b.province,"其他")
  ,ifnull(b.city,"其他")
  ,ifnull(b.technical_sales,"其他")
  ,ifnull(b.academic_sales,"其他")
  ,ifnull(b.cdefine001,"其他")
  ,ifnull(b.ccusgrade,"其他")
  ,ifnull(b.cus_type,"其他")
  ,ifnull(b.ccus_Hierarchy,"其他")
  ,ifnull(b.Hospital_grade,"其他")
  ,ifnull(b.cus_nature,"其他")
  ,ifnull(b.Credit_rating,"其他")
  ,b.nsieve_mechanism
  ,b.screen_mechanism
  ,b.medical_mechanism
  ,b.license_plate
  ,ifnull(b.sales_dept,"其他")
  ,ifnull(b.sales_region_new,"其他")
from (select ccuscode from bidata.bi_customer_pre group by ccuscode) as a 
left join edw.map_customer as b
on a.ccuscode = b.bi_cuscode;
