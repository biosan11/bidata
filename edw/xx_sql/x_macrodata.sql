
-- 全国地市先更新到gdp表
-- insert into ufdata.x_macrodata_gdp (province,city) values(
-- select a.province,a.city,
--   from ufdata.x_macrodata_abudget a
--   left join ufdata.x_macrodata_gdp b
--     on a.province = b.province
--    and a.city = b.city
--  where b.city is null)
-- ;
-- 宏观数据整合,只整合2000以后的数据
truncate table edw.x_macrodata;
insert into edw.x_macrodata
select a.province
      ,a.city
      ,'2018' as year_
      ,ifnull(a.2018,0) as gdp
      ,ifnull(b.2018,0) as agdp
      ,ifnull(c.2018,0) as hrp
      ,ifnull(d.2018,0) as tp
      ,ifnull(e.2018,0) as abudget_nc
      ,ifnull(g.2018,0) as abudget_cs
      ,ifnull(f.2018,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2017' as year_
      ,ifnull(a.2017,0) as gdp
      ,ifnull(b.2017,0) as agdp
      ,ifnull(c.2017,0) as hrp
      ,ifnull(d.2017,0) as tp
      ,ifnull(e.2017,0) as abudget_nc
      ,ifnull(g.2017,0) as abudget_cs
      ,ifnull(f.2017,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;


insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2016' as year_
      ,ifnull(a.2016,0) as gdp
      ,ifnull(b.2016,0) as agdp
      ,ifnull(c.2016,0) as hrp
      ,ifnull(d.2016,0) as tp
      ,ifnull(e.2016,0) as abudget_nc
      ,ifnull(g.2016,0) as abudget_cs
      ,ifnull(f.2016,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;


insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2015' as year_
      ,ifnull(a.2015,0) as gdp
      ,ifnull(b.2015,0) as agdp
      ,ifnull(c.2015,0) as hrp
      ,ifnull(d.2015,0) as tp
      ,ifnull(e.2015,0) as abudget_nc
      ,ifnull(g.2015,0) as abudget_cs
      ,ifnull(f.2015,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;
insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2014' as year_
      ,ifnull(a.2014,0) as gdp
      ,ifnull(b.2014,0) as agdp
      ,ifnull(c.2014,0) as hrp
      ,ifnull(d.2014,0) as tp
      ,ifnull(e.2014,0) as abudget_nc
      ,ifnull(g.2014,0) as abudget_cs
      ,ifnull(f.2014,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2013' as year_
      ,ifnull(a.2013,0) as gdp
      ,ifnull(b.2013,0) as agdp
      ,ifnull(c.2013,0) as hrp
      ,ifnull(d.2013,0) as tp
      ,ifnull(e.2013,0) as abudget_nc
      ,ifnull(g.2013,0) as abudget_cs
      ,ifnull(f.2013,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2012' as year_
      ,ifnull(a.2012,0) as gdp
      ,ifnull(b.2012,0) as agdp
      ,ifnull(c.2012,0) as hrp
      ,ifnull(d.2012,0) as tp
      ,ifnull(e.2012,0) as abudget_nc
      ,ifnull(g.2012,0) as abudget_cs
      ,ifnull(f.2012,0) as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join ufdata.x_macrodata_natality f
    on a.province = f.province
   and a.city = f.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2011' as year_
      ,ifnull(a.2011,0) as gdp
      ,ifnull(b.2011,0) as agdp
      ,ifnull(c.2011,0) as hrp
      ,ifnull(d.2011,0) as tp
      ,ifnull(e.2011,0) as abudget_nc
      ,ifnull(g.2011,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2010' as year_
      ,ifnull(a.2010,0) as gdp
      ,ifnull(b.2010,0) as agdp
      ,ifnull(c.2010,0) as hrp
      ,ifnull(d.2010,0) as tp
      ,ifnull(e.2010,0) as abudget_nc
      ,ifnull(g.2010,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2009' as year_
      ,ifnull(a.2009,0) as gdp
      ,ifnull(b.2009,0) as agdp
      ,ifnull(c.2009,0) as hrp
      ,ifnull(d.2009,0) as tp
      ,ifnull(e.2009,0) as abudget_nc
      ,ifnull(g.2009,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2008' as year_
      ,ifnull(a.2008,0) as gdp
      ,ifnull(b.2008,0) as agdp
      ,ifnull(c.2008,0) as hrp
      ,ifnull(d.2008,0) as tp
      ,ifnull(e.2008,0) as abudget_nc
      ,ifnull(g.2008,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2007' as year_
      ,ifnull(a.2007,0) as gdp
      ,ifnull(b.2007,0) as agdp
      ,ifnull(c.2007,0) as hrp
      ,ifnull(d.2007,0) as tp
      ,ifnull(e.2007,0) as abudget_nc
      ,ifnull(g.2007,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2006' as year_
      ,ifnull(a.2006,0) as gdp
      ,ifnull(b.2006,0) as agdp
      ,ifnull(c.2006,0) as hrp
      ,ifnull(d.2006,0) as tp
      ,ifnull(e.2006,0) as abudget_nc
      ,ifnull(g.2006,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2005' as year_
      ,ifnull(a.2005,0) as gdp
      ,ifnull(b.2005,0) as agdp
      ,ifnull(c.2005,0) as hrp
      ,ifnull(d.2005,0) as tp
      ,ifnull(e.2005,0) as abudget_nc
      ,ifnull(g.2005,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2004' as year_
      ,ifnull(a.2004,0) as gdp
      ,ifnull(b.2004,0) as agdp
      ,ifnull(c.2004,0) as hrp
      ,ifnull(d.2004,0) as tp
      ,ifnull(e.2004,0) as abudget_nc
      ,ifnull(g.2004,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2003' as year_
      ,ifnull(a.2003,0) as gdp
      ,ifnull(b.2003,0) as agdp
      ,ifnull(c.2003,0) as hrp
      ,ifnull(d.2003,0) as tp
      ,ifnull(e.2003,0) as abudget_nc
      ,ifnull(g.2003,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2002' as year_
      ,ifnull(a.2002,0) as gdp
      ,ifnull(b.2002,0) as agdp
      ,ifnull(c.2002,0) as hrp
      ,ifnull(d.2002,0) as tp
      ,ifnull(e.2002,0) as abudget_nc
      ,ifnull(g.2002,0) as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '农村人均可支配') e
    on a.province = e.province
   and a.city = e.city
  left join (select * from ufdata.x_macrodata_abudget where rural_urban = '城镇人均可支配') g
    on a.province = g.province
   and a.city = g.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2001' as year_
      ,ifnull(a.2001,0) as gdp
      ,ifnull(b.2001,0) as agdp
      ,ifnull(c.2001,0) as hrp
      ,ifnull(d.2001,0) as tp
      ,0 as abudget_nc
      ,0 as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city
;

insert into edw.x_macrodata
select a.province
      ,a.city
       ,'2000' as year_
      ,ifnull(a.2000,0) as gdp
      ,ifnull(b.2000,0) as agdp
      ,ifnull(c.2000,0) as hrp
      ,ifnull(d.2000,0) as tp
      ,0 as abudget_nc
      ,0 as abudget_cs
      ,0 as natality
  from ufdata.x_macrodata_gdp a
  left join ufdata.x_macrodata_agdp b
    on a.province = b.province
   and a.city = b.city
  left join ufdata.x_macrodata_hrp c
    on a.province = c.province
   and a.city = c.city
  left join ufdata.x_macrodata_tp d
    on a.province = d.province
   and a.city = d.city


