-- ----------------------------------程序头部------------------------------------
-- 建表bidata.ft_41_cusitem_occupy
-- use bidata;
-- drop table if exists bidata.ft_41_cusitem_occupy;
-- create table if not exists bidata.ft_41_cusitem_occupy(
--     sales_region varchar(20) comment '销售大区',
--     province varchar(60) comment '省份',
--     city varchar(60) comment '地级市',
--     ccuscode varchar(20) comment '客户编码',
--     ccusname varchar(120) comment '客户名称',
--     level_one varchar(60) comment '一级目录（产品线）',
--     level_two varchar(255) comment '二级目录（产品组）',
--     item_code varchar(60) comment '项目编码',
--     item_name varchar(255) comment '项目名称',
--     equipment varchar(20) comment '是否设备',
--     screen_class varchar(20) comment '新筛产筛产诊',
--     cbustype varchar(60) comment '业务类型',
--     competitor varchar(10) comment '是否竞争对手',
--     plan_start_dt date comment '计划启用日期',
--     bidding_dt date comment '中标日期',
--     contract_dt date comment '合同日期',
--     install_dt date comment '装机时间',
--     iquantity_addup float(13,3) comment '累计发货数',
--     first_consign_dt date comment '初次发货日期',
--     last_consign_dt date comment '末次发货日期',
--     isum_addup float(13,3) comment '累计开票金额',
--     first_invoice_price_dt date comment '初次开票日期(单价大于0)',
--     first_invoice_dt date comment '初次开票日期(不考虑单价)',
--     last_invoice_dt date comment '末次开票日期',
--     end_date date comment '确认丢单日期',
--     occupy_class varchar(20) comment '占有类型',
--     item_start_dt date comment '项目启用日期',
--     occupy_status varchar(20) comment '占有阶段',
--     problem_mark varchar(20) comment '问题标记',
--     next_consign_dt_forecast date comment '预测下次发货日期',
--     next_inum_person_forecast float(13,3) comment '预测下次发货人份数1',
--     delivery_cycle float(13,3) comment '过去发货周期-日',
--     result_mark varchar(50) comment '风险or其他标记',
--     result_risk varchar(50) comment '风险值',
--     key pdm_cusitem_occupy_ccuscode (ccuscode),
--     key pdm_cusitem_occupy_item_code (item_code)
-- ) engine=innodb default charset=utf8 comment='客户项目占有情况';


-- 1.从pdm.cusitem_archives中取数 条件：ccuscode 取终端，type不取个人销售 并且group by ccuscode,item_code,cbustype
-- end_date 取ufdata.x_cusitem_enddate 
-- 项目取bidata.auxi_cusitem_ne_sc_me里的项目
drop temporary table if exists bidata.cusitem_tem00;
create temporary table if not exists bidata.cusitem_tem00
select 
	 a.ccuscode
	,a.ccusname
	,a.item_code
	,a.citemname as item_name
	,b.equipment as equipment
	,b.screen_class as screen_class
	,a.cbustype
	,a.competitor
	,min(a.plan_start_dt) as plan_start_dt
	,min(a.bidding_dt) as bidding_dt
	,min(a.contract_dt) as contract_dt
	,min(install_dt) as install_dt
	,sum(a.iquantity_addup) as iquantity_addup
	,min(a.first_consign_dt) as first_consign_dt
	,max(a.last_consign_dt) as last_consign_dt
	,sum(a.isum_addup) as isum_addup
	,min(a.first_invoice_price_dt) as first_invoice_price_dt
	,min(a.first_invoice_dt) as first_invoice_dt
	,max(a.last_invoice_dt) as last_invoice_dt
	,max(c.end_date) as end_date
	,c.status_class as end_date_status
	,case 
		when isum_addup >0
			then "购买" 
		when (isum_addup <=0 or isum_addup is null)
			and iquantity_addup >0
			and first_invoice_dt is not null 
			then "赠送"
		when (isum_addup <=0 or isum_addup is null)
			and iquantity_addup >0
			and first_invoice_dt is null 
			then "发货未开票" 
		else "未知"
		end as occupy_class
