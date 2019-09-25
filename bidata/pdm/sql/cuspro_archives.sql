------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：cuspro_archives.sql
--目标模型：cuspro_archives
--源    表：pdm.outdepot_order,pdm.invoice_order
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------

-- CREATE TABLE `cuspro_archives` (
--   `ccuscode` varchar(20) default null comment '客户编码',
--   `ccusname` varchar(120) default null comment '客户名称',
--   `item_code` varchar(60) default null comment '项目编码',
--   `citemname` varchar(255) default null comment '项目名称',
--   `cinvcode` varchar(60) default null comment '存货编码',
--   `cinvname` varchar(255) default null comment '存货名称',
--   `equipment` varchar(255) default null comment '是否设备',
--   `type` varchar(60) DEFAULT NULL COMMENT '销售类型',
--   `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
--   `plan_start_dt` date default null comment '产品计划启用时间',
--   `bidding_dt` date default null comment '中标日期',
--   `contract_dt` date default null comment '合同日期',
--   `first_consign_dt` date default null comment '初次发货日期',
--   `last_consign_dt` date default null comment '最后一次发货日期',
--   `iquantity_addup` int DEFAULT NULL COMMENT '累计发货数',
--   `install_dt`date default null comment '装机时间',
--   `first_invoice_dt` date default null comment '初次开票日期',
--   `first_invoice_price_dt` date default null comment '初次开票日期(单价大于0)',
--   `last_invoice_dt` date default null comment '最后一次开票日期',
--   `isum_addup` decimal(18,4) DEFAULT NULL COMMENT '累计开票金额',
--   `product_start_dt` date default null comment '产品启用日期',
--   `product_end_dt` date default null comment '产品停用日期',
--   `end_date` date default null comment '确认丢单日期',
--   `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--   `competitor` varchar(20) DEFAULT NULL COMMENT '是否竞争对手',
--   `cohr` varchar(20) default null comment '公司（客户供应商）'
--  ) engine=innodb default charset=utf8 comment '客户产品档案';

-- 发货、外送、收入、装机数据整合
-- 收入需要处理金额大于0的数据
-- 清空数据
truncate table pdm.cuspro_archives;

create temporary table pdm.invoice_order_temp as
SELECT LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2) as type,case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end  as finnal_ccuscode,
                                case when finnal_ccusname = 'multi' then ccusname else finnal_ccusname end  as finnal_ccusname,item_code,cinvcode,cinvname,sum(isum) AS isum 
  FROM pdm.invoice_order 
 GROUP BY LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2),(case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ), item_code, cinvcode
 having sum(isum) > 0
;

create temporary table pdm.invoice_order_temp1 as
SELECT LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2) as type,case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end  as ccuscode,
                                case when finnal_ccusname = 'multi' then ccusname else finnal_ccusname end  as ccusname,item_code,cinvcode,cinvname,min(ddate) as ddate ,sum(isum) AS isum 
  FROM pdm.invoice_order 
 GROUP BY LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2),(case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ), item_code, cinvcode
 having sum(isum) > 0
;

create temporary table pdm.outdepot_order_temp as
SELECT LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2) as type,case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end  as finnal_ccuscode,
                                case when finnal_ccusname = 'multi' then ccusname else finnal_ccusname end  as finnal_ccusname,item_code,cinvcode,cinvname,sum(iquantity) AS isum
  FROM pdm.outdepot_order 
 where finnal_ccuscode <> ''
 GROUP BY LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2),(case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ), item_code, cinvcode
 having sum(iquantity) > 0
;



-- 获取发货、收入、装机的客户、产品、项目
drop table if exists pdm.mid1_cuspro_archives;
CREATE TEMPORARY TABLE pdm.mid1_cuspro_archives AS 
( SELECT type,finnal_ccuscode as ccuscode,finnal_ccusname as ccusname, item_code, cinvcode,cinvname FROM pdm.invoice_order_temp WHERE isum > 0)
 UNION
