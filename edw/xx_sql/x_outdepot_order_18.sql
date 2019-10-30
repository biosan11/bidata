
truncate table edw.x_outdepot_order_18;
insert into edw.x_outdepot_order_18
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
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
      ,a.cmaker
      ,a.cverifier
      ,a.cmodifier
      ,a.dcreatesystime
      ,a.dmodifysystime
      ,a.cdepcode
      ,a.cstcode
      ,a.cpersoncode
      ,a.cwhcode
      ,a.ccode
      ,a.cebexpresscode
      ,a.cvouchtype
      ,a.cvencode
      ,a.cordercode
      ,a.cbillcode
      ,a.cdefine3
      ,a.autoid
      ,a.cdefine22
      ,a.isaleoutid
      ,a.isodid
      ,a.isotype
      ,a.csocode
      ,a.isbsid
      ,a.coutvouchtype
      ,a.cinvouchtype
      ,a.cinvouchcode
      ,a.cvouchcode
      ,a.child_id
      ,a.idlsid
      ,a.iorderdid
      ,a.iordercode
      ,a.cinvcode
      ,a.cinvname
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,d.item_code
      ,d.level_three as item_name
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,a.inum_person
      ,a.citemcode
      ,a.true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.state
      ,d.cinvbrand
      ,d.business_class as cbustype
      ,a.sys_time
  from ufdata.x_outdepot_order_18  a
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
