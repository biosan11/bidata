----------------------------------程序头部----------------------------------------------
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
create temporary table report.invoice_order_pre as 
select a.ccuscode as ccuscode
      ,1 as key_num
      ,a.isum as isum
      ,a.isum - a.itax as invoice_amount
      ,a.cost
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

CREATE INDEX index_invoice_order_pre_cinvcode ON report.invoice_order_pre(cinvcode);
CREATE INDEX index_invoice_order_pre_ccuscode ON report.invoice_order_pre(ccuscode);

drop table if exists report.x_cinv_relation_pre;
create temporary table report.x_cinv_relation_pre as 
select distinct a.cinvcode_main
      ,a.cinvname_main
      ,a.cinvcode_child as cinvcode
      ,a.cinvname_child as cinvname
      ,1 as key_num
      ,level_two_cx
  from edw.x_cinv_relation a
-- where level_two_cx = '主试剂'
;

-- 创建合集，这里是项目合集
drop table if exists report.mid00_ccus_03_item_effect_19;
create temporary table report.mid00_ccus_03_item_effect_19 as
select a.ccuscode
      ,b.cinvcode_main as cinvcode
      ,b.cinvname_main as cinvname
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
  from (select * from report.invoice_order_pre group by ccuscode) a
  left join (select * from report.x_cinv_relation_pre group by cinvcode_main) b
    on a.key_num = b.key_num
-- where level_two_cx = '主试剂'
-- group by ccuscode
;

CREATE INDEX index_mid00_ccus_03_item_effect_19_cinvcode ON report.mid00_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid00_ccus_03_item_effect_19_ccuscode ON report.mid00_ccus_03_item_effect_19(ccuscode);

-- 这里是主试剂合集
drop table if exists report.mid0_ccus_03_item_effect_19;
create temporary table report.mid0_ccus_03_item_effect_19 as
select a.ccuscode
      ,b.cinvcode
      ,b.cinvname
      ,b.cinvcode_main
      ,b.cinvname_main
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
  from report.invoice_order_pre a
  left join report.x_cinv_relation_pre b
    on a.key_num = b.key_num
 where level_two_cx = '主试剂'
 group by ccuscode,cinvcode
;

CREATE INDEX index_mid0_ccus_03_item_effect_19_cinvcode ON report.mid0_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid0_ccus_03_item_effect_19_ccuscode ON report.mid0_ccus_03_item_effect_19(ccuscode);

-- 主试剂对应的收入汇总
drop table if exists report.mid1_ccus_03_item_effect_19;
create temporary table report.mid1_ccus_03_item_effect_19 as
 select a.ccuscode
       ,a.cinvcode
       ,a.cinvname
       ,a.cinvcode_main
       ,a.cinvname_main
       ,a.province
       ,a.city
       ,a.ccusname
       ,a.cbustype
       ,sum(isum) as isum
       ,sum(cost) as cost
       ,sum(invoice_amount) as invoice_amount
   from report.mid0_ccus_03_item_effect_19 a
   left join report.invoice_order_pre b
     on a.cinvcode = b.cinvcode
    and a.ccuscode = b.ccuscode
  group by a.cinvcode,a.ccuscode
 ;

CREATE INDEX index_mid1_ccus_03_item_effect_19_cinvcode ON report.mid1_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid1_ccus_03_item_effect_19_ccuscode ON report.mid1_ccus_03_item_effect_19(ccuscode);

-- 这里是辅助试剂合集
drop table if exists report.mid2_ccus_03_item_effect_19;
create temporary table report.mid2_ccus_03_item_effect_19 as
select distinct a.ccuscode
      ,b.cinvcode
      ,b.cinvname
      ,b.cinvcode_main
      ,b.cinvname_main
      ,a.province
      ,a.city
      ,a.ccusname
      ,a.cbustype
  from (select * from report.invoice_order_pre group by ccuscode) a
  left join (select * from report.x_cinv_relation_pre where level_two_cx = '辅助试剂耗材' group by cinvcode) b
    on a.key_num = b.key_num
--   and b.cinvcode is not null
;

