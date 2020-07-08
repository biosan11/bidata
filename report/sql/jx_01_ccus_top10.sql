----------------------------------程序头部----------------------------------------------
--功能：绩效考和对应年度客户top10
------------------------------------------------------------------------------------------
--程序名称：jx_01_ccus_top10.sql
--目标模型：jx_01_ccus_top10
--源    表：report.fin_11_sales_cost_base
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
 --作者：jiangsh
 --开发日期：2020-03-09
 ------------------------------------------------------------------------------------------
 --版本控制：版本号  提交人   提交日期   提交内容
 --         V1.0     jiangsh  2020-03-11   开发上线
 --调用方法　sh /home/bidata/report/python/jx_01_ccus_top10.py
 ------------------------------------开始处理逻辑------------------------------------------

-- 获取截至指定季度的之前的数据，之前年份数据汇总
-- 历史数据汇总到年
drop table if exists report.mid1_jx_01_ccus_top10;
create temporary table report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,12 as month_
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_base a
 where year(ddate) < year('2020-03-01')
 group by year_,ccuscode
 order by year_,isum desc
;

-- 插入当前年份的每季度的情况
insert into report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,case when left(month(ddate) / 3,3) <= 1 then 3
            when left(month(ddate) / 3,3) <= 2 then 6
            when left(month(ddate) / 3,3) <= 3 then 9
            when left(month(ddate) / 3,3) <= 4 then 12
       end as month_
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_base a
 where year(ddate) = year('2020-03-01')
 group by month_,ccuscode
 order by month_,isum desc
;

-- 当前状态求和，获取一个总收入和总有效客户数
-- drop table if exists report.mid2_jx_01_ccus_top10;
-- create temporary table report.mid2_jx_01_ccus_top10
-- select year_
--       ,month_
--       ,sum(isum) as isum
--   from report.mid1_jx_01_ccus_top10 a
--  where a.isum <> 0
--  group by year_,month_
-- ;

-- 排序求出当年、季度前十客户
truncate table report.jx_01_ccus_top10;
insert into report.jx_01_ccus_top10
select @r:= case when @year_=a.year_ and @month_ = a.month_ then @r+1 else 1 end as rownum
      ,@year_:=a.year_ as year_
      ,@month_:=a.month_ as month_
      ,ccuscode
      ,ccusname
      ,isum
  from report.mid1_jx_01_ccus_top10 a
,(select @r:=0,@year_:='',@month_:='') b
;





