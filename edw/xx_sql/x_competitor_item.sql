
truncate table edw.x_competitor_item;
insert into edw.x_competitor_item
select a.province
      ,a.city
      ,a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,d.type
      ,a.project_class_name
      ,a.item_code
      ,a.item_name
      ,case when c.item_code is null then '请核查' else c.item_code end as bi_item_code
      ,case when c.item_code is null then '请核查' else c.level_three end as bi_item_name
      ,a.cinvbrand
      ,a.new_project_status
      ,a.specification_type
      ,a.cvenabbname
      ,a.product_start_dt
      ,a.product_end_dt
  from ufdata.x_competitor_item a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.map_customer group by bi_cuscode) d
    on b.bi_cuscode = d.bi_cuscode
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_code = c.item_code
;



