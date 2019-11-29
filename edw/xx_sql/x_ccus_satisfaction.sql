
truncate table edw.x_ccus_satisfaction;
insert into edw.x_ccus_satisfaction
select a.ddate
      ,a.ccusname
      ,case when b.ccusname is null then '' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '' else b.bi_cusname end as bi_cusname
      ,a.applicant
      ,a.keshi
      ,a.item_name
      ,a.comment
  from ufdata.x_ccus_satisfaction a
  left join(select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
;