from pdm.cusitem_archives as a
left join bidata.auxi_cusitem_ne_sc_me as b
on a.item_code = b.item_code
left join ufdata.x_cusitem_enddate as c
on a.ccuscode = c.ccuscode and a.item_code = c.item_code
where left(a.ccuscode,2) = "ZD"
and type != "个人销售"
and b.item_code is not null 
group by a.ccuscode,a.item_code,a.cbustype;

alter table bidata.cusitem_tem00 add index index_cusitem_tem00_ccuscode (ccuscode);
alter table bidata.cusitem_tem00 add index index_cusitem_tem00_item_code (item_code);


-- 2.加工上面的临时表bidata.cusitem_tem00 生成 item_start_dt (这些是已经占有 或数据有问题的部分)
drop temporary table if exists bidata.cusitem_tem01;
create temporary table if not exists bidata.cusitem_tem01
select 
	 *
	,case 
		when equipment = "是" 
			and occupy_class in ("未知","赠送","发货未开票") 
			then install_dt 
		when occupy_class = "购买"
			then first_invoice_price_dt
		when equipment = "否" 
			and occupy_class in ("赠送","发货未开票")
			then first_consign_dt
		else null 
		end as item_start_dt
	,"已占有" as occupy_status
from bidata.cusitem_tem00
where plan_start_dt is null and end_date is null;

alter table bidata.cusitem_tem01 add index index_cusitem_tem01_ccuscode (ccuscode);
alter table bidata.cusitem_tem01 add index index_cusitem_tem01_item_code (item_code);
alter table bidata.cusitem_tem01 modify occupy_status varchar(20);

-- 增加已占有部分 同时计划启用日期不是空
insert into bidata.cusitem_tem01
select 
	 *
	,case 
		when equipment = "是" 
			and occupy_class in ("未知","赠送","发货未开票") 
			then install_dt 
		when occupy_class = "购买"
			then first_invoice_price_dt
		when equipment = "否" 
			and occupy_class in ("赠送","发货未开票")
			then first_consign_dt
		else null 
		end as item_start_dt
	,"已占有" as occupy_status
from bidata.cusitem_tem00
where plan_start_dt is not null and end_date is null
and occupy_class != "未知";


-- 增加计划占有部分数据 
insert into bidata.cusitem_tem01
select 
	 *
	,null
	,"计划占有" as occupy_status
from bidata.cusitem_tem00
where plan_start_dt is not null and end_date is null
and occupy_class = "未知";


-- 增加确认停止部分数据
-- 分成3类：1. 确认丢单 2.确认停用 3 其他（科研用、数据问题等）
insert into bidata.cusitem_tem01
select 
	 *
	,case 
		when equipment = "是" 
			and occupy_class in ("未知","赠送","发货未开票") 
			then install_dt 
		when occupy_class = "购买"
			then first_invoice_price_dt
		when equipment = "否" 
			and occupy_class in ("赠送","发货未开票")
			then first_consign_dt
		else null 
		end as item_start_dt
	,end_date_status as occupy_status
from bidata.cusitem_tem00
where end_date is not null;

-- 导入数据 并 增加异常数据标签

truncate table bidata.ft_41_cusitem_occupy;
insert into bidata.ft_41_cusitem_occupy
select 
	 b.sales_region
	,b.province
	,b.city
	,a.ccuscode
	,a.ccusname
	,c.level_one
	,c.level_two
	,a.item_code
	,a.item_name
	,a.equipment
	,a.screen_class
	,a.cbustype
	,a.competitor
	,a.plan_start_dt
	,a.bidding_dt
	,a.contract_dt
	,a.install_dt
	,a.iquantity_addup
	,a.first_consign_dt
	,a.last_consign_dt
	,a.isum_addup
	,a.first_invoice_price_dt
	,a.first_invoice_dt
	,a.last_invoice_dt
	,a.end_date
	,a.occupy_class
	,a.item_start_dt
	,a.occupy_status
	,case 
		when a.occupy_status = "已占有" and a.item_start_dt is null
			then "已占有无时间"
		else null
		end as problem_mark
	,null
	,null
	,null
	,null
	,null
from bidata.cusitem_tem01 as a
left join edw.map_customer as b
on a.ccuscode = b.bi_cuscode
left join edw.map_item as c
on a.item_code = c.item_code;