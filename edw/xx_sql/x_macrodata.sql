
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
      ,a.2018 as gdp
      ,b.2018 as agdp
      ,c.2018 as hrp
      ,d.2018 as tp
      ,e.2018 as abudget_nc
      ,g.2018 as abudget_cs
      ,f.2018 as natality
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
      ,a.2017 as gdp
      ,b.2017 as agdp
      ,c.2017 as hrp
      ,d.2017 as tp
      ,e.2017 as abudget_nc
      ,g.2017 as abudget_cs
      ,f.2017 as natality
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
      ,a.2016 as gdp
      ,b.2016 as agdp
      ,c.2016 as hrp
      ,d.2016 as tp
      ,e.2016 as abudget_nc
      ,g.2016 as abudget_cs
      ,f.2016 as natality
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
      ,a.2015 as gdp
      ,b.2015 as agdp
      ,c.2015 as hrp
      ,d.2015 as tp
      ,e.2015 as abudget_nc
      ,g.2015 as abudget_cs
      ,f.2015 as natality
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
      ,a.2014 as gdp
      ,b.2014 as agdp
      ,c.2014 as hrp
      ,d.2014 as tp
      ,e.2014 as abudget_nc
      ,g.2014 as abudget_cs
      ,f.2014 as natality
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
      ,a.2013 as gdp
      ,b.2013 as agdp
      ,c.2013 as hrp
      ,d.2013 as tp
      ,e.2013 as abudget_nc
      ,g.2013 as abudget_cs
      ,f.2013 as natality
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
      ,a.2012 as gdp
      ,b.2012 as agdp
      ,c.2012 as hrp
      ,d.2012 as tp
      ,e.2012 as abudget_nc
      ,g.2012 as abudget_cs
      ,f.2012 as natality
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
      ,a.2011 as gdp
      ,b.2011 as agdp
      ,c.2011 as hrp
      ,d.2011 as tp
      ,e.2011 as abudget_nc
      ,g.2011 as abudget_cs
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
      ,a.2010 as gdp
      ,b.2010 as agdp
      ,c.2010 as hrp
      ,d.2010 as tp
      ,e.2010 as abudget_nc
      ,g.2010 as abudget_cs
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
      ,a.2009 as gdp
      ,b.2009 as agdp
      ,c.2009 as hrp
      ,d.2009 as tp
      ,e.2009 as abudget_nc
      ,g.2009 as abudget_cs
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
      ,a.2008 as gdp
      ,b.2008 as agdp
      ,c.2008 as hrp
      ,d.2008 as tp
      ,e.2008 as abudget_nc
      ,g.2008 as abudget_cs
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
      ,a.2007 as gdp
      ,b.2007 as agdp
      ,c.2007 as hrp
      ,d.2007 as tp
      ,e.2007 as abudget_nc
      ,g.2007 as abudget_cs
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
      ,a.2006 as gdp
      ,b.2006 as agdp
      ,c.2006 as hrp
      ,d.2006 as tp
      ,e.2006 as abudget_nc
      ,g.2006 as abudget_cs
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
      ,a.2005 as gdp
      ,b.2005 as agdp
      ,c.2005 as hrp
      ,d.2005 as tp
      ,e.2005 as abudget_nc
      ,g.2005 as abudget_cs
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
      ,a.2004 as gdp
      ,b.2004 as agdp
      ,c.2004 as hrp
      ,d.2004 as tp
      ,e.2004 as abudget_nc
      ,g.2004 as abudget_cs
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
      ,a.2003 as gdp
      ,b.2003 as agdp
      ,c.2003 as hrp
      ,d.2003 as tp
      ,e.2003 as abudget_nc
      ,g.2003 as abudget_cs
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
      ,a.2002 as gdp
      ,b.2002 as agdp
      ,c.2002 as hrp
      ,d.2002 as tp
      ,e.2002 as abudget_nc
      ,g.2002 as abudget_cs
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
      ,a.2001 as gdp
      ,b.2001 as agdp
      ,c.2001 as hrp
      ,d.2001 as tp
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
      ,a.2000 as gdp
      ,b.2000 as agdp
      ,c.2000 as hrp
      ,d.2000 as tp
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


