
truncate table edw.x_out_inv_relation;
insert into edw.x_out_inv_relation
select a.db
      ,a.ddate
      ,a.cdlcode
      ,a.cstcode
      ,a.cdepname
      ,a.cpersonname
      ,a.ccusname
      ,case when b.ccuscode is null then '请核查' else b.bi_cuscode end as bi_ccuscode
      ,case when b.ccuscode is null then '请核查' else b.bi_cusname end as bi_ccusname
      ,a.province
      ,a.city
      ,a.cmemo
      ,a.cinvcode
      ,a.cinvname
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvcode end as bi_cinvcode
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvname end as bi_cinvname
      ,a.iquantity
      ,a.cdefine22
      ,a.cdefine23
      ,a.isettlequantity
      ,a.plan_dt
      ,state
      ,iunitcost
  from ufdata.x_out_inv_relation a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) d
    on a.cinvcode = d.cinvcode
;