( SELECT type,finnal_ccuscode as ccuscode,finnal_ccusname as ccusname, item_code, cinvcode,cinvname FROM pdm.outdepot_order_temp WHERE isum > 0)
UNION
( SELECT 'ZD' as type,bi_cuscode AS ccuscode,bi_cusname as ccusname, item_code, bi_cinvcode AS cinvcode,bi_cinvname as cinvname FROM edw.crm_account_equipments where statecode  = '可用' GROUP BY bi_cuscode, item_code, bi_cinvcode )
union
( SELECT 'ZD' as type,ccuscode AS ccuscode,ccusname as ccusname, item_code, cinvcode AS cinvcode,cinvname as cinvname FROM edw.x_sales_budget_19 where plan_complete_dt_recount is not null GROUP BY ccuscode, cinvcode, item_code )
;

-- 重新获取到项目名称和业务类型
CREATE TEMPORARY TABLE pdm.mid2_cuspro_archives as 
select a.type
      ,a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,b.level_three as item_name
      ,a.cinvcode
      ,a.cinvname
      ,c.business_class as cbustype
  from pdm.mid1_cuspro_archives a
  left join (select item_code,level_three from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
  left join edw.map_inventory c
    on a.cinvcode = c.bi_cinvcode;


-- 通过发货表获取18新增的产品第一次发货日期作为计划发货时间,是否设备判断
create TEMPORARY TABLE pdm.mid3_cuspro_archives as
select LEFT(ccuscode,2) as type,
       ccuscode as ccuscode,
       cinvcode as cinvcode,
       a.item_code as item_code,
       min(plan_complete_dt_recount) as plan_start_dt
  from edw.x_sales_budget_19 a
--   left join edw.map_item b
--     on a.item_code = b.item_code
--    and b.equipment = '是'
 where a.plan_complete_dt_recount > 0
--    and b.item_code is not null
 group by a.ccuscode,a.item_code
;
   
-- insert into pdm.mid3_cuspro_archives
-- select LEFT(ccuscode,2) as type,
--        ccuscode as ccuscode,
--        cinvcode as cinvcode,
--        a.item_code as item_code,
--        min(ddate) as plan_start_dt
--   from edw.x_sales_budget_19 a
--   left join edw.map_item b
--     on a.item_code = b.item_code
--    and b.equipment = '否'
--  where a.isum_budget > 0
--    and b.item_code is not null
--    and not exists(select 1 from pdm.outdepot_order c
--                           where a.ccuscode = c.finnal_ccuscode
--                             and a.item_code = c.item_code
--                             and YEAR(c.ddate) < 2019
--                             and YEAR(c.ddate) >= 2018)
--  group by a.ccuscode,a.item_code
-- ;

-- 增加项目、产品启用日期
CREATE TEMPORARY TABLE pdm.mid4_cuspro_archives as 
select a.type
      ,a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.item_name
      ,a.cinvcode
      ,a.cinvname
      ,a.cbustype
      ,b.plan_start_dt
  from pdm.mid2_cuspro_archives a
  left join pdm.mid3_cuspro_archives b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and a.type = b.type
;

-- 计算发货的初次、最后一次发货时间，沟通后定位产品不需要这样的逻辑
CREATE TEMPORARY TABLE pdm.mid5_cuspro_archives as
-- select a.type,a.yearmonth,a.finnal_ccuscode,a.item_code,a.cinvcode,sum(num_person)/3 from
select a.type,a.yearmonth,a.finnal_ccuscode,a.item_code,a.cinvcode,num_person from
(select LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2) as type,
date_format(ddate,"%Y-%m-%d") as `yearmonth`
,(case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ) as finnal_ccuscode
,item_code
,cinvcode
,count(*) as `num_person`
from pdm.outdepot_order 
where iquantity > 0
 GROUP BY LEFT((case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end ),2)
         ,(case when finnal_ccuscode = 'multi' then ccuscode else finnal_ccuscode end )
	       ,item_code
	       ,cinvcode
 having sum(iquantity) > 0) a
