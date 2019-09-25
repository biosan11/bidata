
use edw;
truncate table edw.x_sales_bk;
create temporary table edw.x_sales_bk_pre as
select a.auto_id
      ,a.db
      ,a.ddate
      ,a.product_ori
      ,a.product_pre
      ,case when c.cinvname is null then '请核查' 
            when c.bi_cinvcode is null then '请核查' else c.cinvname end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' 
            when c.bi_cinvname is null then '请核查' else c.cinvname end as bi_cinvname
      ,a.business_class
      ,a.iquantity
      ,a.price
      ,a.isum
      ,a.company_invoice
      ,a.ccusname_ori
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
  from ufdata.x_sales_bk a
  left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) b
    on a.ccusname_ori = b.ccusname
  left join (select cinvname,bi_cinvcode,bi_cinvname from edw.dic_inventory_ldt group by cinvname) c
    on a.product_ori = c.cinvname
;

insert into edw.x_sales_bk
select a.auto_id
      ,a.db
      ,a.ddate
      ,a.product_ori
      ,a.product_pre
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,case when b.bi_cinvcode is not null then b.item_code else '请核查' end 
      ,a.business_class
      ,a.iquantity
      ,a.price
      ,a.isum
      ,a.company_invoice
      ,a.ccusname_ori
      ,a.bi_cuscode
      ,a.bi_cusname
  from edw.x_sales_bk_pre a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode
;


