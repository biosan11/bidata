------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：cusitem_person_add.sql
--目标模型：cusitem_person_add
--源    表：edw.x_cusitem_person,edw.invoice_order
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------


-- 在第三层发票列表中, 取出所有无人员信息的客户项目
drop table if exists pdm.invoice_order_pre;
create temporary table pdm.invoice_order_pre as
select finnal_ccuscode
      ,item_code
      ,cbustype
      ,ddate
      ,cohr
      ,cinvcode
      ,cast(null as char(60)) as areadirector
      ,cast(null as char(60)) as cverifier
  from pdm.invoice_order a
 where a.ddate >='2020-01-01'
   and a.item_code != 'JK0101'
   and a.cohr != '杭州贝生' 
;

-- 按照王涛提供的客户项目负责人跟新18年以后的数据
update pdm.invoice_order_pre a
 inner join edw.x_cusitem_person b
    on a.finnal_ccuscode = b.bi_cuscode
   and a.item_code = b.item_code
   and a.cbustype = b.cbustype
   set a.areadirector = b.areadirector
      ,a.cverifier = b.cverifier
 where a.ddate >= '2018-01-01'
   and a.ddate >= b.start_dt
   and a.ddate  < b.end_dt
;



drop table if exists pdm.cusitem_person_add;
create temporary table pdm.cusitem_person_add as
select 
    a.finnal_ccuscode as ccuscode
    ,c.city
    ,a.item_code
    ,a.cbustype
    ,b.screen_class
    ,b.equipment
    ,cast(null as char(60)) as areadirector
    ,cast(null as char(60)) as mark_area
    ,cast(null as char(60)) as cverifier
    ,cast(null as char(60)) as mark_cver
from pdm.invoice_order_pre as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode 
left join edw.map_customer as c 
on a.finnal_ccuscode = c.bi_cuscode
where a.ddate >='2020-01-01'
and a.item_code != 'JK0101'
and a.cohr != '杭州贝生' 
and a.areadirector is null and a.cverifier is null 
group by a.finnal_ccuscode,a.item_code,a.cbustype;


-- 从线下表中, 提取最新的客户项目负责人数据 (20年)
drop temporary table if exists pdm.cusitem_person_recent;
create temporary table if not exists pdm.cusitem_person_recent
select 
    a.bi_cuscode
    ,a.item_code
    ,a.cbustype
    ,a.areadirector
    ,a.cverifier
    ,b.bi_cusname 
    ,b.sales_dept
    ,b.sales_region_new
    ,b.province 
    ,b.city 
    ,c.level_three 
    ,c.equipment
    ,c.screen_class
from (
    select 
        bi_cuscode
        ,item_code
        ,cbustype 
        ,areadirector
        ,cverifier
    from edw.x_cusitem_person 
    where start_dt >= '2020-01-01'
    order by end_dt desc
    ) as a 
left join edw.map_customer as b 
on a.bi_cuscode = b.bi_cuscode 
left join edw.map_item as c 
on a.item_code = c.item_code 
group by bi_cuscode,item_code,cbustype ;

-- 先处理主管

-- 1.以客户+筛查诊断 区分 
drop temporary table if exists pdm.cusitem_person_zhuguan01;
create temporary table if not exists pdm.cusitem_person_zhuguan01
select 
    a.bi_cuscode as ccuscode 
    ,a.screen_class
    ,a.areadirector
from (
    select 
        bi_cuscode 
        ,screen_class
        ,areadirector 
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,screen_class,areadirector
    order by count_ desc
    ) as a 
group by a.bi_cuscode,a.screen_class;

-- 2.以客户区分 
drop temporary table if exists pdm.cusitem_person_zhuguan02;
create temporary table if not exists pdm.cusitem_person_zhuguan02
select 
    a.bi_cuscode as ccuscode 
    ,a.areadirector
from (
    select 
        bi_cuscode 
        ,areadirector 
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,areadirector
    order by count_ desc 
    ) as a 
group by a.bi_cuscode;

-- 3.以地级市区分 
drop temporary table if exists pdm.cusitem_person_zhuguan03;
create temporary table if not exists pdm.cusitem_person_zhuguan03
select 
    a.city
    ,a.areadirector
from (
    select 
        city 
        ,areadirector 
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by city,areadirector
    order by count_ desc 
    ) as a 
group by a.city;

-- 补充数据, 并打上标签 
update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_zhuguan01 as b 
on a.ccuscode = b.ccuscode and a.screen_class = b.screen_class
set a.areadirector = b.areadirector,a.mark_area = 'ccus+sc'
where a.areadirector is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_zhuguan02 as b 
on a.ccuscode = b.ccuscode 
set a.areadirector = b.areadirector,a.mark_area = 'ccus'
where a.areadirector is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_zhuguan03 as b 
on a.city = b.city 
set a.areadirector = b.areadirector,a.mark_area = 'city'
where a.areadirector is null and b.city is not null;