-- union all
-- select LEFT(ccuscode,2) as type,
-- date_format(date_add(ddate,INTERVAL + 1 month),"%Y-%m-%d") as `yearmonth`
-- ,finnal_ccuscode
-- ,item_code
-- ,cinvcode
-- ,count(*) as `num_person`
-- from pdm.outdepot_order
-- where iquantity > 0
-- group by LEFT(ccuscode,2),yearmonth,finnal_ccuscode,item_code,cinvcode
-- union all
-- select LEFT(ccuscode,2) as type,
-- date_format(date_add(ddate,INTERVAL + 2 month),"%Y-%m-%d") as `yearmonth`
-- ,finnal_ccuscode
-- ,item_code
-- ,cinvcode
-- ,count(*) as `num_person`
-- from pdm.outdepot_order
-- where iquantity > 0
-- group by LEFT(ccuscode,2),yearmonth,finnal_ccuscode,item_code,cinvcode) a
group by a.type,a.finnal_ccuscode,a.item_code,a.cinvcode,a.yearmonth;
-- group by a.finnal_ccuscode,a.item_code,a.cinvcode,a.yearmonth having sum(num_person)>=15;

-- 条件是截止目前总开票额大于0，否则为空
drop table if exists pdm.mid6_cuspro_archives;
create TEMPORARY table pdm.mid6_cuspro_archives as
select LEFT((case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ) ,2) as type
      ,min(a.ddate) as mindate
      ,max(a.ddate) as maxdate
      ,(case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ) as ccuscode
      ,a.item_code
      ,a.cinvcode
  from pdm.invoice_order a
  left join pdm.invoice_order_temp b
    on (case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ) = b.finnal_ccuscode
   and a.item_code = b.item_code
   and LEFT((case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ),2)  = b.type
   and a.cinvcode = b.cinvcode
 where b.finnal_ccuscode is not null
 group by (case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ),a.item_code,a.cinvcode
;

-- 获取出货的非LDT类的初次末次发货时间
create TEMPORARY table pdm.mid7_cuspro_archives as 
select LEFT((case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ),2) as type
      ,min(ddate) as mindate
      ,max(ddate) as maxdate
      ,(case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ) AS ccuscode
      ,item_code
      ,cinvcode
  FROM pdm.outdepot_order  a
 where cbustype <> 'LDT'
   and finnal_ccuscode <> ''
 GROUP BY LEFT((case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end ),2)
         ,(case when a.finnal_ccuscode = 'multi' then a.ccuscode else a.finnal_ccuscode end )
	       ,item_code
	       ,cinvcode
 having sum(iquantity) > 0
;

-- 插入时间数据
create TEMPORARY table pdm.mid8_cuspro_archives as 
select a.type
      ,a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.item_name
      ,a.cinvcode
      ,a.cinvname
      ,a.cbustype
      ,a.plan_start_dt
      ,CAST(b.mon1 as date) as first_consign_dt
      ,CAST(b.mon2 as date) as last_consign_dt
      ,CAST(d.mon as date) as install_dt
      ,CAST(c.mindate as date) as first_invoice_dt
      ,CAST(c.maxdate as date)  as last_invoice_dt
  from pdm.mid4_cuspro_archives a
  left join (select type,min(yearmonth) as mon1,max(yearmonth) as mon2,finnal_ccuscode,item_code,cinvcode from pdm.mid5_cuspro_archives group by finnal_ccuscode,item_code,cinvcode) b
    on a.ccuscode = b.finnal_ccuscode
   and a.item_code = b.item_code
   and a.cinvcode = b.cinvcode
   and a.type = b.type
  left join pdm.mid6_cuspro_archives c
    on a.ccuscode = c.ccuscode
   and a.item_code = c.item_code
   and a.cinvcode = c.cinvcode
   and a.type = c.type
  left join (select 'ZD' as type,bi_cuscode AS ccuscode, item_code, bi_cinvcode AS cinvcode,min(new_installation_date) as mon FROM edw.crm_account_equipments GROUP BY bi_cuscode, item_code, bi_cinvcode) d
