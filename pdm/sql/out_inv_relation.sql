----------------------------------程序头部----------------------------------------------
--功能：主试剂对应的成效分析
------------------------------------------------------------------------------------------
--程序名称：out_inv_relation.sql
--目标模型：out_inv_relation
--源    表：edw.outdepot_order,edw.invoice_order,edw.dispatch_order
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
 --作者：jiangsh
 --开发日期：2020-03-09
 ------------------------------------------------------------------------------------------
 --版本控制：版本号  提交人   提交日期   提交内容
 --         V1.0     jiangsh  2020-03-11   开发上线
 --调用方法　sh /home/bidata/report/python/jsh_test.sh
 ------------------------------------开始处理逻辑------------------------------------------

-- 17年：取2017年发货单列表的未开票数量
-- 18年-19年3月14日：配件销售出库的数据取发货单列表的未开票数量，其他出库类型取销售出库单列表的数量减掉已开票数量。
-- 19年3月15日-至今，取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_111;
create temporary table pdm.out_inv_relation_111 as 
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate BETWEEN '2018-01-01' and '2019-03-14'
   and db = 'UFDATA_111_2018'
   and cstcode = '配件销售'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
;

insert into pdm.out_inv_relation_111
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate < '2018-01-01'
   and db = 'UFDATA_111_2018'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
;

insert into pdm.out_inv_relation_111
select db
      ,ccode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate BETWEEN '2018-01-01' and '2019-03-14'
   and db = 'UFDATA_111_2018'
   and cstcode <> '配件销售'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
;

insert into pdm.out_inv_relation_111
select db
      ,ccode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate > '2019-03-14'
   and db = 'UFDATA_111_2018'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
;



-- 19年1月之前，取发货单列表的未开票数量
-- 19年2月-至今：取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_222;
create temporary table pdm.out_inv_relation_222 as 
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate BETWEEN '2017-01-01' and '2019-02-28'
   and db = 'UFDATA_222_2019'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
   and ifnull(iquantity,0) <> 0
;

insert into pdm.out_inv_relation_222
select db
      ,ccode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate >= '2019-02-01'
   and db = 'UFDATA_222_2019'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
   and ifnull(iquantity,0) <> 0
;

-- 17年：取2017年发货单列表的未开票数量。
-- 18年-至今：取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_118;
create temporary table pdm.out_inv_relation_118 as 
select db
      ,ccode as cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty as isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate >= '2018-01-01'
   and db = 'UFDATA_118_2018'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
   and iquantity <> 0
;

insert into pdm.out_inv_relation_118
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate < '2018-01-01'
   and db = 'UFDATA_118_2018'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
;

-- 17年：取2017年发货单列表的未开票数量。
-- 18年-至今：取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_123;
create temporary table pdm.out_inv_relation_123 as 
select db
      ,ccode as cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty as isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate >= '2017-01-01'
   and db = 'UFDATA_123_2018'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
   and ifnull(iquantity,0) <> 0
;

insert into pdm.out_inv_relation_123
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate < '2018-01-01'
   and db = 'UFDATA_123_2018'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
;
-- 17年：取2017年发货单列表的未开票数量。
-- 18年-至今：取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_333;
create temporary table pdm.out_inv_relation_333 as 
select db
      ,ccode as cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty as isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate >= '2017-01-01'
   and db = 'UFDATA_333_2018'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
   and ifnull(iquantity,0) <> 0
;

insert into pdm.out_inv_relation_333
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where ddate < '2018-01-01'
   and db = 'UFDATA_333_2018'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
;

-- 2018年，取发货单列表的未开票数量
-- 19年-至今：取销售出库单列表的数量减掉已开票数量。
drop table if exists pdm.out_inv_relation_168;
create temporary table pdm.out_inv_relation_168 as 
select db
      ,cdlcode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,isettlequantity
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'发货单' as type
  from edw.dispatch_order
 where year(ddate) <= '2018'
   and db = 'UFDATA_168_2019'
   and ifnull(iquantity,0) -ifnull( isettlequantity,0) <> 0
   and ifnull(iquantity,0) <> 0
;

insert into pdm.out_inv_relation_168
select db
      ,ccode
      ,ddate
      ,true_ccuscode as ccuscode
      ,true_ccusname as ccusname
      ,true_finnal_ccuscode as finnal_ccuscode
      ,true_finnal_ccusname2 as finnal_ccusname
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,cinvcode as cinvcode_old
      ,null
      ,cdefine22
      ,iquantity
      ,fsettleqty
      ,cdefine23
      ,plan_dt
      ,cstcode
      ,cdepcode
      ,cpersoncode
      ,cmemo
      ,'出库单' as type
  from edw.outdepot_order
 where ddate >= '2019-01-01'
   and db = 'UFDATA_168_2019'
   and ifnull(iquantity,0) - ifnull(fsettleqty,0) <> 0
   and ifnull(iquantity,0) <> 0
