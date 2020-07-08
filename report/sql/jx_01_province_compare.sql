-- --------------------------------程序头部----------------------------------------------
-- 功能：绩效考和对应省区对比
-- ----------------------------------------------------------------------------------------
-- 程序名称：jx_01_province_compare.sql
-- 目标模型：jx_01_province_compare
-- 源    表：report.fin_11_sales_cost_cw_base
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

-- 直接从第二层获取输入月份的'销售中心'人数，中心人数简单拆分
drop table if exists report.mid1_jx_01_province_compare;
create temporary table report.mid1_jx_01_province_compare as
select second_dept
      ,third_dept
      ,fourth_dept
      ,count(*) as ct 
      ,fourth_dept as pro_type
  from edw.ehr_employee 
 where entrydate < '2020-04-01' and ifnull(lastworkdate,'2020-01-02') > '2020-01-01' and employeestatus <> '待入职' and employeestatus <> '试用' and employmenttype = '正式' and second_dept = '销售中心'
 group by second_dept,third_dept,fourth_dept
 order by second_dept,third_dept,fourth_dept
;

update report.mid1_jx_01_province_compare set pro_type = '中心' where third_dept = '销售一部' and ifnull(fourth_dept,'一部公卫部') = '一部公卫部';
update report.mid1_jx_01_province_compare set pro_type = '中心' where third_dept = '销售二部' and ifnull(fourth_dept,'二部公卫部') = '二部公卫部';
update report.mid1_jx_01_province_compare set pro_type = '中心' where ifnull(third_dept,'销售管理部')	= '销售管理部';

-- 聚合一次
drop table if exists report.mid2_jx_01_province_compare;
create table report.mid2_jx_01_province_compare as
select sum(ct) as ct
      ,pro_type
  from report.mid1_jx_01_province_compare
 group by pro_type
;

-- 人数分摊
drop table if exists report.mid3_jx_01_province_compare;
create temporary table report.mid3_jx_01_province_compare as
select a.*,a.ct / b.ct * c.ct + a.ct as ct_all
  from (select * from report.mid2_jx_01_province_compare where pro_type <> '中心') a,(select sum(ct) as ct from report.mid2_jx_01_province_compare where pro_type <> '中心') b
  ,(select sum(ct) as ct from report.mid2_jx_01_province_compare where pro_type = '中心') c
;

drop table if exists report.mid2_jx_01_province_compare;

-- 收入相关1季度数据
-- 自由产品
drop table if exists report.mid4_jx_01_province_compare;
create temporary table report.mid4_jx_01_province_compare as
select sum(isum      ) as isum
      ,sum(isum_notax) as isum_notax
      ,sum(cost      ) as cost
      ,sales_region_new
      ,'自有' as cinv_type
  from report.fin_11_sales_cost_cw_base a
  left join edw.map_inventory b
    on a.cinvcode = b.bi_cinvcode
 where year(ddate) = 2020
   and month(ddate) <= 3
   and cohr <> '杭州贝生'
   and b.cinv_own like '%自有%'
 group by sales_region_new,cinv_type
;

-- 所有产品
drop table if exists report.mid5_jx_01_province_compare;
create temporary table report.mid5_jx_01_province_compare as
select sum(isum      ) as isum
      ,sum(isum_notax) as isum_notax
      ,sum(cost      ) as cost
      ,sales_region_new
  from report.fin_11_sales_cost_cw_base a
  left join edw.map_inventory b
    on a.cinvcode = b.bi_cinvcode
 where year(ddate) = 2020
   and month(ddate) <= 3
   and cohr <> '杭州贝生'
 group by sales_region_new
;


-- 费用相关的人员成本的表
drop table if exists report.mid6_jx_01_province_compare;
create temporary table report.mid6_jx_01_province_compare as
select province,sum(a.md - a.md_sy) as md
  from report.fin_21_expenses_dept a
 where code = '人员成本' and year_ = '2020' and month_ <= 3
 group by province
;

