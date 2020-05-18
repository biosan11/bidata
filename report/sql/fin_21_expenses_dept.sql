------------------------------------程序头部----------------------------------------------
--功能：report层费用分摊-部门省区
------------------------------------------------------------------------------------------
--程序名称：fin_21_expenses_dept.sql
--目标模型：fin_21_expenses_dept
--源    表：report.fin_21_expenses_base
-----------------------------------------------------------------------------------------
--加载周期：日全
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-04-127
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-04-127   开发上线
--调用方法　python /home/bidata/report/py/fin_21_expenses_dept.py
------------------------------------开始处理逻辑------------------------------------------

-- 费用分摊，来源re层费用明细表
-- 分摊规则直接到省区的，然后销售中心，间接费用，管理费用，在直接匹配内部分摊
-- 直接销售费用获取
drop table if exists report.mid1_fin_21_expenses_dept;
create temporary table report.mid1_fin_21_expenses_dept as
select cohr
      ,year(ddate) as year_
      ,month(ddate) as month_
      ,dept_type as province
      ,code_type as code
      ,sum(md) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base
 where dept_type1  in ('销售省区','销售省区2')
   and ddate >= '2019-01-01'
 group by year_,month_,dept_type,code_type
;


-- 销售一部、二部进行拆分
drop table if exists report.mid2_fin_21_expenses_dept;
create temporary table report.mid2_fin_21_expenses_dept as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.sales_region_new as province
      ,a.code_type as code
      ,sum(a.md * per_dept) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_province_per b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
   and a.dept_type = b.sales_dept
 where a.dept_type1 = '直接销售部'
   and a.ddate >= '2019-01-01'
 group by year(a.ddate),month(a.ddate),b.sales_region_new,a.code_type
;

-- 销售中心直接拆分下去
drop table if exists report.mid21_fin_21_expenses_dept;
create temporary table report.mid21_fin_21_expenses_dept as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,ifnull(b.sales_region_new,dept_type) as province
      ,a.code_type as code
      ,sum(a.md * ifnull(per_allexcepthzbs,1)) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_province_per b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
 where a.dept_type1 = '直接销售'
   and a.ddate >= '2019-01-01'
   and ifnull(b.sales_region_new,0) <> '杭州贝生'
 group by year(a.ddate),month(a.ddate),b.sales_region_new,a.code_type
;

-- 销售大区拆分下去
drop table if exists report.mid3_fin_21_expenses_dept;
create temporary table report.mid3_fin_21_expenses_dept as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,ifnull(b.sales_region_new,dept_type) as province
      ,a.code_type as code
      ,sum(a.md * ifnull(per_salesregion,1)) as md
      ,'直接费用' as dept_type
      ,'直接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_province_per b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
   and a.dept_type = b.sales_region
 where a.dept_type1 = '直接销售区域'
   and a.ddate >= '2019-01-01'
   and ifnull(b.sales_region_new,0) <> '杭州贝生'
 group by year(a.ddate),month(a.ddate),b.sales_region_new,a.code_type
;

-- 间接费用的拆分
drop table if exists report.mid4_fin_21_expenses_dept;
create temporary table report.mid4_fin_21_expenses_dept as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.sales_region_new as province
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,dept_type
      ,'间接费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_province_per b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
 where a.dept_type1 = '间接费用'
   and a.ddate >= '2019-01-01'
   and ifnull(b.sales_region_new,0) <> '杭州贝生'
 group by year(a.ddate),month(a.ddate),b.sales_region_new,dept_type
;

-- 管理费用的拆分
drop table if exists report.mid5_fin_21_expenses_dept;
create temporary table report.mid5_fin_21_expenses_dept as
select a.cohr
      ,year(a.ddate) as year_
      ,month(a.ddate) as month_
      ,b.sales_region_new as province
      ,'' as code
      ,sum(a.md * per_allexcepthzbs) as md
      ,'管理费用' as dept_type
      ,'管理费用' as type
  from report.fin_21_expenses_base a
  left join report.auxi_01_province_per b
    on year(a.ddate) = b.year_
   and month(a.ddate) = b.month_
 where a.dept_type1 = '管理费用'
   and a.ddate >= '2019-01-01'
   and ifnull(b.sales_region_new,0) <> '杭州贝生'
 group by year(a.ddate),month(a.ddate),b.sales_region_new
;

-- 生成最终数据表格
drop table if exists report.mid6_fin_21_expenses_dept;
create temporary table report.mid6_fin_21_expenses_dept as
select * from report.mid1_fin_21_expenses_dept union all
select * from report.mid2_fin_21_expenses_dept union all
select * from report.mid21_fin_21_expenses_dept union all
select * from report.mid3_fin_21_expenses_dept union all
select * from report.mid4_fin_21_expenses_dept union all
select * from report.mid5_fin_21_expenses_dept
;

-- 这里更新一下省区名称
update report.mid6_fin_21_expenses_dept a
 inner join (select distinct sales_region_new from edw.map_customer where sales_region_new is not null) b
    on left(a.province,2) =  left(b.sales_region_new,2)
   set a.province = b.sales_region_new
;

-- 销售一区的省区改为东北区
update report.mid6_fin_21_expenses_dept a set province = '东北区' where province = '销售一区';
update report.mid6_fin_21_expenses_dept a set province = '西北区' where province = '销售九区';



-- 聚合
truncate table report.fin_21_expenses_dept;
insert into report.fin_21_expenses_dept
select cohr
      ,year_
      ,month_
      ,province
      ,code
      ,sum(md) as md
      ,0 as md_sy
      ,0 as md_bx
      ,0 as md_fw
      ,dept_type
      ,type
  from report.mid6_fin_21_expenses_dept
 group by year_,month_,province,code,dept_type
;



-- 实验员人力成本计算,1908之前是销售中心
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_sy) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_sy = b.md
 where date(concat(a.year_,'-',a.month_,'-1')) < '2019-09-01'
   and type = '直接费用'
   and code = '人员成本'
;

-- 1909以后实验员费用放在
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_sy) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_sy = b.md
 where date(concat(a.year_,'-',a.month_,'-1')) >= '2019-09-01'
   and type = '间接费用'
   and dept_type = '技术保障中心'
;

-- 保险费用计算在销售中心的其他费用中
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_bx) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_bx = b.md
 where type = '直接费用'
   and code = '其他费用'
;

-- 服务费用更新到间接费用中
-- 技术保障
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_js) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_fw = b.md
 where type = '间接费用'
   and dept_type = '技术保障中心'
;

-- 信息中心
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_xx) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_fw = b.md
 where type = '间接费用'
   and dept_type = '信息中心'
;

-- 物流快递
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_wl) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_fw = b.md
 where type = '间接费用'
   and dept_type = '供应链中心'
;

-- 维修维保
update report.fin_21_expenses_dept a
 inner join (select year(ddate) as year_,month(ddate) as month_,sales_region_new,sum(isum_wx) as md from report.fin_22_expenses_else_base group by year_,month_,sales_region_new) b
    on a.year_ = b.year_
   and a.month_ = b.month_
   and a.province = b.sales_region_new
   set a.md_fw = b.md + a.md_fw
 where type = '间接费用'
   and dept_type = '技术保障中心'
;



