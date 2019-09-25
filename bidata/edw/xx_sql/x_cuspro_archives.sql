-- 清洗客户和产品
truncate table edw.x_cuspro_archives;
insert into edw.x_cuspro_archives
select a.auto_id
      ,a.new_name as device_id
      ,a.device_name as cinvcode
      ,a.new_product as cinvname
      ,case when c.cinvcode is null then '请核查' 
            when c.bi_cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvcode is null then '请核查' 
            when c.bi_cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,a.new_model as specification_type
      ,a.new_use_mode as use_state
      ,a.ownerid as cverifier
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccuscode is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccuscode is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.new_prod_brand
      ,a.new_installation_date
      ,a.new_instrument_nature
      ,a.new_administrative_office
      ,a.new_supplier as cvenabbname
      ,a.new_original_date
      ,a.new_expiration_date
      ,a.new_open_project
      ,a.new_main
      ,a.new_competitor
      ,a.statecode
  from ufdata.x_cuspro_archives a
  left join (select ccuscode,bi_cuscode,bi_cusname from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
  left join (select cinvcode,bi_cinvcode,bi_cinvname from edw.dic_inventory group by cinvcode) c
    on a.device_name = c.cinvcode
  left join edw.map_inventory d
    on c.bi_cinvcode = d.bi_cinvcode
;




