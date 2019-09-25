-- 15_ft_23_outdepot_forecast

-- 功能：生成bi层发货预测&预警数据|可迭代预测次数 
-- 生成表：bidata.ft_21_outdepot_forecast  &  bidata.ft_21_outdepot_forecast_pro
-- 文件路径：/home/bidata/bidata/sql/11_ft_21_outdepot_forecast.sql
-- 依赖表：
-- 1. bidata.ft_21_outdepot
-- 2. bidata.ft_41_cusitem_occupy

/*
-- 建表bidata.ft_23_outdepot_forecast
drop table if exists bidata.ft_23_outdepot_forecast;
create table if not exists bidata.ft_23_outdepot_forecast(
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(60) comment '项目编码',
    cinvcode varchar(50) comment '预测存货编码',
    ddate date comment '单据日期',
    inum_person float(13,3) comment '人份数',
    iquantity float(13,3) comment '数量',
    forecast_mark varchar(20) comment '是否预测值标记',
    primary key(ccuscode,item_code,ddate),
    key index_ft_21_outdepot_forecast_ccuscode (ccuscode),
    key index_ft_21_outdepot_forecast_item_code (item_code)
) engine=innodb default charset=utf8 comment='bi销售发货预测表';

-- 建表bidata.ft_24_outdepot_forecast_pro
drop table if exists bidata.ft_24_outdepot_forecast_pro;
create table if not exists bidata.ft_24_outdepot_forecast_pro(
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(20) comment '项目编码',
    first_consign_dt date comment '初次发货日期',
    last_consign_dt date comment '末次发货日期',
    interval_day float(13,3) comment '间隔天',
    interval_month float(13,3) comment '间隔月',
    lastmonth_inum_person float(13,3) comment '最近一次发货月份发货人份数',
    year_consign_num smallint comment '一年内发货月份数',
    total_rmlastmonth_inum_person float(13,3) comment '累计发货人份数(去除最后发货那个月)',
    addup4_inum_person float(13,3) comment '累计4月发货人份数（去除最后那个月）',
    addup6_inum_person float(13,3) comment '累计6月发货人份数（去除最后那个月）',
    addup12_inum_person float(13,3) comment '累计12月发货人份数（去除最后那个月',
    avgttl_single_inum_person float(13,3) comment '平均每次发货人份数all',
    avg12_single_inum_person float(13,3) comment '平均每次发货人份数12',
    avg_month_inum_person float(13,3) comment '月均用量人份数_根据发货',
    mark_ varchar(60) comment '发货预测标记',
    avg_month_inum_person_jc float(13,3) comment '月均用量人份数_根据检测量',
    difference_per float(13,3) comment '月均差异（检测量与发货）',
    next_consign_dt_forecast date comment '预测下次发货日期',
    next_inum_person_forecast float(13,3) comment '预测下次发货人份数1',
    last_cinvcode varchar(50) comment '末次发货存货编码',
    inum_unit_person float(13,3) comment '末次发货存货单位人份数',
    next_iquantity_forecast float(13,3) comment '预测下次发货盒数（四舍五入）',
    next_inum_person_forecast_2 float(13,3) comment '预测下次发货人份数2（根据盒数）',
    key bidata_ft_21_outdepot_forecast_pro_ccuscode (ccuscode),
    key bidata_ft_21_outdepot_forecast_pro_item_code (item_code)
) engine=innodb default charset=utf8 comment='bi销售发货预测表(1次迭代中间过程)';
*/

-- step1
-- 提取基础数据
-- 客户项目取bidata.ft_41_cusitem_occupy
-- 条件：业务类型取产品类    and    发货数量不等于0    and    不取设备   and 不取质控品
-- 分组条件：按finnal_ccuscode,item_code,ddate 分组聚合
truncate table bidata.ft_23_outdepot_forecast;
insert into bidata.ft_23_outdepot_forecast
select 
    finnal_ccuscode as ccuscode
    ,item_code
    ,null as cinvcode -- 初始数据不取产品级别
    ,ddate
    ,sum(round(inum_person,2)) as inum_person
    ,null as iquantity -- 数量 初始数据不取产品级别 
    ,"0" as forecast_mark -- 预测标记 0代表初始数据 1代表第一次预测 2代表第二次预测