CREATE INDEX index_mid2_ccus_03_item_effect_19_cinvcode ON report.mid2_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid2_ccus_03_item_effect_19_ccuscode ON report.mid2_ccus_03_item_effect_19(ccuscode);

-- 辅助试剂分配的试剂大于1的情况下进行拆分,辅助试剂耗材
-- 这里计算辅助试剂各个客户的汇总
drop table if exists report.mid3_ccus_03_item_effect_19;
create temporary table report.mid3_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,case when ifnull(b.cost1,0.01) = 0 then 0.00001 else ifnull(b.cost1,0.00001) end as cost
      ,case when ifnull(b.isum_1,0.01) = 0 then 0.00001 else ifnull(b.isum_1,0.00001) end as isum
      ,case when ifnull(b.invoice_amount_1,0.01) = 0 then 0.00001 else ifnull(b.invoice_amount_1,0.00001) end as invoice_amount
  from report.mid2_ccus_03_item_effect_19 a
  left join (select *,sum(isum) as isum_1,sum(cost) as cost1,sum(invoice_amount) as invoice_amount_1 from report.mid1_ccus_03_item_effect_19 group by cinvcode_main,ccuscode) b
    on a.ccuscode = b.ccuscode
   and a.cinvcode_main = b.cinvcode_main
-- where b.ccuscode is not null
;

-- 主试剂成本,下面移动上来的
drop table if exists report.mid8_ccus_03_item_effect_19;
create temporary table report.mid8_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode_main as cinvcode
      ,sum(b.cost) as isum
  from report.mid1_ccus_03_item_effect_19 a
  left join report.fin_11_sales_cost_base b
    on a.ccuscode = b.ccuscode
   and a.cinvcode = b.cinvcode
 where year(b.ddate) = '2019'
   and b.ccuscode is not null
 group by a.cinvname_main,a.ccuscode
;


-- 删除没有主试剂成本的数据
drop table if exists report.mid31_ccus_03_item_effect_19;
create temporary table report.mid31_ccus_03_item_effect_19 as
select a.*
  from report.mid3_ccus_03_item_effect_19 a
  left join (select * from report.mid8_ccus_03_item_effect_19 where isum <> 0) b
    on a.cinvcode_main = b.cinvcode
   and a.ccuscode = b.ccuscode
 where b.ccuscode is not null
;

-- 相关的主试剂汇总
drop table if exists report.mid4_ccus_03_item_effect_19;
create temporary table report.mid4_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,sum(a.isum) as isum
      ,sum(a.cost) as cost
      ,sum(a.invoice_amount) as invoice_amount
  from report.mid31_ccus_03_item_effect_19 a
  group by cinvcode,ccuscode
;

CREATE INDEX index_mid31_ccus_03_item_effect_19_cinvcode ON report.mid31_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid31_ccus_03_item_effect_19_ccuscode ON report.mid31_ccus_03_item_effect_19(ccuscode);

CREATE INDEX index_mid4_ccus_03_item_effect_19_cinvcode ON report.mid4_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid4_ccus_03_item_effect_19_ccuscode ON report.mid4_ccus_03_item_effect_19(ccuscode);

-- 计算每家客户辅助试剂比例
drop table if exists report.mid5_ccus_03_item_effect_19;
create temporary table report.mid5_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvcode_main
      ,ifnull(a.isum / b.isum,0) as bl
      ,ifnull(a.cost / b.cost,0) as cost
      ,ifnull(a.invoice_amount / b.invoice_amount,0) as bl_amount
  from report.mid31_ccus_03_item_effect_19 a
  left join report.mid4_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
;

CREATE INDEX index_mid5_ccus_03_item_effect_19_cinvcode ON report.mid5_ccus_03_item_effect_19(cinvcode);
CREATE INDEX index_mid5_ccus_03_item_effect_19_ccuscode ON report.mid5_ccus_03_item_effect_19(ccuscode);

