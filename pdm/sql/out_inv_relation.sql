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
      ,a.cinvcode_old
      ,a.cdefine22
      ,a.iquantity
      ,ifnull(a.isettlequantity,0)
      ,a.cdefine23
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
    on a.ccuscode = d.bi_cuscode
 group by cdlcode,ddate,left(a.db,10),cinvcode
;

update pdm.out_inv_relation a
 inner join (select * from pdm.invoice_price where state = '最后一次价格') b
    on a.finnal_ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
   set a.price = b.itaxunitprice
;

delete from pdm.out_inv_relation where cdlcode = '0000000253';
delete from pdm.out_inv_relation where cdlcode = '0000000567';
delete from pdm.out_inv_relation where cdlcode = '0000000812';
delete from pdm.out_inv_relation where cdlcode = '0000001909';
delete from pdm.out_inv_relation where cdlcode = '0000002334';
delete from pdm.out_inv_relation where cdlcode = '0000003153';
delete from pdm.out_inv_relation where cdlcode = '0000003864';