from bidata.ft_21_outdepot 
where 
finnal_ccuscode in (select ccuscode from bidata.ft_41_cusitem_occupy group by ccuscode)
and item_code in (select item_code from bidata.ft_41_cusitem_occupy where equipment = "否" group by item_code)
and item_code != "XS0109" -- 预测数据 不取采血卡XS0109
and item_code not in ("CQ0611","CQ0612","XS0113","XS0302") -- 不取质控品
and cbustype = "产品类" 
and inum_person != 0 
group by finnal_ccuscode,item_code,ddate;

-- step 2
-- 定义以下处理过程：
use bidata;
drop procedure if exists bidata.bi_outdepot_forecast_pro;

delimiter $$
create procedure bidata.bi_outdepot_forecast_pro()
begin
-- 1.提取客户项目明细 并 增加索引 (ccuscode,item_code)
drop temporary table if exists bidata.outfor_tem00;
create temporary table if not exists bidata.outfor_tem00
select ccuscode,item_code
from bidata.ft_23_outdepot_forecast
group by ccuscode,item_code;
alter table bidata.outfor_tem00 add index index_outfor_tem00_ccuscode (ccuscode);
alter table bidata.outfor_tem00 add index index_outfor_tem00_item_code (item_code);


-- 2.提取按年月分组数据 并 增加索引 (中间表)
drop temporary table if exists bidata.outfor_tem001;
create temporary table if not exists bidata.outfor_tem001
select
	ccuscode
	,item_code
	,date_format(ddate,"%y%m") as yearmonth
	,sum(inum_person) as inum_person
from bidata.ft_23_outdepot_forecast
group by ccuscode,item_code,date_format(ddate,"%y%m")
having sum(inum_person) > 0;
alter table bidata.outfor_tem001 add index index_outfor_tem001_ccuscode (ccuscode);
alter table bidata.outfor_tem001 add index index_outfor_tem001_item_code (item_code);

-- 3.初次，最近一次发货日期临时表 计算时间间隔 (first_consign_dt,last_consign_dt,interval_day,interval_month)
drop temporary table if exists bidata.outfor_tem01;
create temporary table if not exists bidata.outfor_tem01
select 
	ccuscode
	,item_code
	,min(ddate) as first_consign_dt
	,max(ddate) as last_consign_dt
	,datediff(max(ddate),min(ddate)) as interval_day
	,(datediff(max(ddate),min(ddate))/30) as interval_month
from bidata.ft_23_outdepot_forecast 
where inum_person != 0
group by ccuscode,item_code; 
alter table bidata.outfor_tem01 add index index_outfor_tem01_ccuscode (ccuscode);
alter table bidata.outfor_tem01 add index index_outfor_tem01_item_code (item_code);

-- 4.最近一次发货月份 总发货数 (lastmonth_inum_person)
drop temporary table if exists bidata.outfor_tem02;
create temporary table if not exists bidata.outfor_tem02
select 
	a.ccuscode
	,a.item_code
	,a.inum_person as lastmonth_inum_person
from 
(
	select ccuscode,item_code,yearmonth,inum_person 
	from bidata.outfor_tem001
	where inum_person > 0
	order by ccuscode,item_code,yearmonth desc
)as a
group by a.ccuscode,a.item_code;
alter table bidata.outfor_tem02 add index index_outfor_tem02_ccuscode (ccuscode);
alter table bidata.outfor_tem02 add index index_outfor_tem02_item_code (item_code);

