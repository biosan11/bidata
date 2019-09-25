
truncate table edw.x_outdepot_history;

insert into edw.x_outdepot_history
select a.auto_id
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end  as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end  as bi_cusname
      ,case when c.ccusname is null then '请核查' else c.bi_cuscode end  as bi_cuscode
      ,case when c.ccusname is null then '请核查' else c.bi_cusname end  as bi_cusname
      ,a.ddate
      ,a.item_code
      ,case when d.item_code is null then '请核查' else d.bi_item_code end as bi_item_code
      ,case when d.item_code is null then '请核查' else d.bi_item_name end as bi_item_name
      ,a.product_ori
      ,case when e.cinvname is null then '请核查' else e.bi_cinvcode end  as bi_cinvcode
      ,case when e.cinvname is null then '请核查' else e.bi_cinvname end  as bi_cinvname
      ,a.cinvcode_ori
      ,a.product
      ,a.specification_type
      ,a.price
      ,a.iquantity
      ,a.price1
      ,a.inum_person
      ,a.item_details
      ,a.cverifier
  from ufdata.x_outdepot_history a
  left join (select ccuscode,ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select ccuscode,ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname
  left join (select item_code,bi_item_code,bi_item_name from edw.dic_item group by item_code) d
    on a.item_code = d.item_code
  left join (select cinvname,bi_cinvcode,cinvcode,bi_cinvname from edw.dic_inventory group by cinvcode) e
    on a.cinvcode_ori = e.cinvcode
;




