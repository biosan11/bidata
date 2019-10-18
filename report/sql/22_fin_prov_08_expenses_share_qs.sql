
/*
drop table if exists report.fin_prov_08_expenses_share_qs;
create table if not exists report.fin_prov_08_expenses_share_qs (
    `fy_share_mk2` varchar(30) default null,
    `fy_share_mk3` varchar(30) default null,
    `province_confirm` varchar(60) default null,
    `mark_insert` varchar(20) default null,
    `act_budget` varchar(20) default null,
    `year_` smallint(20) default null,
    `month_` smallint(20) default null,
    `name_ehr_id` varchar(60) default null,
    `second_dept` varchar(120) default null,
    `third_dept` varchar(120) default null,
    `fourth_dept` varchar(120) default null,
    `fifth_dept` varchar(120) default null,
    `province` varchar(60) default null,
    `second_dept_old` varchar(120) default null,
    `third_dept_old` varchar(120) default null,
    `fourth_dept_old` varchar(120) default null,
    `fifth_dept_old` varchar(120) default null,
    `province_old` varchar(60) default null,
    `code` varchar(60) default null,
    `ccode_name` varchar(20) default null,
    `ccode_name_2` varchar(20) default null,
    `ccode_name_3` varchar(20) default null,
    `md` double default null,
    `amount_budget` float(14,5) default null,
    `fy_share_m1` varchar(60) default null,
    `name_ehr_id2` varchar(80) default null,
key `index_report_fin_prov_08_expenses_share_qs_province_confirm` (`province_confirm`),
key `index_report_fin_prov_08_expenses_share_qs_name_ehr_id` (`name_ehr_id`),
key `index_report_fin_prov_08_expenses_share_qs_year_` (`year_`),
key `index_report_fin_prov_08_expenses_share_qs_month_` (`month_`),
key `index_report_fin_prov_08_expenses_share_qs_name_ehr_id2` (`name_ehr_id2`),
key `index_report_fin_prov_08_expenses_share_qs_fy_share_m1` (`fy_share_m1`)
) engine=innodb default charset=utf8 comment '省区财务绩效用费用分摊（七省一市）';



drop table if exists report.fin_prov_08_expenses_share_qs_groupby;
create table if not exists report.fin_prov_08_expenses_share_qs_groupby (
    `province_confirm` varchar(60) default null,
    `year_` smallint(20) default null,
    `month_` smallint(20) default null,
    `ccode_name_2` varchar(20) default null,
    `md` double default null,
    `amount_budget` float(14,5) default null,
key `index_fin_prov_08_expenses_groupby_province_confirm` (`province_confirm`),
key `index_fin_prov_08_expenses_groupby_year_` (`year_`),
key `index_fin_prov_08_expenses_groupby_month_` (`month_`)
) engine=innodb default charset=utf8 comment '省区财务绩效用费用分摊（七省一市）聚合';
*/

-- 2019.08之前的费用分摊用
-- 1. 非杭州贝生 2018年以后 按年、月、省份 分组
drop temporary table if exists report.fin_prov_tem01;
create temporary table if not exists report.fin_prov_tem01
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,b.province
    ,b.sales_region
    ,sum(a.isum) as isum 
from bidata.ft_11_sales as a 
left join edw.map_customer as b 
on a.finnal_ccuscode = b.bi_cuscode 
where a.cohr != "杭州贝生"
and year(a.ddate) >=2018
group by year_,month_,b.province
having sum(a.isum) != 0 ;

-- 2.各上级大区总收入
drop temporary table if exists report.fin_prov_tem02;
create temporary table if not exists report.fin_prov_tem02
select 
    year_
    ,month_
    ,sales_region 
    ,sum(isum) as isum
from report.fin_prov_tem01 
group by year_,month_,sales_region;

-- 3.营销中心总收入 
drop temporary table if exists report.fin_prov_tem03;
create temporary table if not exists report.fin_prov_tem03
select 
    year_
    ,month_
    ,sum(isum) as isum
from report.fin_prov_tem01 
group by year_,month_;

