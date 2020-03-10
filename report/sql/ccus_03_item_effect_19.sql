------------------------------------程序头部----------------------------------------------
--功能：项目对应的成效分析
------------------------------------------------------------------------------------------
--程序名称：ccus_03_item_effect_19.sql
--目标模型：invoice_order
--源    表：pdm.invoice_order,edw.x_eq_depreciation_19_relation,edw.x_cinv_relation
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-03-09
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-03-09   开发上线
--调用方法　sh /home/bidata/report/python/jsh_test.sh
------------------------------------开始处理逻辑------------------------------------------

-- 各个项目对应的成效分析，涉及主辅设备
-- 先给出合集，开篇关联主辅表主产品
-- 思路变更，所有用户拉出一个主试剂合集出来
drop table if exists report.invoice_order_pre;
create  table report.invoice_order_pre as 
select a.finnal_ccuscode as ccuscode
      ,1 as key_num
      ,a.isum
      ,a.isum - a.itax as invoice_amount
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
  from pdm.invoice_order a
 where year(a.ddate) = '2019'
--   and a.isum <> 0
   and finnal_ccuscode <> 'multi'
   and left(finnal_ccuscode,2) <> 'GR'
;

drop table if exists report.x_cinv_relation_pre;
create  table report.x_cinv_relation_pre as 
select distinct a.cinvcode_main
      ,a.cinvname_main
      ,a.cinvcode_child as cinvcode
      ,a.cinvname_child as cinvname
      ,1 as key_num
  from edw.x_cinv_relation a
 where level_two_cx = '主试剂'
;

-- 创建合集，这里是项目合集
drop table if exists report.mid0_ccus_03_item_effect_19;
create  table report.mid0_ccus_03_item_effect_19 as
select a.ccuscode
      ,b.cinvcode_main as cinvcode
      ,b.cinvname_main as cinvname
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
      ,sum(isum) as isum
      ,sum(invoice_amount) as invoice_amount
  from report.invoice_order_pre a
  left join report.x_cinv_relation_pre b
    on a.key_num = b.key_num
 group by ccuscode,cinvcode_main
;

-- 这里是主试剂合集
drop table if exists report.mid00_ccus_03_item_effect_19;
create  table report.mid00_ccus_03_item_effect_19 as
select a.ccuscode
      ,b.cinvcode
      ,b.cinvname
      ,b.cinvcode_main
      ,b.cinvname_main
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
      ,sum(isum) as isum
      ,sum(invoice_amount) as invoice_amount
  from report.invoice_order_pre a
  left join report.x_cinv_relation_pre b
    on a.key_num = b.key_num
 group by ccuscode,cinvcode
;



-- 辅助试剂对应开票的所有记录,这里辅助耗材试剂重复计算了
drop table if exists report.mid1_ccus_03_item_effect_19;
create  table report.mid1_ccus_03_item_effect_19 as
select a.finnal_ccuscode as ccuscode
      ,a.finnal_ccusname as ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.item_code
      ,a.citemname as item_name
      ,a.province
      ,a.city
      ,a.cbustype
      ,sum(a.isum) as isum
      ,sum(a.isum - a.itax) as invoice_amount
      ,b.cinvcode_main
      ,b.cinvname_main
      ,b.level_two_cx
  from pdm.invoice_order a
  left join (select * from edw.x_cinv_relation group by cinvcode_child,cinvcode_main) b
    on a.cinvcode = b.cinvcode_child
 where year(a.ddate) = '2019'
   and b.cinvcode_child is not null
--   and a.isum <> 0
 group by finnal_ccuscode,cinvcode,cinvcode_main
;

-- 主试剂合计，汇总,主试剂默认是1对1的情况
drop table if exists report.mid2_ccus_03_item_effect_19;
create  table report.mid2_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,ccuscode
      ,ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,a.cinvname_main
      ,level_two_cx
      ,sum(isum) as isum
      ,sum(invoice_amount) as invoice_amount
  from report.mid1_ccus_03_item_effect_19 a
 where level_two_cx = '主试剂'
 group by cinvcode_main,ccuscode
;

-- 辅助试剂分配的试剂大于1的情况下进行拆分,辅助试剂耗材
-- 这里计算辅助试剂各个客户的汇总
drop table if exists report.mid3_ccus_03_item_effect_19;
create  table report.mid3_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,b.isum
      ,b.invoice_amount
  from report.mid1_ccus_03_item_effect_19 a
  left join report.mid0_ccus_03_item_effect_19 b
    on a.ccuscode = b.ccuscode
   and a.cinvcode_main = b.cinvcode
 where a.level_two_cx = '辅助试剂耗材'
  and b.ccuscode is not null
;

-- 相关的主试剂汇总
drop table if exists report.mid4_ccus_03_item_effect_19;
create  table report.mid4_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,sum(a.isum) as isum
      ,sum(a.invoice_amount) as invoice_amount
  from report.mid3_ccus_03_item_effect_19 a
  group by cinvcode,ccuscode
