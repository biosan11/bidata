-- --------------------------------程序头部----------------------------------------------
-- 功能：绩效考和对应省区对比
-- ----------------------------------------------------------------------------------------
-- 程序名称：jx_01_province_detail.sql
-- 目标模型：jx_01_province_detail
-- 源    表：report.fin_11_sales_cost_base
-- ---------------------------------------------------------------------------------------
-- 加载周期：日增
-- ----------------------------------------------------------------------------------------
-- -作者：jiangsh
-- -开发日期：2020-03-09
-- -----------------------------------------------------------------------------------------
-- -版本控制：版本号  提交人   提交日期   提交内容
-- -         V1.0     jiangsh  2020-03-11   开发上线
-- -调用方法　sh /home/bidata/report/python/jx_01_province_compare.py
-- -----------------------------------开始处理逻辑------------------------------------------

set @dt = '2020-06-30';
-- 已发货未开票的需要处理一下，现有是最新你的，需要减去这段时间发货加上这段时间开票
drop table if exists report.out_inv_relation;
create temporary table report.out_inv_relation as
select finnal_ccuscode,finnal_ccusname,sum(bzj*iquantity) as md
  from pdm.out_inv_relation
 group by finnal_ccuscode
;

drop table if exists report.invoice_order;
create temporary table report.invoice_order as
select finnal_ccuscode,finnal_ccusname,sum(isum) as md
  from pdm.invoice_order
 where ddate > @dt
 group by finnal_ccuscode
;

drop table if exists report.dispatch_order;
create temporary table report.dispatch_order as
select finnal_ccuscode,finnal_ccusname,sum(isum) as md
  from pdm.dispatch_order
 where ddate > @dt
 group by finnal_ccuscode
;

drop table if exists report.mid1_jx_01_province_detail;
create temporary table report.mid1_jx_01_province_detail as
select a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.md - c.md + b.md as md
  from report.out_inv_relation a
  left join report.invoice_order b
    on a.finnal_ccuscode = b.finnal_ccuscode
  left join report.dispatch_order c
    on a.finnal_ccuscode = c.finnal_ccuscode
;  
  
-- 90天以内的回款
drop table if exists report.mid2_jx_01_province_detail;
create temporary table report.mid2_jx_01_province_detail as
select ccuscode
      ,ccusname
      ,sum(icamount_month) as md
  from report.fin_31_account_base a
 where ddate <= @dt
   and ddate > DATE_ADD(@dt,INTERVAL -3 month)
 group by ccuscode
 having md <> 0
;

-- 90天内的发货
drop table if exists report.dispatch_order;
create temporary table report.dispatch_order as
select finnal_ccuscode,finnal_ccusname,sum(isum) as md
  from pdm.dispatch_order
 where ddate <= @dt
   and ddate > DATE_ADD(@dt,INTERVAL -3 month)
 group by finnal_ccuscode
;


drop table if exists report.ar_detail_aging;
create temporary table report.ar_detail_aging as
select ccuscode
      ,ccusname
      ,ar_class
      ,sum(balance_closing) as balance_closing
      ,sum(date_6_12+date_12_24+date_24_36+date_36) as md
  from pdm.ar_detail_aging
 where ddate = @dt
 group by ccuscode,ar_class
 having md > 0
;

truncate table report.jx_01_province_detail;
insert into report.jx_01_province_detail
select b.sales_region
      ,null as areadirector
      ,null as cverifier
      ,a.ccuscode
      ,a.ccusname
      ,a.ar_class
      ,a.balance_closing
      ,c.md as md1
      ,a.md as md2
      ,d.md as md3
      ,e.md as md4
  from report.ar_detail_aging a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
  left join report.mid1_jx_01_province_detail c
    on a.ccuscode = c.finnal_ccuscode
  left join report.mid2_jx_01_province_detail d
    on a.ccuscode = d.ccuscode
  left join report.dispatch_order e
    on a.ccuscode = e.finnal_ccuscode
;



update report.jx_01_province_detail a
 inner join pdm.cusitem_person b
    on a.ccuscode = b.ccuscode
   set a.areadirector = b.areadirector
      ,a.cverifier = b.cverifier
 where @dt >= b.start_dt
   and @dt <= b.end_dt
;



