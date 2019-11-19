
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

-- 插入18年线下数据
delete from pdm.outdepot_order where year(ddate) = '2018';
insert into pdm.outdepot_order
select a.id
      ,a.autoid
      ,a.db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '杭州贝生'
            when a.db = 'UFDATA_168_2019' then '杭州贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝荣'
            when a.db = 'UFDATA_222_2019' then '宝荣'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '奥博特'
            when a.db = 'UFDATA_588_2019' then '奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '美博特'
            when a.db = 'UFDATA_889_2019' then '美博特'
            when a.db = 'UFDATA_555_2018' then '贝安云'
            end
      ,a.ccode
      ,a.ddate
      ,a.cwhcode
      ,c.cwhname
      ,a.cdepcode
      ,d.cdepname
      ,a.cpersoncode
      ,a.sales_region
      ,a.province
      ,a.city
      ,a.ccustype
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname
      ,a.cbustype
      ,a.sales_region
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.iunitcost
      ,a.iquantity
      ,a.iprice
      ,a.inum_person
      ,a.item_code
      ,b.plan_class
      ,b.key_project
      ,a.item_name
      ,null
      ,b.cinvbrand
      ,a.cstcode
      ,a.fsettleqty
      ,a.iorderdid
      ,a.idlsid
      ,localtimestamp()
  from edw.x_outdepot_order_18 a
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.outdepot_order_item group by bi_cinvcode) b
    on a.bi_cinvcode = b.bi_cinvcode
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
;

--  插入数据，计算数量屏蔽远比含税单价
delete from pdm.outdepot_order where db = 'old';
insert into pdm.outdepot_order
select null
      ,a.auto_id
      ,'old'
      ,'博圣'
      ,null
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
      ,g.item_code
      ,e.plan_class
      ,e.key_project
      ,g.level_three
      ,null
      ,e.cinvbrand
      ,null
      ,null
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
  left join (select * from edw.map_inventory group by bi_cinvcode) g
    on a.true_cinvcode = g.bi_cinvcode
;


-- 增加对无效客户的删除
delete from pdm.outdepot_order where left(ccuscode,2) = 'GL';
delete from pdm.outdepot_order where left(cinvcode,2) = 'JC';


-- 检测外送数据的插入
-- 按时间时间，客户，产品分组排序，取月维度的信息
-- delete from pdm.outdepot_order where db = 'bkgr';
-- insert into pdm.outdepot_order
-- select null
--       ,min(auto_id)
--       ,'bkgr'
--       ,'贝康个人'
--       ,null
--       ,a.ddate
--       ,null
--       ,null
--       ,null
--       ,null
--       ,null
--       ,b.sales_region
--       ,b.province
--       ,b.city
--       ,b.type
--       ,a.true_ccuscode as ccuscode
--       ,a.true_ccusname as ccusname
--       ,b.finnal_cuscode
--       ,b.finnal_ccusname
--       ,'LDT'
--       ,null
--       ,a.bi_cinvcode
--       ,a.bi_cinvname
--       ,null
--       ,case when g.inum_unit_person > 0 then count(*)/g.inum_unit_person
--             when g.inum_unit_person is null then '请核查'
--             else count(*) end as iquantity
--       ,null
--       ,count(*) as inum_person
--       ,a.item_code
--       ,null
--       ,null
--       ,case when f.item_code is not null then f.level_three end 
--       ,null
--       ,null
--       ,null
--       ,null
--       ,localtimestamp()
--   from edw.x_sales_bkgr a
--   left join edw.map_customer b
--     on a.true_ccuscode = b.bi_cuscode
--   left join (select item_code,level_three from edw.map_item group by item_code) f
--     on a.item_code = f.item_code
--   left join (select bi_cinvcode,inum_unit_person from edw.map_inventory group by bi_cinvcode) g
--     on a.bi_cinvcode = g.bi_cinvcode
--  where left(true_ccuscode,2) <> 'GL' 
--  group by a.ddate,a.true_ccuscode,a.bi_cinvcode
-- ;
set @n = 99999;
delete from pdm.outdepot_order where db = 'bkgr';
insert into pdm.outdepot_order
select null
      ,(@n := @n + 1) as id
      ,'bkgr'
      ,'贝康个人'
      ,null
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
      ,a.ccuscode
      ,a.ccusname
      ,a.ccuscode
      ,a.ccusname
      ,'LDT'
      ,null
      ,a.cinvcode
      ,a.cinvname
      ,null
      ,case when g.inum_unit_person > 0 then inum_person/g.inum_unit_person
            when g.inum_unit_person is null then inum_person -- 这里存在一点瑕疵
            else inum_person end as iquantity
      ,null
      ,a.inum_person
      ,a.item_code
      ,null
      ,null
      ,case when f.item_code is not null then f.level_three end 
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,localtimestamp()
  from pdm.checklist a
  left join edw.map_customer b
    on a.ccuscode = b.bi_cuscode
  left join (select item_code,level_three from edw.map_item group by item_code) f
    on a.item_code = f.item_code
  left join (select bi_cinvcode,inum_unit_person from edw.map_inventory group by bi_cinvcode) g
    on a.cinvcode = g.bi_cinvcode
 where left(ccuscode,2) <> 'GL' 
   and a.cbustype = 'LDT'
   and a.competitor = '否'
;