-- 得到19年所有辅助试剂已经分配完的金额
drop table if exists report.mid6_ccus_03_item_effect_19;
create temporary table report.mid6_ccus_03_item_effect_19 as
select b.province
      ,b.city
      ,b.ccuscode
      ,b.ccusname
      ,b.cbustype
      ,b.cinvcode
      ,b.cinvname
      ,b.cinvcode_main
      ,sum(a.isum * b.cost) as cost
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
create temporary table report.mid7_ccus_03_item_effect_19 as
select a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode_main as cinvcode
      ,a.cinvname_main as cinvname
      ,ifnull(a.isum_1,0) as isum_main
      ,ifnull(c.isum,0) as isum_child
      ,ifnull(a.invoice_amount_1,0) as invoice_amount_main
      ,ifnull(c.invoice_amount,0) as invoice_amount_child
  from (select *,sum(isum) as isum_1,sum(invoice_amount) as invoice_amount_1 from report.mid1_ccus_03_item_effect_19 group by cinvcode_main,ccuscode) a
--  left join report.mid2_ccus_03_item_effect_19 b
--    on a.cinvcode = b.cinvcode_main
--   and a.ccuscode = b.ccuscode
  left join report.mid6_ccus_03_item_effect_19 c
    on a.cinvcode_main = c.cinvcode_main
   and a.ccuscode = c.ccuscode
;

-- 增加19年试剂成本

-- 辅助试剂成本
drop table if exists report.mid9_ccus_03_item_effect_19;
create temporary table report.mid9_ccus_03_item_effect_19 as
select b.ccuscode
      ,b.cinvcode
      ,b.cinvcode_main
--      ,case when sum(a.cost * b.bl) = 0 then sum(a.cost) else sum(a.cost * b.bl) end as isum
      ,sum(a.cost * b.bl) as isum
      ,sum(a.cost * b.cost) as cost_bl
      ,sum(a.cost) as cost
  from report.fin_11_sales_cost_base a
  left join report.mid5_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
 where year(a.ddate) = '2019'
--   and b.cinvcode is not null
   and a.cost <> 0
 group by a.ccuscode,cinvcode_main
;

drop table if exists report.mid10_ccus_03_item_effect_19;
create temporary table report.mid10_ccus_03_item_effect_19 as
select cinvcode,ccuscode from report.mid8_ccus_03_item_effect_19 union
select cinvcode_main,ccuscode from report.mid9_ccus_03_item_effect_19
;

-- 成本主辅合并到一起
drop table if exists report.mid11_ccus_03_item_effect_19;
create temporary table report.mid11_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode
      ,b.isum as isum_main
      ,c.isum as isum_child
  from report.mid10_ccus_03_item_effect_19 a
  left join report.mid8_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
  left join report.mid9_ccus_03_item_effect_19 c
    on a.cinvcode = c.cinvcode_main
   and a.ccuscode = c.ccuscode
;

-- 这里计算保险的相关费用
-- 主试剂相关的拆分
drop table if exists report.mid1_x_insure_cover;
create temporary table report.mid1_x_insure_cover as
select a.bi_cinvcode as cinvcode
      ,a.bi_cuscode as cuscode
      ,b.cinvcode_main
      ,c.cinvcode_child
  from edw.x_insure_cover a
  left join (select * from edw.x_cinv_relation group by cinvcode_child,cinvcode_main) b
    on a.bi_cinvcode = b.cinvcode_child
  left join (select * from edw.x_cinv_relation where level_two_cx = '主试剂' group by cinvcode_child,cinvcode_main) c
    on b.cinvcode_main = c.cinvcode_main
 where year(a.ddate) = '2019'
 group by a.bi_cinvcode,a.bi_cuscode,cinvcode_main,c.cinvcode_child
;

drop table if exists report.mid2_x_insure_cover;
create temporary table report.mid2_x_insure_cover as
select a.* 
      ,sum(ifnull(b.cost,0.00001)) as cost
  from report.mid1_x_insure_cover a
  left join report.invoice_order_pre b
    on a.cinvcode_child = b.cinvcode
   and a.cuscode = b.ccuscode
 group by cuscode,cinvcode_child,cinvcode_main,a.cinvcode
;

-- 聚合
drop table if exists report.mid3_x_insure_cover;
create temporary table report.mid3_x_insure_cover as
select cinvcode
      ,cuscode
      ,cinvcode_main
      ,cinvcode_child
      ,sum(cost) as cost
  from report.mid2_x_insure_cover
 group by cinvcode,cuscode
