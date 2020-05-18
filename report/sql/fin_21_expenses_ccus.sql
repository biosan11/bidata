------------------------------------程序头部----------------------------------------------
--功能：report层费用分摊-客户省区
------------------------------------------------------------------------------------------
--程序名称：fin_21_expenses_ccus.sql
--目标模型：fin_21_expenses_ccus
--源    表：report.fin_21_expenses_base
-----------------------------------------------------------------------------------------
--加载周期：日全
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-04-127
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-04-27   开发上线
--调用方法　python /home/bidata/report/py/fin_21_expenses_dept.py
------------------------------------开始处理逻辑------------------------------------------

-- 费用分摊，来源re层费用明细表
-- 分摊规则直接到客户的，到省区的，然后销售中心，间接费用，管理费用，在直接匹配内部分摊
-- 直接销售费用获取
drop table if exists report.mid1_fin_21_expenses_ccus;
create temporary table report.mid1_fin_21_expenses_ccus as
select cohr
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,cuscode as ccuscode
      ,code_type as code
      ,sum(md) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base
 where cuscode is not null
   and LEFT(cuscode,2) <> 'GL'
   and dept_type <> '杭州贝生'
   and ddate >= '2019-01-01'
 group by year_,month_,cuscode,code_type
;

-- 直接到省区的且没有客户的
drop table if exists report.mid2_fin_21_expenses_ccus;
create temporary table report.mid2_fin_21_expenses_ccus as
select a.cohr
      ,a.year_
      ,a.month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_salesregionnew) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from (SELECT cohr,year_,month_,dept_type,sum(md) as md from report.fin_21_expenses_base
	         where dept_type1  in ('销售省区','销售省区2')
	           and ddate >= '2019-01-01'
           and (cuscode is null or LEFT(cuscode,2) = 'GL')
         group by year_,month_,dept_type) a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and left(a.dept_type,2) = left(b.sales_region_new,2)
 where ifnull(b.sales_region_new,0) <> 'hzbs'
   and b.year_ is not null
 group by a.year_,a.month_,b.ccuscode
;

-- 直接到省区的且没有客户的,匹配不上直接到中心
drop table if exists report.mid3_fin_21_expenses_ccus;
create temporary table report.mid3_fin_21_expenses_ccus as
select a.cohr
      ,a.year_
      ,a.month_
      ,'' as code_type
      ,a.md
      ,a.dept_type
  from report.fin_21_expenses_base a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and left(a.dept_type,2) = left(b.sales_region_new,2)
 where a.dept_type1  in ('销售省区','销售省区2')
   and a.ddate >= '2019-01-01'
   and (cuscode is null or LEFT(cuscode,2) = 'GL')
   and dept_type <> '杭州贝生'
   and ifnull(b.sales_region_new,0) <> 'hzbs'
   and b.year_ is null
;

-- 直接到销售几部的费用
drop table if exists report.mid4_fin_21_expenses_ccus;
create temporary table report.mid4_fin_21_expenses_ccus as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_dept) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and left(a.dept_type,4) = left(b.sales_dept,4)
 where a.dept_type1  in ('直接销售部')
   and a.ddate >= '2019-01-01'
   and (cuscode is null or LEFT(cuscode,2) = 'GL')
   and dept_type <> '杭州贝生'
   and ifnull(b.sales_region_new,0) <> 'hzbs'
 group by a.year_,a.month_,b.ccuscode,a.code_type
;

-- 直接到销售中心
drop table if exists report.mid5_fin_21_expenses_ccus;
create temporary table report.mid5_fin_21_expenses_ccus as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
 where a.dept_type1  in ('直接销售')
   and a.ddate >= '2019-01-01'
   and (cuscode is null or LEFT(cuscode,2) = 'GL')
   and ifnull(b.sales_region_new,0) <> 'hzbs'
 group by a.year_,a.month_,b.ccuscode,a.code_type
;

insert into report.mid5_fin_21_expenses_ccus
select a.cohr
      ,a.year_
      ,a.month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.mid3_fin_21_expenses_ccus a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
 where ifnull(b.sales_region_new,0) <> 'hzbs'
 group by a.year_,a.month_,b.ccuscode,a.code_type
;

-- 直接到销售区域
drop table if exists report.mid6_fin_21_expenses_ccus;
create temporary table report.mid6_fin_21_expenses_ccus as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_salesregion) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and left(a.dept_type,4) = left(b.sales_region,4)
 where a.dept_type1  in ('直接销售区域')
   and a.ddate >= '2019-01-01'
   and (cuscode is null or LEFT(cuscode,2) = 'GL')
   and ifnull(b.sales_region_new,0) <> 'hzbs'
   and b.year_ is not null
 group by a.year_,a.month_,b.ccuscode,a.code_type
;
drop table if exists report.mid61_fin_21_expenses_ccus;
create temporary table report.mid61_fin_21_expenses_ccus as
select a.cohr
      ,a.year_
      ,a.month_
      ,'' as code_type
      ,a.md
      ,a.dept_type
  from report.fin_21_expenses_base a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and left(a.dept_type,4) = left(b.sales_region,4)
 where a.dept_type1  in ('直接销售区域')
   and a.ddate >= '2019-01-01'
   and (cuscode is null or LEFT(cuscode,2) = 'GL')
   and ifnull(b.sales_region_new,0) <> 'hzbs'
   and b.year_ is null
 group by a.year_,a.month_,b.ccuscode,a.code_type
