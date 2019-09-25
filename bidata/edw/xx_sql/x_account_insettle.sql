
truncate table edw.x_account_insettle;
insert into edw.x_account_insettle
select a.ccusname
      ,case when b.ccusname is null then 'ÇëºË²é' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then 'ÇëºË²é' else b.bi_cusname end as bi_cusname
      ,c.sales_region
      ,c.province
      ,a.year_
      ,a.type
      ,a.isum
  from ufdata.x_account_insettle a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.map_customer group by bi_cuscode) c
    on b.bi_cuscode = c.bi_cuscode
;


