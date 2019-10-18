
use edw;
truncate table edw.x_ldt_list_before;
create temporary table edw.x_ldt_list_before_pre as
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
  from ufdata.x_ldt_list_before a 
  left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) b
    on REPLACE(a.true_ccusname_ori,' ','') = b.ccusname
  left join (select bi_cinvcode,bi_cinvname,cinvcode from edw.dic_inventory group by cinvcode) c
    on a.true_product_code = c.cinvcode
;



insert into edw.x_ldt_list_before
select a.auto_id
      ,a.db
      ,a.id_ori
      ,a.province_ori
      ,a.person_ori
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
  from edw.x_ldt_list_before_pre a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode
;
