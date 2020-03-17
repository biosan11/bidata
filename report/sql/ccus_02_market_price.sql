------------------------------------程序头部----------------------------------------------
--功能：地市客单价
------------------------------------------------------------------------------------------
--程序名称：ccus_02_market_price.sql
--目标模型：ccus_02_market_price
--源    表：pdm.invoice_order,report.ccus_01_map_population
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-02-26
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-02-26   开发上线
--调用方法　sh /home/bidata/report/python/ccus_02_market_price.sh
------------------------------------开始处理逻辑------------------------------------------

-- 获取19年7省收入，按月进行分组，这里按照产品来处理，项目跟在后面
drop table if exists report.invoice_order_pre;
create temporary table report.invoice_order_pre as
select a.city
	    ,a.item_code
	    ,cinvcode
	    ,cinvname
	    ,b.level_three as item_name
	    ,sum( ifnull(a.isum, 0 ) ) as isum
	    ,left (a.ddate, 7 ) as y_mon
	    ,a.province
  from pdm.invoice_order a
  left join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
 where year ( ddate ) >= '2019' 
	 and province in ( '浙江省', '江苏省', '安徽省', '山东省', '湖南省', '湖北省', '福建省' ) 
 group by cinvcode,city,left ( ddate, 7 )
 order by city
;

-- 获取19年所有项目的存在产品送检数据，加工一张月维度数据
drop table if exists report.x_ccus_delivery_sj;
create temporary table report.x_ccus_delivery_sj as
select city_get,city_give,item_code,ddate,province_get
  from edw.x_ccus_delivery
 where ddate >= '2019-01-01'
   and city_grade = '市级'
;

drop table if exists report.x_ccus_delivery_xj;
create temporary table report.x_ccus_delivery_xj as
select city_get,county,item_code,ddate,province_get
  from edw.x_ccus_delivery
 where ddate >= '2019-01-01'
   and city_grade = '县级'
;

-- 区县的tsh代替区县的人口
drop table if exists report.x_ccus_delivery_tsh;
create temporary table report.x_ccus_delivery_tsh as
select city_get,county,item_code,ddate,inum_person,province_get
  from edw.x_ccus_delivery
 where ddate >= '2019-01-01'
   and city_grade = '县级'
   and item_name = 'tsh'
;


-- 市级计算，市级人口增加
drop table if exists report.ccus_01_map_population_pre;
create temporary table report.ccus_01_map_population_pre as
select a.city_get
      ,left(a.ddate,7) as y_mon
      ,a.item_code
      ,b.fin_data,a.province_get as province
 from report.x_ccus_delivery_sj a
 left join report.ccus_01_map_population b
   on a.city_give = b.city
  and left(a.ddate,7) = left(b.ddate,7)
;

-- 区县人口增加
insert into report.ccus_01_map_population_pre
select a.city_get
      ,left(a.ddate,7) as y_mon
      ,a.item_code
      ,b.inum_person,a.province_get as province
 from report.x_ccus_delivery_xj a
 left join report.x_ccus_delivery_tsh b
   on a.county = b.county
  and left(a.ddate,7) = left(b.ddate,7)
 where b.county is not null
   and b.inum_person <> 0
;

-- 收样地市自己存在人口
insert into report.ccus_01_map_population_pre
select a.city_get
      ,left(a.ddate,7) as y_mon
      ,a.item_code
      ,b.fin_data,a.province_get as province
 from (select * from edw.x_ccus_delivery where ddate >= '2019-01-01' group by city_get,ddate,item_code) a
 left join report.ccus_01_map_population b
   on a.city_get = b.city
  and left(a.ddate,7) = left(b.ddate,7)
;

drop table if exists report.ccus_01_map_population_shou;
create temporary table report.ccus_01_map_population_shou as
select a.city_get as city
      ,a.y_mon
      ,a.item_code
      ,sum(a.fin_data) as fin_data,province
  from report.ccus_01_map_population_pre a
 group by city_get,y_mon,item_code
;


-- 送样区县处理
drop table if exists report.ccus_01_map_population_pre1;
create temporary table report.ccus_01_map_population_pre1 as
select a.city_give
      ,left(a.ddate,7) as y_mon
      ,a.item_code
      ,b.fin_data,a.province_get as province
 from (select * from edw.x_ccus_delivery where ddate >= '2019-01-01' and city_grade = '县级' group by city_give,ddate,item_code) a
 left join report.ccus_01_map_population b
   on a.city_give = b.city
  and left(a.ddate,7) = left(b.ddate,7)