;

-- 计算每家客户辅助试剂比例
drop table if exists report.mid5_ccus_03_item_effect_19;
create  table report.mid5_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,a.isum / b.isum as bl
      ,a.invoice_amount / b.invoice_amount as bl_amount
  from report.mid3_ccus_03_item_effect_19 a
  left join report.mid4_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
;

-- 得到19年所有辅助试剂已经分配完的金额
drop table if exists report.mid6_ccus_03_item_effect_19;
create  table report.mid6_ccus_03_item_effect_19 as
select b.province
      ,b.city
      ,b.ccuscode
      ,b.ccusname
      ,b.cbustype
      ,b.cinvcode
      ,b.cinvname
      ,b.cinvcode_main
      ,sum(a.isum * b.bl) as isum
      ,sum((a.isum - a.itax) * b.bl_amount) as invoice_amount
  from pdm.invoice_order a
  left join report.mid5_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.finnal_ccuscode = b.ccuscode
 where year(a.ddate) = '2019'
   and b.cinvcode is not null
   and a.isum <> 0
   and a.finnal_ccuscode <> 'multi'
 group by finnal_ccuscode,cinvcode_main
;

-- 主辅试剂合并到一起
drop table if exists report.mid7_ccus_03_item_effect_19;
create  table report.mid7_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,ifnull(b.isum,0) as isum_main
      ,ifnull(c.isum,0) as isum_child
      ,ifnull(b.invoice_amount,0) as invoice_amount_main
      ,ifnull(c.invoice_amount,0) as invoice_amount_child
  from report.mid0_ccus_03_item_effect_19 a
  left join report.mid2_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode_main
   and a.ccuscode = b.ccuscode
  left join report.mid6_ccus_03_item_effect_19 c
    on a.cinvcode = c.cinvcode_main
   and a.ccuscode = c.ccuscode
;

-- 增加19年试剂成本
-- 主试剂成本
drop table if exists report.mid8_ccus_03_item_effect_19;
create  table report.mid8_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode_main as cinvcode
      ,sum(b.cost) as isum
  from report.mid00_ccus_03_item_effect_19 a
  left join report.fin_11_sales_cost_base b
    on a.ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
 where year(b.ddate) = '2019'
   and b.ccuscode is not null
 group by a.cinvname_main,a.ccuscode
;

-- 辅助试剂成本
drop table if exists report.mid9_ccus_03_item_effect_19;
create  table report.mid9_ccus_03_item_effect_19 as
select b.ccuscode
      ,b.cinvcode
      ,b.cinvcode_main
      ,sum(a.cost * b.bl) as isum
  from report.fin_11_sales_cost_base a
  left join report.mid5_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
 where year(a.ddate) = '2019'
   and b.cinvcode is not null
   and a.cost <> 0
 group by a.ccuscode,cinvcode_main
;
-- 成本主辅合并到一起
drop table if exists report.mid10_ccus_03_item_effect_19;
create  table report.mid10_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode
      ,a.isum as isum_main
      ,b.isum as isum_child
  from report.mid8_ccus_03_item_effect_19 a
  left join report.mid9_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode_main
   and a.ccuscode = b.ccuscode
;

-- 实验员成本计算




-- 数据汇总
truncate table report.ccus_03_item_effect_19;
insert into report.ccus_03_item_effect_19
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,ifnull(a.isum_main,0) as isum_main
      ,ifnull(a.isum_child,0) as isum_child
      ,ifnull(a.invoice_amount_main,0) asinvoice_amount_main
      ,ifnull(a.invoice_amount_child,0) as invoice_amount_child
      ,ifnull(b.isum_main,0) as iunitcost_main
      ,ifnull(b.isum_child,0) as iunitcost_child
      ,ifnull(c.amount_19,0) as amount_19
      ,0 as sy_md
      ,d.install_dt
  from report.mid7_ccus_03_item_effect_19 a
  left join report.mid10_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
  left join (select bi_cuscode,bi_cinvcode,sum(amount_19) as amount_19 from edw.x_eq_depreciation_19_relation group by bi_cuscode,bi_cinvcode) c
    on a.ccuscode = c.bi_cuscode
   and a.cinvcode = c.bi_cinvcode
  left join (select * from pdm.cuspro_archives group by ccuscode,cinvcode) d
    on a.ccuscode = d.ccuscode
   and a.cinvcode = d.cinvcode
;

-- 删除所有数值为0的数据
delete from report.ccus_03_item_effect_19 
 where isum_main = 0 
   and isum_child = 0
   and asinvoice_amount_main = 0
   and invoice_amount_child = 0
   and iunitcost_main = 0
   and iunitcost_child = 0
   and amount_19 = 0
   and sy_md = 0
   and install_dt is null
;
