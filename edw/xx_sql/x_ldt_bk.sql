
truncate table edw.x_ldt_bk;
insert into edw.x_ldt_bk
select a.*
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,case when c.cinvname is null then '请核查' else C.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else C.bi_cinvname end as bi_cinvname
      ,d.item_code
      ,d.level_three as item_name
      ,d.business_class
      ,e.province
  from ufdata.x_ldt_bk a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory where db = 'BKJC') c
    on a.cinvname = c.cinvname
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
  left join (select * from edw.map_customer group by bi_cuscode) e
    on b.bi_cuscode = e.bi_cuscode
;