-- 5.一年内发货月份数 并增加索引 (year_consign_num)
drop temporary table if exists bidata.outfor_tem03;
create temporary table if not exists bidata.outfor_tem03
select 
c.ccuscode
,c.item_code
,count(c.yearmonth) as year_consign_num
from
(
	select 
	a.ccuscode as ccuscode
	,a.item_code as item_code
	,a.yearmonth as `yearmonth`
	,date_format(date_add(b.last_consign_dt, interval -12 month),"%y%m") as start_dt
	,date_format(date_add(b.last_consign_dt, interval -1 month),"%y%m") as end_dt
	from
	(
		select
		ccuscode
		,item_code
		,date_format(ddate,"%y%m") as yearmonth
		,sum(inum_person)
		from bidata.ft_23_outdepot_forecast
		group by ccuscode,item_code,date_format(ddate,"%y%m")
		having sum(inum_person) > 0
	) as a
	left join bidata.outfor_tem01 as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where a.yearmonth >= date_format(date_add(b.last_consign_dt, interval -12 month),"%y%m")
	and a.yearmonth <= date_format(date_add(b.last_consign_dt, interval -1 month),"%y%m")
) as c
group by ccuscode,item_code;
alter table bidata.outfor_tem03 add index index_outfor_tem03_ccuscode (ccuscode);
alter table bidata.outfor_tem03 add index index_outfor_tem03_item_code (item_code);

-- 6.累计发货数(去除最后发货那个月) (total_rmlastmonth_inum_person)
drop temporary table if exists bidata.outfor_tem05;
create temporary table if not exists bidata.outfor_tem05
    select 
    c.ccuscode
    ,c.item_code
    ,sum(c.inum_person) as total_rmlastmonth_inum_person
    from
    (
        select 
        a.*
        ,b.last_consign_dt
        from bidata.outfor_tem001 as a
        left join 
        (
            select 
            ccuscode
            ,item_code
            ,date_format(last_consign_dt,"%y%m") as last_consign_dt
            from bidata.outfor_tem01
        ) as b
        on a.ccuscode = b.ccuscode and a.item_code = b.item_code
        where a.yearmonth < b.last_consign_dt
    ) as c
    group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem05 add index index_outfor_tem05_ccuscode (ccuscode);
alter table bidata.outfor_tem05 add index index_outfor_tem05_item_code (item_code);

-- 7.累计4月发货数（去除最后那个月） (addup4_inum_person)
drop temporary table if exists bidata.outfor_tem06;
create temporary table if not exists bidata.outfor_tem06
select 
c.ccuscode
,c.item_code
,sum(c.inum_person) as addup4_inum_person
from
(
	select 
		a.ccuscode
		,a.item_code
		,a.ddate
		-- 辅助判断
		-- ,date_format(a.ddate,"%y%m") 
		,a.inum_person
		,b.last_consign_dt
		-- ,date_format(b.last_consign_dt,"%y%m")
		-- ,date_format(date_add(b.last_consign_dt, interval -5 month),"%y%m")
	from bidata.ft_23_outdepot_forecast as a
	left join 
	(
		select 
			ccuscode
			,item_code
			,last_consign_dt
		from bidata.outfor_tem01
	) as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where date_format(a.ddate,"%y%m") < date_format(b.last_consign_dt,"%y%m")
		and date_format(a.ddate,"%y%m") > 
			date_format(date_add(b.last_consign_dt, interval -5 month),"%y%m")
) as c
group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem06 add index index_outfor_tem06_ccuscode (ccuscode);
alter table bidata.outfor_tem06 add index index_outfor_tem06_item_code (item_code);

-- 8.累计6月发货数（去除最后那个月） (addup6_inum_person)
drop temporary table if exists bidata.outfor_tem07;
create temporary table if not exists bidata.outfor_tem07
select 
c.ccuscode
,c.item_code
,sum(c.inum_person) as addup6_inum_person
from
(
	select 
		a.ccuscode
		,a.item_code
		,a.ddate
		-- 辅助判断
		-- ,date_format(a.ddate,"%y%m") 
		,a.inum_person
		,b.last_consign_dt
		-- ,date_format(b.last_consign_dt,"%y%m")
		-- ,date_format(date_add(b.last_consign_dt, interval -7 month),"%y%m")
	from bidata.ft_23_outdepot_forecast as a
	left join 
	(
		select 
			ccuscode
			,item_code
			,last_consign_dt
		from bidata.outfor_tem01
	) as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where date_format(a.ddate,"%y%m") < date_format(b.last_consign_dt,"%y%m")
		and date_format(a.ddate,"%y%m") > 
			date_format(date_add(b.last_consign_dt, interval -7 month),"%y%m")
) as c
group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem07 add index index_outfor_tem07_ccuscode (ccuscode);
alter table bidata.outfor_tem07 add index index_outfor_tem07_item_code (item_code);

