-- 创建临时表
drop table if exists edw.oa_meet_market_conference_pre;
create temporary table edw.oa_meet_market_conference_pre as
select a.liuchengbh
      ,a.huiyimc
      ,a.lastname
      ,a.departmentname
      ,a.shenqingrq
      ,a.huiyilx
      ,a.huiyiksrq
      ,a.huiyijsrq
      ,a.qitamd
      ,a.shichangyszfy
      ,a.shijizfy
      ,a.huiyijl
      ,a.huihougj
      ,a.xiaoshoujscjh
      ,a.yusuanxm
      ,a.yusuanxjje
      ,a.juesuanje
      ,a.liuchengjd
      ,case when LENGTH(xs_md) = 1 and xs_md = 0 then null
            when LENGTH(xs_md) = 2 then concat(SUBSTRING(xs_md, 1, 1),';',SUBSTRING(xs_md, 2, 1))
            when LENGTH(xs_md) = 3 then concat(SUBSTRING(xs_md, 1, 1),';',SUBSTRING(xs_md, 2, 1),';',SUBSTRING(xs_md, 3, 1))
            when LENGTH(xs_md) = 4 then concat(SUBSTRING(xs_md, 1, 1),';',SUBSTRING(xs_md, 2, 1),';',SUBSTRING(xs_md, 3, 1),';',SUBSTRING(xs_md, 4, 1))
            when LENGTH(xs_md) = 5 then concat(SUBSTRING(xs_md, 1, 1),';',SUBSTRING(xs_md, 2, 1),';',SUBSTRING(xs_md, 3, 1),';',SUBSTRING(xs_md, 4, 1),';',SUBSTRING(xs_md, 5, 1))
            else null end as xs_md
      ,case when LENGTH(cs_md) = 1 and xs_md = 0 then null
            when LENGTH(cs_md) = 2 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1))
            when LENGTH(cs_md) = 3 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1))
            when LENGTH(cs_md) = 4 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1),';',SUBSTRING(cs_md, 4, 1))
            when LENGTH(cs_md) = 5 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1),';',SUBSTRING(cs_md, 4, 1),';',SUBSTRING(cs_md, 5, 1))
            when LENGTH(cs_md) = 6 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1),';',SUBSTRING(cs_md, 4, 1),';',SUBSTRING(cs_md, 5, 1),';',SUBSTRING(cs_md, 6, 1))
            when LENGTH(cs_md) = 7 then concat(SUBSTRING(cs_md, 1, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1),';',SUBSTRING(cs_md, 4, 1),';',SUBSTRING(cs_md, 5, 1),';',SUBSTRING(cs_md, 6, 1),';',SUBSTRING(cs_md, 7, 1))
            when LENGTH(cs_md) = 7 then concat(SUBSTRING(cs_md, 8, 1),';',SUBSTRING(cs_md, 2, 1),';',SUBSTRING(cs_md, 3, 1),';',SUBSTRING(cs_md, 4, 1),';',SUBSTRING(cs_md, 5, 1),';',SUBSTRING(cs_md, 6, 1),';',SUBSTRING(cs_md, 7, 1),';',SUBSTRING(cs_md, 8, 1))
            else null end as cs_md
  from ufdata.oa_meet_market_conference a
;


truncate table edw.oa_meet_market_conference;
insert into edw.oa_meet_market_conference
select a.liuchengbh
      ,a.huiyimc
      ,a.lastname
      ,a.departmentname
      ,a.shenqingrq
      ,a.huiyilx
      ,a.huiyiksrq
      ,a.huiyijsrq
      ,a.qitamd
      ,a.shichangyszfy
      ,a.shijizfy
      ,a.huiyijl
      ,a.huihougj
      ,a.xiaoshoujscjh
      ,a.yusuanxm
      ,a.yusuanxjje
      ,a.juesuanje
      ,a.liuchengjd
      ,replace(replace(replace(replace(replace(xs_md,'1','新筛增项/上量(CAH/G6PD/MSMS)'),'2','新筛增项/上量(耳聋/溶酶体/DMD/SCID/其他病种)'),'3','新筛质量控制'),'4','遗传代谢病诊断'),'5','专家圈维护(新筛)')
      ,replace(replace(replace(replace(replace(replace(replace(replace(cs_md,'1','传统产筛增项(早孕，中孕)'),'2','产筛新项目推广/上量(子娴，NIPT)'),'3','产筛网络建设及管理(下沉模式/指控)'),'4','细胞遗传学推广/上量(原位)'),'5','超声异常增项/上量(CMA/WES)'),'6','诊断体系建设增项(信息化：NX、管理软件/指控)'),'7','学科建设'),'8','专家圈维护(产筛/产诊)')
      ,localtimestamp()
  from edw.oa_meet_market_conference_pre a
;