--  left join (select 'ZD' as type,true_ccuscode AS ccuscode, item_code, bi_cinvcode AS cinvcode,min(new_installation_date) as mon FROM edw.x_cuspro_archives GROUP BY true_ccuscode, item_code, bi_cinvcode) d
    on a.ccuscode = d.ccuscode
   and a.item_code = d.item_code
   and a.cinvcode = d.cinvcode
   and a.type = d.type
 where a.cbustype = 'LDT'
;

-- CREATE INDEX index_mid4_cuspro_archives_cinvcode ON pdm.mid4_cuspro_archives(cinvcode);
-- CREATE INDEX index_mid4_cuspro_archives_ccuscode ON pdm.mid4_cuspro_archives(ccuscode);
-- CREATE INDEX index_mid4_cuspro_archives_item_code ON pdm.mid4_cuspro_archives(item_code);
-- CREATE INDEX index_mid4_cuspro_archives_type ON pdm.mid4_cuspro_archives(type);
-- CREATE INDEX index_mid6_cuspro_archives_cinvcode ON pdm.mid6_cuspro_archives(cinvcode);
-- CREATE INDEX index_mid6_cuspro_archives_ccuscode ON pdm.mid6_cuspro_archives(ccuscode);
-- CREATE INDEX index_mid6_cuspro_archives_item_code ON pdm.mid6_cuspro_archives(item_code);
-- CREATE INDEX index_mid6_cuspro_archives_type ON pdm.mid6_cuspro_archives(type);
-- CREATE INDEX index_mid7_cuspro_archives_cinvcode ON pdm.mid7_cuspro_archives(cinvcode);
-- CREATE INDEX index_mid7_cuspro_archives_ccuscode ON pdm.mid7_cuspro_archives(ccuscode);
-- CREATE INDEX index_mid7_cuspro_archives_item_code ON pdm.mid7_cuspro_archives(item_code);
-- CREATE INDEX index_mid7_cuspro_archives_type ON pdm.mid7_cuspro_archives(type);

-- 插入非LDT类的数据
insert into pdm.mid8_cuspro_archives
select a.type
      ,a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.item_name
      ,a.cinvcode
      ,a.cinvname
      ,a.cbustype
      ,a.plan_start_dt
      ,CAST(b.mindate as date) as first_consign_dt
      ,CAST(b.maxdate as date) as last_consign_dt
      ,CAST(d.mon as date) as install_dt
      ,CAST(c.mindate as date) as first_invoice_dt
      ,CAST(c.maxdate as date) as last_invoice_dt
  from pdm.mid4_cuspro_archives a
  left join pdm.mid7_cuspro_archives b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and a.cinvcode = b.cinvcode
   and a.type = b.type
  left join pdm.mid6_cuspro_archives c
    on a.ccuscode = c.ccuscode
   and a.item_code = c.item_code
   and a.cinvcode = c.cinvcode
   and a.type = c.type
--  left join (select 'ZD' as type,true_ccuscode AS ccuscode, item_code, bi_cinvcode AS cinvcode,min(new_installation_date) as mon FROM edw.x_cuspro_archives GROUP BY true_ccuscode, item_code, bi_cinvcode) d
  left join (select 'ZD' as type,bi_cuscode AS ccuscode, item_code, bi_cinvcode AS cinvcode,min(new_installation_date) as mon FROM edw.crm_account_equipments GROUP BY bi_cuscode, item_code, bi_cinvcode) d
    on a.ccuscode = d.ccuscode
   and a.item_code = d.item_code
   and a.cinvcode = d.cinvcode
   and a.type = d.type
 where a.cbustype <> 'LDT'
;

