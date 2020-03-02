
truncate table edw.x_ccus_delivery;
insert into edw.x_ccus_delivery
select a.*
      ,b.bi_cuscode as bi_cuscode
      ,b.bi_cusname as bi_cusname
      ,c.item_code
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
;





