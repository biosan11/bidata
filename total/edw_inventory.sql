
truncate table edw.invoice_order;
insert into edw.invoice_order select * from edw18.invoice_order;

use edw;
drop table if exists edw.invoice_order_pre;

create temporary table edw.invoice_order_pre as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
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
  from ufdata.salebillvouch a
  left join (select ccusname,ccuscode,bi_cusname,bi_cuscode from edw.dic_customer group by ccuscode) b
    on a.ccuscode = b.ccuscode
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start2_dt}')
   and a.ccuscode not in ("001","002","003","004","005","006","007","008","009","010","011","012","013");

insert into edw.invoice_order_pre
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then "请核查"
       else b.bi_cuscode end as true_ccuscode 
      ,case when b.ccusname is null then "请核查"
       else b.bi_cusname end as true_ccusname 
      ,a.cdefine10 as finnal_ccusname
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
  from ufdata.salebillvouch a
  left join edw.dic_customer b
    on a.ccuscode = b.ccuscode
   and a.db = b.db
 where (left(a.dcreatesystime,10) >= '${start1_dt}' or left(a.dmodifysystime,10) >= '${start2_dt}')
   and a.ccuscode in ("001","002","003","004","005","006","007","008","009","010","011","012","013");


create temporary table edw.mid1_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
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
  from edw.invoice_order_pre a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select ccusname,bi_cusname from edw.dic_customer group by ccusname) c
    on a.finnal_ccusname = c.ccusname;


create temporary table edw.mid2_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccusname1
      ,case when a.true_finnal_ccusname2 like "个人%" and char_LENGTH(a.true_finnal_ccusname2) > 6 then substr(a.true_finnal_ccusname2,4,char_length(a.true_finnal_ccusname2)-4) else a.true_finnal_ccusname2 end as true_finnal_ccusname2
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
  from edw.mid1_invoice_order a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cusname) c
    on a.true_finnal_ccusname2 = c.bi_cusname
;

delete from edw.invoice_order where concat(db,sbvid) in (select concat(db,sbvid) from  edw.invoice_order_pre);
CREATE INDEX index_mid2_invoice_order_db ON edw.mid2_invoice_order(db);
CREATE INDEX index_mid2_invoice_order_sbvid ON edw.mid2_invoice_order(sbvid);

create temporary table edw.mid3_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
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
      ,b.autoid
      ,b.isaleoutid
      ,b.cbdlcode
      ,b.isosid
      ,b.idlsid
      ,b.cdefine22
      ,b.sbvid as child_sbvid
      ,b.cinvcode
      ,b.cinvname
      ,b.cwhcode
      ,b.cvenabbname
      ,b.iquantity
      ,b.itaxunitprice
      ,b.itax
      ,b.isum
      ,b.itaxrate
      ,b.citemcode
      ,b.citem_class
      ,b.citemname
      ,b.citem_cname
      ,localtimestamp() as sys_time
  from edw.mid2_invoice_order a
  left join ufdata.salebillvouchs b
    on a.sbvid = b.sbvid
   and a.db = b.db
  left join (select bi_cuscode,ccusname from edw.dic_customer group by ccusname) c
    on a.true_finnal_ccusname2 = c.ccusname
;

create temporary table edw.mid4_invoice_order as
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.sys_time
  from edw.mid3_invoice_order a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from edw.dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where a.db in('UFDATA_111_2018','UFDATA_118_2018','UFDATA_123_2018','UFDATA_168_2018','UFDATA_333_2018','UFDATA_666_2018','UFDATA_169_2018')
;

insert into edw.mid4_invoice_order
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' 
            when b.bi_cinvname is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,a.sys_time
  from edw.mid3_invoice_order a
  left join edw.dic_inventory b
    on a.db = b.db
   and a.cinvcode = b.cinvcode
 where a.db in('UFDATA_222_2018','UFDATA_588_2018','UFDATA_889_2018')
;

insert into edw.invoice_order
select a.db
      ,a.sbvid
      ,a.csbvcode
      ,a.csocode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.true_ccuscode
      ,a.true_ccusname
      ,a.finnal_ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname1
      ,a.true_finnal_ccusname2
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
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.cwhcode
      ,a.cvenabbname
      ,a.iquantity
      ,a.itaxunitprice
      ,a.itax
      ,a.isum
      ,a.itaxrate
      ,a.citemcode
      ,case when b.bi_cinvcode is null then '请核查' else b.item_code end as true_itemcode
      ,a.citem_class
      ,a.citemname
      ,a.citem_cname
      ,'有效'
      ,a.sys_time
  from edw.mid4_invoice_order a
  left join edw.map_inventory b
    on a.bi_cinvcode = b.bi_cinvcode;

create temporary table edw.mid5_invoice_order as 
select a.sbvid
      ,a.db
  from edw.invoice_order a
  left join ufdata.salebillvouch b
    on a.sbvid = b.sbvid
   and a.db = b.db
 where b.sbvid is null
   and a.db <> 'UFDATA_889_2018'
;

update edw.invoice_order set state = '无效',sys_time = localtimestamp() where concat(db,sbvid) in (select concat(db,sbvid) from edw.mid5_invoice_order) ;






update edw.invoice_order set true_finnal_ccuscode = 'ZD4205001' , finnal_ccusname = '个人（宜昌市妇幼保健院）' , true_finnal_ccusname2 = '宜昌市妇幼保健院'  where db = 'UFDATA_111_2018' and autoid = '1000015839';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , finnal_ccusname = '威海市妇女儿童医院（威海市妇幼保健院）' , true_finnal_ccusname2 = '威海市妇女儿童医院（威海市妇幼保健院）'  where db = 'UFDATA_111_2018' and autoid = '1000014395';
update edw.invoice_order set true_finnal_ccuscode = 'ZD3710003' , finnal_ccusname = '威海市妇女儿童医院（威海市妇幼保健院）' , true_finnal_ccusname2 = '威海市妇女儿童医院（威海市妇幼保健院）'  where db = 'UFDATA_111_2018' and autoid = '1000014396';

update edw.invoice_order 
set true_finnal_ccuscode = 'ZD5101015' 
, true_finnal_ccusname2 = '四川省妇幼保健院'
,true_ccuscode = 'GR5101003'
,true_ccusname = '个人（四川省妇幼保健院）'
where db = 'UFDATA_889_2018'
  and ccusname = '其他-个人检测';

