----------------------------------程序头部----------------------------------------------
--功能：线下费用整合:保险、实验员、内部结算
------------------------------------------------------------------------------------------
--程序名称：fin_22_expenses_else_base.sql
--目标模型：fin_22_expenses_else_base
--源    表：edw.x_insure_cover,edw.x_account_sy,edw.x_account_insettle
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
 --作者：jiangsh
 --开发日期：2020-03-09
 ------------------------------------------------------------------------------------------
 --版本控制：版本号  提交人   提交日期   提交内容
 --         V1.0     jiangsh  2020-04-09   开发上线
 --调用方法　sh /home/bidata/report/python/jsh_test.sh
 ------------------------------------开始处理逻辑------------------------------------------

-- 获取所有的客户年月合集
drop table if exists report.mid1_fin_22_expenses_else_base;
create temporary table report.mid1_fin_22_expenses_else_base as 
select distinct bi_cuscode as ccuscode,y_mon from edw.x_account_insettle union
select distinct bi_cuscode as ccuscode,y_mon from edw.x_account_sy union
select distinct bi_cuscode as ccuscode,left(ddate,7) from edw.x_insure_cover
;

-- 匹配上客户相关的信息
drop table if exists report.mid2_fin_22_expenses_else_base;
create temporary table report.mid2_fin_22_expenses_else_base as 
select a.ccuscode
      ,b.bi_cusname as ccusname
      ,a.y_mon
      ,b.sales_dept
      ,b.sales_region_new
      ,b.province
  from report.mid1_fin_22_expenses_else_base a
  left join edw.map_customer b
    on a.ccuscode = b.bi_cuscode
;

truncate table report.fin_22_expenses_else_base;
insert into report.fin_22_expenses_else_base
select a.ccuscode
      ,a.ccusname
      ,concat(a.y_mon,'-01') as ddate
      ,a.sales_dept
      ,a.sales_region_new
      ,a.province
      ,ifnull(b.isum,0) as isum_xx
      ,ifnull(c.isum,0) as isum_js
      ,ifnull(d.isum,0) as iusm_wx
      ,ifnull(e.isum,0) as isum_wl
      ,ifnull(f.isum,0) as isum_sy
      ,ifnull(g.isum,0) as isum_ht
  from report.mid2_fin_22_expenses_else_base a
  left join (select * from edw.x_account_insettle where type = 'infor_center') b
    on a.ccuscode = b.bi_cuscode
   and a.y_mon = b.y_mon
  left join (select * from edw.x_account_insettle where type = 'technical') c
    on a.ccuscode = c.bi_cuscode
   and a.y_mon = c.y_mon
  left join (select * from edw.x_account_insettle where type = 'maintenance') d
    on a.ccuscode = d.bi_cuscode
   and a.y_mon = d.y_mon
  left join (select * from edw.x_account_insettle where type = 'logistics') e
    on a.ccuscode = e.bi_cuscode
   and a.y_mon = e.y_mon
  left join edw.x_account_sy f
    on a.ccuscode = f.bi_cuscode
   and a.y_mon = f.y_mon
  left join (select left(ddate,7) as y_mon,bi_cuscode,sum(iunitcost*act_num) as isum from edw.x_insure_cover group by y_mon,bi_cuscode)  g
    on a.ccuscode = g.bi_cuscode
   and a.y_mon = g.y_mon
;


