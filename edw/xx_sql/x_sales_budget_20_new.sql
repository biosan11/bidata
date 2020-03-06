
-- 20年预期收入发货表
truncate table edw.x_sales_budget_20_new;
insert into edw.x_sales_budget_20_new
select a.ddate
      ,a.cohr
      ,a.sales_region
      ,a.areadirector
      ,a.cverifier
      ,a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cusname end as bi_cusname
      ,d.screen_class
      ,d.level_one
      ,d.level_two
      ,d.item_code
      ,d.level_three as item_name
      ,a.cinvcode
      ,a.cinvname
      ,case when c.bi_cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.bi_cinvcode is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,d.business_class as cbustype
      ,d.equipment
      ,a.inum_person_new
      ,a.isum_budget_new
  from ufdata.x_sales_budget_20_new a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
 ;


