truncate table edw.x_insure_indemnity ;
insert into edw.x_insure_indemnity 
select a.db
      ,a.policy_number
      ,a.the_insured
      ,a.strendcasedate
      ,a.init_amount
      ,a.total_pay
      ,a.report_date
      ,a.collection_date
      ,a.id_smaple
      ,a.nm_hospital
      ,case when a.nm_hospital is not null and b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when a.nm_hospital is not null and b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.claim_type
      ,a.nifty_result
      ,a.second_date
      ,a.sample_type
      ,a.second_hospital
      ,case when a.second_hospital is not null and c.ccusname is null then '请核查' else c.bi_cuscode end as bi_cuscode2
      ,case when a.second_hospital is not null and c.ccusname is null then '请核查' else c.bi_cusname end as bi_cusname2
      ,a.second_methods
      ,a.second_result
      ,a.same_niffy
      ,a.abnormal_chromosomes
      ,a.exception_types
      ,a.whether_chimeric
      ,a.pregnancy_status
      ,a.invoice_amount
      ,a.state
      ,a.tsafe
  from ufdata.x_insure_indemnity a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.nm_hospital = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.second_hospital = c.ccusname
;











