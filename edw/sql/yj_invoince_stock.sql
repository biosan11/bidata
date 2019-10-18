truncate table edw.yj_invoince_stock;
insert into edw.yj_invoince_stock
select a.uguid1,
	     date(concat('20',left(a.sdefineno,2),'-',substring(a.sdefineno,3,2),'-',substring(a.sdefineno,5,2))) as ddate,
       o.sname,
       e.sname as ssupplyname,
	     upper(a.sproductcode),
	     a.sproductname,
	     case when c.cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode,
	     case when c.cinvcode is null then '请核查' else c.bi_cinvname end as bi_cinvname,
	     b.sproductstyle,
	     b.sproductmodel,
       case when ifnull( b.bnotmedical, 0 ) = 1 then '非医疗器械产品' else '医疗器械产品' end as smedical,
	     a.swarehouseno,
	     case when a.sWareHouseNo = 'YD' then '云鼎仓库'
	          when a.sWareHouseNo = '' then '未填写'
	          when a.sWareHouseNo is null then '未填写'
	          else '请核查' end as swarehousename,
	     a.sposition,
	     f.sname as spositionname,
	     a.sracking,
	     r.sname as srackingname,
	     a.scell,
	     rc.sname as scellname,
	     a.dinitqty,
	     a.dinqty,
	     a.doutqty,
	     ifnull( a.dinitqty, 0 ) + ifnull( a.dinqty, 0 ) - ifnull( a.doutqty, 0 ) as dstoreqty,
	     a.dinventoryqty,
	     a.dnooutqty,
	     a.dbadqty,
       d.sname as sbasicunit,
	     a.dprice,
	     a.dmoney,
	     a.sdefineno,
	     b.sbrand,
	     date(a.tproductdate) as tproductdate,
	     date(a.teffectdate) as teffectdate,
	     a.tlatestindate,
	     a.dqualitydays,
	     a.slicnumber,
	     a.spoductlotno,
	     ifnull( a.sproductcode, '' ) + ifnull( a.sdefineno, '' ) as sbarcode,
	     ifnull( b.dstoreday, 0 ) as dstoreday,
	     ifnull( b.dwarndays, 0 ) as dwarndays,
	     a.tsafedate,
	     '有效' as state,
	     localtimestamp() as sys_time
  from ufdata.yj_stk_productstore_position a
	left join ufdata.yj_ele_warehouse_position_racking_cell rc 
	  on a.scell = rc.scode
	left join ufdata.yj_sys_organization o 
	  on o.scode = rc.sorgcode
	left join ufdata.yj_ele_product b 
	  on a.sproductcode = b.scode 
	left join ufdata.yj_ele_supply e 
	  on e.scode=a.ssupplycode 
	 and o.uguid1=e.uorgid
  left join ufdata.yj_ele_unit d 
    on b.sbasicunit=d.scode 
	left join ufdata.yj_ele_warehouse_position f 
	  on f.scode = a.sposition
	left join ufdata.yj_ele_warehouse_position_racking r 
	  on a.sracking = r.scode
	left join (select * from edw.dic_inventory group by cinvcode) c
	  on left(upper(a.sproductcode),7) = c.cinvcode
-- where (a.dInventoryQty<>0 or (ifnull(a.dBadQty,0)<>0) or (ifnull(a.dNoOutQty,0)<>0))
;

-- 删除批次为空的数据，影响数据19条
delete from edw.yj_invoince_stock where sdefineno is null;

update edw.yj_invoince_stock
   set dinventoryqty = dinventoryqty+1
 where uguid1 = 'B115D841-9260-4AD9-9A3F-67B76DF8ADF3';

update edw.yj_invoince_stock
   set dinventoryqty = dinventoryqty+2
 where uguid1 = '4526A2BC-EAE4-4EB5-859F-1ADE260614AF';

update edw.yj_invoince_stock
   set dinventoryqty = dinventoryqty+3
 where uguid1 = 'E9ABF90A-E539-4F50-8C21-BD21C69E2C8E';


