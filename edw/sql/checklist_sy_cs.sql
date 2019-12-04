insert into edw.checklist_sy_cs
select left(date_label,7) as y_mon
      ,a.hospital
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as company_id
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as company_exp
      ,a.collection_hospital
      ,case when c.ccusname is null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.ccusname is null then '请核查' else c.bi_cusname end as bi_cusname
      ,sum(a.amount) as amount
      ,PAPPA
      ,hCGb
      ,AFP
      ,uE3
      ,pregnant
  from share.preg_amount_peoject a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.collection_hospital = c.ccusname
 where left(date_label,7) = '${y_mon}'
 group by PAPPA
      ,hCGb
      ,AFP
      ,uE3
      ,pregnant
      ,collection_hospital
      ,hospital
      ,y_mon
;