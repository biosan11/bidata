
truncate table edw.x_ccus_mechanism;
insert into edw.x_ccus_mechanism
select a.ccuscode
      ,a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.mechanism_offline
  from ufdata.x_ccus_mechanism a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
;






