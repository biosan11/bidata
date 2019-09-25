/*
use report;
drop table if exists report.fin_12_salesbudget_person_post;
create table if not exists report.fin_12_salesbudget_person_post(
	mark varchar(100) comment '分类1',
	p_sales_sup varchar(100) comment '主管（技术or临床）',
	p_sales_spe varchar(100) comment '销售（技术or临床）',
	ddate date comment '日期',
	ccuscode varchar(20) comment '客户编码',
	item_code varchar(50) comment '项目编码',
    cinvcode varchar(30) ,
	equipment varchar(10) comment '是否设备',
	screen_class varchar(20) comment '筛查诊断分类',
	cbustype varchar(20) comment '业务类型',
    itax float(13,3) comment '实际税额',
	isum float(13,3) comment '实际收入',
	isum_budget float(13,3) comment '预算收入',
	isum_budget_notax float(13,3) comment '预算收入（不含税）',
    cost_notax float(13,3) comment'不含税成本',
    amount_depre float(13,3) comment'折旧金额',
	key report_fin_12_salesbudget_person_post_ddate (ddate),
	key report_fin_12_salesbudget_person_post_p_sales_sup (p_sales_sup),
	key report_fin_12_salesbudget_person_post_p_sales_spe (p_sales_spe),
	key report_fin_12_salesbudget_person_post_ccuscode (ccuscode),
	key report_fin_12_salesbudget_person_post_item_code (item_code),
	key report_fin_12_salesbudget_person_post_cbustype (cbustype)
)engine=innodb default charset=utf8 comment='bi收入人员表_人汇总';
*/

-- 拆分 技术销售  临床学术  按比例 
truncate table report.fin_12_salesbudget_person_post;
insert into report.fin_12_salesbudget_person_post 
select 
    "noperson" as mark
    ,"noperson" as p_sales_sup_tec
    ,"noperson" as p_sales_spe_tec
    ,ddate
    ,finnal_ccuscode as ccuscode 
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itax
    ,isum
    ,isum_budget
    ,isum_budget_notax
    ,case 
        when eq_if_launch is null then ifnull(iquantity_adjust,0) * cost_price_notax
        else 0 
    end as cost_notax 
    ,amount_depre
from report.fin_11_salesbudget_cost_depre
where uniqueid is null;

insert into report.fin_12_salesbudget_person_post 
select 
    "tec" as mark 
    ,p_sales_sup_tec
    ,p_sales_spe_tec 
    ,ddate
    ,finnal_ccuscode as ccuscode 
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itax * ifnull(per_tec,0)
    ,isum * ifnull(per_tec,0)
    ,isum_budget * ifnull(per_tec,0)
    ,isum_budget_notax * ifnull(per_tec,0)
    ,case 
        when eq_if_launch is null then ifnull(iquantity_adjust,0) * cost_price_notax * ifnull(per_tec,0)
        else 0 
    end as cost_notax
    ,amount_depre * ifnull(per_tec,0)
from report.fin_11_salesbudget_cost_depre
where uniqueid is not null ;

insert into report.fin_12_salesbudget_person_post
select 
    "clinic" as mark 
    ,p_sales_sup_clinic
    ,p_sales_spe_clinic
    ,ddate
    ,finnal_ccuscode as ccuscode 
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itax * ifnull(per_clinic,0)
    ,isum * ifnull(per_clinic,0)
    ,isum_budget * ifnull(per_clinic,0)
    ,isum_budget_notax * ifnull(per_clinic,0)
    ,case 
        when eq_if_launch is null then ifnull(iquantity_adjust,0) * cost_price_notax * ifnull(per_clinic,0)
        else 0 
    end as cost_notax
    ,amount_depre * ifnull(per_clinic,0)
from report.fin_11_salesbudget_cost_depre
where uniqueid is not null ; 