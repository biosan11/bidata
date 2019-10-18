
truncate table edw.x_sales_budget_19;

create temporary table ufdata.x_sales_budget_19_pre as
select a.*
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查'end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查'end as bi_cusname
  from ufdata.x_sales_budget_19 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
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





