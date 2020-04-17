
truncate table edw.x_out_inv_relation;
insert into edw.x_out_inv_relation
select a.db
      ,a.cdlcode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when c.ccuscode is null then '请核查' else c.bi_cuscode end as bi_ccuscode
      ,case when c.ccuscode is null then '请核查' else c.bi_cusname end as bi_ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,case when b.ccuscode is null then '请核查' else b.bi_cuscode end as true_finnal_ccuscode
      ,case when b.ccuscode is null then '请核查' else b.bi_cusname end as true_finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvcode end as bi_cinvcode
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvname end as bi_cinvname
      ,a.cinvcode_old
      ,a.cdefine22
      ,a.iquantity
      ,a.isettlequantity
      ,a.cdefine23
      ,a.price
      ,a.plan_dt
      ,a.cstcode
      ,a.cdepname
      ,a.cpersonname
      ,a.province
      ,a.city
      ,a.cmemo
      ,a.type
      ,a.beizhu
  from ufdata.x_out_inv_relation a
  left join (select * from edw.dic_customer group by ccuscode) b
    on a.finnal_ccuscode = b.ccuscode
  left join (select * from edw.dic_customer group by ccuscode) c
    on a.ccuscode = c.ccuscode
  left join (select * from edw.dic_inventory group by cinvcode) d
    on a.cinvcode = d.cinvcode
;