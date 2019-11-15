
use edw;
drop table if exists edw.x_sales_bkgr_pre;
create temporary table edw.x_sales_bkgr_pre as
select a.auto_id
      ,a.db
      ,a.id_ori
      ,a.province_ori
      ,a.person_ori
      ,REPLACE(a.ccusname_ori,' ','') as ccusname_ori
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.name_sample 
      ,a.ddate_sample
      ,a.product_ori
      ,case when c.cinvcode is not null then c.bi_cinvcode else '请核查' end as bi_cinvcode
      ,case when c.cinvcode is not null then c.bi_cinvname else '请核查' end as bi_cinvname
      ,a.id_smaple
      ,a.class_smaple
      ,a.company_exp
      ,a.method_settlement
      ,a.isum
      ,a.remittance
      ,a.accounts
      ,a.remark
      ,a.ddate_rem
      ,a.tracking
      ,a.ddate
      ,REPLACE(a.true_ccusname_ori,' ','') as true_ccusname_ori
      ,a.true_product_code
      ,a.true_product_ori
      ,a.invoice
  from ufdata.x_ldt_list a 
  left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) b
    on REPLACE(a.true_ccusname_ori,' ','') = b.ccusname
  left join (select bi_cinvcode,bi_cinvname,cinvcode from edw.dic_inventory group by cinvcode) c
    on a.true_product_code = c.cinvcode
;

drop table if exists edw.x_sales_bkgr_pre1;
create temporary table edw.x_sales_bkgr_pre1 as
select a.auto_id
      ,a.db
      ,a.id_ori
      ,a.province_ori
      ,a.person_ori
      ,a.ccusname_ori
      ,concat('个人（',REPLACE(a.bi_cusname,' ',''),'）') as old_finnal_ccusname
      ,case when d.ccusname is not null then d.bi_cuscode else '请核查' end as finnal_ccuscode
      ,case when d.ccusname is not null then d.bi_cusname else '请核查' end as finnal_ccusname
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.name_sample 
      ,a.ddate_sample
      ,a.product_ori
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.id_smaple
      ,a.class_smaple
      ,a.company_exp
      ,a.method_settlement
      ,a.isum
      ,a.remittance
      ,a.accounts
      ,a.remark
      ,a.ddate_rem
      ,a.tracking
      ,a.ddate
      ,a.true_ccusname_ori
      ,a.true_product_code
      ,a.true_product_ori
      ,a.invoice
  from edw.x_sales_bkgr_pre a 
  left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) d
    on concat('个人（',a.bi_cusname,'）') = d.ccusname
;


truncate table edw.x_sales_bkgr;
insert into edw.x_sales_bkgr
select a.auto_id
      ,a.db
      ,a.id_ori
      ,a.province_ori
      ,a.person_ori
      ,a.old_finnal_ccusname
      ,finnal_ccuscode
      ,finnal_ccusname
      ,a.ccusname_ori
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.name_sample
      ,a.ddate_sample
      ,a.product_ori
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,case when b.bi_cinvcode is not null then b.item_code else '请核查' end
      ,a.id_smaple
      ,a.class_smaple
      ,a.company_exp
      ,a.method_settlement
      ,a.isum
      ,a.remittance
      ,a.accounts
      ,a.remark
      ,a.ddate_rem
      ,a.tracking
      ,a.ddate
      ,a.true_ccusname_ori
      ,a.true_product_code
      ,a.true_product_ori
      ,a.invoice
  from edw.x_sales_bkgr_pre1 a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode
;

update edw.x_sales_bkgr
   set true_ccuscode = finnal_ccuscode
      ,true_ccusname = finnal_ccusname
      ,ccusname_ori = old_finnal_ccusname
 where ifnull(method_settlement,'') <> '个人' or ifnull(accounts,'') <> '贝康'
;


