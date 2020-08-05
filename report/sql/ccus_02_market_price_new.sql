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

-- 地市客单价人口数据还原
-- 浙江省：人口数据不需要还原，现有crm的填报已经分离(之后对接客户系统和其他地市处理方式一致)
-- 先获取七省的地市人口数
drop table if exists report.ccus_01_map_population_pre;
create temporary table report.ccus_01_map_population_pre as
select a.province
      ,a.city
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,a.fin_data
  from report.ccus_01_map_population a
 where province in ( '浙江省', '江苏省', '安徽省', '山东省', '湖南省', '湖北省', '福建省' ) 
   and ddate >= '2019-01-01'
   and ifnull(a.fin_data,0) <> 0
   and ddate < DATE_ADD(now(),INTERVAL -0 month)
;

-- 补充收送样关系表，送样地市在上一张不存在的人口
insert into report.ccus_01_map_population_pre
select a.province_get
      ,a.city_give
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,a.inum_person
  from (select * from edw.x_ccus_delivery where item_name = 'TSH' and ddate >= '2019-01-01' and inum_person <> 0 and city_grade = '市级') a
  left join (select * from report.ccus_01_map_population where ifnull(fin_data,0) <> 0) b
    on a.city_give = b.city
   and left(a.ddate,7) = left(b.ddate,7)
  where b.city is null
;

drop table if exists report.x_ccus_delivery_get;
create temporary table report.x_ccus_delivery_get as
select city_get as city
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,sum(inum_person) as inum_person
  from edw.x_ccus_delivery 
 where item_name = 'TSH' 
   and ddate >= '2019-01-01' 
   and inum_person <> 0
 group by city,year_,month_
;

drop table if exists report.x_ccus_delivery_give;
create temporary table report.x_ccus_delivery_give as
select city_give as city
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,sum(inum_person) as inum_person
  from edw.x_ccus_delivery 
 where item_name = 'TSH' 
   and ddate >= '2019-01-01' 
   and inum_person <> 0
   and city_grade = '县级'
 group by city,year_,month_
;


-- 收样地市人口处理减去送样地市人口
update report.ccus_01_map_population_pre a
 inner join report.x_ccus_delivery_get b
    on a.city = b.city
   and a.year_ = b.year_
   and a.month_ = b.month_
   set a.fin_data = a.fin_data - b.inum_person
 where a.province <> '浙江省'
;

-- 送样地市加上区县人口
update report.ccus_01_map_population_pre a
 inner join report.x_ccus_delivery_give b
    on a.city = b.city
   and a.year_ = b.year_
   and a.month_ = b.month_
   set a.fin_data = a.fin_data + b.inum_person
 where a.province <> '浙江省'
;

-- 上面是人口计算
-- 地市间送样处理
drop table if exists report.mid1_ccus_02_market_price;
create temporary table report.mid1_ccus_02_market_price as
select city_get
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,city_give
      ,city_grade
      ,sum(inum_person) as inum_person
      ,item_code
      ,item_name
      ,province_get
  from edw.x_ccus_delivery 
 where ddate >= '2019-01-01' 
   and inum_person <> 0
 group by city_get,city_give,city_grade,item_code,year_,month_
;

-- 收养先增加一个检测量
insert into report.mid1_ccus_02_market_price
select city_get
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,city_get
      ,'市级'
      ,0
      ,item_code
      ,item_name
      ,province_get
  from edw.x_ccus_delivery 
 where ddate >= '2019-01-01' 
   and inum_person <> 0
 group by city_get,item_code,year_,month_
;


-- 地市检测量比例计算
drop table if exists report.mid2_ccus_02_market_price;
create temporary table report.mid2_ccus_02_market_price as
select b.city
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,item_code
      ,item_name
      ,sum(inum_person) as inum_person
      ,a.province_ori
  from pdm.checklist a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
 where a.ddate >= '2019-01-01'
 group by year_,month_,item_code,city
;

delete from report.mid2_ccus_02_market_price where province_ori = '安徽省' and item_name = 'NIPT' and year_ >= '2019';

-- 这里增加对安徽NIPT的处理逻辑
insert into report.mid2_ccus_02_market_price
select '合肥市'
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,item_code
      ,item_name
      ,sum(inum_person) as inum_person
      ,'安徽省'
  from pdm.checklist a
 where a.ddate >= '2019-01-01'
   and a.province_ori = '安徽省'
   and item_name = 'NIPT'
   and ddate >= '2019-01-01'
 group by year_,month_,item_code
;



-- 这里需要计算收样的收了多少
drop table if exists report.mid3_ccus_02_market_price;
create temporary table report.mid3_ccus_02_market_price as
select city_get as city
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,sum(inum_person) as inum_person
      ,item_code
  from edw.x_ccus_delivery 
 where ddate >= '2019-01-01' 
   and inum_person <> 0
   and province_get <> '浙江省'
 group by city,year_,month_,item_code