-- 再处理销售负责人

-- 1.以客户+筛查诊断+业务类型+是否设备 区分 
drop temporary table if exists pdm.cusitem_person_xiaoshou01;
create temporary table if not exists pdm.cusitem_person_xiaoshou01
select 
    a.bi_cuscode as ccuscode 
    ,a.screen_class
    ,a.equipment
    ,a.cbustype
    ,a.cverifier
from (
    select 
        bi_cuscode 
        ,screen_class
        ,equipment
        ,cbustype
        ,cverifier
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,screen_class,equipment,cbustype,cverifier
    order by count_ desc
    ) as a 
group by a.bi_cuscode,a.screen_class,a.equipment,a.cbustype;

-- 2.以客户+筛查诊断+业务类型 区分 
drop temporary table if exists pdm.cusitem_person_xiaoshou02;
create temporary table if not exists pdm.cusitem_person_xiaoshou02
select 
    a.bi_cuscode as ccuscode 
    ,a.screen_class
    ,a.cbustype
    ,a.cverifier
from (
    select 
        bi_cuscode 
        ,screen_class
        ,cbustype
        ,cverifier
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,screen_class,cbustype,cverifier
    order by count_ desc
    ) as a 
group by a.bi_cuscode,a.screen_class,a.cbustype;

-- 3.以客户+筛查诊断 区分 
drop temporary table if exists pdm.cusitem_person_xiaoshou03;
create temporary table if not exists pdm.cusitem_person_xiaoshou03
select 
    a.bi_cuscode as ccuscode 
    ,a.screen_class
    ,a.cverifier
from (
    select 
        bi_cuscode 
        ,screen_class
        ,cverifier
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,screen_class,cverifier
    order by count_ desc
    ) as a 
group by a.bi_cuscode,a.screen_class;

-- 4.以客户 区分 
drop temporary table if exists pdm.cusitem_person_xiaoshou04;
create temporary table if not exists pdm.cusitem_person_xiaoshou04
select 
    a.bi_cuscode as ccuscode 
    ,a.cverifier
from (
    select 
        bi_cuscode 
        ,cverifier
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by bi_cuscode,cverifier
    order by count_ desc
    ) as a 
group by a.bi_cuscode;

-- 5.以地级市 区分 
drop temporary table if exists pdm.cusitem_person_xiaoshou05;
create temporary table if not exists pdm.cusitem_person_xiaoshou05
select 
    a.city 
    ,a.cverifier
from (
    select 
        city 
        ,cverifier
        ,count(*) as count_
    from pdm.cusitem_person_recent 
    group by city,cverifier
    order by count_ desc
    ) as a 
group by a.city;

-- 补充数据, 并打上标签 
update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_xiaoshou01 as b 
on a.ccuscode = b.ccuscode and a.screen_class = b.screen_class and a.cbustype = b.cbustype and a.equipment = b.equipment
set a.cverifier = b.cverifier,a.mark_cver = 'ccus+sc+cbus+eq'
where a.cverifier is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_xiaoshou02 as b 
on a.ccuscode = b.ccuscode and a.screen_class = b.screen_class and a.cbustype = b.cbustype
set a.cverifier = b.cverifier,a.mark_cver = 'ccus+sc+cbus'
where a.cverifier is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_xiaoshou03 as b 
on a.ccuscode = b.ccuscode and a.screen_class = b.screen_class
set a.cverifier = b.cverifier,a.mark_cver = 'ccus+sc'
where a.cverifier is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_xiaoshou04 as b 
on a.ccuscode = b.ccuscode 
set a.cverifier = b.cverifier,a.mark_cver = 'ccuscode'
where a.cverifier is null and b.ccuscode is not null;

update pdm.cusitem_person_add as a 
left join pdm.cusitem_person_xiaoshou05 as b 
on a.city = b.city 
set a.cverifier = b.cverifier,a.mark_cver = 'city'
where a.cverifier is null and b.city is not null;

truncate table pdm.cusitem_person;
insert into pdm.cusitem_person
select start_dt
      ,end_dt
      ,bi_cuscode
      ,bi_cusname
      ,item_code
      ,item_name
      ,cbustype
      ,areadirector
      ,'线下'
      ,cverifier
      ,'线下'
  from edw.x_cusitem_person
;

-- 插入线上数据
insert into pdm.cusitem_person
select '2020-01-01'
      ,'2021-01-01'
      ,a.ccuscode
      ,b.bi_cusname
      ,a.item_code
      ,c.level_three
      ,a.cbustype
      ,a.areadirector
      ,a.mark_area
      ,a.cverifier
      ,a.mark_cver
  from pdm.cusitem_person_add a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_code = c.item_code
 where a.areadirector is not null
   and a.cverifier is not null
;
