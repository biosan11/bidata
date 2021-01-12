
-- 获取2020年的客户项目负责人数据 
drop temporary table if exists test.cusitem_person;
create temporary table if not exists test.cusitem_person
select 
    start_dt
    ,end_dt
    ,concat(bi_cuscode,item_code,cbustype) as matchid
    ,areadirector
    ,cverifier
from edw.x_cusitem_person 
where start_dt >= '2020-01-01';
alter table test.cusitem_person add index (start_dt),add index (end_dt),add index (matchid);


-- 实际收入处理
-- 19-20年收入 最终客户是multi的 改为ccuscode 不取健康检测, 不取杭州贝生 分组聚合 不取非销售数据 210112补充
drop temporary table if exists test.bonus_base;
create temporary table if not exists test.bonus_base
select 
    a.cohr
    ,a.ddate
    ,case 
        when a.finnal_ccuscode = 'multi' then a.ccuscode
        else a.finnal_ccuscode
        end as ccuscode
    ,a.cinvcode
    ,b.item_code
    ,b.business_class as cbustype 
    ,sum(a.isum) as isum
    ,concat( if(a.finnal_ccuscode = 'multi',a.ccuscode,a.finnal_ccuscode),b.item_code,b.business_class) as matchid
from pdm.invoice_order as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode
where a.item_code != 'JK0101' and year(ddate) >= 2019 and a.if_xs is null 
and a.cohr != '杭州贝生'
group by a.cohr,a.ddate,a.ccuscode,a.finnal_ccuscode,a.cinvcode;
alter table test.bonus_base add index (ddate),add index (matchid);

-- 计划收入处理 
drop temporary table if exists test.bonus_base_budget;
create temporary table if not exists test.bonus_base_budget
select 
    a.cohr
    ,a.ddate
    ,a.bi_cuscode as ccuscode
    ,a.bi_cinvcode as cinvcode
    ,b.item_code
    ,b.business_class as cbustype 
    ,sum(a.isum_budget) as isum_budget
    ,concat( a.bi_cuscode,b.item_code,b.business_class) as matchid
from edw.x_sales_budget_20 as a 
left join edw.map_inventory as b 
on a.bi_cinvcode = b.bi_cinvcode
where a.cohr != '杭州贝生'
group by a.cohr,a.ddate,a.bi_cuscode,a.bi_cinvcode;
alter table test.bonus_base_budget add index (ddate),add index (matchid);


-- 明细匹配人员数据(19年人员 用20年客户同期的人员)

drop table if exists report.bonus_base_person;
create table if not exists report.bonus_base_person
-- 先取2020年实际数据
select 
    a.cohr
    ,a.ddate
    ,c.sales_dept
    ,c.sales_region_new
    ,c.province
    ,case
        when c.province in ("浙江省","安徽省","福建省","江苏省","山东省","湖南省") then "六省"
        else "非六省"
        end as mark_province
    ,a.ccuscode
    ,c.bi_cusname
    ,a.cinvcode
    ,a.item_code
    ,a.cbustype 
    ,b.areadirector
    ,b.cverifier
    ,cast('act' as char(10)) as 'if_act'
    ,a.isum 
    ,cast(0 as decimal(18,4)) as isum_budget
from test.bonus_base as a 
left join test.cusitem_person as b 
on a.matchid = b.matchid
and a.ddate >= b.start_dt and a.ddate <= b.end_dt
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
where a.ddate >= '2020-01-01'
and a.isum !=0 ; -- 收入是0的数据不取 

-- 取2019年实际数据
insert into report.bonus_base_person
select 
    a.cohr
    ,a.ddate
    ,c.sales_dept
    ,c.sales_region_new
    ,c.province
    ,case
        when c.province in ("浙江省","安徽省","福建省","江苏省","山东省","湖南省") then "六省"
        else "非六省"
        end as mark_province
    ,a.ccuscode
    ,c.bi_cusname
    ,a.cinvcode
    ,a.item_code
    ,a.cbustype 
    ,b.areadirector
    ,b.cverifier
    ,cast('act' as char(10)) as 'if_act'
    ,a.isum
    ,cast(0 as decimal(18,4)) as isum_budget
from test.bonus_base as a 
left join test.cusitem_person as b 
on a.matchid = b.matchid
and date_add(a.ddate,interval 1 year) >= b.start_dt and date_add(a.ddate,interval 1 year) <= b.end_dt  -- a表日期加一年 
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
where a.ddate >= '2019-01-01' and a.ddate <= '2019-12-31'
and a.isum != 0 ; -- 收入是0的数据不取 

-- 取2020年计划数据 
insert into report.bonus_base_person
select 
    a.cohr
    ,a.ddate
    ,c.sales_dept
    ,c.sales_region_new
    ,c.province
    ,case
        when c.province in ("浙江省","安徽省","福建省","江苏省","山东省","湖南省") then "六省"
        else "非六省"
        end as mark_province
    ,a.ccuscode
    ,c.bi_cusname
    ,a.cinvcode
    ,a.item_code
    ,a.cbustype 
    ,b.areadirector
    ,b.cverifier
    ,cast('budget' as char(10)) as 'if_act'
    ,cast(0 as decimal(18,4)) as isum
    ,a.isum_budget
from test.bonus_base_budget as a 
left join test.cusitem_person as b 
on a.matchid = b.matchid
and a.ddate >= b.start_dt and a.ddate <= b.end_dt
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
where a.ddate >= '2020-01-01'
and a.isum_budget != 0; -- 计划收入是0的数据不取 

