
-- 清空表数据
truncate table pdm.checklist;

-- 插入检测量数据,19n年以前的历史数据
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
;

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
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
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
    on a.true_ccuscode = b.bi_cuscode
  left join (select bi_cinvcode,item_code,level_three from edw.map_inventory group by bi_cinvcode) c
    on a.bi_cinvcode = c.bi_cinvcode
 where left(a.true_ccuscode,2) <> 'GL' 
   and ddate_sample < '2019-06-01'
 group by a.ddate,a.true_ccuscode,a.bi_cinvcode,a.class_smaple
;

-- 19年6月开始的数据由于及时性的调整，修改为
-- 1、对账前的外送一览表取数
-- 2、贝康线下数据
-- 3、甄元实验室的数据

-- 甄元数据
insert into pdm.checklist
select null
      ,'zysy'
      ,a.province
      ,null
      ,ddate_sampling
      ,a.class_smaple
      ,a.bi_cusname
      ,ddate_sampling
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,a.item_name
      ,a.business_class
      ,count(*) as inum_person
      ,0
      ,'否'
      ,null
      ,localtimestamp()
  from edw.x_sales_hospital a
 where ddate_sampling >= '2019-06-01'
 group by ddate_sampling,bi_cuscode,bi_cinvcode,a.class_smaple
;
-- 贝康数据
insert into pdm.checklist
select null
      ,'bksy'
      ,a.province
      ,null
      ,ddate_sample
      ,a.class_smaple
      ,a.bi_cusname
      ,ddate_sample
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,a.item_name
      ,a.business_class
      ,count(*) as inum_person
      ,0
      ,'否'
      ,null
      ,localtimestamp()
  from edw.x_ldt_bk a
 where ddate_sample >= '2019-06-01'
 group by ddate_sample,bi_cuscode,bi_cinvcode,a.class_smaple
;

insert into pdm.checklist
select min(auto_id)
      ,'wsylb'
      ,b.province
      ,a.person_ori
      ,a.ddate_sample
      ,a.class_smaple
      ,a.company_exp
      ,a.ddate
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
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
  from edw.x_ldt_list_before a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select bi_cinvcode,item_code,level_three from edw.map_inventory group by bi_cinvcode) c
    on a.bi_cinvcode = c.bi_cinvcode
 where left(a.true_ccuscode,2) <> 'GL' 
   and ddate_sample >= '2019-06-01'
   and company_exp not in ('贝康','甄元')
 group by a.ddate,a.true_ccuscode,a.bi_cinvcode,a.class_smaple
;






-- crm筛查诊断数据修改
-- 19年的数据插入12次,这里是所有的自建的数据
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-01-01'
      ,null
      ,a.bi_cusname
      ,'2019-01-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;

insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-02-01'
      ,null
      ,a.bi_cusname
      ,'2019-02-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;

insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-03-01'
      ,null
      ,a.bi_cusname
      ,'2019-03-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-04-01'
      ,null
      ,a.bi_cusname
      ,'2019-04-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-05-01'
      ,null
      ,a.bi_cusname
      ,'2019-05-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-06-01'
      ,null
      ,a.bi_cusname
      ,'2019-06-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-07-01'
      ,null
      ,a.bi_cusname
      ,'2019-07-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-08-01'
      ,null
      ,a.bi_cusname
      ,'2019-08-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-09-01'
      ,null
      ,a.bi_cusname
      ,'2019-09-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-10-01'
      ,null
      ,a.bi_cusname
      ,'2019-10-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-11-01'
      ,null
      ,a.bi_cusname
      ,'2019-11-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;
insert into pdm.checklist
select null
      ,'crm'
      ,a.new_province
      ,a.lastname
      ,'2019-12-01'
      ,null
      ,a.bi_cusname
      ,'2019-12-01'
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
   and year_ = '2019'
   and a.hzfs = '自建'
;


-- insert into pdm.checklist
-- select a.id
--       ,null
--       ,a.new_province
--       ,a.ownerid
--       ,left(a.createdon,10)
--       ,null
--       ,a.name
--       ,left(a.new_finish_time,10)
--       ,b.bi_cuscode
--       ,b.bi_cusname
--       ,null
--       ,null
--       ,c.bi_item_code
--       ,c.bi_item_name
--       ,'产品类'
--       ,a.new_biosan
--       ,a.new_cszh
--       ,'否'
--       ,null
--       ,localtimestamp()
--    from edw.crm_screening_diagnosises a
--    left join (select * from edw.dic_customer group by ccuscode) b
--      on a.new_num = b.ccuscode
--    left join (select * from edw.dic_item group by item_name) c
--      on a.item_mx = c.item_name
--  where a.new_biosan > 0
--    and new_finish_time >= '2019-01-01'
--    and a.hzfs = '自建'
-- ;
-- 
-- insert into pdm.checklist
-- select a.id
--       ,null
--       ,a.new_province
--       ,a.ownerid
--       ,left(a.createdon,10)
--       ,null
--       ,a.name
--       ,left(a.new_finish_time,10)
--       ,b.bi_cuscode
--       ,b.bi_cusname
--       ,null
--       ,null
--       ,c.bi_item_code
--       ,c.bi_item_name
--       ,'产品类'
--       ,a.new_competitor_number
--       ,a.new_cszh
--       ,'是'
--       ,jzds_name
--       ,localtimestamp()
--    from edw.crm_screening_diagnosises a
--    left join (select * from edw.dic_customer group by ccuscode) b
--      on a.new_num = b.ccuscode
--    left join (select * from edw.dic_item group by item_name) c
--      on a.item_mx = c.item_name
--  where a.new_competitor_number > 0
--    and new_finish_time >= '2019-01-01'
--    and a.hzfs = '自建'
-- ;