-- CREATE INDEX index_mid8_cuspro_archives_cinvcode ON pdm.mid8_cuspro_archives(cinvcode);
-- CREATE INDEX index_mid8_cuspro_archives_ccuscode ON pdm.mid8_cuspro_archives(ccuscode);
-- CREATE INDEX index_mid8_cuspro_archives_item_code ON pdm.mid8_cuspro_archives(item_code);
-- CREATE INDEX index_mid8_cuspro_archives_type ON pdm.mid8_cuspro_archives(type);
-- CREATE INDEX index_outdepot_order_temp_cinvcode ON pdm.outdepot_order_temp(cinvcode);
-- CREATE INDEX index_outdepot_order_temp_finnal_ccuscode ON pdm.outdepot_order_temp(finnal_ccuscode);
-- CREATE INDEX index_outdepot_order_temp_item_code ON pdm.outdepot_order_temp(item_code);
-- CREATE INDEX index_outdepot_order_temp_type ON pdm.outdepot_order_temp(type);
-- CREATE INDEX index_invoice_order_temp1_cinvcode ON pdm.invoice_order_temp1(cinvcode);
-- CREATE INDEX index_invoice_order_temp1_ccuscode ON pdm.invoice_order_temp1(ccuscode);
-- CREATE INDEX index_invoice_order_temp1_item_code ON pdm.invoice_order_temp1(item_code);
-- CREATE INDEX index_invoice_order_temp1_type ON pdm.invoice_order_temp1(type);

-- 插入数据并修改最后时间
insert into pdm.cuspro_archives
select a.ccuscode
      ,a.ccusname
      ,a.item_code
      ,a.item_name
      ,a.cinvcode
      ,a.cinvname
      ,c.equipment
      ,case when a.type = 'GR' then '个人销售'
            when a.type = 'ZD' then '终端销售'
            when a.type = 'DL' then '代理销售'
            else '其他' end
      ,a.cbustype
      ,a.plan_start_dt
      ,null
      ,null
      ,a.first_consign_dt
      ,a.last_consign_dt
      ,e.isum
      ,a.install_dt
      ,a.first_invoice_dt
      ,d.ddate
      ,a.last_invoice_dt
      ,d.isum
      ,cast(case when (ifnull(a.first_consign_dt,'1900-01-01') > ifnull(a.install_dt,'1900-01-01') and ifnull(a.first_consign_dt,'1900-01-01') > ifnull(a.first_invoice_dt,'1900-01-01')) then ifnull(a.first_consign_dt,'1900-01-01')
            when (ifnull(a.install_dt,'1900-01-01') > ifnull(a.first_consign_dt,'1900-01-01') and ifnull(a.install_dt,'1900-01-01') > ifnull(a.first_invoice_dt,'1900-01-01')) then ifnull(a.install_dt,'1900-01-01')
            else ifnull(a.first_invoice_dt,'1900-01-01') end as date) as product_start_dt
      ,cast(case when ifnull(a.last_consign_dt,'1900-01-01') > ifnull(a.last_invoice_dt,'1900-01-01') then ifnull(a.last_consign_dt,'1900-01-01')
            else ifnull(a.last_invoice_dt,'1900-01-01') end as date) as product_end_dt
      ,null
      ,b.cinvbrand
      ,'否'
      ,'博圣公司'
  from pdm.mid8_cuspro_archives a
  left join (select bi_cinvcode,cinvbrand from edw.map_inventory group by bi_cinvcode)  b
    on a.cinvcode = b.bi_cinvcode
  left join edw.map_item c
    on a.item_code = c.item_code
  left join pdm.invoice_order_temp1 d
    on a.ccuscode = d.ccuscode
   and a.item_code = d.item_code
   and a.cinvcode = d.cinvcode
   and a.type = d.type
  left join pdm.outdepot_order_temp e
    on a.ccuscode = e.finnal_ccuscode
   and a.item_code = e.item_code
   and a.cinvcode = e.cinvcode
   and a.type = e.type
;

update pdm.cuspro_archives
   set product_start_dt = null
 where product_start_dt = '1900-01-01'
;
update pdm.cuspro_archives
   set product_end_dt = null
 where product_end_dt = '1900-01-01'
;
