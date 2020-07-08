-- --------------------------------程序头部----------------------------------------------
-- 功能：绩效考和对应年度客户top10
-- ----------------------------------------------------------------------------------------
-- 程序名称：jx_01_ccus_top10.sql
-- 目标模型：jx_01_ccus_top10
-- 源    表：report.fin_11_sales_cost_base
-- ---------------------------------------------------------------------------------------
-- 加载周期：日增
-- ----------------------------------------------------------------------------------------
-- 作者：jiangsh
-- 开发日期：2020-03-09
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
--          V1.0     jiangsh  2020-03-11   开发上线
-- 调用方法　sh /home/bidata/report/python/jx_01_ccus_top10.py
-- ----------------------------------开始处理逻辑------------------------------------------

-- 获取截至指定季度的之前的数据，之前年份数据汇总
-- 历史数据汇总到年
drop table if exists report.mid1_jx_01_ccus_top10;
create temporary table report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,12 as month_
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_cw_base a
 where year(ddate) < year(now()) -- 这里是小于当年数据全部汇总到年
 and cohr != '杭州贝生' and cohr != '美博特'
 and type = '正常'  -- 取非关联公司, 非美博特
 group by year_,ccuscode
 order by year_,isum desc
;

-- 插入当前年份的每季度的情况
-- 插入1季度情况
insert into report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,3
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_cw_base a
 where year(ddate) =  year(now())
   and month(ddate) <= 3
 and cohr != '杭州贝生' and cohr != '美博特'
 and type = '正常'  -- 取非关联公司, 非美博特
 group by ccuscode
 order by isum desc
;


-- 插入2季度情况
insert into report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,6
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_cw_base a
 where year(ddate) =  year(now())
   and month(ddate) <= 6
 and cohr != '杭州贝生' and cohr != '美博特'
 and type = '正常'  -- 取非关联公司, 非美博特
 group by ccuscode
 order by isum desc
;

-- 插入3季度情况
insert into report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,9
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_cw_base a
 where year(ddate) =  year(now())
   and month(ddate) <= 9
 and cohr != '杭州贝生' and cohr != '美博特'
 and type = '正常'  -- 取非关联公司, 非美博特
 group by ccuscode
 order by isum desc
;

-- 插入4季度情况
insert into report.mid1_jx_01_ccus_top10
select year(ddate) as year_
      ,12
      ,ccuscode
      ,ccusname
      ,sum(isum) as isum
  from report.fin_11_sales_cost_cw_base a
 where year(ddate) =  year(now())
   and month(ddate) <= 12
 and cohr != '杭州贝生' and cohr != '美博特'
 and type = '正常'  -- 取非关联公司, 非美博特
 group by ccuscode
 order by isum desc
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
      ,@month_:=a.month_ as quarter
      ,ccuscode
      ,ccusname
      ,isum
  from report.mid1_jx_01_ccus_top10 a
,(select @r:=0,@year_:='',@month_:='') b
;





