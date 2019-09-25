truncate table edw.oa_meet_market_inspection;
insert into edw.oa_meet_market_inspection
select a.liuchengbh
      ,a.shenqingrq
      ,a.huiyibt
      ,a.lastname
      ,a.departmentname
      ,a.shenqinxx
      ,a.kaochaksrq
      ,a.kaochajsrq
      ,a.kehumc
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.hedongmudi
      ,a.xingchengjh
      ,a.muqianqyxkjh
      ,a.weilai3z6ytjmb
      ,a.yusuanzje
      ,a.shijisfy
      ,a.feiyongcys
      ,a.shichangyszfy
      ,a.kehuyszfy
      ,a.yuangongyszfy
      ,a.yujiyqzrs
      ,a.huiyijl
      ,a.huihougj
      ,a.xiaoshoujscjh
      ,a.liuchengjd
      ,a.sys_time
  from ufdata.oa_meet_market_inspection a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.kehumc = b.ccusname
;