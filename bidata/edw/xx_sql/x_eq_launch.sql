
truncate table edw.x_eq_launch;
insert into edw.x_eq_launch
select a.cohr
      ,a.year_month
      ,a.vouchid
      ,a.sales_return
      ,a.ccusname_ori
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as ccuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as ccusname
      ,a.cperson
      ,a.finnal_ccuaname_ori
      ,case when c.ccusname is null then '请核查' else c.bi_cuscode end as finnal_ccuscode
      ,case when c.ccusname is null then '请核查' else c.bi_cusname end as finnal_ccusname
      ,a.cinvcode_oir
      ,a.cinvname_ori
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvcode end as cinvcode
      ,case when d.cinvcode is null then '请核查' else d.bi_cinvname end as cinvname
      ,a.iquantity
      ,a.itb
      ,a.comment
  from ufdata.x_eq_launch a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname_ori = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.finnal_ccuaname_ori = c.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) d
    on upper(a.cinvcode_oir) = d.cinvcode
;