;

insert into report.mid5_fin_21_expenses_ccus
select a.cohr
      ,a.year_
      ,a.month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.mid61_fin_21_expenses_ccus a
  left join report.auxi_01_ccuscode_per b
    on a.year_ = b.year_
   and a.month_ = b.month_
 where ifnull(b.sales_region_new,0) <> 'hzbs'
 group by a.year_,a.month_,b.ccuscode,a.code_type
;


-- 间接费用
drop table if exists report.mid7_fin_21_expenses_ccus;
create temporary table report.mid7_fin_21_expenses_ccus as
select a.cohr
      ,a.year_
      ,a.month_
      ,b.ccuscode
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,'管理费用' as dept_type
      ,'管理费用' as type
  from (SELECT cohr,year_,month_,sum(md) as md from report.fin_21_expenses_base
	         where dept_type1  in ('间接费用','管理费用')
	           and ddate >= '2019-01-01'
           and (cuscode is null or LEFT(cuscode,2) = 'GL')
         group by year_,month_) a
  left join (select * from report.auxi_01_ccuscode_per where year_ >= '2019') b
    on a.year_ = b.year_
   and a.month_ = b.month_
 where ifnull(b.sales_region_new,0) <> 'hzbs'
 group by a.year_,a.month_,b.ccuscode
;

drop table if exists report.mid8_fin_21_expenses_ccus;
create table report.mid8_fin_21_expenses_ccus as
select * from report.mid1_fin_21_expenses_ccus union all
select * from report.mid2_fin_21_expenses_ccus union all
select * from report.mid4_fin_21_expenses_ccus union all
select * from report.mid5_fin_21_expenses_ccus union all
select * from report.mid6_fin_21_expenses_ccus union all
select * from report.mid7_fin_21_expenses_ccus
;

-- 聚合
truncate table report.fin_21_expenses_ccus;
insert into report.fin_21_expenses_ccus
select a.cohr
      ,a.year_
      ,a.month_
      ,a.ccuscode
      ,b.bi_cusname
      ,a.code
      ,sum(md) as md
      ,0 as md_sy
      ,0 as md_bx
      ,0 as md_fw
      ,a.dept_type
      ,a.type
  from report.mid8_fin_21_expenses_ccus a
  left join (select * from edw.dic_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
 group by year_,month_,a.ccuscode,code,dept_type
;

-- 插入内部结算有但是费用没有的当月客户
-- 插入实验员
insert into report.fin_21_expenses_ccus
select '博圣'
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,a.ccuscode
      ,a.ccusname
      ,'人员成本'
      ,0
      ,0 as md_sy
      ,0 as md_bx
      ,0 as md_fw
      ,'直接费用'
      ,'直接费用'
  from (select * from report.fin_22_expenses_else_base where ddate >= '2019-01-01' and ddate < date_add(curdate(),interval -day(curdate())+1 day) and isum_sy <> 0  group by year(ddate),month(ddate),ccuscode) a
  left join (select * from report.fin_21_expenses_ccus where code = '人员成本') b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
   and a.ccuscode = b.ccuscode
 where b.year_ is null
;

-- 插入其他的费用
insert into report.fin_21_expenses_ccus
select '博圣'
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,a.ccuscode
      ,a.ccusname
      ,''
      ,0
      ,0 as md_sy
      ,0 as md_bx
      ,0 as md_fw
      ,'管理费用'
      ,'管理费用'
  from (select * from report.fin_22_expenses_else_base where ddate >= '2019-01-01' and ddate < date_add(curdate(),interval -day(curdate())+1 day)  group by year(ddate),month(ddate),ccuscode) a
  left join (select * from report.fin_21_expenses_ccus where dept_type = '管理费用') b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
   and a.ccuscode = b.ccuscode
 where b.year_ is null
;


-- 实验员人力成本计算,1908之前是销售中心
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_sy) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md = a.md - b.md
      ,a.md_sy = b.md
 where date(concat(a.year_,'-',a.month_,'-1')) < '2019-09-01'
   and type = '直接费用'
   and code = '人员成本'
;

-- 实验员人力成本计算,1908之前是销售中心
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_sy) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md = a.md - b.md
      ,a.md_sy = b.md
 where date(concat(a.year_,'-',a.month_,'-1')) >= '2019-09-01'
   and type = '管理费用'
;

-- 实验员人力成本计算,1908之前是销售中心
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_bx) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md_bx = b.md
 where type = '管理费用'
;

-- 服务费用更新到间接费用中
-- 技术保障
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_js) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md_fw = b.md
 where type = '管理费用'
;

-- 信息中心
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_xx) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md_fw = b.md + a.md_fw
 where type = '管理费用'
;

-- 物流快递
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_wl) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md_fw = b.md + a.md_fw
 where type = '管理费用'
;

-- 物流快递
update report.fin_21_expenses_ccus a
 inner join (select year(ddate) as year_,month(ddate) as month_,ccuscode,sum(isum_wx) as md from report.fin_22_expenses_else_base group by year_,month_,ccuscode) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.ccuscode = b.ccuscode
   set a.md_fw = b.md + a.md_fw
 where type = '管理费用'
;


