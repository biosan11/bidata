
truncate table edw.x_yj_outdepot;
insert into edw.x_yj_outdepot
select a.cohr
      ,a.ddate
      ,a.ccusname
      ,a.bi_cuscode
      ,a.bi_cusname
	    ,a.finnal_cuscode
	    ,a.finnal_ccusname
      ,a.sbillno
      ,a.cinvname
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,a.sproductstyle
      ,a.ssupplyname
      ,a.sbasicunit
      ,a.dqty
      ,a.dprice
      ,a.dmoney
      ,a.dcostprice
      ,a.spoductlotno
      ,a.teffectdate
      ,a.slicnumber
  from ufdata.x_yj_outdepot a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.cinvname = c.cinvname
	left join edw.map_customer g
	  on b.bi_cuscode = g.bi_cuscode
;

-- update edw.x_yj_outdepot 
--    set finnal_cuscode = bi_cuscode
--       ,finnal_ccusname = bi_cusname
--  where finnal_cuscode= 'multi'
-- ;


