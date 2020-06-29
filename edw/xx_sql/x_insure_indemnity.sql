

-- 20200629更新  ( 金晶)
-- 调整字段, 留有效字段, 根据20200629钉钉与彭丽沟通


truncate table edw.x_insure_indemnity ;
insert into edw.x_insure_indemnity 
select replace( a.db, '[null]',""),
	     replace ( trim( a.policy_number ), '[null]',""),
	     replace ( a.the_insured, '[null]',""),
	     replace ( a.strendcasedate, '[null]',""),
-- 	     replace ( a.init_amount, '[null]',""),
	     replace ( a.total_pay, '[null]',""),
	     replace ( a.report_date, '[null]',""),
	     replace ( a.collection_date, '[null]',""),
-- 	     replace ( a.id_smaple, '[null]',""),
	     replace ( a.nm_hospital, '[null]',""),
	     replace ( case when a.nm_hospital is not null and b.ccusname is null then '请核查' else b.bi_cuscode end, '[null]',"") as bi_cuscode,
	     replace ( case when a.nm_hospital is not null and b.ccusname is null then '请核查' else b.bi_cusname end, '[null]',"") as bi_cusname,
	     replace ( a.claim_type, '[null]',""),
	     replace ( a.nifty_result, '[null]',""),
	     replace ( a.second_date, '[null]',""),
	     replace ( a.sample_type, '[null]',""),
	     replace ( a.second_hospital, '[null]',""),
	     replace ( case when a.second_hospital is not null and c.ccusname is null then '请核查' else c.bi_cuscode end, '[null]',"") as bi_cuscode2,
	     replace ( case when a.second_hospital is not null and c.ccusname is null then '请核查' else c.bi_cusname end, '[null]',"") as bi_cusname2,
	     replace ( a.second_methods, '[null]',""),
         replace ( a.else_methods, '[null]',""),
	     replace ( a.second_result, '[null]',""),
         replace ( a.else_methods, '[null]',""),
	     replace ( a.same_niffy, '[null]',""),
-- 	     replace ( a.abnormal_chromosomes, '[null]',""),
-- 	     replace ( a.exception_types, '[null]',""),
-- 	     replace ( a.whether_chimeric, '[null]',""),
	     replace ( a.pregnancy_status, '[null]',""),
	     replace ( a.invoice_amount, '[null]',"")
-- 	     replace ( a.state, '[null]',""),
-- 	     replace ( a.tsafe, '[null]',"")
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
--       ,init_amount
      ,total_pay
      ,report_date
      ,collection_date
--       ,id_smaple
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
      ,else_methods
      ,second_result
      ,else_result
      ,same_niffy
      ,pregnancy_status
      ,invoice_amount
  from edw.x_insure_indemnity a
,(select @r:=0,@policy_number:='') b
;

truncate table edw.x_insure_indemnity ;
insert into edw.x_insure_indemnity 
select a.db
      ,ifnull(b.policy_number       ,a.policy_number        )
      ,ifnull(b.the_insured         ,a.the_insured          )
      ,ifnull(b.strendcasedate      ,a.strendcasedate       )
--       ,ifnull(b.init_amount         ,a.init_amount          )
      ,ifnull(b.total_pay           ,a.total_pay            )
      ,ifnull(b.report_date         ,a.report_date          )
      ,ifnull(b.collection_date     ,a.collection_date      )
--       ,ifnull(b.id_smaple           ,a.id_smaple            )
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
      ,ifnull(b.else_methods        ,a.else_methods       )
      ,ifnull(b.second_result       ,a.second_result        )
      ,ifnull(b.else_result         ,a.else_result        )
      ,ifnull(b.same_niffy          ,a.same_niffy           )
      ,ifnull(b.pregnancy_status    ,a.pregnancy_status     )
      ,ifnull(b.invoice_amount      ,a.invoice_amount       )
  from (select * from edw.x_insure_indemnity_pre where rownum = 1) a
  left join (select * from edw.x_insure_indemnity_pre where rownum = 2) b
    on a.policy_number = b.policy_number
;

drop table if exists edw.x_insure_indemnity_pre;

-- 更新
-- update edw.x_insure_indemnity
--    set second_methods = case when second_methods like '%核型%' and second_methods like '%bobs%' then '核型+bobs'
--                              when second_methods like '%核型%' and second_methods like '%cma%' then '核型+cma'
--                              when second_methods like '%核型%' and second_methods like '%snp%' then '核型+cma'
--                              when second_methods like '%核型%' and second_methods like '%芯片%' then '核型+cma'
--                              when second_methods like '%核型%' and second_methods like '%全基因组%' then '核型+cma'
--                              when second_methods like '%核型%' and second_methods like '%畸变%' then '核型+cma'
--                              when second_methods like '%核型%' and second_methods like '%fish%' then '核型+fish'
--                              when second_methods like '%核型%' and second_methods like '%cnv-seq%' then '核型+cnv-seq'
--                              when second_methods like '%核型%' and second_methods like '%afp%' then '核型+afp'
--                              when second_methods like '%核型%' then '核型'
--                              when second_methods like '%bobs%' then 'bobs'
--                              when second_methods like '%cma%' then 'cma'
--                              when second_methods like '%snp%' then 'cma'
--                              when second_methods like '%芯片%' then 'cma'
--                              when second_methods like '%全基因组%' then 'cma'
--                              when second_methods like '%畸变%' then 'cma'
--                              when second_methods like '%fish%' then 'fish'
--                              when second_methods like '%afp%' then '血清学'
--                              when second_methods like '%cnv-seq%' then 'cnv-seq'
--                              else '未知' end
-- ;
