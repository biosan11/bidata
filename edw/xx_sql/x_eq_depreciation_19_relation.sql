-- 19年折旧对应的主辅关系的整理表
truncate table edw.x_eq_depreciation_19_relation;
insert into edw.x_eq_depreciation_19_relation
select a.year_belong
      ,a.ddate_belong
      ,a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.eq_name
      ,a.cinvcode
      ,a.cinvname
      ,case when c.cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvcode is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,d.item_code
      ,d.level_three as item_name
      ,a.amount_19
  from ufdata.x_eq_depreciation_19_relation a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname  = b.ccusname
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode  = c.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode  = d.bi_cinvcode
;

