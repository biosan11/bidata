
truncate table edw.x_sales_budget_20;

drop table if exists ufdata.x_sales_budget_20_pre;
create temporary table ufdata.x_sales_budget_20_pre as
select a.autoid
      ,a.cohr
      ,e.sales_dept
      ,a.areadirector
      ,a.cverifier
      ,e.sales_region_new
      ,e.province
      ,e.city
      ,a.ccuscode
      ,a.ccusname
      ,d.screen_class
      ,d.level_one
      ,d.level_two
      ,d.item_code
      ,d.level_three as item_name
      ,a.cinvcode
      ,a.cinvname
      ,d.business_class as cbustype
      ,d.equipment
      ,d.cinvbrand
      ,a.plan_class
      ,a.iunitcost
      ,a.plan_complete_dt
      ,a.plan_success_rate
      ,a.inum_person_2001
      ,a.inum_person_2002
      ,a.inum_person_2003
      ,a.inum_person_2004
      ,a.inum_person_2005
      ,a.inum_person_2006
      ,a.inum_person_2007
      ,a.inum_person_2008
      ,a.inum_person_2009
      ,a.inum_person_2010
      ,a.inum_person_2011
      ,a.inum_person_2012
      ,a.inum_person_addup_20
      ,a.isum_budget_2001
      ,a.isum_budget_2002
      ,a.isum_budget_2003
      ,a.isum_budget_2004
      ,a.isum_budget_2005
      ,a.isum_budget_2006
      ,a.isum_budget_2007
      ,a.isum_budget_2008
      ,a.isum_budget_2009
      ,a.isum_budget_2010
      ,a.isum_budget_2011
      ,a.isum_budget_2012
      ,a.isum_budget_addup_20
      ,a.itaxrate
      ,a.own_product
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查'end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查'end as bi_cusname
      ,case when c.cinvcode is not null then c.bi_cinvcode else '请核查'end as bi_cinvcode
      ,case when c.cinvcode is not null then c.bi_cinvname else '请核查'end as bi_cinvname
  from ufdata.x_sales_budget_20 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
  left join (select * from edw.map_inventory) d
    on c.bi_cinvcode = d.bi_cinvcode
  left join (select * from edw.map_customer) e
    on b.bi_cuscode = e.bi_cuscode
;


insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2001,0) as inum_person
      ,ifnull(isum_budget_2001,0) as isum_budget
      ,ifnull(inum_person_2001,0) * plan_success_rate
      ,ifnull(isum_budget_2001,0) * plan_success_rate 
      ,'2020-01-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2002,0) as inum_person
      ,ifnull(isum_budget_2002,0) as isum_budget
      ,ifnull(inum_person_2002,0) * plan_success_rate
      ,ifnull(isum_budget_2002,0) * plan_success_rate
      ,'2020-02-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2003,0) as inum_person
      ,ifnull(isum_budget_2003,0) as isum_budget
      ,ifnull(inum_person_2003,0) * plan_success_rate
      ,ifnull(isum_budget_2003,0) * plan_success_rate
      ,'2020-03-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2004,0) as inum_person
      ,ifnull(isum_budget_2004,0) as isum_budget
      ,ifnull(inum_person_2004,0) * plan_success_rate
      ,ifnull(isum_budget_2004,0) * plan_success_rate
      ,'2020-04-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2005,0) as inum_person
      ,ifnull(isum_budget_2005,0) as isum_budget
      ,ifnull(inum_person_2005,0) * plan_success_rate
      ,ifnull(isum_budget_2005,0) * plan_success_rate 
      ,'2020-05-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2006,0) as inum_person
      ,ifnull(isum_budget_2006,0) as isum_budget
      ,ifnull(inum_person_2006,0) * plan_success_rate
      ,ifnull(isum_budget_2006,0) * plan_success_rate
      ,'2020-06-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2007,0) as inum_person
      ,ifnull(isum_budget_2007,0) as isum_budget
      ,ifnull(inum_person_2007,0) * plan_success_rate
      ,ifnull(isum_budget_2007,0) * plan_success_rate 
      ,'2020-07-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2008,0) as inum_person
      ,ifnull(isum_budget_2008,0) as isum_budget
      ,ifnull(inum_person_2008,0) * plan_success_rate
      ,ifnull(isum_budget_2008,0) * plan_success_rate
      ,'2020-08-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2009,0) as inum_person
      ,ifnull(isum_budget_2009,0) as isum_budget
      ,ifnull(inum_person_2009,0) * plan_success_rate
      ,ifnull(isum_budget_2009,0) * plan_success_rate
      ,'2020-09-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2010,0) as inum_person
      ,ifnull(isum_budget_2010,0) as isum_budget
      ,ifnull(inum_person_2010,0) * plan_success_rate
      ,ifnull(isum_budget_2010,0) * plan_success_rate
      ,'2020-10-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2011,0) as inum_person
      ,ifnull(isum_budget_2011,0) as isum_budget
      ,ifnull(inum_person_2011,0) * plan_success_rate
      ,ifnull(isum_budget_2011,0) * plan_success_rate
      ,'2020-11-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_dept
      ,areadirector
      ,cverifier
      ,sales_region_new
      ,province
      ,city
      ,ccuscode
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,screen_class
      ,level_one
      ,level_two
      ,item_code
      ,item_name
      ,cinvcode
      ,cinvname
      ,bi_cinvcode
      ,bi_cinvname
      ,cbustype
      ,equipment
      ,cinvbrand
      ,plan_class
      ,iunitcost
      ,plan_complete_dt
      ,plan_success_rate
      ,itaxrate
      ,ifnull(inum_person_2012,0) as inum_person
      ,ifnull(isum_budget_2012,0) as isum_budget
      ,ifnull(inum_person_2012,0) * plan_success_rate
      ,ifnull(isum_budget_2012,0) * plan_success_rate
      ,'2020-12-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;


-- 更新计划开始时间
-- 取用发票发货最早时间来进行处理
drop table if exists ufdata.x_sales_budget_20_pre1;
create temporary table ufdata.x_sales_budget_20_pre1 as
select true_finnal_ccuscode as bi_cuscode
      ,true_finnal_ccusname2 as bi_cusname
      ,bi_cinvcode
      ,bi_cinvname
      ,min(ddate) as ddate
  from edw.invoice_order where ddate >= '2020-01-01' and ifnull(isum,0) > 0 group by true_finnal_ccuscode,bi_cinvcode union 
select true_finnal_ccuscode as bi_cuscode
      ,true_finnal_ccusname2 as bi_cusname
      ,bi_cinvcode
      ,bi_cinvname
      ,min(ddate) as ddate
  from edw.outdepot_order where ddate >= '2020-01-01' and ifnull(inum_person,0) > 0 group by true_finnal_ccuscode,bi_cinvcode
;

drop table if exists ufdata.x_sales_budget_20_pre2;
create temporary table ufdata.x_sales_budget_20_pre2 as
select bi_cuscode,bi_cinvcode,min(ddate) as ddate
  from ufdata.x_sales_budget_20_pre1
 group by bi_cuscode,bi_cinvcode
;

update edw.x_sales_budget_20 set plan_complete_dt = null;

update edw.x_sales_budget_20 a
 inner join ufdata.x_sales_budget_20_pre2 b
    on a.bi_cuscode = b.bi_cuscode
   and a.bi_cinvcode = b.bi_cinvcode
   set a.plan_complete_dt = b.ddate
 where a.isum_budget_ori > 0
;










