truncate table edw.x_ccus_seniority;
insert into edw.x_ccus_seniority
select a.province
      ,a.city
      ,a.ccusname
      ,case when b.ccusname is not null then bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then bi_cusname else '请核查' end as bi_cusname
      ,a.new_cz
      ,a.ddate
      ,a.source
      ,a.url
      ,a.remark
  from ufdata.x_ccus_seniority a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
;