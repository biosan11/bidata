------------------------------------程序头部----------------------------------------------
--功能：整合层记录开票变动情况的处理
------------------------------------------------------------------------------------------
--程序名称：invoice_order_change.sql
--目标模型：invoice_order_change
--源    表：pdm.invoice_order,edw.invoice_order
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------

-- 获取当天最新数据
drop table if exists pdm.mid1_invoice_order_change;
create temporary table pdm.mid1_invoice_order_change
select db
      ,finnal_ccuscode
      ,cinvcode
      ,csbvcode
      ,ifnull(round(sum( isum )),0) as isum
      ,ddate
  from pdm.invoice_order 
 where year ( ddate ) = '2020' 
	 and db like 'ufdata%' 
 group by db,finnal_ccuscode,csbvcode,cinvcode
;

ALTER TABLE pdm.mid1_invoice_order_change ADD INDEX index_mid1_invoice_order_change_db(db) ;
ALTER TABLE pdm.mid1_invoice_order_change ADD INDEX index_mid1_invoice_order_change_finnal_ccuscode(finnal_ccuscode) ;
ALTER TABLE pdm.mid1_invoice_order_change ADD INDEX index_mid1_invoice_order_change_cinvcode(cinvcode) ;
ALTER TABLE pdm.mid1_invoice_order_change ADD INDEX index_mid1_invoice_order_change_csbvcode(csbvcode) ;

-- 获取有变化的数据
drop table if exists pdm.mid2_invoice_order_change;
create temporary table pdm.mid2_invoice_order_change
select a.*
  from pdm.mid1_invoice_order_change a
  left join pdm.invoice_order_change b
    on a.db = b.db
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.csbvcode = b.csbvcode
   and ifnull(a.isum,0) = ifnull(b.isum_new,0)
 where b.db is null
;

ALTER TABLE pdm.mid2_invoice_order_change ADD INDEX index_mid2_invoice_order_change_db(db) ;
ALTER TABLE pdm.mid2_invoice_order_change ADD INDEX index_mid2_invoice_order_change_finnal_ccuscode(finnal_ccuscode) ;
ALTER TABLE pdm.mid2_invoice_order_change ADD INDEX index_mid2_invoice_order_change_cinvcode(cinvcode) ;
ALTER TABLE pdm.mid2_invoice_order_change ADD INDEX index_mid2_invoice_order_change_csbvcode(csbvcode) ;

-- 上游已经删除的数据，打上已删除标签
drop table if exists pdm.mid3_invoice_order_change;
create temporary table pdm.mid3_invoice_order_change
select db
      ,csbvcode
      ,left(sys_time,10) as ddate
  from edw.invoice_order 
 where year ( ddate ) = '2020' 
	 and db like 'ufdata%' 
	 and state = '无效'
 group by db,csbvcode
;

ALTER TABLE pdm.mid3_invoice_order_change ADD INDEX index_mid3_invoice_order_change_db(db) ;
ALTER TABLE pdm.mid3_invoice_order_change ADD INDEX index_mid3_invoice_order_change_csbvcode(csbvcode) ;



-- 更新数据历史的金额
update pdm.invoice_order_change a
 inner join pdm.mid2_invoice_order_change b
    on a.db = b.db
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.csbvcode = b.csbvcode
   set a.isum_old = ifnull(a.isum_new,0)
;

-- 更新今天的金额
update pdm.invoice_order_change a
 inner join pdm.mid2_invoice_order_change b
    on a.db = b.db
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.csbvcode = b.csbvcode
   set a.isum_new = b.isum
      ,a.ddate = b.ddate
      ,a.type = '变动'
;

-- 掺入今天的数据
insert into pdm.invoice_order_change
select a.db
      ,a.finnal_ccuscode
      ,a.cinvcode
      ,a.csbvcode
      ,0
      ,a.isum
      ,a.ddate
      ,'开票'
  from pdm.mid2_invoice_order_change a
  left join pdm.invoice_order_change b
    on a.db = b.db
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.csbvcode = b.csbvcode
   and a.isum = b.isum_new
 where b.isum_new is null
;

-- 更新上游已经删除的数据
update pdm.invoice_order_change a
 inner join pdm.mid3_invoice_order_change b
    on a.db = b.db
   and a.csbvcode = b.csbvcode
   set a.ddate = b.ddate
      ,a.type = '删除'
;


