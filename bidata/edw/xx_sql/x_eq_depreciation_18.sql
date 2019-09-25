
-- 设备折旧19

drop table if exists edw.x_eq_depreciation_18_pre;
create temporary table edw.x_eq_depreciation_18_pre as
select a.cohr
      ,a.year_belong
      ,a.vouchid
      ,a.ddate_belong
      ,a.vouchnum
      ,a.province
      ,a.sales_region
      ,a.ccusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.eq_name
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,case when d.bi_cinvcode is null then '请核查' else d.level_three end as level_three
      ,case when d.bi_cinvcode is null then '请核查' else d.level_two end as level_two
      ,case when d.bi_cinvcode is null then '请核查' else d.level_one end as level_one
      ,a.isum
      ,a.iquantity
      ,a.amount_depre_mon
      ,a.comment
      ,a.amount_depre_1
      ,a.amount_depre_2
      ,a.amount_depre_3
      ,a.amount_depre_4
      ,a.amount_depre_5
      ,a.amount_depre_6
      ,a.amount_depre_7
      ,a.amount_depre_8
      ,a.amount_depre_9
      ,a.amount_depre_10
      ,a.amount_depre_11
      ,a.amount_depre_12
  from ufdata.x_eq_depreciation_18 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.eq_name = c.cinvname
  left join edw.map_inventory d
    on c.bi_cinvcode = d.bi_cinvcode
;

update edw.x_eq_depreciation_18_pre a
 inner join (select * from edw.fa_cards group by sassetnum) b
    on a.vouchid = b.sassetnum
   set a.eq_name = b.sassetname
 where a.cinvcode = '请核查';


truncate table edw.x_eq_depreciation_18;
insert into edw.x_eq_depreciation_18
select a.cohr
      ,a.year_belong
      ,a.vouchid
      ,a.ddate_belong
      ,a.vouchnum
      ,a.province
      ,a.sales_region
      ,a.ccusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.eq_name
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,case when d.bi_cinvcode is null then '请核查' else d.level_three end as level_three
      ,case when d.bi_cinvcode is null then '请核查' else d.level_two end as level_two
      ,case when d.bi_cinvcode is null then '请核查' else d.level_one end as level_one
      ,a.isum
      ,a.iquantity
      ,a.amount_depre_mon
      ,a.comment
      ,a.amount_depre_1
      ,a.amount_depre_2
      ,a.amount_depre_3
      ,a.amount_depre_4
      ,a.amount_depre_5
      ,a.amount_depre_6
      ,a.amount_depre_7
      ,a.amount_depre_8
      ,a.amount_depre_9
      ,a.amount_depre_10
      ,a.amount_depre_11
      ,a.amount_depre_12
  from edw.x_eq_depreciation_18_pre a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.eq_name = c.cinvname
  left join edw.map_inventory d
    on c.bi_cinvcode = d.bi_cinvcode
;