;



truncate table pdm.out_inv_relation;
insert into pdm.out_inv_relation
select a.db
      ,a.cdlcode
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,e.specification_type
      ,a.cinvcode_old
      ,e.u8_name as cinvname_old
      ,a.cdefine22
      ,a.iquantity
      ,ifnull(a.isettlequantity,0)
      ,a.cdefine23
      ,0
      ,0
      ,a.plan_dt
      ,a.cstcode
      ,c.cdepname
      ,b.cpersonname
      ,d.province
      ,d.city
      ,a.cmemo
      ,a.type
  from (select * from pdm.out_inv_relation_111 union all
        select * from pdm.out_inv_relation_222 union all
        select * from pdm.out_inv_relation_333 union all
        select * from pdm.out_inv_relation_118 union all
        select * from pdm.out_inv_relation_123 union all
        select * from pdm.out_inv_relation_168) a
  left join (select * from ufdata.person group by db,cpersoncode) b
    on a.cpersoncode = b.cpersoncode
   and a.db = b.db
  left join (select * from ufdata.department group by db,cdepcode) c
    on a.cdepcode = c.cdepcode
   and a.db = c.db
  left join edw.map_customer d
    on a.finnal_ccuscode = d.bi_cuscode
  left join edw.map_inventory e
    on a.cinvcode = e.bi_cinvcode
 group by cdlcode,ddate,left(a.db,10),cinvcode
;

update pdm.out_inv_relation a
 inner join (select * from pdm.invoice_price where state = '最后一次价格') b
    on a.finnal_ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
   set a.price = b.itaxunitprice
;

-- 删除线下确认已经开票的数据
delete from pdm.out_inv_relation where cdlcode in(
'0000000253'
,'0000000567'
,'0000000812'
,'0000001909'
,'0000002334'
,'0000003153'
,'0000003864'
,'ZJBSFH180209017'
,'ZJBSFH180403021'
,'ZJBSFH180418026'
,'ZJBSFH180502014'
,'ZJBSFH180627060'
,'ZJBSFH180726010'
,'ZJBSFH181114035'
,'ZJBSFH181220053'
,'ZJBSFH181224027'
,'ZJBSFH181224028'
,'ZJBSFH181224031'
,'ZJBSFH181229010'
,'ZJBSFH181229011'
,'ZJBSFH190122041'
,'ZJBSFH190122044'
,'ZJBSFH190122046'
,'ZJBSFH190124046'
,'ZJBSFH190125023'
,'ZJBSFH190228020'
,'ZJBSFH190228023'
,'ZJBSXC180131163'
,'ZJBSXC181024026'
,'ZJBSXC181213002'
,'ZJBSXC190911013'
,'ZJBSXC191031064'
,'ZJBSXC191231018'
,'ZJBSXC191224013'
);

-- 插入财务每月手动增加的数据
insert into pdm.out_inv_relation
select a.db
      ,a.cdlcode
      ,a.ddate
      ,a.bi_ccuscode
      ,a.bi_ccusname
      ,a.bi_ccuscode
      ,a.bi_ccusname
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,e.specification_type
      ,a.cinvcode
      ,a.cinvname
      ,a.cdefine22
      ,a.iquantity
      ,a.isettlequantity
      ,a.cdefine23
      ,ifnull(c.itaxunitprice,0)
      ,0
      ,a.plan_dt
      ,a.cstcode
      ,a.cdepname
      ,a.cpersonname
      ,a.province
      ,a.city
      ,a.cmemo
      ,'作废未开票'
  from edw.x_out_inv_relation a
  left join (select * from pdm.out_inv_relation group by cdlcode) b
    on a.cdlcode = b.cdlcode
   and a.bi_cinvcode = b.cinvcode
  left join (select * from pdm.invoice_price where state = '最后一次价格' group by finnal_ccuscode,cinvcode) c
    on a.bi_ccuscode = c.finnal_ccuscode
   and a.bi_cinvcode = c.cinvcode
  left join edw.map_inventory e
    on a.bi_cinvcode = e.bi_cinvcode
 where b.cdlcode is null
;

-- oa_uf_shebeicpqd 加工oa标准价格，chanpinbh，biaozhunjg
drop table if exists pdm.out_inv_relation_oa;
create temporary table pdm.out_inv_relation_oa as 
select a.chanpinbh
      ,b.bi_cinvcode
      ,a.biaozhunjg
  from ufdata.oa_uf_shebeicpqd a
  left join (select * from edw.dic_inventory group by cinvcode) b
    on a.chanpinbh = b.cinvcode
 where b.cinvcode is not null
;

update pdm.out_inv_relation a
 inner join pdm.out_inv_relation_oa b
    on a.cinvcode = b.bi_cinvcode
   set a.bzj = b.biaozhunjg
;