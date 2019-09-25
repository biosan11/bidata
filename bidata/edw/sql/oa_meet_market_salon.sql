truncate table edw.oa_meet_market_salon;
insert into edw.oa_meet_market_salon
select a.liuchengbh
      ,a.shenqingrq
      ,a.huiyibt
      ,a.lastname
      ,a.departmentname
      ,a.kehumc
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.keshi
      ,a.huiyizt
      ,a.huiyiksrq
      ,a.kaishisj
      ,a.jieshusj
      ,a.huiyidz
      ,a.yusuanzfy
      ,a.shijihffy
      ,a.keshiglxz
      ,a.cunzaidwt
      ,a.nigaibgn
      ,a.xiwangjz
      ,a.tingzhong
      ,a.zhuchi
      ,a.huiyijsrq
      ,a.huiyiztsj
      ,a.kaishisjsj
      ,a.jieshusjsj
      ,a.huiyizjrsj
      ,a.tingzhongxcfk
      ,a.zhurenxcfk
      ,a.hudongwthz
      ,a.xianchangjdjl
      ,a.huihoudcgs
      ,a.zhurentd
      ,a.tingzhonggn
      ,a.keshijhxd
      ,a.xiayibuxq
      ,a.xiaoshoujscjh
      ,a.liuchengjd
      ,a.sys_time
  from ufdata.oa_meet_market_salon a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.kehumc = b.ccusname
;