-- 9.累计12月发货数（去除最后那个月） (addup12_inum_person)
drop temporary table if exists bidata.outfor_tem08;
create temporary table if not exists bidata.outfor_tem08
select 
c.ccuscode
,c.item_code
,sum(c.inum_person) as addup12_inum_person
from
(
	select 
		a.ccuscode
		,a.item_code
		,a.ddate
		-- 辅助判断
		-- ,date_format(a.ddate,"%y%m") 
		,a.inum_person
		,b.last_consign_dt
		-- ,date_format(b.last_consign_dt,"%y%m")
		-- ,date_format(date_add(b.last_consign_dt, interval -13 month),"%y%m")
	from bidata.ft_23_outdepot_forecast as a
	left join 
	(
		select 
			ccuscode
			,item_code
			,last_consign_dt
		from bidata.outfor_tem01
	) as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where date_format(a.ddate,"%y%m") < date_format(b.last_consign_dt,"%y%m")
		and date_format(a.ddate,"%y%m") > 
			date_format(date_add(b.last_consign_dt, interval -13 month),"%y%m")
) as c
group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem08 add index index_outfor_tem08_ccuscode (ccuscode);
alter table bidata.outfor_tem08 add index index_outfor_tem08_item_code (item_code);

-- 10.计算平均每次发货数量 (avgttl_single_inum_person)
drop temporary table if exists bidata.outfor_tem09;
create temporary table if not exists bidata.outfor_tem09
select 
c.ccuscode
,c.item_code
,count(c.ddate)
,(sum(c.inum_person)/count(c.ddate)) as avgttl_single_inum_person
from
(
	select 
		a.ccuscode
		,a.item_code
		,a.ddate
		-- 辅助判断
		-- ,date_format(a.ddate,"%y%m") 
		,a.inum_person
		,b.last_consign_dt
		-- ,date_format(b.last_consign_dt,"%y%m")
		-- ,date_format(date_add(b.last_consign_dt, interval -5 month),"%y%m")
	from bidata.ft_23_outdepot_forecast as a
	left join 
	(
		select 
			ccuscode
			,item_code
			,last_consign_dt
		from bidata.outfor_tem01
	) as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where date_format(a.ddate,"%y%m") < date_format(b.last_consign_dt,"%y%m")
) as c
group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem09 add index index_outfor_tem09_ccuscode (ccuscode);
alter table bidata.outfor_tem09 add index index_outfor_tem09_item_code (item_code);

-- 11.计算平均每次发货数量 (avg12_single_inum_person)
drop temporary table if exists bidata.outfor_tem10;
create temporary table if not exists bidata.outfor_tem10
select 
c.ccuscode
,c.item_code
,count(c.ddate)
,(sum(c.inum_person)/count(c.ddate)) as avg12_single_inum_person
from
(
	select 
		a.ccuscode
		,a.item_code
		,a.ddate
		-- 辅助判断
		-- ,date_format(a.ddate,"%y%m") 
		,a.inum_person
		,b.last_consign_dt
		-- ,date_format(b.last_consign_dt,"%y%m")
		-- ,date_format(date_add(b.last_consign_dt, interval -5 month),"%y%m")
	from bidata.ft_23_outdepot_forecast as a
	left join 
	(
		select 
			ccuscode
			,item_code
			,last_consign_dt
		from bidata.outfor_tem01
	) as b
	on a.ccuscode = b.ccuscode and a.item_code = b.item_code
	where date_format(a.ddate,"%y%m") < date_format(b.last_consign_dt,"%y%m")
		and date_format(a.ddate,"%y%m") > 
			date_format(date_add(b.last_consign_dt, interval -13 month),"%y%m")
) as c
group by c.ccuscode,c.item_code;
alter table bidata.outfor_tem10 add index index_outfor_tem10_ccuscode (ccuscode);
alter table bidata.outfor_tem10 add index index_outfor_tem10_item_code (item_code);

