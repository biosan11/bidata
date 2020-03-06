
truncate table edw.x_sales_budget_20;

drop table if exists ufdata.x_sales_budget_20_pre;
create temporary table ufdata.x_sales_budget_20_pre as
select a.*
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查'end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查'end as bi_cusname
      ,case when c.cinvcode is not null then c.bi_cinvcode else '请核查'end as bi_cinvcode
      ,case when c.cinvcode is not null then c.bi_cinvname else '请核查'end as bi_cinvname
  from ufdata.x_sales_budget_20 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2001,0) * plan_success_rate else ifnull(isum_budget_2001,0) * 1 end 
      ,'2020-01-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2002,0) * plan_success_rate else ifnull(isum_budget_2002,0) * 1 end 
      ,'2020-02-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2003,0) * plan_success_rate else ifnull(isum_budget_2003,0) * 1 end 
      ,'2020-03-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2004,0) * plan_success_rate else ifnull(isum_budget_2004,0) * 1 end 
      ,'2020-04-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2005,0) * plan_success_rate else ifnull(isum_budget_2005,0) * 1 end 
      ,'2020-05-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2006,0) * plan_success_rate else ifnull(isum_budget_2006,0) * 1 end 
      ,'2020-06-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2007,0) * plan_success_rate else ifnull(isum_budget_2007,0) * 1 end 
      ,'2020-07-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2008,0) * plan_success_rate else ifnull(isum_budget_2008,0) * 1 end 
      ,'2020-08-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2009,0) * plan_success_rate else ifnull(isum_budget_2009,0) * 1 end 
      ,'2020-09-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2010,0) * plan_success_rate else ifnull(isum_budget_2010,0) * 1 end 
      ,'2020-10-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2011,0) * plan_success_rate else ifnull(isum_budget_2011,0) * 1 end 
      ,'2020-11-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;

insert into edw.x_sales_budget_20
select autoid
      ,cohr
      ,sales_region
      ,areadirector
      ,cverifier
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
      ,case when cohr = '博圣体系' then ifnull(isum_budget_2012,0) * plan_success_rate else ifnull(isum_budget_2012,0) * 1 end 
      ,'2020-12-01' as ddate
      ,own_product
  from ufdata.x_sales_budget_20_pre
;












