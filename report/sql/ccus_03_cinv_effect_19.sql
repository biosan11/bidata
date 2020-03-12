----------------------------------程序头部----------------------------------------------
--功能：主试剂对应的成效分析
------------------------------------------------------------------------------------------
--程序名称：ccus_03_cinv_effect_19.sql
--目标模型：ccus_03_cinv_effect_19
--源    表：pdm.ccus_03_item_effect_19,edw.x_cinv_relation,pdm.invoice_order
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

-- 项目级别的计算已经生成了，只需要按照主试剂拆分下去即可
-- 先获取主试剂的各个项目的比例，已经19年的销售额
drop table if exists report.x_cinv_relation_pre;
create table report.x_cinv_relation_pre as 
select distinct a.cinvcode_main
      ,a.cinvname_main
      ,a.cinvcode_child as cinvcode
      ,a.cinvname_child as cinvname
--      ,1 as key_num
      ,level_two_cx
  from edw.x_cinv_relation a
-- where level_two_cx = '主试剂'
;

-- 获取2019年所又主试剂的发货人份数
drop table if exists report.outdepot_order_pre;
create table report.outdepot_order_pre as 
select a.finnal_ccuscode as ccuscode
      ,a.finnal_ccusname as ccusname
      ,sum(a.inum_person) as inum_person
      ,min(ddate) as ddate
      ,TIMESTAMPDIFF(month,case when min(ddate) <= '2019-01-01' then '2019-01-01' else min(ddate) end,'2020-01-01') + 1 as mon_diff
      ,sum(a.inum_person) / (1 + TIMESTAMPDIFF(month,case when min(ddate) <= '2019-01-01' then '2019-01-01' else min(ddate) end,'2020-01-01')) as inum_person_mon 
      ,a.cinvcode
      ,a.cinvname
  from pdm.outdepot_order a
 where year(a.ddate) = '2019'
   and a.finnal_ccuscode <> 'multi'
   and left(a.finnal_ccuscode,2) <> 'GR'
 group by finnal_ccuscode,cinvcode
;

-- 获取2019年所有主试剂的检测量
drop table if exists report.checklist_pre;
create table report.checklist_pre as
select ccuscode,cinvcode,sum(inum_person) as inum_person
  from pdm.checklist
 where year(ddate) = '2019'
 group by ccuscode,cinvcode
;


drop table if exists report.invoice_order_pre;
create table report.invoice_order_pre as 
select a.ccuscode as ccuscode
      ,1 as key_num
      ,a.cost as cost
      ,a.isum as isum
      ,(a.isum - a.itax) as invoice_amount
      ,a.iquantity_adjust as iquantity
      ,b.province
      ,b.city
      ,a.ccusname as ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
  from report.fin_11_sales_cost_base a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
 where year(a.ddate) = '2019'
--   and a.isum <> 0
   and a.ccuscode <> 'multi'
   and left(a.ccuscode,2) <> 'GR'
;

-- 获取19年所有客户的主试剂合集
drop table if exists report.mid1_ccus_03_cinv_effect_19;
create table report.mid1_ccus_03_cinv_effect_19 as
select ccuscode
      ,ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.province
      ,a.city
      ,sum(a.iquantity) as iquantity
      ,sum(cost)as cost
      ,sum(isum) as isum
      ,sum(a.invoice_amount) as invoice_amount
      ,b.cinvcode_main
      ,b.cinvname_main
  from report.invoice_order_pre a
  left join (select * from report.x_cinv_relation_pre where level_two_cx = '主试剂' group by cinvcode) b
    on a.cinvcode = b.cinvcode
 where b.cinvcode is not null
 group by a.ccuscode,a.cinvcode
;

-- 按照客户项目聚合
drop table if exists report.mid2_ccus_03_cinv_effect_19;
create table report.mid2_ccus_03_cinv_effect_19 as
select ccuscode
      ,sum(cost) as cost
      ,a.cinvcode_main
  from report.mid1_ccus_03_cinv_effect_19 a
 group by ccuscode,cinvcode_main
;

-- 各个客户主试剂在同一个项目之间的占比
drop table if exists report.mid3_ccus_03_cinv_effect_19;
create table report.mid3_ccus_03_cinv_effect_19 as
select a.ccuscode
      ,a.ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,a.province
      ,a.city
      ,a.iquantity
      ,a.cost / b.cost as bl
  from report.mid1_ccus_03_cinv_effect_19 a
  left join report.mid2_ccus_03_cinv_effect_19 b
    on a.ccuscode = b.ccuscode
   and a.cinvcode_main = b.cinvcode_main
