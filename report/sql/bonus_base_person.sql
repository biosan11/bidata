
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
-- 19-20年收入 最终客户是multi的 改为ccuscode 不取健康检测, 不取杭州贝生 分组聚合
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
where a.item_code != 'JK0101' and year(ddate) >= 2019
and a.cohr != '杭州贝生'
group by a.cohr,a.ddate,a.ccuscode,a.cinvcode;
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

-- 非省区客户,手动维护 
update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "浙江迪安深海冷链物流有限公司";
update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "杭州优客互动网络科技有限公司";
-- 20200717更新 这家客户是销售负责 update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "湖南文吉健康管理有限公司";
update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "浙江玺诺医疗器械有限公司";
update report.bonus_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where bi_cusname = "杭州方回春堂同心中医门诊部有限公司";


-- 根据20年奖金方案 聚合减少数据量
drop table if exists report.bonus_base_cal;
create table if not exists report.bonus_base_cal
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