;

-- 插入区县送出去的情况
insert into report.ccus_01_map_population_pre1
select a.city_give
      ,left(a.ddate,7) as y_mon
      ,a.item_code
      ,- b.inum_person,a.province_get as province
 from (select * from edw.x_ccus_delivery where ddate >= '2019-01-01' and city_grade = '县级' group by county,ddate,item_code) a
 left join report.x_ccus_delivery_tsh b
   on a.county = b.county
  and left(a.ddate,7) = left(b.ddate,7)
 where b.county is not null
   and b.inum_person <> 0
;

drop table if exists report.ccus_01_map_population_song;
create temporary table report.ccus_01_map_population_song as
select a.city_give as city
      ,a.y_mon
      ,a.item_code,province
      ,sum(a.fin_data) as fin_data
  from report.ccus_01_map_population_pre1 a
 group by city_give,y_mon,item_code
;



-- 除去收样地市其余的地市情况
drop table if exists report.ccus_01_map_population_else;
create temporary table report.ccus_01_map_population_else as
select a.city
      ,left(ddate,7) as y_mon
      ,a.fin_data
  from report.ccus_01_map_population a
  left join report.ccus_01_map_population_shou b
    on a.city = b.city
 where b.city is null
;


-- 生成地市单价表
truncate table report.ccus_02_market_price;
insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,b.fin_data
      ,case when isum = 0 or fin_data = 0 then 0 else a.isum / b.fin_data end as pct
      ,'无关系'
  from report.invoice_order_pre a
  left join report.ccus_01_map_population_else b
    on a.city = b.city
   and a.y_mon = b.y_mon
 where b.city is not null
;

insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,b.fin_data
      ,case when isum = 0 or fin_data = 0 then 0 else a.isum / b.fin_data end as pct
      ,'收样'
  from report.invoice_order_pre a
  left join report.ccus_01_map_population_shou b
    on a.city = b.city
   and a.y_mon = b.y_mon
   and a.item_code = b.item_code
 where b.city is not null
;

insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,b.fin_data
      ,case when isum = 0 or fin_data = 0 then 0 else a.isum / b.fin_data end as pct
      ,'送样'
  from report.invoice_order_pre a
  left join report.ccus_01_map_population_song b
    on a.city = b.city
   and a.y_mon = b.y_mon
   and a.item_code = b.item_code
 where b.city is not null
;

drop table if exists report.invoice_order_pre1;
create temporary table report.invoice_order_pre1 as
select a.*
  from report.invoice_order_pre a
  left join (select * from report.ccus_02_market_price group by city,cinvcode) b
    on a.city = b.city
   and a.cinvcode = b.cinvcode
 where b.cinvcode is null
;

-- 插入不存在关系的数据
insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,b.fin_data
      ,case when isum = 0 or fin_data = 0 then 0 else a.isum / b.fin_data end as pct
      ,'无关系'
  from report.invoice_order_pre1 a
  left join report.ccus_01_map_population b
    on a.city = b.city
   and a.y_mon = left(ddate,7)
 where b.city is not null
;


drop table if exists report.ccus_02_market_price_pre;
create temporary table report.ccus_02_market_price_pre
select a.province
      ,a.city
      ,b.cinvcode
      ,b.cinvname
      ,b.item_code
      ,b.item_name
      ,a.y_mon
      ,a.fin_data
  from report.ccus_01_map_population_shou a
  left join (select * from report.ccus_02_market_price group by city,cinvcode) b
    on a.city = b.city
   and a.item_code = b.item_code
 where b.city is not null
;

insert into report.ccus_02_market_price_pre
select a.province
      ,a.city
      ,b.cinvcode
      ,b.cinvname
      ,b.item_code
      ,b.item_name
      ,a.y_mon
      ,a.fin_data
  from report.ccus_01_map_population_song a
  left join (select * from report.ccus_02_market_price group by city,cinvcode) b
    on a.city = b.city
   and a.item_code = b.item_code
 where b.city is not null
;

