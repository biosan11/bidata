-- 合同相关数据加工

truncate table edw.cm_contract;
insert into edw.cm_contract
select a.guid
      ,b.id
      ,a.cdefine13
      ,a.strbisectionunit
      ,f.ccusname as ccusname
      ,a.strcontractname
      ,a.cdefine10
      ,case when d.ccusname is null then '请核查' else d.bi_cuscode end as bi_cuscode
      ,case when d.ccusname is null then '请核查' else d.bi_cusname end as bi_cusname
      ,a.cdefine12
      ,a.dbltotalcurrency
      ,a.strcontractstartdate
      ,a.strcontractenddate
      ,a.strrepair
      ,a.strcontractdesc
      ,a.strcontractid
      ,a.cdefine11
      ,a.intauditsymbol
      ,a.strcontracttype
      ,a.strcontractkind
      ,a.strpersonid
      ,b.strCode
      ,b.strName
      ,case when c.cinvname is null and b.strcode is not null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null and b.strcode is not null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,g.item_code
      ,g.level_three as item_name
      ,g.business_class as cbustype
      ,b.dblQuantity
      ,b.strMeasureUnit
      ,b.dblPriceRMB
      ,b.cDefine27
      ,b.cDefine26
      ,b.dblSumRMB
      ,b.strMemo
      ,localtimestamp()
  from ufdata.cm_contract a
  left join ufdata.cm_contract_item b
    on a.GUID = b.GUID
  left join (select * from edw.inventory group by cinvcode,cinvccode) e
    on left(b.strCode,11) = concat(e.cinvccode,e.cinvcode)
  left join (select * from edw.dic_inventory group by cinvcode) c
    on e.cinvcode = c.cinvcode
  left join (select * from edw.dic_customer group by ccusname) d
    on a.cdefine10 = d.ccusname
  left join (select * from edw.customer group by ccuscode) f
    on a.strbisectionunit = f.ccuscode
  left join (select * from edw.map_inventory group by bi_cinvcode) g
    on c.bi_cinvcode = g.bi_cinvcode
 where a.strcontractkind = '销售类合同'
;

-- 更新这个傻逼特例
update edw.cm_contract
   set bi_cinvcode = 'JC0100001'
      ,bi_cinvname = '科研服务'
  where strcode = 'JC01JC0100001'
;

-- 最终客户到不了的采用客户清洗
update edw.cm_contract as a 
left join (select * from edw.dic_customer group by ccusname) as b 
on a.ccusname = b.ccusname
set a.bi_cuscode = b.bi_cuscode ,a.bi_cusname = b.bi_cusname
where a.bi_cuscode = '请核查'
;

