
truncate table edw.x_ccus_invoice;
insert into edw.x_ccus_invoice
select year_
      ,a.cusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
  from ufdata.x_ccus_invoice a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.cusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
;