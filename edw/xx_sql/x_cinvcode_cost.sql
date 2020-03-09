
truncate table edw.x_cinvcode_cost;
insert into edw.x_cinvcode_cost
select a.year_
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvname is null then '请核查' else bi_cinvcode end as bi_cinvcode
      ,case when b.cinvname is null then '请核查' else bi_cinvname end as bi_cinvname
      ,a.specification_type
      ,a.cost_price
  from ufdata.x_cinvcode_cost a
  left join (select * from edw.dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
;

