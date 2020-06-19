-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2020年每月计划与实际回款表(含主管,不含销售)
-- 说明：取edw.x_ar_plan, 匹配客户项目负责人中的负责主管
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
drop table if exists report.kpi_03_ar_plan_base_person;
create table if not exists report.kpi_03_ar_plan_base_person(
    cohr varchar(30) comment '公司',
    sales_dept varchar(30) comment '销售部门',
    sales_region_new varchar(30) comment '销售区域',
    province varchar(60) comment '省份',
    ccuscode varchar(30) comment '客户编码',
    ccusname varchar(255) comment '客户名称',
    ddate date comment '日期',
    ar_class varchar(30) comment '应收类型',
    amount_plan decimal(18,4) comment '计划回款',
    amount_act decimal(18,4) comment '实际回款',
    areadirector varchar(30) comment '客户项目负责人中的主管',
key repot_kpi_03_ar_plan_base_person_cohr (cohr),
key repot_kpi_03_ar_plan_base_person_ccuscode (ccuscode),
key repot_kpi_03_ar_plan_base_person_ar_class (ar_class)
)engine=innodb default charset=utf8 comment='2020年每月计划与实际回款表(含主管,不含销售)';
*/

-- 获取2020年区域主管信息(一个客户对应一个主管)
drop table if exists report.kpi_03_person_tem;
create table if not exists report.kpi_03_person_tem(
    autoid smallint primary key auto_increment,
    start_dt date ,
    end_dt date,
    ccuscode varchar(30) ,
    areadirector varchar(60),
key report_kpi_03_person_tem_start_dt (start_dt),
key report_kpi_03_person_tem_end_dt (end_dt),
key report_kpi_03_person_tem_ccuscode (ccuscode)
)engine=innodb default charset=utf8 ;

-- 增加数据
insert into report.kpi_03_person_tem (start_dt,end_dt,ccuscode,areadirector)
select 
    a.start_dt
    ,a.end_dt
    ,a.ccuscode
    ,a.areadirector
from 
(
select 
    start_dt
    ,end_dt
    ,ccuscode
    ,areadirector
    ,count(*) as count_
from pdm.cusitem_person 
where start_dt >= '2020-01-01'
group by start_dt,ccuscode,areadirector
order by start_dt asc , end_dt asc ,count_ desc
) as a 
group by a.start_dt,a.ccuscode;

-- 直接取出的 客户对应主管数据, 会有前后开始日期, 结束日期交叉问题, 以开始日期为准, 重置结束日期

-- 1. 将end_dt全部都改成空 
update report.kpi_03_person_tem
set end_dt = null ;

-- 2. 取出所有ccuscode有重复的数据  并加上自增编号
set @i = 0;
drop table if exists test.cusitem_tem01;
create table if not exists test.cusitem_tem01
select 
    autoid
    ,ccuscode
    ,start_dt
    ,end_dt
    ,@i:=@i+1 as id 
from report.kpi_03_person_tem as a 
where ccuscode in 
    (
    select ccuscode from report.kpi_03_person_tem group by ccuscode having count(*) >1
    )
order by ccuscode,start_dt asc
;

-- 3. 通过自增编号自关联，取得应该调整的结束日期
drop temporary table if exists test.cusitem_tem02;
create temporary table if not exists test.cusitem_tem02
select 
    a.autoid
    ,if(a.ccuscode = b.ccuscode,date_add(b.start_dt, interval -1 day),null) as end_dt
from test.cusitem_tem01 as a 
left join test.cusitem_tem01 as b 
on a.id = b.id - 1;

delete from test.cusitem_tem02 where end_dt is null ;

-- 4. 更改结束日期
update report.kpi_03_person_tem as a 
left join test.cusitem_tem02 as b 
on a.autoid = b.autoid
set a.end_dt = b.end_dt ;

drop table if exists test.cusitem_tem01;

-- 5. 更改结束日期为空的  改成2019-12-31
update report.kpi_03_person_tem
set end_dt = "2020-12-31"
where end_dt is null ;

-- 将edw.x_ar_plan匹配20年客户项目负责人数据, 导入
truncate table report.kpi_03_ar_plan_base_person;
insert into report.kpi_03_ar_plan_base_person
select 
    a.company
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province
    ,a.true_ccuscode
    ,a.true_ccusname
    ,a.ddate
    ,a.ar_class
    ,a.amount_plan 
    ,a.amount_act 
    ,c.areadirector
from edw.x_ar_plan as a 
left join edw.map_customer as b 
on a.true_ccuscode = b.bi_cuscode 
left join report.kpi_03_person_tem as c 
on a.true_ccuscode = c.ccuscode and 
a.ddate >= c.start_dt and a.ddate <= c.end_dt
where year(a.ddate) >= 2020 
;

-- 删除多余数据, 计划与实际回款都是0 
delete from report.kpi_03_ar_plan_base_person
where amount_plan = 0 and amount_act = 0;

drop table if exists report.kpi_03_person_tem;

