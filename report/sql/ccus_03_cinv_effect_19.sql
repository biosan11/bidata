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
create temporary table report.x_cinv_relation_pre as 
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
create temporary table report.outdepot_order_pre as 
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
create temporary table report.checklist_pre as
select ccuscode,cinvcode,sum(inum_person) as inum_person
  from pdm.checklist
 where year(ddate) = '2019'
 group by ccuscode,cinvcode
;


drop table if exists report.invoice_order_pre;
create temporary table report.invoice_order_pre as 
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
create temporary table report.mid1_ccus_03_cinv_effect_19 as
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
create temporary table report.mid2_ccus_03_cinv_effect_19 as
select ccuscode
      ,sum(cost) as cost
      ,a.cinvcode_main
  from report.mid1_ccus_03_cinv_effect_19 a
 group by ccuscode,cinvcode_main
;

-- 各个客户主试剂在同一个项目之间的占比
drop table if exists report.mid3_ccus_03_cinv_effect_19;
create temporary table report.mid3_ccus_03_cinv_effect_19 as
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
create temporary table report.mid4_ccus_03_cinv_effect_19 as
select a.province
      ,a.city
      ,'终端客户' as type
      ,a.finnal_ccuscode as ccuscode
      ,a.finnal_ccusname as ccusname
      ,a.cbustype
      ,b.cinvcode
      ,a.cinvcode as cinvcode_main
      ,b.cinvname
      ,0 as itaxunitprice
      ,0 as isum_main
      ,a.isum_child * bl as isum_child
      ,0 as invoice_amount_main
      ,a.invoice_amount_child * bl as invoice_amount_child
      ,a.iunitcost_main * bl as iunitcost_main
      ,a.iunitcost_child * bl as iunitcost_child
      ,a.amount_19 * bl as amount_19
      ,a.sy_md * bl as sy_md
      ,a.insure_md * bl as insure_md
      ,c.inum_unit_person
      ,b.iquantity * c.inum_unit_person as inum_person_inv
      ,d.inum_person as inum_person_out
      ,d.ddate
      ,d.inum_person_mon
      ,e.inum_person as inum_person_jc
      ,a.install_dt
      ,a.profit_margin as profit_margin_item
  from report.ccus_03_item_effect_19 a
  left join report.mid3_ccus_03_cinv_effect_19 b
    on a.finnal_ccuscode = b.ccuscode
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
   and left(a.cinvname,2) <> 'qt'
   and left(a.cinvname,2) <> 'YQ'
 order by a.finnal_ccuscode,b.cinvcode
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

-- 插入jc开头检测量的数据
insert into report.mid4_ccus_03_cinv_effect_19
select a.province
      ,a.city
      ,'终端客户'
      ,a.ccuscode
      ,a.ccusname
      ,'LDT'
      ,a.cinvcode
      ,null
      ,a.cinvname
      ,0
      ,a.isum1
      ,0
      ,a.invoice_amount1
      ,0
      ,a.cost1
      ,0
      ,0
      ,0
      ,0
      ,c.inum_unit_person
      ,a.iquantity1 * c.inum_unit_person as inum_person_inv
      ,b.inum_person as inum_person_out
      ,b.ddate
      ,b.inum_person_mon
      ,0
      ,null
      ,(a.invoice_amount1 - a.cost1) / a.invoice_amount1
  from (select *
              ,sum(isum) as isum1
              ,sum(invoice_amount) as invoice_amount1
              ,sum(iquantity) as iquantity1
              , sum(cost) as cost1
          from report.invoice_order_pre where left(cinvcode,2) = 'JC' group by ccuscode,cinvcode) a
  left join report.outdepot_order_pre b
    on a.ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) c
    on a.cinvcode = c.bi_cinvcode
;

-- 更新最后一次开票金额，以及最终客户对应的客户的性质
update report.mid4_ccus_03_cinv_effect_19 a
 inner join (select * from pdm.invoice_price where state = '最后一次价格') b
    on a.ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   set a.type = (case when left(b.ccuscode,2) = 'DL' then '代理商' when left(b.ccuscode,2) = 'ZD' then '终端客户' when left(b.ccuscode,2) = 'GR' then '个人客户' else '其他' end )
      ,a.itaxunitprice = b.itaxunitprice / b.inum_unit_person
;


-- 计算所有的利润
drop table if exists report.mid5_ccus_03_cinv_effect_19;
create temporary table report.mid5_ccus_03_cinv_effect_19 as
select a.province
      ,a.city
      ,a.type
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvcode_main
      ,a.cinvname
      ,a.ddate
      ,a.install_dt
      ,a.itaxunitprice
      ,a.isum_main
      ,a.isum_child
      ,a.invoice_amount_main
      ,a.invoice_amount_child
      ,a.iunitcost_main
      ,a.iunitcost_child
      ,a.amount_19
      ,a.sy_md
      ,a.insure_md
      ,a.inum_unit_person
      ,a.inum_person_inv
      ,a.inum_person_out
      ,a.inum_person_mon
      ,a.inum_person_jc
      ,a.isum_main / a.inum_person_inv as price_true
      ,a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - insure_md as profit
      ,(a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - insure_md) / inum_person_inv as profit_price
      ,(a.invoice_amount_main - a.iunitcost_main + invoice_amount_child - iunitcost_child - amount_19 - insure_md) / (invoice_amount_main + invoice_amount_child) as profit_margin
      ,a.profit_margin_item
  from report.mid4_ccus_03_cinv_effect_19 a
