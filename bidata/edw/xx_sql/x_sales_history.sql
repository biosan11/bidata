
use edw;
truncate table edw.x_sales_history;
create temporary table edw.x_sales_history_pre as
select auto_id
      ,a.db
      ,a.ccuscode_ori
      ,a.finnal_ccuscode_ori
      ,a.ddate
      ,a.invoice_num
      ,a.business_class
      ,a.sales_region
      ,a.ccusname_ori
      ,a.project_class_name_ori
      ,a.product_ori
      ,case when d.cinvcode is not null then d.bi_cinvcode else '请核查' end as bi_cinvcode
      ,case when d.cinvcode is not null then d.bi_cinvname else '请核查' end as bi_cinvname
      ,a.cinvcode_ori
      ,a.itax_excluded
      ,a.isum
      ,a.tax_rate
      ,a.ccusname
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,a.item_details
      ,a.finnal_ccusname
      ,case when c.ccusname is not null then c.bi_cusname else '请核查' end as bi_finnal_ccusname
      ,case when c.ccusname is not null then c.bi_cuscode else '请核查' end as bi_finnal_ccuscode
      ,a.cverifier
  from ufdata.x_sales_history a
  left join (select bi_cuscode,bi_cusname,ccusname from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname 
  left join (select bi_cuscode,bi_cusname,ccusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname
  left join (select cinvcode,cinvname,bi_cinvcode,bi_cinvname from edw.dic_inventory group by cinvcode) d
    on a.cinvcode_ori = d.cinvcode
;



insert into edw.x_sales_history
select a.auto_id
      ,a.db
      ,a.ccuscode_ori
      ,a.finnal_ccuscode_ori
      ,a.ddate
      ,a.invoice_num
      ,a.business_class
      ,a.sales_region
      ,a.ccusname_ori
      ,a.project_class_name_ori
      ,a.product_ori
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,case when b.bi_cinvcode is not null then b.item_code else '请核查' end
      ,a.cinvcode_ori
      ,a.itax_excluded
      ,a.isum
      ,a.tax_rate
      ,a.ccusname
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.item_details
      ,a.bi_finnal_ccuscode
      ,a.finnal_ccusname
      ,a.bi_finnal_ccusname
      ,a.cverifier
  from edw.x_sales_history_pre a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode
;

update edw.x_sales_history 
   set true_ccuscode = 'GR3301006'
      ,true_ccusname = '个人（浙江）'
      ,true_finnal_ccuscode = 'GR3301006'
      ,true_finnal_ccusname = '个人（浙江）'
 where ccusname = '浙江博圣生物技术股份有限公司'
    or true_finnal_ccusname = '浙江博圣生物技术股份有限公司';