-- 非省区客户,手动维护 -- 210112更新 已经通过pdm.invoice_order 区分是否销售负责的数据
-- update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "浙江迪安深海冷链物流有限公司";
-- update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "杭州优客互动网络科技有限公司";
-- 20200717更新 这家客户是销售负责 update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "湖南文吉健康管理有限公司";
-- update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "浙江玺诺医疗器械有限公司";
-- update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "杭州方回春堂同心中医门诊部有限公司";


-- 根据20年奖金方案 聚合减少数据量
drop temporary table if exists report.bonus_base_cal_;
create temporary table if not exists report.bonus_base_cal_
select 
    year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,a.sales_dept
    ,a.sales_region_new
    ,a.province
    ,a.mark_province
    ,a.areadirector
    ,a.cverifier
    ,c.cinv_key_2020
    ,ifnull(c.screen_class,"筛查") as screen_class
    ,c.equipment
    ,sum(isum) as isum 
    ,sum(isum_budget) as isum_budget
from report.bonus_base_person as a 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode 
group by year_,month_,a.province,a.areadirector,a.cverifier,c.cinv_key_2020,c.screen_class,c.equipment;
alter table report.bonus_base_cal_ add index (areadirector),add index(cverifier);


-- ehr离职人员档案  最后工作日期+1 钉钉群 销售奖金工作群 谷晓丽确认 2020-10-22 
drop table if exists report.bonus_base_ehr;
create table if not exists report.bonus_base_ehr
select 
	name 
    ,employeestatus
    ,TransitionType
    ,date_add(lastworkdate, interval 1 day) as lastworkdate_add1
    ,year(date_add(lastworkdate, interval 1 day)) as year_ 
    ,month(date_add(lastworkdate, interval 1 day)) as month_ 
from pdm.ehr_employee 
where employeestatus = '离职' and year(lastworkdate) = 2020;
alter table report.bonus_base_ehr add index (name);

		     
		     
-- 根据20年奖金方案 聚合减少数据量
drop table if exists report.bonus_base_cal;
create table if not exists report.bonus_base_cal
select 
    a.year_
    ,a.month_
    ,a.sales_dept
    ,a.sales_region_new
    ,a.province
    ,a.mark_province
    ,a.areadirector
    ,a.cverifier
    ,a.cinv_key_2020
    ,a.screen_class
    ,a.equipment
    ,a.isum 
    ,a.isum_budget
	,b.TransitionType as TransitionType_area
	,b.lastworkdate_add1 as lastworkdate_area
	,b.month_ as month_area
	,c.TransitionType as TransitionType_cver
	,c.lastworkdate_add1 as lastworkdate_cver
	,c.month_ as month_cver
from report.bonus_base_cal_ as a 
left join report.bonus_base_ehr as b 
on a.areadirector = b.name 
left join report.bonus_base_ehr as c 
on a.cverifier = c.name 
;


-- 以下2020-10-23 彭丽电话确认  源数据中不改确认空

-- -- 被动离职的, 改 确认空
-- update report.bonus_base_cal set areadirector = '确认空' where TransitionType_area = '被动离职';
-- update report.bonus_base_cal set cverifier = '确认空' where TransitionType_cver = '被动离职';
-- 
-- -- 主动离职的, 根据最后工作日期判断
-- -- 1. 最后工作日期在Q1, 改 确认空
-- update report.bonus_base_cal set areadirector = '确认空' 
-- where TransitionType_area != '主动离职' and lastworkdate_area is not null 
-- and month_area <= 3;
-- 
-- update report.bonus_base_cal set cverifier = '确认空' 
-- where TransitionType_cver != '主动离职' and lastworkdate_cver is not null 
-- and month_cver <= 3;
-- 
-- -- 2. 最后工作日期在Q2 , Q1不变, 其余改 确认空 
-- update report.bonus_base_cal set areadirector = '确认空' 
-- where (TransitionType_area = '主动离职' or TransitionType_area is null )and lastworkdate_area is not null 
-- and month_area > 3 and month_area <= 6 and month_ >3;
-- 
-- update report.bonus_base_cal set cverifier = '确认空' 
-- where (TransitionType_cver = '主动离职' or TransitionType_cver is null ) and lastworkdate_cver is not null 
-- and month_cver > 3 and month_cver <= 6 and month_ >3;
-- 
-- -- 3. 最后工作日期在Q3 , Q1-Q2不变, 其余改 确认空 
-- update report.bonus_base_cal set areadirector = '确认空' 
-- where (TransitionType_area = '主动离职' or TransitionType_area is null ) and lastworkdate_area is not null 
-- and month_area > 6 and month_area <= 9 and month_ >6;
-- 
-- update report.bonus_base_cal set cverifier = '确认空' 
-- where (TransitionType_cver = '主动离职' or TransitionType_cver is null )  and lastworkdate_cver is not null 
-- and month_cver > 6 and month_cver <= 9 and month_ >6;
-- 
-- -- 4. 最后工作日期在Q4 , Q1-Q3不变, 其余改 确认空 
-- update report.bonus_base_cal set areadirector = '确认空' 
-- where (TransitionType_area = '主动离职' or TransitionType_area is null ) and lastworkdate_area is not null 
-- and month_area > 9 and month_area <= 12 and month_ >9;
-- 
-- update report.bonus_base_cal set cverifier = '确认空' 
-- where (TransitionType_cver = '主动离职' or TransitionType_cver is null )  and lastworkdate_cver is not null 
-- and month_cver > 9 and month_cver <= 12 and month_ >9;

