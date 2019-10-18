
create temporary table pdm.invoice_order_item as
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

delete from pdm.invoice_order where db = 'bkgr';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,'bkgr'
      ,'贝康个人'
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
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,null
      ,null
      ,case when year(a.ddate) = '2019' then ifnull(a.isum,0) /(1+0.06)*0.06
            when year(a.ddate) = '2018' then ifnull(a.isum,0) /(1+0.06)*0.06
          else null end
      ,ifnull(a.isum,0)
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,null
      ,null
      ,localtimestamp()
  from edw.x_sales_bkgr a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
 where year(a.ddate) >= 2018
   and a.method_settlement = '个人'
   and a.accounts like '%贝康%';

delete from pdm.invoice_order where db = 'bk';
delete from pdm.invoice_order where db = 'zyjk';
delete from pdm.invoice_order where db = 'zysy';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,case when a.db = 'bk' then 'bk'
            when a.db = 'ZYJK' then 'zyjk'
            else 'zysy' end
      ,case when a.db = 'bk' then '贝康'
            when a.db = 'ZYJK' then '甄元健康'
            else '甄元实验室' end
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
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,a.price
      ,a.iquantity
      ,case when year(a.ddate) = '2019' then a.itax
            when year(a.ddate) = '2018' then ifnull(a.isum,0) /(1+0.06)*0.06
          else null end
      ,ifnull(a.isum,0)
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,null
      ,null
      ,localtimestamp()
  from edw.x_sales_bk a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
 where year(a.ddate)>=2018
;


delete from pdm.invoice_order where db = 'old';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,'old'
      ,case when a.db = '博圣' then '博圣' 
            when a.db = '四川美博特' then '美博特'
            when a.db = '湖北奥博特' then '奥博特'
            when a.db = '贝康' then '贝康'
            when a.db = 'UFDATA_111_2018' then '博圣'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_666_2018' then '启代'
            end
      ,null
      ,null
      ,null
      ,null
      ,null
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.type
      ,a.true_ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname
      ,d.business_class
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,null
      ,null
      ,a.isum - a.itax_excluded
      ,a.isum
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,null
      ,null
      ,localtimestamp()
  from edw.x_sales_history a
  left join (select bi_cuscode,bi_cusname,sales_region,province,city,type from edw.map_customer group by bi_cusname) b
    on a.true_finnal_ccusname = b.bi_cusname
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
  left join (select bi_cinvcode,business_class from edw.map_inventory group by bi_cinvcode) d
    on a.bi_cinvcode = d.bi_cinvcode
 where year(a.ddate) < 2018 or (a.auto_id >= '448548')
;