-- group by ccuscode,cinvcode_main
;



-- 获取19年所有的客户、项目、主试剂的合集
drop table if exists report.mid4_ccus_03_cinv_effect_19;
create table report.mid4_ccus_03_cinv_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,b.cinvcode
      ,a.cinvcode as cinvcode_main
      ,b.cinvname
      ,0 as isum_main
      ,a.isum_child * bl as isum_child
      ,0 as invoice_amount_main
      ,a.invoice_amount_child * bl as invoice_amount_child
      ,a.iunitcost_main * bl as iunitcost_main
      ,a.iunitcost_child * bl as iunitcost_child
      ,a.amount_19 * bl as amount_19
      ,a.sy_md * bl as sy_md
      ,c.inum_unit_person
      ,b.iquantity * c.inum_unit_person as inum_person_inv
      ,d.inum_person as inum_person_out
      ,d.ddate
      ,d.inum_person_mon
      ,e.inum_person as inum_person_jc
      ,a.install_dt
  from report.ccus_03_item_effect_19 a
  left join report.mid3_ccus_03_cinv_effect_19 b
    on a.ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode_main
  left join (select * from edw.map_inventory group by bi_cinvcode) c
    on b.cinvcode = c.bi_cinvcode
  left join report.outdepot_order_pre d
    on b.ccuscode = d.ccuscode
   and b.cinvcode = d.cinvcode
  left join report.checklist_pre e
    on b.ccuscode = e.ccuscode
   and b.cinvcode = e.cinvcode
 where b.ccuscode is not null
 order by a.ccuscode,b.cinvcode
;

-- 这里更新主试剂的金额，含税不含税
update report.mid4_ccus_03_cinv_effect_19 a
 inner join report.mid1_ccus_03_cinv_effect_19 b
    on a.ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
   set a.isum_main = b.isum
      ,a.invoice_amount_main = b.invoice_amount
;

-- 更新项目存在辅助试剂成本，由于主试剂没有成本拆分不进去的，直接塞进去
update report.mid4_ccus_03_cinv_effect_19 a
 inner join report.ccus_03_item_effect_19 b
    on a.ccuscode = b.ccuscode
   and a.cinvcode_main = b.cinvcode
   set a.iunitcost_child = b.iunitcost_child
 where a.iunitcost_child is null
;

-- 计算所有的利润
drop table if exists report.mid5_ccus_03_cinv_effect_19;
create table report.mid5_ccus_03_cinv_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvcode_main
      ,a.cinvname
      ,a.ddate
      ,a.install_dt
      ,a.isum_main
      ,a.isum_child
      ,a.invoice_amount_main
      ,a.invoice_amount_child
      ,a.iunitcost_main
      ,a.iunitcost_child
      ,a.amount_19
      ,a.inum_unit_person
      ,a.inum_person_inv
      ,a.inum_person_out
      ,a.inum_person_mon
      ,a.inum_person_jc
      ,a.isum_main / a.inum_person_inv as price_true
      ,a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - sy_md as profit
      ,(a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - sy_md) / inum_person_inv as profit_price
      ,(a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - sy_md) / (invoice_amount_main + invoice_amount_child) as profit_margin
  from report.mid4_ccus_03_cinv_effect_19 a
;

-- 计算公司平均利润单价
drop table if exists report.mid6_ccus_03_cinv_effect_19;
create table report.mid6_ccus_03_cinv_effect_19 as
select cinvcode
      ,avg(profit_price) as profit_price
  from report.mid5_ccus_03_cinv_effect_19
 group by cinvcode
;

-- 计算省份平均利润单价
drop table if exists report.mid7_ccus_03_cinv_effect_19;
create table report.mid7_ccus_03_cinv_effect_19 as
select cinvcode,province
      ,avg(profit_price) as profit_price
  from report.mid5_ccus_03_cinv_effect_19
 group by cinvcode,province
;

-- 插入数据
truncate table report.ccus_03_cinv_effect_19;
insert into report.ccus_03_cinv_effect_19
select a.*
      ,b.profit_price as profit_price_cohr
      ,c.profit_price as profit_price_pro
  from report.mid5_ccus_03_cinv_effect_19 a
  left join report.mid6_ccus_03_cinv_effect_19 b
    on a.cinvcode = b.cinvcode
  left join report.mid7_ccus_03_cinv_effect_19 c
    on a.cinvcode = c.cinvcode
   and a.province = c.province
;