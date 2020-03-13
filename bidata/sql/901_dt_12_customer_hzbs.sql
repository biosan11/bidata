-- 10_dt_12_customer
/*
-- 建表 bidata.dt_12_customer_hzbs
use bidata;
drop table if exists dt_12_customer_hzbs;
create table if not exists `dt_12_customer_hzbs` (
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
)engine=innodb default charset=utf8 comment'BI杭州贝生客户维度表';
*/

-- 1. bi_customer取数据
drop temporary table if exists bidata.bi_customer_pre;

-- 1.1 取ft_11_sales去重客户
create temporary table if not exists bidata.bi_customer_pre
select ccuscode from bidata.ft_14_sales_hzbs group by ccuscode;

-- 1.3 取ft_12_sales_budget去重客户
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_12_sales_budget 
where cohr = "杭州贝生"
group by true_ccuscode;

-- 1.4 取ft_13_sales_budget_new去重客户
insert into bidata.bi_customer_pre
select true_ccuscode from bidata.ft_13_sales_budget_new 
where cohr = "杭州贝生"
group by true_ccuscode;


-- 1.5 取 ft_25_outdepot_hzbs 去重客户
insert into bidata.bi_customer_pre
select ccuscode from bidata.ft_25_outdepot_hzbs group by ccuscode;



-- 1.* 生成bi_customer
truncate table bidata.dt_12_customer_hzbs;
insert into bidata.dt_12_customer_hzbs
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
from (select ccuscode from bidata.bi_customer_pre group by ccuscode) as a 
left join edw.map_customer_hzbs as b
on a.ccuscode = b.bi_cuscode;
