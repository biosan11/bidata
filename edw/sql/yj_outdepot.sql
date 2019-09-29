-- 加上最终客户
truncate table edw.yj_outdepot;
insert into edw.yj_outdepot
select a.uguid1
      ,b.uguid2
      ,f.sname as cohr
      ,a.tbilldate
      ,a.tcrtdate
      ,a.torderdate
      ,upper(b.sproductcode) as sproductcode
      ,b.sproductname
	    ,case when c.cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
	    ,case when c.cinvcode is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,b.sproductmodel
      ,b.sproductstyle
      ,b.slicnumber
      ,b.sdefineno
      ,b.spoductlotno
      ,b.dqty
      ,b.dprice
      ,b.dmoney
      ,d.sname as ccusname
	    ,case when e.ccusname is null then '请核查' else e.bi_cuscode end as bi_cuscode
	    ,case when e.ccusname is null then '请核查' else e.bi_cusname end as bi_cusname
	    ,case when g.bi_cuscode is null then '请核查' else g.finnal_cuscode end as finnal_cuscode
	    ,case when g.bi_cuscode is null then '请核查' else g.finnal_ccusname end as finnal_ccusname
	    ,g.province
	    ,b.tproductdate
	    ,b.teffectdate
	    ,localtimestamp() as sys_time
  from ufdata.yj_mft_deliver a
  left join ufdata.yj_mft_deliver_detail b
    on a.uguid1 = b.uguid1
	left join (select * from edw.dic_inventory group by cinvcode) c
	  on left(upper(b.sproductcode),7) = c.cinvcode
	left join ufdata.yj_ele_customer d
	  on a.scustcode = d.scode
	left join (select * from edw.dic_customer group by ccusname) e
	  on d.sname = e.ccusname
	left join ufdata.yj_sys_organization f
	  on b.sorgcode = f.scode
	left join edw.map_customer g
	  on e.bi_cuscode = g.bi_cuscode
;

-- 更新一对多的情况
-- update edw.yj_outdepot 
--    set finnal_cuscode = bi_cuscode
--       ,finnal_ccusname = bi_cusname
--  where finnal_cuscode= 'multi'
-- ;

-- 删除试剂123情况的23
delete from edw.yj_outdepot
 where sproductcode in ('SJ05133-2',
                       'SJ05126-2',
                       'SJ02018-2',
                       'SJ02018-3',
                       'SJ03012-2',
                       'SJ02019-2',
                       'SJ02002-2',
                       'SJ02019-3',
                       'SJ02002-3')
;















