truncate table edw.x_insure_cover;
insert into edw.x_insure_cover
select a.province
      ,a.city
      ,a.hospital
      ,case when a.hospital is not null and b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when a.hospital is not null and b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.item_name
      ,case when a.item_name is not null and c.bi_cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when a.item_name is not null and c.bi_cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,a.ddate
      ,a.insure_num
      ,a.tickling
      ,a.collect_num
      ,a.sales
      ,a.act_num
      ,a.iappids
      ,a.iunitcost
  from ufdata.x_insure_cover a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.item_name = c.cinvname
;