-- 12 组合以上临时表 得到
drop temporary table if exists bidata.outfor_tem11;
create temporary table if not exists bidata.outfor_tem11
select
     a.*
    ,b.first_consign_dt
    ,b.last_consign_dt
    ,b.interval_day
    ,b.interval_month
    ,c.lastmonth_inum_person
    ,d.year_consign_num
    ,e.total_rmlastmonth_inum_person
    ,f.addup4_inum_person
    ,g.addup6_inum_person
    ,h.addup12_inum_person
    ,i.avgttl_single_inum_person
    ,j.avg12_single_inum_person
    ,case
        when d.year_consign_num is null  then null
        when b.interval_day <= 180 then (e.total_rmlastmonth_inum_person/b.interval_month)
        when b.interval_day >= 181 and b.interval_day <= 365 and d.year_consign_num >= 6 then (f.addup4_inum_person/4)
        when b.interval_day >= 181 and b.interval_day <= 365 and d.year_consign_num >= 4 and d.year_consign_num <= 5 then (g.addup6_inum_person/6)
        when b.interval_day >= 181 and b.interval_day <= 365 and d.year_consign_num >= 1 and d.year_consign_num <= 3 then (e.total_rmlastmonth_inum_person/b.interval_month)
        when b.interval_day >365 and d.year_consign_num >= 6 then (f.addup4_inum_person/4)
        when b.interval_day >365 and d.year_consign_num >= 4 and d.year_consign_num <= 5 then (g.addup6_inum_person/6)
        when b.interval_day >365 and d.year_consign_num >= 1 and d.year_consign_num <= 3 then (h.addup12_inum_person/12)
        else null
        end as avg_month_inum_person
    ,case
        when year_consign_num is null then "1_once_consign_recently"
        when b.last_consign_dt <= date_add(current_date(), interval -12 month) then "2_last_consign_dt_-12y"
        else null 
        end as mark_
from bidata.outfor_tem00 as a
left join bidata.outfor_tem01 as b
    on a.ccuscode = b.ccuscode and a.item_code = b.item_code
left join bidata.outfor_tem02 as c
    on a.ccuscode = c.ccuscode and a.item_code = c.item_code
left join bidata.outfor_tem03 as d
    on a.ccuscode = d.ccuscode and a.item_code = d.item_code
left join bidata.outfor_tem05 as e
    on a.ccuscode = e.ccuscode and a.item_code = e.item_code
left join bidata.outfor_tem06 as f
    on a.ccuscode = f.ccuscode and a.item_code = f.item_code
left join bidata.outfor_tem07 as g
    on a.ccuscode = g.ccuscode and a.item_code = g.item_code
left join bidata.outfor_tem08 as h
    on a.ccuscode = h.ccuscode and a.item_code = h.item_code
left join bidata.outfor_tem09 as i
    on a.ccuscode = i.ccuscode and a.item_code = i.item_code
left join bidata.outfor_tem10 as j
    on a.ccuscode = j.ccuscode and a.item_code = j.item_code
;
alter table bidata.outfor_tem11 add index index_outfor_tem11_ccuscode (ccuscode);
alter table bidata.outfor_tem11 add index index_outfor_tem11_item_code (item_code);

-- 13.新增检测量数据 取2018年开始 到现在的 月均检测量 （后续优化：时间序列）
drop temporary table if exists bidata.outfor_tem12;
create temporary table if not exists bidata.outfor_tem12
select 
    aa.ccuscode
    ,aa.item_code 
    ,avg(aa.inum_person) as avg_month_inum_person_jc
from 
    (
        select 
            a.ccuscode
            ,a.item_code 
            ,date_format(a.ddate,"%y%m") as yearmonth
            ,sum(a.inum_person) as inum_person 
        from bidata.ft_31_checklist as a 
        left join (select ccuscode,item_code from bidata.outfor_tem11 where mark_ is null ) as b 
        on a.ccuscode = b.ccuscode and a.item_code = b.item_code 
        where year(a.ddate) >= 2018 and b.ccuscode is not null and b.item_code is not null
        group by a.ccuscode,a.item_code,date_format(ddate,"%y%m")
    ) as aa 
