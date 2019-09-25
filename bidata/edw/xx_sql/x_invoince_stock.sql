truncate table edw.x_invoince_stock;
insert into edw.x_invoince_stock
select a.*
      ,b.bi_cuscode as ccuscode
  from ufdata.x_invoince_stock a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
;
  