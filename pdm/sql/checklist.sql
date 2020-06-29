------------------------------------程序头部----------------------------------------------
--功能：检测量整合
------------------------------------------------------------------------------------------
--程序名称：checklist.sql
--目标模型：checklist
--源    表：edw.x_detection_table,edw.crm_sale_screenings,edw.x_sales_bkgr
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/pdm/py/checklist.py 2020-06-29
------------------------------------开始处理逻辑------------------------------------------

-- 20200628修改: 
--     3.1、自建 新筛产筛数据
--         3.1.1、19年以前取用先下数据、数据不包含贝康数据：x_detection_table
--         3.1.2、19年以后取用crm检测量自建数据：crm_sale_screenings
--     3.2、ldt 数据(全部重置)
--         3.2.1、取用外送一览表：x_sales_bkgr
-- 清空表数据
truncate table pdm.checklist;

-- 插入检测量数据,19n年以前的自建历史数据
insert into pdm.checklist
select a.autoid
      ,a.db
      ,b.province
      ,a.cverifier
      ,null
      ,null
      ,case when a.feeler_mechanism is not null then a.feeler_mechanism else a.bi_cusname end
      ,a.ddate
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.bi_item_code
      ,a.bi_item_name
      ,a.business_class
      ,a.detection_num
      ,a.recall_num
      ,'否'
      ,null
      ,localtimestamp()
  from edw.x_detection_table a
  left join edw.map_customer b
    on a.bi_cuscode = b.bi_cuscode
 where a.detection_num > 0
   and a.state = '取用'
   and db <> '外送一览表'
;

-- 竞争对手的检测量
insert into pdm.checklist
select a.autoid
      ,a.db
      ,b.province
      ,a.cverifier
      ,null
      ,null
      ,case when a.feeler_mechanism is not null then a.feeler_mechanism else a.bi_cusname end
      ,a.ddate
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.bi_item_code
      ,a.bi_item_name
      ,a.business_class
      ,a.competitor_num
      ,a.recall_num
      ,'是'
      ,competitor
      ,localtimestamp()
  from edw.x_detection_table a
  left join edw.map_customer b
    on a.bi_cuscode = b.bi_cuscode
 where a.competitor_num > 0
   and a.state = '取用'
   and db <> '外送一览表'
;


-- 插入外送一览表数据
-- 修改最新的逻辑，外送一览表历史的只取到2019-05以前的数据
insert into pdm.checklist
select min(auto_id)
      ,'bkgr'
      ,b.province
      ,a.person_ori
      ,a.ddate_sample
      ,a.class_smaple
      ,a.company_exp
      ,a.ddate
      ,a.finnal_ccuscode as ccuscode
      ,a.finnal_ccusname as ccusname
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,case when c.bi_cinvcode is not null then c.item_code else '请核查' end
      ,case when c.bi_cinvcode is not null then c.level_three else '请核查' end
      ,'LDT'
      ,count(*) as inum_person
      ,null
      ,'否'
      ,null
      ,localtimestamp()
  from edw.x_sales_bkgr a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
  left join (select bi_cinvcode,item_code,level_three from edw.map_inventory group by bi_cinvcode) c
    on a.bi_cinvcode = c.bi_cinvcode
 where left(a.true_ccuscode,2) <> 'GL' 
--   and ddate < '2019-06-01'
 group by a.ddate,a.finnal_ccuscode,a.bi_cinvcode,a.class_smaple
;

-- crm筛查诊断数据修改
-- 19年的数据插入12次,这里是所有的自建的数据
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-01-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-01-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_january
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_january > 0
--   and year_ = '2019'
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;

insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-02-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-02-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_february
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_february > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;

insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-03-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-03-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_march
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_march > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-04-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-04-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_april
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_april > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-05-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-05-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_may
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_may > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-06-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-06-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_june
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_june > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-07-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-07-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_july
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_july > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-08-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-08-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_august
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_august > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-09-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-09-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_september
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_september > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-10-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-10-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_october
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_october > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-11-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-11-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_november
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_november > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,concat(year_,'-12-01')
      ,null
      ,a.bi_cusname
      ,concat(year_,'-12-01')
      ,a.bi_cuscode
      ,a.bi_cusname
      ,null
      ,null
      ,a.item_code
      ,a.item_name
      ,'产品类'
      ,a.new_december
      ,0
      ,'否'
      ,null
      ,localtimestamp()
   from edw.crm_sale_screenings a
 where a.new_december > 0
   and a.hzfs = '自建'
 group by year_,bi_cuscode,item_code
;

