
truncate table edw.x_ccus_delivery;
insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate
      ,a.inum_person
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;





