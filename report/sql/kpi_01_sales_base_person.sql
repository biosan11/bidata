-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2019,2020年实际计划收入匹配人员数据
-- 说明：实际开票收入取自pdm层invoice_order(不含健康检测),join edw.x_cusitem_person 
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者:
-- 开发日期：
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 
-- 调用方法　
--  建表脚本
-- use report;
-- drop table if exists report.kpi_01_sales_base_person;
-- create table if not exists report.kpi_01_sales_base_person(
--     ddate date comment '日期',
--     cohr varchar(20) comment '公司',
--     ccuscode varchar(20) comment '客户编码',
--     ccusname varchar(90) comment '客户名称',
--     sales_dept varchar(30) comment '销售部门',
--     sales_region_new varchar(30) comment '销售区域',
--     province varchar(60) comment '省份',
--     cbustype varchar(30) comment '业务类型',
--     cinvcode varchar(30) comment '产品编码',
--     cinvname varchar(255) comment '产品名称',
--     item_code varchar(30) comment '项目编码',
--     level_three varchar(30) comment '项目明细',
--     level_two varchar(30) comment '产品组',
--     level_one varchar(30) comment '产品线',
--     equipment varchar(30) comment '是否设备',
--     screen_class varchar(30) comment '筛诊分类',
--     cinv_key_2020 varchar(30) comment '20年新品要品',
--     cinv_own varchar(30) comment '自有产品',
--     areadirector varchar(30) comment '主管',
--     cverifier varchar(30) comment '销售',
--     if_act varchar(30) comment '是否实际',
--     isum decimal(18,4) comment '实际销售额',
--     isum_budget decimal (18,4) comment '计划销售额',
-- key repot_kpi_01_sales_base_person_cohr (cohr),
-- key repot_kpi_01_sales_base_person_ccuscode (ccuscode),
-- key repot_kpi_01_sales_base_person_cinvcode (cinvcode),
-- key repot_kpi_01_sales_base_person_item_code (item_code)
-- )engine=innodb default charset=utf8 comment='2019,2020年实际计划收入匹配人员数据';


-- 获取2020年的客户项目负责人数据 
drop temporary table if exists report.cusitem_person;
create temporary table if not exists report.cusitem_person
select 
    start_dt
    ,end_dt
    ,concat(bi_cuscode,item_code,cbustype) as matchid
    ,areadirector
    ,cverifier
from edw.x_cusitem_person 
where start_dt >= '2020-01-01';
alter table report.cusitem_person add index (start_dt),add index (end_dt),add index (matchid);


-- 实际收入处理
-- 19-20年收入 最终客户是multi的 改为ccuscode 不取健康检测, 不取杭州贝生 分组聚合
drop temporary table if exists report.bonus_base;
create temporary table if not exists report.bonus_base
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
where a.item_code != 'JK0101' and year(ddate) >= 2019 and a.if_xs is null -- 增加if_xs = null 条件 (分中心部门)
group by a.cohr,a.ddate,a.ccuscode,a.cinvcode;
alter table report.bonus_base add index (ddate),add index (matchid);

-- 计划收入处理 
drop temporary table if exists report.bonus_base_budget;
create temporary table if not exists report.bonus_base_budget
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
group by a.cohr,a.ddate,a.bi_cuscode,a.bi_cinvcode;
alter table report.bonus_base_budget add index (ddate),add index (matchid);


-- 明细匹配人员数据(19年人员 用20年客户同期的人员)
truncate table report.kpi_01_sales_base_person;
insert into report.kpi_01_sales_base_person
select a.ddate
      ,a.cohr
      ,a.ccuscode 
      ,c.bi_cusname
      ,c.sales_dept
      ,c.sales_region_new
      ,c.province
      ,a.cbustype
      ,a.cinvcode
      ,d.bi_cinvname
      ,d.item_code 
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,d.equipment
      ,d.screen_class
      ,d.cinv_key_2020
      ,d.cinv_own
      ,b.areadirector
      ,b.cverifier
      ,'act'  as 'if_act'
      ,a.isum 
      ,0 as isum_budget
from report.bonus_base as a 
left join report.cusitem_person as b 
on a.matchid = b.matchid
and a.ddate >= b.start_dt and a.ddate <= b.end_dt
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
left join edw.map_inventory as d 
on a.cinvcode = d.bi_cinvcode 
where a.ddate >= '2020-01-01'
and a.isum !=0 ; 
-- 收入是0的数据不取 

-- 取2019年实际数据
insert into report.kpi_01_sales_base_person
select a.ddate
      ,a.cohr
      ,a.ccuscode 
      ,c.bi_cusname
      ,c.sales_dept
      ,c.sales_region_new
      ,c.province
      ,a.cbustype
      ,a.cinvcode
      ,d.bi_cinvname
      ,d.item_code 
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,d.equipment
      ,d.screen_class
      ,d.cinv_key_2020
      ,d.cinv_own
      ,b.areadirector
      ,b.cverifier
      ,'act'  as 'if_act'
      ,a.isum 
      ,0 as isum_budget
from report.bonus_base as a 
left join report.cusitem_person as b 
on a.matchid = b.matchid
and date_add(a.ddate,interval 1 year) >= b.start_dt and date_add(a.ddate,interval 1 year) <= b.end_dt  -- a表日期加一年 
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
left join edw.map_inventory as d 
on a.cinvcode = d.bi_cinvcode 
where a.ddate >= '2019-01-01' and a.ddate <= '2019-12-31'
and a.isum != 0 
; 
-- 收入是0的数据不取 

-- 取2020年计划数据 
insert into report.kpi_01_sales_base_person
select a.ddate
      ,a.cohr
      ,a.ccuscode 
      ,c.bi_cusname
      ,c.sales_dept
      ,c.sales_region_new
      ,c.province
      ,a.cbustype
      ,a.cinvcode
      ,d.bi_cinvname
      ,d.item_code 
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,d.equipment
      ,d.screen_class
      ,d.cinv_key_2020
      ,d.cinv_own
      ,b.areadirector
      ,b.cverifier
      ,'budget'  as 'if_act'
      ,0 as isum 
      ,a.isum_budget
from report.bonus_base_budget as a 
left join report.cusitem_person as b 
on a.matchid = b.matchid
and a.ddate >= b.start_dt and a.ddate <= b.end_dt
left join edw.map_customer as c 
on a.ccuscode = c.bi_cuscode
left join edw.map_inventory as d 
on a.cinvcode = d.bi_cinvcode 
where a.ddate >= '2020-01-01'
and a.isum_budget != 0 
;
-- 计划收入是0的数据不取 

-- 非省区客户,手动维护 
update report.kpi_01_sales_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where ccusname = "浙江迪安深海冷链物流有限公司";
update report.kpi_01_sales_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where ccusname = "杭州优客互动网络科技有限公司";
update report.kpi_01_sales_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where ccusname = "湖南文吉健康管理有限公司";
update report.kpi_01_sales_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where ccusname = "浙江玺诺医疗器械有限公司";
update report.kpi_01_sales_base_person set areadirector = '非省区客户' , cverifier = '非省区客户' where ccusname = "杭州方回春堂同心中医门诊部有限公司";

