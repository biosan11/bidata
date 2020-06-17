
-- 将安徽省NIPT2020年的检测量更新
drop table if exists edw.x_ccus_delivery_tem0;
create temporary table if not exists edw.x_ccus_delivery_tem0
select
new_province
,new_city
,year_
,item_name
,sum(new_january) as month_1
,sum(new_february) as month_2
,sum(new_march) as month_3
,sum(new_april) as month_4
,sum(new_may) as month_5
,sum(new_june) as month_6
,sum(new_july) as month_7
,sum(new_august) as month_8
,sum(new_september) as month_9
,sum(new_october) as month_10
,sum(new_november) as month_11
,sum(new_december) as month_12
from edw.crm_sale_screenings
where new_province = '安徽省' and item_name ='NIPT' and year_ = 2020
group by new_city
;

-- 更新第一层数据
update ufdata.x_ccus_delivery as a
  join edw.x_ccus_delivery_tem0 as b
   on a.province_get = b.new_province and a.city_get = b.new_city and a.item_name = b.item_name and a.year_ = b.year_
  set a.month_1 = b.month_1 ,a.month_2 = b.month_2 ,a.month_3 = b.month_3 ,a.month_4 = b.month_4 ,
      a.month_5 = b.month_5 ,a.month_6 = b.month_6 ,a.month_7 = b.month_7 ,a.month_8 = b.month_8,
      a.month_9 = b.month_9 ,a.month_10 = b.month_10 ,a.month_11 = b.month_11 ,a.month_12 = b.month_12
;

truncate table edw.x_ccus_delivery;
insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-01','-01') as ddate
      ,a.month_1
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-02','-01') as ddate
      ,a.month_2
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-03','-01') as ddate
      ,a.month_3
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-04','-01') as ddate
      ,a.month_4
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-05','-01') as ddate
      ,a.month_5
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-06','-01') as ddate
      ,a.month_6
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-07','-01') as ddate
      ,a.month_7
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-08','-01') as ddate
      ,a.month_8
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-09','-01') as ddate
      ,a.month_9
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-10','-01') as ddate
      ,a.month_10
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-11','-01') as ddate
      ,a.month_11
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

insert into edw.x_ccus_delivery
select a.province_get
      ,a.city_get
      ,a.hospital
      ,a.city_give
      ,a.county
      ,a.city_grade
      ,a.type
      ,a.collection_hospital
      ,a.item_name as item_name_old
      ,a.ddate_start
      ,a.ddate_end
      ,concat(a.year_,'-12','-01') as ddate
      ,a.month_12
      ,case when d.bi_cuscode is null then '请核查' else d.bi_cuscode end  as bi_cuscode
      ,case when d.bi_cusname is null then '请核查' else d.bi_cusname end  as bi_cusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end  as finnal_cuscode
      ,case when b.bi_cusname is null then '请核查' else b.bi_cusname end  as finnal_cusname
      ,case when c.item_code is null then '请核查' else c.item_code end  as item_code
      ,case when c.level_three is null then '请核查' else c.level_three end  as item_name
  from ufdata.x_ccus_delivery a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_name = c.level_three
  left join (select * from edw.dic_customer group by ccusname) d
    on a.collection_hospital = d.ccusname
;

-- 删除在结束送样日期之后的数据
delete from edw.x_ccus_delivery where ifnull(ddate_end,'3000-12-31') < ddate and inum_person is null;
