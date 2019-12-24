
truncate table edw.oa_uf_chanpinsbdz;
insert into edw.oa_uf_chanpinsbdz
select a.chanpinmcz
      ,a.chanpinbhz as cinvcode
      ,a.chanpinmczw as cinvname
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.id
      ,a.chanpinbhp as cinvcode_pt
      ,a.chanpinmcpw as cinvname_pt
      ,case when c.cinvcode is null then '请核查' else c.bi_cinvcode end as bi_cinvcode_pt
      ,case when c.cinvcode is null then '请核查' else c.bi_cinvname end as bi_cinvname_pt
      ,a.pinpai
      ,a.huohao
      ,a.guigexh
      ,a.yongliang
  from ufdata.oa_uf_chanpinsbdz a
  left join (select * from edw.dic_inventory group by cinvcode) b
    on a.chanpinbhz = b.cinvcode
  left join (select * from edw.dic_inventory group by cinvcode) c
    on a.chanpinbhp = c.cinvcode
;

insert into edw.oa_uf_chanpinsbdz
select a.id
      ,a.chanpinbh as cinvcode
      ,a.chanpinmc as cinvname
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvcode end as bi_cinvcode
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvname end as bi_cinvname
      ,a.id
      ,a.chanpinbh
      ,a.chanpinmc
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvname end
      ,a.pinpai
      ,a.huohao
      ,a.guigexh
      ,c.yongliang
  from ufdata.oa_uf_shebeicpqd a
  left join (select * from edw.dic_inventory group by cinvcode) b
    on a.chanpinbh = b.cinvcode
  left join (select chanpinmcz,yongliang from ufdata.oa_uf_chanpinsbdz group by chanpinmcz) c
    on a.id = c.chanpinmcz
 where c.chanpinmcz is not null
;