CREATE INDEX index_ccus_02_market_price_pre_city ON report.ccus_02_market_price_pre(city);
CREATE INDEX index_ccus_02_market_price_pre_item_code ON report.ccus_02_market_price_pre(item_code);
CREATE INDEX index_ccus_02_market_price_pre_y_mon ON report.ccus_02_market_price_pre(y_mon);

-- 第一次插入的数据是因为，受送样的地市人口处理过的
insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,0
      ,a.fin_data
      ,0
      ,'无收入'
  from report.ccus_02_market_price_pre a
  left join report.ccus_02_market_price b
    on a.city = b.city
   and a.cinvcode = b.cinvcode
   and a.y_mon = b.y_mon
 where b.city is null
;

-- 补全所有的地市数据
truncate table report.ccus_02_market_price_pre;
insert into report.ccus_02_market_price_pre
select a.province
      ,a.city
      ,b.cinvcode
      ,b.cinvname
      ,b.item_code
      ,b.item_name
      ,left(ddate,7) as y_mon
      ,a.fin_data
  from report.ccus_01_map_population a
  left join (select * from report.ccus_02_market_price group by city,cinvcode) b
    on a.city = b.city
 where year(ddate) >= '2019'
   and b.city is not null
   and ddate < DATE_ADD(now(),INTERVAL -1 month)
;


insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,0
      ,a.fin_data
      ,0
      ,'无收入'
  from report.ccus_02_market_price_pre a
  left join report.ccus_02_market_price b
    on a.city = b.city
   and a.cinvcode = b.cinvcode
   and a.y_mon = b.y_mon
 where b.city is null
;


drop table if exists report.ccus_02_market_price_pre2;
create temporary table report.ccus_02_market_price_pre2
select a.province
      ,b.city_give as city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,a.fin_data
      ,a.pct
      ,'送样'  as type
  from report.ccus_02_market_price a
  left join (select * from edw.x_ccus_delivery where ddate >= '2019-01-01' and city_grade = '市级' group by city_get,item_code,city_give) b
    on a.city = b.city_get
   and a.item_code = b.item_code
 where b.item_code is not null
;

insert into report.ccus_02_market_price
select a.province
      ,a.city
      ,a.cinvcode
	    ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.y_mon
      ,a.isum
      ,a.fin_data
      ,a.pct
      ,'送样'
  from report.ccus_02_market_price_pre2 a
  left join report.ccus_02_market_price b
    on a.city = b.city
   and a.cinvcode = b.cinvcode
   and a.y_mon = b.y_mon
 where b.y_mon is null
;

-- 修改存在送检地市的单价保持和
update report.ccus_02_market_price a
 inner join (select *,left(ddate,7) as y_mon from edw.x_ccus_delivery where city_grade = '市级' group by y_mon,city_give,item_code) b
    on a.y_mon = b.y_mon
   and a.city = b.city_give
   and a.item_code = b.item_code
 inner join (select * from report.ccus_02_market_price group by y_mon,city,item_code) c
    on b.y_mon = c.y_mon
   and b.city_get = c.city
   and b.item_code = c.item_code
   set a.pct =c. pct
      ,a.type = '送样'
      ,a.isum = c.isum
      ,a.fin_data = c.fin_data
;

-- 插入送样地市不存在数据的情况
-- insert into report.ccus_02_market_price
-- select a.province
--       ,b.city_give
--       ,a.cinvcode
--       ,a.cinvname
--       ,a.item_code
--       ,a.item_name
--       ,a.y_mon
--       ,a.isum
--       ,a.fin_data
--       ,a.pct
--       ,'送样'
--   from (select * from report.ccus_02_market_price group by y_mon,city,item_code) a
--   left join (select *,left(ddate,7) as y_mon from edw.x_ccus_delivery where city_grade = '市级' and ddate>='2019-01-01' group by y_mon,city_give,item_code) b
--     on a.city = b.city_get
--    and a.y_mon = b.y_mon
--    and a.item_code = b.item_code
--  where b.y_mon is not null
-- ;


drop table if exists report.ccus_02_market_price_pre3;
create temporary table report.ccus_02_market_price_pre3 as select * from report.ccus_02_market_price;
truncate table report.ccus_02_market_price;
insert into report.ccus_02_market_price
select *
  from report.ccus_02_market_price_pre3
 group by cinvcode,y_mon,city
;






