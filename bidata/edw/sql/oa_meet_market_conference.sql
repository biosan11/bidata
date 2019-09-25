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
      ,a.sys_time
  from ufdata.oa_meet_market_conference a
;