
truncate table pdm.outdepot_order;
create temporary table pdm.outdepot_order_pre as 
select a.*
      ,b.type as ccustype
  from edw.outdepot_order a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 where left(a.sys_time,10) > '2019-01-01'
  and year(ddate)>=2018;


delete from pdm.outdepot_order_pre where left(true_ccuscode,2) = 'GL';
delete from pdm.outdepot_order_pre where left(bi_cinvcode,2) = 'JC';

create temporary table pdm.outdepot_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,f.plan_class
      ,f.key_project
   from (select bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;

insert into pdm.outdepot_order
select a.id
      ,a.autoid
      ,a.db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '杭州贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝荣'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '美博特'
            end
      ,a.ddate
      ,a.cwhcode
      ,c.cwhname
      ,a.cdepcode
      ,d.cdepname
      ,a.cpersoncode
      ,b.sales_region
      ,b.province
      ,b.city
      ,a.ccustype
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname2 as finnal_ccusname
      ,e.business_class
      ,a.cdefine22
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,md5(a.iunitcost)
      ,a.iquantity
      ,md5(a.iprice)
      ,a.inum_person
      ,a.true_itemcode
      ,e.plan_class
      ,e.key_project
      ,case when f.item_code is not null and a.citemname is null then f.level_three else a.citemname end 
      ,null
      ,e.cinvbrand
      ,a.cstcode
      ,a.fsettleqty
      ,localtimestamp()
  from pdm.outdepot_order_pre a
  left join edw.map_customer b
    on a.true_finnal_ccuscode = b.bi_cuscode 
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.outdepot_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) f
    on a.true_itemcode = f.item_code
;



create temporary table pdm.x_outdepot_history as
select a.*
      ,b.type as ccustype
  from edw.x_outdepot_history a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 where year(ddate) < 2018;

create temporary table pdm.outdepot_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,f.plan_class
      ,f.key_project
   from (select bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;

insert into pdm.outdepot_order
select null
      ,a.auto_id
      ,'old'
      ,'博圣'
      ,a.ddate
      ,null
      ,null
      ,null
      ,null
      ,a.cverifier
      ,b.sales_region
      ,b.province
      ,b.city
      ,a.ccustype
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname as finnal_ccusname
      ,e.business_class
      ,null
      ,a.true_cinvcode as cinvcode
      ,a.true_cinvname as cinvname
      ,a.price1
      ,case when a.iquantity is null and g.inum_unit_person > 0 then a.inum_person/g.inum_unit_person
            when a.iquantity is null and g.inum_unit_person is null then '请核查'
            else a.iquantity end as iquantity
      ,null
      ,a.inum_person
      ,a.true_item_code
      ,e.plan_class
      ,e.key_project
      ,case when f.item_code is not null then f.level_three end 
      ,null
      ,e.cinvbrand
      ,null
      ,null
      ,localtimestamp()
  from pdm.x_outdepot_history a
  left join edw.map_customer b
    on a.true_finnal_ccuscode = b.bi_cuscode 
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.outdepot_order_item group by bi_cinvcode) e
    on a.true_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) f
    on a.true_item_code = f.item_code
  left join (select bi_cinvcode,inum_unit_person from edw.map_inventory group by bi_cinvcode) g
    on a.true_cinvcode = g.bi_cinvcode
;


insert into pdm.outdepot_order
select null
      ,min(auto_id)
      ,'bkgr'
      ,'贝康个人'
      ,a.ddate
      ,null
      ,null
      ,null
      ,null
      ,null
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.type
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,b.finnal_cuscode
      ,b.finnal_ccusname
      ,'LDT'
      ,null
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,null
      ,case when g.inum_unit_person > 0 then count(*)/g.inum_unit_person
            when g.inum_unit_person is null then '请核查'
            else count(*) end as iquantity
      ,null
      ,count(*) as inum_person
      ,a.item_code
      ,null
      ,null
      ,case when f.item_code is not null then f.level_three end 
      ,null
      ,null
      ,null
      ,null
      ,localtimestamp()
  from edw.x_sales_bkgr a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select item_code,level_three from edw.map_item group by item_code) f
    on a.item_code = f.item_code
  left join (select bi_cinvcode,inum_unit_person from edw.map_inventory group by bi_cinvcode) g
    on a.bi_cinvcode = g.bi_cinvcode
 group by a.ddate,a.true_ccuscode,a.bi_cinvcode
;



