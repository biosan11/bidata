
truncate table edw.x_sales_hzbs;
insert into edw.x_sales_hzbs
select a.ddate
      ,a.cohr
      ,a.ccuscode
      ,a.ccusname
      ,b.bi_cuscode
      ,b.bi_cusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,c.bi_cuscode as true_finnal_ccuscode
      ,c.bi_cusname as true_finnal_ccusname
      ,e.business_class as cbustype
      ,a.cinvcode
      ,a.cinvname
      ,d.bi_cinvcode
      ,d.bi_cinvname
      ,e.item_code
      ,e.level_one
      ,e.level_two
      ,e.level_three
      ,a.itaxunitprice
      ,a.itax
      ,a.iquantity
      ,a.isum
  from ufdata.x_sales_hzbs a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) d
    on a.cinvcode = d.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) e
    on d.bi_cinvcode = e.bi_cinvcode
;
