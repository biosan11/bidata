truncate table edw.x_insure_cover;
insert into edw.x_insure_cover
select d.province
      ,d.city
      ,a.hospital
      ,case when a.hospital is not null and b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when a.hospital is not null and b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.item_name
      ,case 
            when left(a.item_name,2) ='串联' then '串联'
            when a.item_name = 'NIPT' then 'NIPT'
            when a.item_name = 'NIPT保险' then 'NIPT'
            when a.item_name = 'NIPT plus' then 'NIPT-pro'
            when a.item_name = 'NIPT plus保险' then 'NIPT-pro'
            else '请核查'
       end as item_name_ad
      ,null as bi_cinvcode
      ,null as bi_cinvname
      -- ,case when a.item_name is not null and c.bi_cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      -- ,case when a.item_name is not null and c.bi_cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,a.ddate
      ,ifnull(a.insure_num ,0)
      ,ifnull(a.tickling   ,0)
      ,ifnull(a.collect_num,0)
      ,ifnull(a.sales      ,0)
      ,ifnull(a.act_num    ,0)
      ,ifnull(a.iappids    ,0)
      ,ifnull(a.iunitcost  ,0)
  from ufdata.x_insure_cover a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.item_name = c.cinvname
  left join edw.map_customer as d 
    on b.bi_cuscode = d.bi_cuscode
;