-- 综合上方1、2、3 费用分摊用占比（以省份为基础单位）
drop temporary table if exists report.fin_prov_tem04;
create temporary table if not exists report.fin_prov_tem04
select 
    a.year_
    ,a.month_
    ,a.province
    ,a.sales_region 
    ,a.isum as isum_province
    ,b.isum as isum_salesregion
    ,round(a.isum/b.isum,6) as per_province
    ,c.isum as isum_all
    ,round(a.isum/c.isum,6) as per_all
from report.fin_prov_tem01 as a 
left join report.fin_prov_tem02 as b 
on a.year_ = b.year_ and a.month_ = b.month_ and a.sales_region = b.sales_region 
left join report.fin_prov_tem03 as c 
on a.year_ = c.year_ and a.month_ = c.month_;


-- 开始费用分摊
truncate table report.fin_prov_08_expenses_share_qs;
-- 将七省一市的直接费用 导入 (不取健康保险费)
insert into report.fin_prov_08_expenses_share_qs
select * from report.fin_prov_08_expenses_share 
where fy_share_mk2 = "fy_province";
-- and province_confirm in ("浙江省","江苏省","安徽省","福建省","湖南省","湖北省","山东省","上海市")
-- and ccode_name != "健康保险费";


-- 销售一部 销售二部 的费用分摊 待定
insert into report.fin_prov_08_expenses_share_qs
select 
    "insert_dq"
    ,a.fy_share_mk3
    ,b.province
    ,"insert"
    ,a.act_budget
    ,a.year_
    ,a.month_
    ,a.name_ehr_id
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.province
    ,a.second_dept_old
    ,a.third_dept_old
    ,a.fourth_dept_old
    ,a.fifth_dept_old
    ,a.province_old
    ,a.code
    ,a.ccode_name
    ,a.ccode_name_2
    ,a.ccode_name_3
    ,(a.md * ifnull(b.per_province,1))
    ,(a.amount_budget * ifnull(b.per_province,1))
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_08_expenses_share as a 
left join report.fin_prov_tem04 as b
on a.year_ = b.year_ and a.month_ = b.month_ and a.fy_share_mk3 = b.sales_region
where a.fy_share_mk2 = "fy_salesregion";
-- and ccode_name != "健康保险费";;
-- and (a.year_ = 2018 or (a.year_ = 2019 and a.month_ <= 7))
-- and a.fy_share_mk3 in ("销售三区","销售四区","销售五区","销售六区","销售八区");

update report.fin_prov_08_expenses_share_qs set province_confirm = "上海市" 
where province_confirm is null 
and fy_share_mk3 = "销售八区"
and (year_ = 2018 or (year_ = 2019 and month_ <= 7));


insert into report.fin_prov_08_expenses_share_qs
select 
    "insert_yxzx"
    ,a.fy_share_mk3
    ,b.province
    ,"insert"
    ,a.act_budget
    ,a.year_
    ,a.month_
    ,a.name_ehr_id
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.province
    ,a.second_dept_old
    ,a.third_dept_old
    ,a.fourth_dept_old
    ,a.fifth_dept_old
    ,a.province_old
    ,a.code
    ,a.ccode_name
    ,a.ccode_name_2
    ,a.ccode_name_3
    ,(a.md * ifnull(b.per_all,1))
    ,(a.amount_budget * ifnull(b.per_all,1))
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_08_expenses_share as a 
left join report.fin_prov_tem04 as b
on a.year_ = b.year_ and a.month_ = b.month_
where a.fy_share_mk2 = "fy_yxzx";
-- and ccode_name != "健康保险费";
-- and (a.year_ = 2018 or (a.year_ = 2019 and a.month_ <= 7))
;

-- 导入聚合数据 
truncate table report.fin_prov_08_expenses_share_qs_groupby;
insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province_confirm
    ,year_
    ,month_
    ,ccode_name_2
    ,sum(md)
    ,sum(amount_budget)
from report.fin_prov_08_expenses_share_qs 
group by province_confirm,year_,month_,ccode_name_2;

-- 需要删掉 线下实验员  线下保险费用 
insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province
    ,year_
    ,month_
    ,"人员成本"
    ,-1 * sy_md
    ,0
from report.fin_prov_11_expenses_fw 
where sy_md != 0;

insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province
    ,year_
    ,month_
    ,"健康保险费"
    ,-1 * bx_md
    ,0
from report.fin_prov_11_expenses_fw
where bx_md != 0;
    
