
truncate table edw.x_cusitem_person;
insert into edw.x_cusitem_person
select a.start_dt
      ,a.end_dt
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.item_code as item_code_old
      ,a.item_name as item_name_old
      ,case when c.item_code is null then '请核查' else c.item_code end as item_code
      ,case when c.item_code is null then '请核查' else c.level_three end as item_name
      ,a.cbustype
      ,a.areadirector
      ,a.cverifier
  from ufdata.x_cusitem_person a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
;


