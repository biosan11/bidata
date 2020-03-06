
truncate table edw.x_sales_budget_19;

drop table if exists ufdata.x_sales_budget_19_pre;
create temporary table ufdata.x_sales_budget_19_pre as
select a.autoid
      ,a.cohr
      ,a.uniqueid
      ,a.type
      ,a.sales_region
      ,a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.screen_class
      ,a.cbustype
      ,a.equipment
      ,a.level_one
      ,a.level_two
      ,a.item_code
      ,a.level_three
      ,c.bi_cinvcode as cinvcode
      ,c.bi_cinvname as cinvname
      ,a.plan_class
      ,a.key_project
      ,a.plan_complete_dt
      ,a.plan_success_rate
      ,a.iunitcost
      ,a.inum_person_1901
      ,a.inum_person_1902
      ,a.inum_person_1903
      ,a.inum_person_1904
      ,a.inum_person_1905
      ,a.inum_person_1906
      ,a.inum_person_1907
      ,a.inum_person_1908
      ,a.inum_person_1909
      ,a.inum_person_1910
      ,a.inum_person_1911
      ,a.inum_person_1912
      ,a.inum_person_addup_19
      ,a.isum_budget_addup_19
      ,a.isum_budget_1901
      ,a.isum_budget_1902
      ,a.isum_budget_1903
      ,a.isum_budget_1904
      ,a.isum_budget_1905
      ,a.isum_budget_1906
      ,a.isum_budget_1907
      ,a.isum_budget_1908
      ,a.isum_budget_1909
      ,a.isum_budget_1910
      ,a.isum_budget_1911
      ,a.isum_budget_1912
      ,a.comment
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查'end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查'end as bi_cusname
  from ufdata.x_sales_budget_19 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
;

-- 1901
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-01-01"
	,inum_person_1901
	,iunitcost
	,isum_budget_1901
	,null
from ufdata.x_sales_budget_19_pre;

-- 1902
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-02-01"
	,inum_person_1902
	,iunitcost
	,isum_budget_1902
	,null
from ufdata.x_sales_budget_19_pre;

-- 1903
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-03-01"
	,inum_person_1903
	,iunitcost
	,isum_budget_1903
	,null
from ufdata.x_sales_budget_19_pre;

-- 1904
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-04-01"
	,inum_person_1904
	,iunitcost
	,isum_budget_1904
	,null
from ufdata.x_sales_budget_19_pre;

-- 1905
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-05-01"
	,inum_person_1905
	,iunitcost
	,isum_budget_1905
	,null
from ufdata.x_sales_budget_19_pre;

-- 1906
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-06-01"
	,inum_person_1906
	,iunitcost
	,isum_budget_1906
	,null
from ufdata.x_sales_budget_19_pre;

-- 1907
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-07-01"
	,inum_person_1907
	,iunitcost
	,isum_budget_1907
	,null
from ufdata.x_sales_budget_19_pre;

-- 1908
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-08-01"
	,inum_person_1908
	,iunitcost
	,isum_budget_1908
	,null
from ufdata.x_sales_budget_19_pre;

-- 1909
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-09-01"
	,inum_person_1909
	,iunitcost
	,isum_budget_1909
	,null
from ufdata.x_sales_budget_19_pre;

-- 1910
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-10-01"
	,inum_person_1910
	,iunitcost
	,isum_budget_1910
	,null
from ufdata.x_sales_budget_19_pre;

-- 1911
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-11-01"
	,inum_person_1911
	,iunitcost
	,isum_budget_1911
	,null
from ufdata.x_sales_budget_19_pre;

-- 1912
insert into edw.x_sales_budget_19
select 
	 autoid
	,cohr
	,uniqueid
	,type
	,sales_region
	,province
	,city
	,ccuscode
	,ccusname
	,bi_cuscode
	,bi_cusname
	,screen_class
	,cbustype
	,equipment
	,level_one
	,level_two
	,item_code
	,level_three
	,cinvcode
	,cinvname
	,plan_class
	,key_project
	,plan_complete_dt
	,null
	,plan_success_rate
	,"2019-12-01"
	,inum_person_1912
	,iunitcost
	,isum_budget_1912
	,null
from ufdata.x_sales_budget_19_pre;


-- 重新计算 计划完成时间

update edw.x_sales_budget_19 as a 
inner join 
(
select uniqueid,min(ddate) as plan_complete_dt_recount
from edw.x_sales_budget_19 
where inum_person > 0
group by uniqueid
) as b
on a.uniqueid = b.uniqueid
set a.plan_complete_dt_recount = b.plan_complete_dt_recount;

-- 更新第一层数据，没有进行清洗数据存在问题
update ufdata.x_sales_budget_19_proportion a
 inner join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
   set a.cinvcode = c.bi_cinvcode
;


insert into edw.x_sales_budget_19
select null
      ,cohr
      ,null
      ,null
      ,null
      ,null
      ,null
      ,ccuscode
      ,null
      ,ccuscode
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,item_code
      ,null
      ,cinvcode
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,ddate
      ,null
      ,null
      ,null
      ,isum_budget
  from ufdata.x_sales_budget_19_proportion
;


