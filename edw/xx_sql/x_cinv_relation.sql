-- 产品主辅关系表
truncate table edw.x_cinv_relation;
insert into edw.x_cinv_relation
select a.source
      ,b.bi_cinvcode as cinvcode_child
      ,b.bi_cinvname as cinvname_child
      ,a.match
      ,a.mixture_ratio
      ,c.bi_cinvcode as cinvcode_main
      ,c.bi_cinvname as cinvname_main
      ,d.item_code
      ,d.level_three as item_name
      ,a.level_two_cx
      ,a.level_two
  from ufdata.x_cinv_relation a
  left join (select * from edw.dic_inventory group by cinvcode) b
    on a.cinvcode_child = b.cinvcode
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.cinvcode_main = c.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
;

