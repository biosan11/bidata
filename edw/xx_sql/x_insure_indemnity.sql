truncate table edw.x_insure_indemnity ;
insert into edw.x_insure_indemnity 
SELECT REPLACE( a.db, '[NULL]',""),
	     REPLACE ( trim( a.policy_number ), '[NULL]',""),
	     REPLACE ( a.the_insured, '[NULL]',""),
	     REPLACE ( a.strendcasedate, '[NULL]',""),
	     REPLACE ( a.init_amount, '[NULL]',""),
	     REPLACE ( a.total_pay, '[NULL]',""),
	     REPLACE ( a.report_date, '[NULL]',""),
	     REPLACE ( a.collection_date, '[NULL]',""),
	     REPLACE ( a.id_smaple, '[NULL]',""),
	     REPLACE ( a.nm_hospital, '[NULL]',""),
	     REPLACE ( CASE WHEN a.nm_hospital IS NOT NULL AND b.ccusname IS NULL THEN '请核查' ELSE b.bi_cuscode END, '[NULL]',"") AS bi_cuscode,
	     REPLACE ( CASE WHEN a.nm_hospital IS NOT NULL AND b.ccusname IS NULL THEN '请核查' ELSE b.bi_cusname END, '[NULL]',"") AS bi_cusname,
	     REPLACE ( a.claim_type, '[NULL]',""),
	     REPLACE ( a.nifty_result, '[NULL]',""),
	     REPLACE ( a.second_date, '[NULL]',""),
	     REPLACE ( a.sample_type, '[NULL]',""),
	     REPLACE ( a.second_hospital, '[NULL]',""),
	     REPLACE ( CASE WHEN a.second_hospital IS NOT NULL AND c.ccusname IS NULL THEN '请核查' ELSE c.bi_cuscode END, '[NULL]',"") AS bi_cuscode2,
	     REPLACE ( CASE WHEN a.second_hospital IS NOT NULL AND c.ccusname IS NULL THEN '请核查' ELSE c.bi_cusname END, '[NULL]',"") AS bi_cusname2,
	     REPLACE ( a.second_methods, '[NULL]',""),
	     REPLACE ( a.second_result, '[NULL]',""),
	     REPLACE ( a.same_niffy, '[NULL]',""),
	     REPLACE ( a.abnormal_chromosomes, '[NULL]',""),
	     REPLACE ( a.exception_types, '[NULL]',""),
	     REPLACE ( a.whether_chimeric, '[NULL]',""),
	     REPLACE ( a.pregnancy_status, '[NULL]',""),
	     REPLACE ( a.invoice_amount, '[NULL]',""),
	     REPLACE ( a.state, '[NULL]',""),
	     REPLACE ( a.tsafe, '[NULL]',"")
  from ufdata.x_insure_indemnity a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.nm_hospital = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.second_hospital = c.ccusname
 order by policy_number
;

drop table if exists edw.x_insure_indemnity_pre;
create table edw.x_insure_indemnity_pre as
select db
      ,@r:= case when @policy_number=a.policy_number then @r+1 else 1 end as rownum
      ,@policy_number:=a.policy_number as policy_number
      ,the_insured
      ,strendcasedate
      ,init_amount
      ,total_pay
      ,report_date
      ,collection_date
      ,id_smaple
      ,nm_hospital
      ,bi_cuscode
      ,bi_cusname
      ,claim_type
      ,nifty_result
      ,second_date
      ,sample_type
      ,second_hospital
      ,bi_cuscode2
      ,bi_cusname2
      ,second_methods
      ,second_result
      ,same_niffy
      ,abnormal_chromosomes
      ,exception_types
      ,whether_chimeric
      ,pregnancy_status
      ,invoice_amount
      ,state
      ,tsafe
  from edw.x_insure_indemnity a
,(select @r:=0,@policy_number:='') b
;

truncate table edw.x_insure_indemnity ;
insert into edw.x_insure_indemnity 
select a.db
      ,ifnull(b.policy_number       ,a.policy_number        )
      ,ifnull(b.the_insured         ,a.the_insured          )
      ,ifnull(b.strendcasedate      ,a.strendcasedate       )
      ,ifnull(b.init_amount         ,a.init_amount          )
      ,ifnull(b.total_pay           ,a.total_pay            )
      ,ifnull(b.report_date         ,a.report_date          )
      ,ifnull(b.collection_date     ,a.collection_date      )
      ,ifnull(b.id_smaple           ,a.id_smaple            )
      ,ifnull(b.nm_hospital         ,a.nm_hospital          )
      ,ifnull(b.bi_cuscode          ,a.bi_cuscode           )
      ,ifnull(b.bi_cusname          ,a.bi_cusname           )
      ,ifnull(b.claim_type          ,a.claim_type           )
      ,ifnull(b.nifty_result        ,a.nifty_result         )
      ,ifnull(b.second_date         ,a.second_date          )
      ,ifnull(b.sample_type         ,a.sample_type          )
      ,ifnull(b.second_hospital     ,a.second_hospital      )
      ,ifnull(b.bi_cuscode2         ,a.bi_cuscode2          )
      ,ifnull(b.bi_cusname2         ,a.bi_cusname2          )
      ,ifnull(b.second_methods      ,a.second_methods       )
      ,ifnull(b.second_result       ,a.second_result        )
      ,ifnull(b.same_niffy          ,a.same_niffy           )
      ,ifnull(b.abnormal_chromosomes,a.abnormal_chromosomes )
      ,ifnull(b.exception_types     ,a.exception_types      )
      ,ifnull(b.whether_chimeric    ,a.whether_chimeric     )
      ,ifnull(b.pregnancy_status    ,a.pregnancy_status     )
      ,ifnull(b.invoice_amount      ,a.invoice_amount       )
      ,ifnull(b.state               ,a.state                )
      ,ifnull(b.tsafe               ,a.tsafe                )
  from (select * from edw.x_insure_indemnity_pre where rownum = 1) a
  left join (select * from edw.x_insure_indemnity_pre where rownum = 2) b
    on a.policy_number = b.policy_number
;

drop table if exists edw.x_insure_indemnity_pre;

-- 更新
update edw.x_insure_indemnity
   set second_methods = case when second_methods like '%核型%' and second_methods like '%BoBs%' then '核型+BoBs'
                             when second_methods like '%核型%' and second_methods like '%CMA%' then '核型+CMA'
                             when second_methods like '%核型%' and second_methods like '%SNP%' then '核型+CMA'
                             when second_methods like '%核型%' and second_methods like '%芯片%' then '核型+CMA'
                             when second_methods like '%核型%' and second_methods like '%全基因组%' then '核型+CMA'
                             when second_methods like '%核型%' and second_methods like '%畸变%' then '核型+CMA'
                             when second_methods like '%核型%' and second_methods like '%FISH%' then '核型+FISH'
                             when second_methods like '%核型%' and second_methods like '%CNV-seq%' then '核型+CNV-seq'
                             when second_methods like '%核型%' and second_methods like '%AFP%' then '核型+AFP'
                             when second_methods like '%核型%' then '核型'
                             when second_methods like '%BoBs%' then 'BoBs'
                             when second_methods like '%CMA%' then 'CMA'
                             when second_methods like '%SNP%' then 'CMA'
                             when second_methods like '%芯片%' then 'CMA'
                             when second_methods like '%全基因组%' then 'CMA'
                             when second_methods like '%畸变%' then 'CMA'
                             when second_methods like '%FISH%' then 'FISH'
                             when second_methods like '%AFP%' then '血清学'
                             when second_methods like '%CNV-seq%' then 'CNV-seq'
                             else '未知' end
;