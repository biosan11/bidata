-- 脚本是为了针对浙江这边存在送检这个情况
-- 客户项目是对应的上的时候进行替换，原值保留

drop table if exists pdm.checklist_fx_pd_pre;
create temporary table pdm.checklist_fx_pd_pre as
select a.index
      ,a.id
      ,b.true_ccuscode as ccuscode
      ,a.item_code
      ,a.ym
      ,a.inum_person
      ,a.quarter_1
      ,a.quarter_3
      ,a.low
      ,a.up
      ,0 as inum_person_ad
      ,a.inum_person_ad as inum_person_ad_sj
      ,a.mark_forecast
  from pdm.checklist_fx_pd a
	left join edw.dic_customer_sj b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
 where b.ccuscode is not null
union all
select a.index
      ,a.id
      ,a.ccuscode
      ,a.item_code
      ,a.ym
      ,a.inum_person
      ,a.quarter_1
      ,a.quarter_3
      ,a.low
      ,a.up
      ,a.inum_person_ad
      ,case when b.ccuscode is null then a.inum_person_ad else 0 end as inum_person_ad_sj
      ,a.mark_forecast
  from pdm.checklist_fx_pd a
	left join edw.dic_customer_sj b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
;

truncate table pdm.checklist_fx_pd_sj;
insert into pdm.checklist_fx_pd_sj
select `index`
      ,id
      ,ccuscode
      ,item_code
      ,ym
      ,inum_person
      ,quarter_1
      ,quarter_3
      ,low
      ,up
      ,sum(inum_person_ad) as inum_person_ad
      ,sum(inum_person_ad_sj) as inum_person_ad_sj
      ,mark_forecast
  from pdm.checklist_fx_pd_pre
 group by ccuscode,item_code,ym
;



-- drop table if exists pdm.checklist_fx_pd_pre;
-- create temporary table pdm.checklist_fx_pd_pre as
-- select a.index
--       ,a.id
--       ,ifnull(b.true_ccuscode,a.ccuscode) as ccuscode
--       ,a.item_code
--       ,a.ym
--       ,a.inum_person
--       ,a.quarter_1
--       ,a.quarter_3
--       ,a.low
--       ,a.up
--       ,0 as inum_person_ad
--       ,a.inum_person_ad as inum_person_ad_sj
--       ,a.mark_forecast
--   from pdm.checklist_fx_pd a
-- 	left join edw.dic_customer_sj b
--     on a.ccuscode = b.ccuscode
--    and a.item_code = b.item_code
-- union all
-- select a.index
--       ,a.id
--       ,a.ccuscode as ccuscode
--       ,a.item_code
--       ,a.ym
--       ,a.inum_person
--       ,a.quarter_1
--       ,a.quarter_3
--       ,a.low
--       ,a.up
--       ,a.inum_person_ad
--       ,0
--       ,a.mark_forecast
--   from pdm.checklist_fx_pd a
-- 	left join edw.dic_customer_sj b
--     on a.ccuscode = b.ccuscode
--    and a.item_code = b.item_code
-- ;


