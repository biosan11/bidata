
truncate table edw.x_invoice_order_18;
insert into edw.x_invoice_order_18
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.finnal_ccusname
      ,case when e.ccusname is null then '请核查' else e.bi_cuscode end as true_finnal_ccuscode
      ,case when e.ccusname is null then '请核查' else e.bi_cusname end as true_finnal_ccusname
      ,f.type as ccustype
      ,f.sales_region
      ,f.province
      ,f.city
      ,f.type
      ,a.cstcode
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cpersoncode
      ,a.ccusperson
      ,a.ccuspersoncode
      ,a.cvouchtype
      ,a.cdlcode
      ,a.cdefine2
      ,a.cdefine3
      ,a.autoid
      ,a.isaleoutid
      ,a.cbdlcode
      ,a.isosid
      ,a.idlsid
      ,a.cdefine22
      ,a.child_sbvid
      ,a.cinvcode
      ,a.cinvname
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,d.item_code
      ,d.level_three as item_name
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.specification_type
      ,a.itb
      ,a.breturnflag
      ,a.state
      ,a.tbquantity
      ,d.cinvbrand
      ,d.business_class as cbustype
      ,a.sys_time
  from ufdata.x_invoice_order_18  a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode = c.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
  left join (select * from edw.dic_customer group by ccusname) e
    on a.finnal_ccusname = e.ccusname
  left join (select bi_cuscode,bi_cusname,sales_region,province,city,type from edw.map_customer group by bi_cusname) f
    on e.bi_cusname = f.bi_cusname
;