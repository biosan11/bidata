-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层--2020年新客户开发基础数据(到人)
-- 说明：取自pdm.cusitem_person_newstate 不取杭州贝生 
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
/* 建表脚本
use report;
drop table if exists report.kpi_02_newcus_base_person;
create table if not exists report.kpi_02_newcus_base_person(
    mark_1 varchar(20) comment '实际or计划标记',
    mark_2 varchar(20) comment '新客户or新项目',
    ddate date comment '日期',
    cohr varchar(30) comment '公司',
    ccuscode varchar(30) comment '客户编码',
    ccusname varchar(255) comment '客户名称',
    screen_class varchar(30) comment '筛诊分类',
    sales_dept varchar(30) comment '销售部门',
    sales_region_new varchar(30) comment '销售区域',
    province varchar(60) comment '省份',
    new_item varchar(60) comment '定义新项目', 
    cverifier_ori varchar(50) comment '销售负责人_未处理',
    areadirector_ori varchar(50) comment '区域主管_未处理',
    cverifier_result varchar(50) comment '销售负责人_处理后',
    areadirector_result varchar(50) comment '区域主管_处理后',
key repot_kpi_02_newcus_person_cohr (cohr),
key repot_kpi_02_newcus_person_ccuscode (ccuscode)
)engine=innodb default charset=utf8 comment='2020年新客户新项目开发基础数据(到人)';
*/

-- 对来源数据按客户 日期升序
drop temporary table if exists report.newcus_tem00;
create temporary table if not exists report.newcus_tem00 
select * from pdm.cusitem_person_newstate 
order by cuscode,ddate asc;




-- 新客户  不取杭州贝生 
truncate table report.kpi_02_newcus_base_person;
insert into report.kpi_02_newcus_base_person 
select 
    "plan" as mark_1
    ,"newcus" as mark_2
    ,a.ddate
    ,a.cohr
    ,a.cuscode as ccuscode 
    ,a.cusname as ccusanme
    ,c.screen_class
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,null as new_item
    ,a.cverifier as cverifier_ori
    ,a.areadirector as areadirector_ori
    ,if(a.cverifier = a.areadirector,null,a.cverifier) as cverifier_result
    ,a.areadirector as areadirector_result
from report.newcus_tem00  as a 
left join edw.map_customer as b 
on a.cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
where a.if_mechanism_online = "True" and cohr != "杭州贝生" and status = "新客户" and ddate_plan is not null -- 资质取True
group by a.cuscode,c.screen_class,a.cverifier ,a.areadirector
order by a.cuscode,a.ddate asc ;

insert into report.kpi_02_newcus_base_person 
select 
    "act" as mark
    ,"newcus" as mark_2
    ,a.ddate
    ,a.cohr
    ,a.cuscode
    ,a.cusname
    ,c.screen_class
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,null as new_item
    ,a.cverifier
    ,a.areadirector
    ,if(a.cverifier = a.areadirector,null,a.cverifier) as cverifier_result
    ,a.areadirector as areadirector_result
from report.newcus_tem00  as a 
left join edw.map_customer as b 
on a.cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
where a.if_mechanism_online = "True" and cohr != "杭州贝生" and status = "新客户" and a.type = "正常开票"-- 资质取True
group by a.cuscode,c.screen_class,a.cverifier ,a.areadirector
order by a.cuscode,a.ddate asc 
;

-- 老客户新项目  不取杭州贝生
insert into report.kpi_02_newcus_base_person 
select 
    "plan" as mark_1
    ,"newitem" as mark_2
    ,a.ddate
    ,a.cohr
    ,a.cuscode as ccuscode 
    ,a.cusname as ccusanme
    ,c.screen_class
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.new_item
    ,a.cverifier as cverifier_ori
    ,a.areadirector as areadirector_ori
    ,if(a.cverifier = a.areadirector,null,a.cverifier) as cverifier_result
    ,a.areadirector as areadirector_result
from report.newcus_tem00  as a 
left join edw.map_customer as b 
on a.cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
where cohr != "杭州贝生" and status = "老客户" and ddate_plan is not null and new_item is not null 
group by a.cuscode,c.screen_class,a.new_item,a.cverifier ,a.areadirector
order by a.cuscode,a.ddate asc;

insert into report.kpi_02_newcus_base_person 
select 
    "act" as mark_1
    ,"newitem" as mark_2
    ,a.ddate
    ,a.cohr
    ,a.cuscode as ccuscode 
    ,a.cusname as ccusanme
    ,c.screen_class
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.new_item
    ,a.cverifier as cverifier_ori
    ,a.areadirector as areadirector_ori
    ,if(a.cverifier = a.areadirector,null,a.cverifier) as cverifier_result
    ,a.areadirector as areadirector_result
from report.newcus_tem00  as a 
left join edw.map_customer as b 
on a.cuscode = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode = c.bi_cinvcode
where cohr != "杭州贝生" and status = "老客户" and a.type = "正常开票" and a.new_item is not null 
group by a.cuscode,c.screen_class,a.new_item,a.cverifier ,a.areadirector
order by a.cuscode,a.ddate asc
;