group by aa.ccuscode,aa.item_code
;
alter table bidata.outfor_tem12 add index index_outfor_tem12_ccuscode (ccuscode);
alter table bidata.outfor_tem12 add index index_outfor_tem12_item_code (item_code);

-- 14.加入月均检测量  
drop temporary table if exists bidata.outfor_tem13;
create temporary table if not exists bidata.outfor_tem13
select 
    a.* 
    ,b.avg_month_inum_person_jc
    ,a.avg_month_inum_person/b.avg_month_inum_person_jc as difference_per
from bidata.outfor_tem11 as a 
left join bidata.outfor_tem12 as b 
on a.ccuscode = b.ccuscode and a.item_code = b.item_code;
alter table bidata.outfor_tem13 add index index_outfor_tem13_ccuscode (ccuscode);
alter table bidata.outfor_tem13 add index index_outfor_tem13_item_code (item_code);

-- 更新mark  检测与发货差异百分比绝对值大于1.5
update bidata.outfor_tem13 
set mark_ = "3_difference_jc_consign" 
where avg_month_inum_person_jc is not null 
and (difference_per < 0.5 or difference_per > 1.5);
-- 更新mark  有检测量 取检测量 没有检测量 取发货月均 
update bidata.outfor_tem13 
set mark_ = "4_use_avg_jc" 
where mark_ is null and avg_month_inum_person_jc is not null;
update bidata.outfor_tem13 
set mark_ = "5_use_avg_outdepot"
where mark_ is null and avg_month_inum_person_jc is null;
-- 更新avg_month_inum_person 当mark_ 5_use_avg_outdepot 且 avg_month_inum_person =0 或null 时  
-- 向上寻找非空的月均用量（发货人份）
update bidata.outfor_tem13 
set mark_ = "5_use_avg_outdepot_ad" , avg_month_inum_person = addup6_inum_person/6 
where mark_ = "5_use_avg_outdepot" and (avg_month_inum_person = 0 or avg_month_inum_person is null);
update bidata.outfor_tem13 
set mark_ = "5_use_avg_outdepot_ad" , avg_month_inum_person = addup12_inum_person/12 
where mark_ = "5_use_avg_outdepot" and (avg_month_inum_person = 0 or avg_month_inum_person is null);
update bidata.outfor_tem13 
set mark_ = "5_use_avg_outdepot_ad" , avg_month_inum_person = total_rmlastmonth_inum_person/interval_month
where mark_ = "5_use_avg_outdepot" and (avg_month_inum_person = 0 or avg_month_inum_person is null);


-- 15.生成发货预测临时表
drop temporary table if exists bidata.outfor_tem14;
create temporary table if not exists bidata.outfor_tem14
select 
	a.*
    ,case 
        when a.mark_ = "1_once_consign_recently" then null 
        when a.mark_ = "2_last_consign_dt_-12y" then null 
        when a.mark_ = "3_difference_jc_consign" then null 
        when a.mark_ = "4_use_avg_jc" then date_add(a.last_consign_dt, interval (lastmonth_inum_person/avg_month_inum_person_jc)*30+1 day) 
        when a.mark_ = "5_use_avg_outdepot" then date_add(a.last_consign_dt, interval (lastmonth_inum_person/avg_month_inum_person)*30+1 day) 
        else null 
    end as next_consign_dt_forecast
-- 	,case
-- 		when a.interval_day >365 then addup12_iquantity
-- 		else avgttl_single_iquantity
-- 		end as next_iquantity_forecast
	,case 
        when a.mark_ = "1_once_consign_recently" then null 
        when a.mark_ = "2_last_consign_dt_-12y" then null 
        when a.mark_ = "3_difference_jc_consign" then null 
        when a.mark_ = "4_use_avg_jc" and a.interval_day > 365 then (12/a.year_consign_num)* a.avg_month_inum_person_jc
        when a.mark_ = "4_use_avg_jc" and a.interval_day <= 365 then (a.interval_month/a.year_consign_num)* a.avg_month_inum_person_jc
        when a.mark_ = "5_use_avg_outdepot" and a.interval_day > 365 then (12/a.year_consign_num)* a.avg_month_inum_person
        when a.mark_ = "5_use_avg_outdepot" and a.interval_day <= 365 then (a.interval_month/a.year_consign_num)* a.avg_month_inum_person
		else null 
		end as next_inum_person_forecast
