
truncate table edw.x_account_sy;
insert into edw.x_account_sy
select a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,c.sales_region
      ,c.province
      ,a.year_
      ,sum(a.mon_1) as mon_1
      ,sum(a.mon_2) as mon_2
      ,sum(a.mon_3) as mon_3
      ,sum(a.mon_4) as mon_4
      ,sum(a.mon_5) as mon_5
      ,sum(a.mon_6) as mon_6
      ,sum(a.mon_7) as mon_7
      ,sum(a.mon_8) as mon_8
      ,sum(a.mon_9) as mon_9
      ,sum(a.mon_10) as mon_10
      ,sum(a.mon_11) as mon_11
      ,sum(a.mon_12) as mon_12
  from ufdata.x_account_sy a
  left join (select * from edw.dic_customer group by ccusname) b
    on trim(a.ccusname) = trim(b.ccusname)
  left join (select * from edw.map_customer group by bi_cuscode) c
    on b.bi_cuscode = c.bi_cuscode
 group by b.bi_cuscode,a.year_
;


