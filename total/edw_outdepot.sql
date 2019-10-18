truncate table edw.outdepot_order;
insert into edw.outdepot_order select * from edw18.outdepot_order;

use edw;
drop table if exists edw.outdepot_order_pre;
create temporary table edw.outdepot_order_pre as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.cdefine2 as ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.chandler as cverifier
      ,a.cmodifyperson as cmodifier
      ,a.dnmaketime as dcreatesystime
      ,a.dnmodifytime as dmodifysystime
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
  from ufdata.rdrecord32 a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dnmaketime,10) >= '${start1_dt}' or left(a.dnmodifytime,10) >= '${start2_dt}')
   and a.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


insert into edw.outdepot_order_pre
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.cdefine2 as ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
      ,a.cmaker
      ,a.chandler as cverifier
      ,a.cmodifyperson as cmodifier
      ,a.dnmaketime as dcreatesystime
      ,a.dnmodifytime as dmodifysystime
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
  from ufdata.rdrecord32 a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and a.db = b.db
 where (left(a.dnmaketime,10) >= '${start1_dt}' or left(a.dnmodifytime,10) >= '${start2_dt}')
   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


create temporary table edw.mid1_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,case when b.bi_cuscode is null then "请核查"
       else b.finnal_ccusname end as true_finnal_ccusname1
      ,case when a.finnal_ccusname is null then
            case when b.bi_cuscode is null then "请核查"
                 else b.finnal_ccusname end
            else case when c.ccusname is null then a.finnal_ccusname
                 else c.bi_cusname end 
       end  as true_finnal_ccusname2
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
  from edw.outdepot_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;

create temporary table edw.mid2_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccusname1
      ,case when a.true_finnal_ccusname2 like "个人%" and char_LENGTH(a.true_finnal_ccusname2) > 6 then substr(a.true_finnal_ccusname2,4,char_length(a.true_finnal_ccusname2)-4) else a.true_finnal_ccusname2 end as true_finnal_ccusname2
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
  from edw.mid1_outdepot_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;

delete from edw.outdepot_order where concat(db,id) in (select concat(db,id) from  edw.outdepot_order_pre);

CREATE INDEX index_mid2_outdepot_order_id ON edw.mid2_outdepot_order(id);
CREATE INDEX index_mid2_outdepot_order_db ON edw.mid2_outdepot_order(db);

create temporary table edw.mid3_outdepot_order as
select a.db
      ,a.id
      ,a.cdlcode
      ,a.cbuscode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,case when c.ccusname is null then "请核查"
       else c.bi_cuscode end as true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,b.autoid
      ,b.cdefine22
      ,b.isaleoutid
      ,b.isodid
      ,b.isotype
      ,b.csocode
      ,b.isbsid
      ,b.coutvouchtype
      ,b.cinvouchtype
      ,b.cinvouchcode
      ,b.cvouchcode
      ,b.id as child_id
      ,b.idlsid
      ,b.iorderdid
      ,b.iordercode
      ,b.cinvcode
      ,b.iquantity
      ,b.iunitcost
      ,b.iprice
      ,b.citemcode
      ,b.citem_class
      ,b.cname as citemname
      ,b.citemcname as citem_cname
      ,b.fsettleqty
      ,localtimestamp() as sys_time
  from edw.mid2_outdepot_order a
  left join ufdata.rdrecords32 b
    on a.id = b.id
   and a.db = b.db
  left join (select bi_cuscode,ccusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;

create temporary table edw.mid4_outdepot_order as
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.sys_time
  from edw.mid3_outdepot_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db in('UFDATA_111_2018','UFDATA_118_2018','UFDATA_123_2018','UFDATA_168_2018','UFDATA_333_2018','UFDATA_666_2018','UFDATA_169_2018')
;

insert into edw.mid4_outdepot_order
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.sys_time
  from edw.mid3_outdepot_order a
  left join dic_inventory b
    on a.db = b.db
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_588_2018','UFDATA_889_2018')
;


insert into edw.outdepot_order
select a.db
      ,a.id
      ,a.cDLCode
      ,a.cBusCode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.iquantity
      ,a.iunitcost
      ,a.iprice
      ,case when (b.inum_unit_person is null or b.inum_unit_person = '' )then iquantity else b.inum_unit_person*iquantity end as inum_person
      ,a.citemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.item_code end as true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.fsettleqty
      ,a.sys_time
  from edw.mid4_outdepot_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;

update edw.outdepot_order set true_finnal_ccuscode = 'ZD5115002' , true_finnal_ccusname2 = '宜宾市妇幼保健院' where year(ddate) <= 2018 and true_ccuscode = 'DL5115001';

update edw.outdepot_order set true_finnal_ccuscode = 'ZD3706028' , true_finnal_ccusname2 = '烟台毓璜顶医院' where year(ddate) <= 2018 and true_ccuscode = 'DL3706001';
update edw.outdepot_order set true_finnal_ccuscode = 'ZD3701019' , true_finnal_ccusname2 = '山东大学齐鲁医院' where year(ddate) <= 2018 and true_ccuscode = 'DL3701012';