from bidata.outfor_tem13 as a ;
alter table bidata.outfor_tem14 add index index_outfor_tem14_ccuscode (ccuscode);
alter table bidata.outfor_tem14 add index index_outfor_tem14_item_code (item_code);


-- 16.取客户项目最后一次发货 存货编码
drop temporary table if exists bidata.outfor_tem15;
create temporary table if not exists bidata.outfor_tem15
select 
	a.ccuscode
	,a.item_code
	,a.cinvcode
	,a.cinvcode as last_cinvcode
from 
	(
		select 
		finnal_ccuscode as ccuscode
		,item_code
		,cinvcode
		,ddate
		from bidata.ft_21_outdepot 
		where 
		finnal_ccuscode in (select ccuscode from bidata.ft_41_cusitem_occupy group by ccuscode)
		and item_code in (select item_code from bidata.ft_41_cusitem_occupy where equipment = "否" group by item_code)
		-- 预测数据 不取采血卡XS0109
		and item_code != "XS0109"
		and cbustype = "产品类"
		and inum_person > 0 
		order by finnal_ccuscode,item_code,ddate desc
	) as a 
	group by a.ccuscode,a.item_code;
alter table bidata.outfor_tem15 add index index_outfor_tem15_ccuscode (ccuscode);
alter table bidata.outfor_tem15 add index index_outfor_tem15_item_code (item_code);


-- 17.生成发货预测临时表2
drop temporary table if exists bidata.outfor_tem16;
create temporary table if not exists bidata.outfor_tem16
select 
a.*
,b.last_cinvcode
,c.inum_unit_person
,round(a.next_inum_person_forecast/c.inum_unit_person,0) as next_iquantity_forecast 
,if(
	(round(a.next_inum_person_forecast/c.inum_unit_person,0) * c.inum_unit_person) = 0,
	1,
	round(a.next_inum_person_forecast/c.inum_unit_person,0) * c.inum_unit_person) as next_inum_person_forecast_2
from bidata.outfor_tem14 as a
left join bidata.outfor_tem15 as b
on a.ccuscode = b.ccuscode and a.item_code = b.item_code
left join 
(select bi_cinvcode,inum_unit_person 
from 
edw.map_inventory group by bi_cinvcode )as c
on b.cinvcode = c.bi_cinvcode;
end 
$$
delimiter ;

-- step3
-- 将结果导入bidata.ft_23_outdepot_forecast
-- 第1次迭代
call bidata.bi_outdepot_forecast_pro();
-- 将第一次中间过程导入bidata.bi_outdepot_forecast_pro
truncate table bidata.ft_24_outdepot_forecast_pro;
insert into bidata.ft_24_outdepot_forecast_pro
select * from bidata.outfor_tem16;

-- 将第一次结果导入bidata.bi_outdepot_forecast
insert into bidata.ft_23_outdepot_forecast 
select
ccuscode
,item_code
,last_cinvcode
,next_consign_dt_forecast
,next_inum_person_forecast_2
,next_iquantity_forecast
,"1"
from bidata.outfor_tem16
where next_consign_dt_forecast is not null;

-- 第2次迭代
call bidata.bi_outdepot_forecast_pro();

insert into bidata.ft_23_outdepot_forecast 
select
ccuscode
,item_code
,last_cinvcode
,next_consign_dt_forecast
,next_inum_person_forecast_2
,next_iquantity_forecast
,"2"
from bidata.outfor_tem16
where next_consign_dt_forecast is not null;

-- 第3次迭代
call bidata.bi_outdepot_forecast_pro();

insert into bidata.ft_23_outdepot_forecast 
select
ccuscode
,item_code
,last_cinvcode
,next_consign_dt_forecast
,next_inum_person_forecast_2
,next_iquantity_forecast
,"3"
from bidata.outfor_tem16
where next_consign_dt_forecast is not null;