;
-- 计算占比
drop table if exists report.mid4_x_insure_cover;
create temporary table report.mid4_x_insure_cover as
select a.cinvcode
      ,a.cuscode
      ,a.cinvcode_main
      ,a.cost / b.cost as cost_bl
  from report.mid2_x_insure_cover a
  left join report.mid3_x_insure_cover b
    on a.cinvcode = b.cinvcode
   and a.cuscode = b.cuscode
;

-- 生成最后的表
-- drop table if exists report.mid5_x_insure_cover;
-- create temporary table report.mid5_x_insure_cover as
-- select a.bi_cinvcode as cinvcode
--       ,a.bi_cuscode as cuscode
--       ,b.cinvcode_main
--       ,sum(sales) * b.cost_bl as isum
--   from edw.x_insure_cover a
--   left join report.mid4_x_insure_cover b
--     on a.bi_cinvcode = b.cinvcode
--    and a.bi_cuscode = b.cuscode
--  where year(a.ddate) = '2019'
--  group by a.bi_cinvcode,a.bi_cuscode
--  order by a.bi_cinvcode,a.bi_cuscode
-- ;
drop table if exists report.mid5_x_insure_cover;
create temporary table report.mid5_x_insure_cover as
select b.cinvcode
      ,b.cuscode
      ,c.cinvcode_main
      ,b.isum * c.cost_bl as isum
  from (select a.bi_cinvcode as cinvcode
              ,a.bi_cuscode as cuscode
              ,sum(act_num*iunitcost) as isum -- 这里改成成本
          from edw.x_insure_cover a
         where year(a.ddate) = '2019'
         group by a.bi_cinvcode,a.bi_cuscode
         order by a.bi_cinvcode,a.bi_cuscode
         ) b
  left join report.mid4_x_insure_cover c
    on b.cinvcode = c.cinvcode
   and b.cuscode = c.cuscode
;


-- 数据汇总
truncate table report.ccus_03_item_effect_19;
insert into report.ccus_03_item_effect_19
select a.province
      ,a.city
      ,null
      ,null
      ,a.ccuscode
      ,a.ccusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,ifnull(e.isum_main,0) as isum_main
      ,ifnull(e.isum_child,0) as isum_child
      ,ifnull(e.invoice_amount_main,0) as invoice_amount_main
      ,ifnull(e.invoice_amount_child,0) as invoice_amount_child
      ,ifnull(b.isum_main,0) as iunitcost_main
      ,ifnull(b.isum_child,0) as iunitcost_child
      ,ifnull(c.amount_19,0) as amount_19
      ,0 as sy_md
      ,ifnull(f.isum,0) as insure_md
      ,d.install_dt
      ,0
      ,0
  from report.mid00_ccus_03_item_effect_19 a
  left join report.mid11_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.ccuscode = b.ccuscode
  left join (select bi_cuscode,bi_cinvcode,sum(amount_19) as amount_19 from edw.x_eq_depreciation_19_relation group by bi_cuscode,bi_cinvcode) c
    on a.ccuscode = c.bi_cuscode
   and a.cinvcode = c.bi_cinvcode
  left join (select * from pdm.cuspro_archives group by ccuscode,cinvcode) d
    on a.ccuscode = d.ccuscode
   and a.cinvcode = d.cinvcode
  left join report.mid7_ccus_03_item_effect_19 e
    on a.ccuscode = e.ccuscode
   and a.cinvcode = e.cinvcode
  left join report.mid5_x_insure_cover f
    on a.ccuscode = f.cuscode
   and a.cinvcode = f.cinvcode_main
;

-- 删除所有数值为0的数据
delete from report.ccus_03_item_effect_19 
 where isum_main < 0.1 
   and isum_child < 0.1 
   and invoice_amount_main < 0.1 
   and invoice_amount_child < 0.1 
   and iunitcost_main < 0.1 
   and iunitcost_child < 0.1 
   and amount_19 < 0.1 
   and sy_md < 0.1 
   and insure_md < 0.1 
--   and install_dt is null
;