;

-- 计算公司平均利润单价
drop table if exists report.mid6_ccus_03_cinv_effect_19;
create temporary table report.mid6_ccus_03_cinv_effect_19 as
select cinvcode
      ,avg(profit_price) as profit_price
  from report.mid5_ccus_03_cinv_effect_19
 group by cinvcode
;

-- 计算省份平均利润单价
drop table if exists report.mid7_ccus_03_cinv_effect_19;
create temporary table report.mid7_ccus_03_cinv_effect_19 as
select cinvcode,province
      ,avg(profit_price) as profit_price
  from report.mid5_ccus_03_cinv_effect_19
 group by cinvcode,province
;

-- 计算20年预计发货人份数
drop table if exists report.mid9_ccus_03_cinv_effect_19;
create temporary table report.mid9_ccus_03_cinv_effect_19 as
select bi_cuscode,bi_cinvcode
      ,sum(ifnull(inum_person,0)) as inum_person
  from edw.x_sales_budget_20
 where ifnull(inum_person,0) <> 0
 group by bi_cuscode,bi_cinvcode
;


-- 插入数据
truncate table report.ccus_03_cinv_effect_19;
insert into report.ccus_03_cinv_effect_19
select a.province
      ,a.city
      ,a.type
      ,null
      ,null
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvcode_main
      ,a.cinvname
      ,a.ddate
      ,a.install_dt
      ,a.itaxunitprice
      ,a.isum_main
      ,a.isum_child
      ,a.invoice_amount_main
      ,a.invoice_amount_child
      ,a.iunitcost_main
      ,a.iunitcost_child
      ,a.amount_19
      ,a.sy_md
      ,a.insure_md
      ,a.inum_unit_person
      ,a.inum_person_inv
      ,a.inum_person_out
      ,a.inum_person_mon
      ,a.inum_person_jc
      ,a.price_true
      ,a.profit
      ,a.profit_price
      ,a.profit_margin
      ,a.profit_margin_item
      ,b.profit_price as profit_price_cohr
      ,c.profit_price as profit_price_pro
      ,d.inum_person as inum_person_pro
  from report.mid5_ccus_03_cinv_effect_19 a
  left join report.mid6_ccus_03_cinv_effect_19 b
    on a.cinvcode = b.cinvcode
  left join report.mid7_ccus_03_cinv_effect_19 c
    on a.cinvcode = c.cinvcode
   and a.province = c.province
  left join report.mid9_ccus_03_cinv_effect_19 d
    on a.cinvcode = d.bi_cinvcode
   and a.ccuscode = d.bi_cuscode
;

update report.ccus_03_cinv_effect_19 a
inner join (select * from pdm.invoice_price where state = '最后一次价格' and left(ccuscode,2) = 'DL' and end_dt >= '2019-01-01' group by finnal_ccuscode,cinvcode) b
    on a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   set a.ccuscode = b.ccuscode
      ,a.ccusname = b.ccusname
;

update report.ccus_03_cinv_effect_19 set ccuscode = finnal_ccuscode,ccusname = finnal_ccusname where ccuscode is null;

update report.ccus_03_cinv_effect_19 b set b.type = (case when left(b.ccuscode,2) = 'DL' then '代理商' when left(b.ccuscode,2) = 'ZD' then '终端客户' when left(b.ccuscode,2) = 'GR' then '个人客户' else '其他' end );

-- 更新前置项目表的客户
update report.ccus_03_item_effect_19 a
inner join report.ccus_03_cinv_effect_19 b
    on a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode_main
   set a.ccuscode = b.ccuscode
      ,a.ccusname = b.ccusname
;


-- 更新最终客户对应的客户情况
-- drop table if exists report.mid8_ccus_03_cinv_effect_19;
-- create temporary table report.mid8_ccus_03_cinv_effect_19 as
-- select a.ccuscode
--       ,a.ccusname
--       ,a.finnal_ccuscode
--       ,a.finnal_ccusname
--       ,a.cinvcode
--       ,b.cinvcode_main
--   from pdm.invoice_order a
--   left join (select * from report.x_cinv_relation_pre group by cinvcode,cinvcode_main) b
--     on a.cinvcode = b.cinvcode
--  where year(ddate) = '2019'
--    and a.finnal_ccuscode <> 'multi'
--    and left(a.finnal_ccuscode,2) <> 'GR'
--    and b.cinvcode_main is not null
--  group by ccuscode,finnal_ccuscode,b.cinvcode
-- ;
-- 
-- update report.ccus_03_cinv_effect_19 a
--  inner join report.mid8_ccus_03_cinv_effect_19 b
--     on a.cinvcode = b.cinvcode_main
--    and a.finnal_ccuscode = b.finnal_ccuscode
--    set a.ccuscode = b.ccuscode
--       ,a.ccusname = b.ccusname
-- ;
-- 
-- update report.ccus_03_cinv_effect_19 set ccuscode = finnal_ccuscode,ccusname = finnal_ccusname where ccuscode is null;
-- 