-- 费用相关总费用
drop table if exists report.mid7_jx_01_province_compare;
create temporary table report.mid7_jx_01_province_compare as
select province,sum(a.md - a.md_sy - a.md_bx - a.md_fw) as md
  from report.fin_21_expenses_dept a
 where year_ = '2020' and month_ <= 3
 group by province
;

-- 新的销售区域的数据汇总补全
drop table if exists report.mid8_jx_01_province_compare;
create temporary table report.mid8_jx_01_province_compare as select * from report.mid5_jx_01_province_compare;

insert into report.mid8_jx_01_province_compare
select 0,0,0,a.sales_region_new
  from (select distinct sales_region_new from edw.map_customer where ifnull(sales_region_new,'其他') <> '其他') a
  left join report.mid5_jx_01_province_compare b
    on a.sales_region_new = b.sales_region_new
 where b.sales_region_new is null
;


-- 数据合并，以收入为依据
truncate table report.jx_01_province_compare;
insert into report.jx_01_province_compare	
select a.sales_region_new
      ,a.isum as isum_all
      ,a.isum_notax
      ,b.isum as isum_zy
      ,b.isum / a.isum as bl_zy
      ,a.isum_notax - a.cost as isum_ml
      ,(a.isum_notax - a.cost) / a.isum_notax as bl_ml
      ,c.md as isum_fs
      ,c.md / a.isum_notax as bl_fs
      ,d.md as isum_ry
      ,d.md / a.isum_notax as bl_ry
      ,a.isum_notax - a.cost - c.md as isum_profit
      ,e.ct_all
  from report.mid8_jx_01_province_compare a
  left join report.mid4_jx_01_province_compare b
    on a.sales_region_new = b.sales_region_new
  left join report.mid7_jx_01_province_compare c
    on a.sales_region_new = c.province
  left join report.mid6_jx_01_province_compare d
    on a.sales_region_new = d.province
  left join report.mid3_jx_01_province_compare e
    on left(a.sales_region_new,2) = left(e.pro_type,2)
;

-- 导入中心情况合集
insert into report.jx_01_province_compare
select '中心'
      ,sum(isum_all)
      ,sum(isum_notax)
      ,sum(isum_zy)
      ,sum(isum_zy) / sum(isum_all)
      ,sum(isum_ml)
      ,sum(isum_ml) / sum(isum_notax)
      ,sum(isum_fs)
      ,sum(isum_fs) / sum(isum_notax)
      ,sum(isum_ry)
      ,sum(isum_ry) / sum(isum_notax)
      ,sum(isum_profit)
      ,sum(ct_all)
  from report.jx_01_province_compare
;

-- 导入一部情况合集
insert into report.jx_01_province_compare
select '一部'
      ,sum(isum_all)
      ,sum(isum_notax)
      ,sum(isum_zy)
      ,sum(isum_zy) / sum(isum_all)
      ,sum(isum_ml)
      ,sum(isum_ml) / sum(isum_notax)
      ,sum(isum_fs)
      ,sum(isum_fs) / sum(isum_notax)
      ,sum(isum_ry)
      ,sum(isum_ry) / sum(isum_notax)
      ,sum(isum_profit)
      ,sum(ct_all)
  from report.jx_01_province_compare
 where sales_region_new in('湖北','湖南','京沪区','河南','西北区','西南区','东北区')
;

-- 导入二部情况合集
insert into report.jx_01_province_compare
select '二部'
      ,sum(isum_all)
      ,sum(isum_notax)
      ,sum(isum_zy)
      ,sum(isum_zy) / sum(isum_all)
      ,sum(isum_ml)
      ,sum(isum_ml) / sum(isum_notax)
      ,sum(isum_fs)
      ,sum(isum_fs) / sum(isum_notax)
      ,sum(isum_ry)
      ,sum(isum_ry) / sum(isum_notax)
      ,sum(isum_profit)
      ,sum(ct_all)
  from report.jx_01_province_compare
 where sales_region_new in('安徽','浙江','福建','江苏','山东')
;



