truncate table pdm.sales_dis_out_inv;
insert into pdm.sales_dis_out_inv
select a.db 
      ,a.ddate as ddate_dd
      ,a.csocode
      ,a.true_ccuscode as ccuscode_dd
      ,a.true_ccusname as ccusname_dd
      ,a.true_finnal_ccuscode as finnal_ccuscode_dd
      ,a.true_finnal_ccusname2 as finnal_ccusname_dd
      ,a.bi_cinvcode as cinvcode_dd
      ,a.bi_cinvname as cinvname_dd
		  ,a.itaxunitprice as md_dd
		  ,b.ddate as ddate_fh
		  ,b.cdlcode
		  ,b.true_ccuscode as ccuscode_fh
		  ,b.true_ccusname as ccusname_fh
      ,b.true_finnal_ccuscode as finnal_ccuscode_fh
      ,b.true_finnal_ccusname2 as finnal_ccusname_fh
      ,b.bi_cinvcode as cinvcode_fh
      ,b.bi_cinvname as cinvname_fh
		  ,b.itaxunitprice as md_fh
		  ,c.ddate as ddate_ck
		  ,c.cbuscode
		  ,c.true_ccuscode as ccuscode_ck
		  ,c.true_ccusname as ccusname_ck
      ,c.true_finnal_ccuscode as finnal_ccuscode_ck
      ,c.true_finnal_ccusname2 as finnal_ccusname_ck
      ,c.bi_cinvcode as cinvcode_ck
      ,c.bi_cinvname as cinvname_ck
		  ,c.iunitcost as md_ck
		  ,d.ddate as ddate_fp
		  ,d.csbvcode
		  ,d.true_ccuscode as ccuscode_fp
		  ,d.true_ccusname as ccusname_fp
      ,d.true_finnal_ccuscode as finnal_ccuscode_fp
      ,d.true_finnal_ccusname2 as finnal_ccusname_fp
      ,d.bi_cinvcode as cinvcode_fp
      ,d.bi_cinvname as cinvname_fp
		  ,d.itaxunitprice as md_fp
		  ,e.province
		  ,''
		  ,''
		  ,''
		  ,''
		  ,''
  from edw.sales_order a
	left join (select * from edw.dispatch_order where ddate >= '2018-01-01') b
    on a.isosid = b.isosid
   and a.db = b.db
	left join (select * from edw.outdepot_order where ddate >= '2018-01-01') c
    on a.isosid = c.iorderdid
   and a.db = c.db
  left join (select * from edw.invoice_order where ddate >= '2018-01-01') d
    on a.isosid = d.isosid
   and a.db = d.db
  left join (select * from edw.map_customer group by bi_cuscode) e
    on a.true_finnal_ccuscode  = e.bi_cuscode
 where a.ddate >= '2018-01-01'
;

-- 客户情况统计
update pdm.sales_dis_out_inv
   set err_ccusname = concat(ifnull(err_ccusname,''),'订单发货')
 where ccuscode_dd <> ccuscode_fh
;

update pdm.sales_dis_out_inv
   set err_ccusname = concat(ifnull(err_ccusname,''),'-发货出库')
 where ccuscode_fh <> ccuscode_ck
;

update pdm.sales_dis_out_inv
   set err_ccusname = concat(ifnull(err_ccusname,''),'-出库开票')
 where ccuscode_fp <> ccuscode_ck
;

-- 最终客户情况
update pdm.sales_dis_out_inv
   set err_finnal_name = concat(ifnull(err_finnal_name,''),'订单发货')
 where finnal_ccuscode_dd <> finnal_ccuscode_fh
;

update pdm.sales_dis_out_inv
   set err_finnal_name = concat(ifnull(err_finnal_name,''),'-发货出库')
 where finnal_ccuscode_fh <> finnal_ccuscode_ck
;

update pdm.sales_dis_out_inv
   set err_finnal_name = concat(ifnull(err_finnal_name,''),'-出库开票')
 where finnal_ccuscode_ck <> finnal_ccuscode_fp
;

-- 产品情况
update pdm.sales_dis_out_inv
   set err_cinvname = concat(ifnull(err_cinvname,''),'订单发货')
 where cinvcode_dd <> cinvcode_fh
;

update pdm.sales_dis_out_inv
   set err_cinvname = concat(ifnull(err_cinvname,''),'-发货出库')
 where cinvcode_fh <> cinvcode_ck
;

update pdm.sales_dis_out_inv
   set err_cinvname = concat(ifnull(err_cinvname,''),'-出库开票')
 where cinvcode_ck <> cinvcode_fp
;

-- 金额不一致，出库金额不参与比较
update pdm.sales_dis_out_inv
   set err_md = concat(ifnull(err_md,''),'订单发货')
 where md_dd <> md_fh
;

update pdm.sales_dis_out_inv
   set err_md = concat(ifnull(err_md,''),'-发货开票')
 where md_fh <> md_fp
;

-- 统计有无的情况
-- 订单未发货
update pdm.sales_dis_out_inv
   set err_all = concat(ifnull(err_all,''),'订单未发货')
 where ccuscode_fh is null
   and cinvcode_dd is not null
;

-- 发货未出库
update pdm.sales_dis_out_inv
   set err_all = concat(ifnull(err_all,''),'发货未出库')
 where ccuscode_ck is null
   and ccuscode_fh is not null
;

-- 出库未开票
update pdm.sales_dis_out_inv
   set err_all = concat(ifnull(err_all,''),'出库未开票')
 where ccuscode_fp is null
   and ccuscode_ck is not null
;







