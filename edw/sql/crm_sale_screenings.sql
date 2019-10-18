
drop table if exists edw.crm_sale_screenings_pre;
create temporary table edw.crm_sale_screenings_pre as
select d.new_area
      ,d.new_province
      ,d.new_city
      ,d.new_county
      ,b.lastname
      ,2019 as year_
      ,case when new_fangshi = 0 then '自建' else '外送' end as hzfs
      ,d.new_num
      ,d.name
      ,e.item_name as item_dl
      ,f.item_name as item_xl
      ,g.item_name as item_mx
      ,a.new_january
      ,a.new_february
      ,a.new_march
      ,a.new_april
      ,a.new_may
      ,a.new_june
      ,a.new_july
      ,a.new_august
      ,a.new_september
      ,a.new_october
      ,a.new_november
      ,a.new_december
      ,localtimestamp() as sys_time
  from ufdata.crm_new_sale_screenings a
  left join ufdata.crm_systemusers b
    on a.ownerid = b.ownerid
  left join ufdata.crm_accounts c
    on a.new_account = c.accountid
  left join edw.crm_accounts d
    on c.new_num = d.new_num
  left join edw.dic_item_crm e
    on a.new_type1 = e.item_code
  left join edw.dic_item_crm f
    on a.new_type2 = f.item_code
  left join edw.dic_item_crm g
    on a.new_type3 = g.item_code
 where a.statecode = '0'
;


truncate table edw.crm_sale_screenings;
insert into edw.crm_sale_screenings
select new_area
      ,a.new_province
      ,a.new_city
      ,a.new_county
      ,a.lastname
      ,a.year_
      ,a.hzfs
      ,a.new_num as cuscode
      ,a.name as cusname
      ,case when c.bi_cuscode is null and a.new_num is not null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.bi_cuscode is null and a.new_num is not null then '请核查' else c.bi_cusname end as bi_cusname
      ,case when b.level_three is null then '请核查' else b.item_code end as item_code
      ,case when b.level_three is null then '请核查' else b.level_three end as item_name
      ,a.item_dl
      ,a.item_xl
      ,a.item_mx
      ,a.new_january
      ,a.new_february
      ,a.new_march
      ,a.new_april
      ,a.new_may
      ,a.new_june
      ,a.new_july
      ,a.new_august
      ,a.new_september
      ,a.new_october
      ,a.new_november
      ,a.new_december
      ,a.sys_time
  from edw.crm_sale_screenings_pre a
 left join (select * from edw.map_item group by level_three) b
   on a.item_mx = b.level_three
 left join (select * from edw.dic_customer group by ccuscode) c
   on a.new_num = c.ccuscode
;