;

-- 更新除了浙江以外的所有收样地市数据
update report.mid1_ccus_02_market_price a
 inner join report.mid2_ccus_02_market_price b
    on a.city_give = b.city
   and a.year_ = b.year_
   and a.month_ = b.month_
   and a.item_code = b.item_code
   set a.inum_person = b.inum_person
 where a.inum_person = 0
--   and province_get = '浙江省'
;

update report.mid1_ccus_02_market_price a
 inner join report.mid3_ccus_02_market_price b
    on a.city_give = b.city
   and a.year_ = b.year_
   and a.month_ = b.month_
   and a.item_code = b.item_code
   set a.inum_person = a.inum_person - b.inum_person
;

-- 计算地市之间的分摊比例
drop table if exists report.mid4_ccus_02_market_price;
create temporary table report.mid4_ccus_02_market_price as
select city_get
      ,year_
      ,month_
      ,sum(inum_person) as inum_person
      ,item_code
      ,item_name
      ,province_get
  from report.mid1_ccus_02_market_price a
 group by city_get,year_,month_,item_code
;

drop table if exists report.mid5_ccus_02_market_price;
create temporary table report.mid5_ccus_02_market_price as
select a.city_get
      ,a.year_
      ,a.month_
      ,a.city_give
      ,(a.inum_person * 1.0) / (b.inum_person*1.0) as bl
      ,a.item_code
      ,a.item_name
  from report.mid1_ccus_02_market_price a
  left join report.mid4_ccus_02_market_price b
    on a.city_get = b.city_get
   and a.year_ = b.year_
   and a.month_ = b.month_
   and a.item_code = b.item_code
 where b.inum_person <> 0
;


-- 获取19年7省收入，按月进行分组，这里按照产品来处理，项目跟在后面
drop table if exists report.invoice_order_pre;
create temporary table report.invoice_order_pre as
select a.city
	    ,a.item_code
	    ,cinvcode
	    ,cinvname
	    ,b.level_three as item_name
	    ,sum( ifnull(a.isum, 0 ) ) as isum
	    ,year(ddate) as year_
	    ,month(ddate) as month_
	    ,a.province
  from pdm.invoice_order a
  left join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
 where year ( ddate ) >= '2019' 
	 and province in ( '浙江省', '江苏省', '安徽省', '山东省', '湖南省', '湖北省', '福建省' ) 
	 and ifnull(a.isum, 0 ) <> 0
 group by cinvcode,city,year_,month_,a.item_code
 order by city
;

drop table if exists report.mid6_ccus_02_market_price;
create temporary table report.mid6_ccus_02_market_price as
select ifnull(b.city_give,a.city) as city
	    ,a.item_code
	    ,a.cinvcode
	    ,a.cinvname
	    ,a.item_name
	    ,a.isum * ifnull(b.bl,1) as isum
	    ,a.year_
	    ,a.month_
	    ,a.province
	from report.invoice_order_pre a
	left join report.mid5_ccus_02_market_price b
    on a.city = b.city_get
   and a.year_ = b.year_
   and a.month_ = b.month_
   and a.item_code = b.item_code
;

truncate table report.ccus_02_market_price_new;
insert into report.ccus_02_market_price_new
select a.province
      ,a.city
      ,a.cinvcode
      ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.year_
      ,a.month_
      ,a.isum_
      ,b.fin_data
      ,a.isum_ / b.fin_data
  from (select *,sum(isum) as isum_ from report.mid6_ccus_02_market_price group by city,cinvcode,item_code,year_,month_) a
  left join report.ccus_01_map_population_pre b
    on a.city = b.city
   and a.year_ = b.year_
   and a.month_ = b.month_
;

-- 获取所有地市和项目合集
drop table if exists report.mid7_ccus_02_market_price;
create temporary table report.mid7_ccus_02_market_price as
select distinct b.province
      ,b.city
      ,b.cinvcode
      ,b.cinvname
      ,b.item_code
      ,b.item_name
      ,a.year_
      ,a.month_
      ,a.fin_data
  from report.ccus_01_map_population_pre a
  left join (select * from report.ccus_02_market_price_new group by city,cinvcode) b
    on a.city = b.city
;

-- 补全所有的地市数据
insert into report.ccus_02_market_price_new
select distinct a.province
      ,a.city
      ,a.cinvcode
      ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.year_
      ,a.month_
      ,0
      ,a.fin_data
      ,0
  from report.mid7_ccus_02_market_price a
  left join report.ccus_02_market_price_new b
    on a.city = b.city
   and a.month_ = b.month_
   and a.year_ = b.year_
   and a.cinvcode = b.cinvcode
 where b.city is null
;

delete from report.ccus_02_market_price_new where province is null;