-- 实验员成本计算，由于只给到项目和客户，需要在处理完之后在处理
drop table if exists report.mid12_ccus_03_item_effect_19;
create temporary table report.mid12_ccus_03_item_effect_19 as
select a.finnal_ccuscode as ccuscode
      ,a.cinvcode
      ,a.iunitcost_main
  from report.ccus_03_item_effect_19 a
  left join edw.x_ccus_invoice b
    on a.finnal_ccuscode = b.bi_cuscode
   and a.cinvcode = b.bi_cinvcode
 where b.bi_cinvcode is not null
   and a.iunitcost_main <> 0
;
-- 项目客户聚合
drop table if exists report.mid13_ccus_03_item_effect_19;
create temporary table report.mid13_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode
      ,sum(a.iunitcost_main) as iunitcost_main
  from report.mid12_ccus_03_item_effect_19 a
 group by a.ccuscode
;

drop table if exists report.mid14_ccus_03_item_effect_19;
create temporary table report.mid14_ccus_03_item_effect_19 as
select a.ccuscode
      ,a.cinvcode
      ,(mon_1+mon_2+mon_3+mon_4+mon_5+mon_6+mon_7+mon_8+mon_9+mon_10+mon_11+mon_12) * a.iunitcost_main / b.iunitcost_main as sy_md
  from report.mid12_ccus_03_item_effect_19 a
  left join report.mid13_ccus_03_item_effect_19 b
    on a.ccuscode = b.ccuscode
--   and a.cinvcode = b.cinvcode
  left join (select * from edw.x_account_sy where year_ = '2019') c
    on a.ccuscode = c.bi_cuscode
;

update report.ccus_03_item_effect_19 a
 inner join report.mid14_ccus_03_item_effect_19 b
    on a.cinvcode = b.cinvcode
   and a.finnal_ccuscode = b.ccuscode
   set a.sy_md = ifnull(b.sy_md,0)
;


-- 更新产品类型
update report.ccus_03_item_effect_19 a
 inner join (select * from edw.map_inventory group by bi_cinvcode) b
    on a.cinvcode = b.bi_cinvcode
   set a.cbustype = b.business_class
;

-- 更新项目利润,这里的实验员改成保险的费用
update report.ccus_03_item_effect_19 set profit = (invoice_amount_main + invoice_amount_child - iunitcost_main - iunitcost_child -amount_19 - insure_md);

-- 更新项目利润率
update report.ccus_03_item_effect_19 set profit_margin = profit / (invoice_amount_main + invoice_amount_child);

-- 更新最终客户对应的客户情况
update report.ccus_03_item_effect_19 a
inner join (select * from pdm.invoice_price where state = '最后一次价格' and left(ccuscode,2) = 'DL' and end_dt >= '2019-01-01' group by finnal_ccuscode) b
    on a.finnal_ccuscode = b.finnal_ccuscode
   set a.ccuscode = b.ccuscode
      ,a.ccusname = b.ccusname
;

update report.ccus_03_item_effect_19 set ccuscode = finnal_ccuscode,ccusname = finnal_ccusname where ccuscode is null;

--  drop table if exists report.mid15_ccus_03_item_effect_19;
--  create temporary table report.mid15_ccus_03_item_effect_19 as
--  select a.ccuscode
--        ,a.ccusname
--        ,a.finnal_ccuscode
--        ,a.finnal_ccusname
--        ,a.cinvcode
--        ,b.cinvcode_main
--    from pdm.invoice_order a
--    left join (select * from report.x_cinv_relation_pre group by cinvcode,cinvcode_main) b
--      on a.cinvcode = b.cinvcode
--   where year(ddate) = '2019'
--     and a.finnal_ccuscode <> 'multi'
--     and left(a.finnal_ccuscode,2) <> 'GR'
--     and b.cinvcode_main is not null
--   group by ccuscode,finnal_ccuscode,b.cinvcode
--  ;
--  
--  update report.ccus_03_item_effect_19 a
--   inner join report.mid15_ccus_03_item_effect_19 b
--      on a.cinvcode = b.cinvcode_main
--     and a.finnal_ccuscode = b.finnal_ccuscode
--     set a.ccuscode = b.ccuscode
--        ,a.ccusname = b.ccusname
--  ;
--  


