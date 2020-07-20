-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层费用整合表
-- ----------------------------------------------------------------------------------------
-- 程序名称：fin_21_expenses_base.sql
-- 目标模型：fin_21_expenses_base
-- 源    表：edw.x_account_fy
-- ---------------------------------------------------------------------------------------
-- 加载周期：日全
-- ----------------------------------------------------------------------------------------
-- 作者：jiangsh
-- 开发日期：2020-04-127
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-04-127   开发上线
-- 调用方法　python /home/bidata/report/py/fin_21_expenses_base.py
-- ----------------------------------开始处理逻辑------------------------------------------

-- 这里是19年开始截至上个月所有的费用数据
truncate table report.fin_21_expenses_base;
insert into report.fin_21_expenses_base
select a.cohr
      ,a.y_mon
      ,a.dbill_date
      ,year(dbill_date)
      ,month(dbill_date)
      ,a.bi_cuscode
      ,a.bi_cusname
      ,b.sales_dept
      ,b.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.region
      ,b.city
      ,a.cdr_dept_name as dept_name
      ,a.cdept_id_ehr
      ,a.name_ehr
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.code
      ,a.code_name
      ,a.code_lv2
      ,a.code_name_lv2
      ,c.ccode_name as code_class
      ,a.kemu as code_name_fx
      ,a.code_class as code_class_fx
      ,a.cd_name
      ,a.u8_liuchengbh
      ,a.md
      ,null as dept_type
      ,null as dept_type1
      ,null as code_type
      ,null as code_type1
  from edw.x_account_fy a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.bi_cuscode = b.bi_cuscode
  left join (select * from ufdata.code group by ccode) c
    on left(code,4) = c.ccode
 where a.dbill_date >= '2018-01-01'
;

-- 更新销售中心的部门标签
-- 贝生标签更新
update report.fin_21_expenses_base
   set dept_type = '杭州贝生',dept_type1 = '杭州贝生'
 where cohr = '杭州贝生'
;

-- 销售中心标签
update report.fin_21_expenses_base
   set dept_type = '销售中心',dept_type1 = '直接销售'
 where second_dept = '销售中心'
   and third_dept is null
   and dept_type is null
;

update report.fin_21_expenses_base
   set dept_type = '销售中心',dept_type1 = '直接销售'
 where second_dept = '销售中心'
   and third_dept = '销售管理部'
   and dept_type is null
;

-- 销售一部标签
update report.fin_21_expenses_base
   set dept_type = '销售一部',dept_type1 = '直接销售部'
 where third_dept = '销售一部'
   and fourth_dept is null
   and dept_type is null
;

update report.fin_21_expenses_base
   set dept_type = '销售一部',dept_type1 = '直接销售部'
 where third_dept = '销售一部'
   and fourth_dept = '一部公卫部'
   and dept_type is null
;

-- 销售二部标签
update report.fin_21_expenses_base
   set dept_type = '销售二部',dept_type1 = '直接销售部'
 where third_dept = '销售二部'
   and fourth_dept is null
   and dept_type is null
;

update report.fin_21_expenses_base
   set dept_type = '销售二部',dept_type1 = '直接销售部'
 where third_dept = '销售二部'
   and fourth_dept = '二部公卫部'
   and dept_type is null
;

-- 销售中心省区标签
update report.fin_21_expenses_base
   set dept_type = fourth_dept,dept_type1 = '销售省区'
 where second_dept = '销售中心'
   and dept_type is null
   and fourth_dept like '%省%'
;

update report.fin_21_expenses_base
   set dept_type = fourth_dept,dept_type1 = '销售省区2'
 where second_dept = '销售中心'
   and dept_type is null
;


-- 间接费用的标签
update report.fin_21_expenses_base
   set dept_type = second_dept,dept_type1 = '间接费用'
 where second_dept in ('400客服部','技术保障中心','供应链中心','信息中心','市场中心','数字创新中心')
   and dept_type is null
;

-- 其余非杭州贝生的打上管理费用
update report.fin_21_expenses_base
   set dept_type = '管理费用',dept_type1 = '管理费用'
 where dept_type is null
;

-- 2.0调整19年的标签
-- 大区公卫部
update report.fin_21_expenses_base
   set dept_type = '销售六区',dept_type1 = '直接销售区域'
 where dept_name in ('六区公卫部','销售六区公卫部','销售六区')
;

update report.fin_21_expenses_base
   set dept_type = '销售三区',dept_type1 = '直接销售区域'
 where dept_name in ('三区公卫部','销售三区公卫部','销售三区')
;

update report.fin_21_expenses_base
   set dept_type = '销售四区',dept_type1 = '直接销售区域'
 where dept_name in ('四区公卫部','销售四区公卫部','销售四区')
;

update report.fin_21_expenses_base
   set dept_type = '销售五区',dept_type1 = '直接销售区域'
 where dept_name in ('五区公卫部','销售五区公卫部','销售五区')
;

-- 销售大区
update report.fin_21_expenses_base
   set dept_type = '销售一区',dept_type1 = '直接销售区域'
 where dept_name = '销售一区'
;

update report.fin_21_expenses_base
   set dept_type = '销售二区',dept_type1 = '直接销售区域'
 where dept_name = '销售二区'
;
update report.fin_21_expenses_base
   set dept_type = '销售七区',dept_type1 = '直接销售区域'
 where dept_name = '销售七区'
;
update report.fin_21_expenses_base
   set dept_type = '销售八区',dept_type1 = '直接销售区域'
 where dept_name = '销售八区'
;
update report.fin_21_expenses_base
   set dept_type = '销售九区',dept_type1 = '直接销售区域'
 where dept_name = '销售九区'
;

-- 科目打赏标签
update report.fin_21_expenses_base
   set code_type = case when code_name_lv2 in ('业务招待费','差旅费','人员成本','会务费','试剂招标经费','科研协作费','会议费') then code_name_lv2 else '其他费用' end 
      ,code_type1 = case when code_class_fx in ('业务招待费','差旅费','人员成本','会务费','试剂招标经费','科研协作费','会议费') then code_class_fx else '其他费用' end
;

update report.fin_21_expenses_base set code_type = '业务招待费' where code_name_lv2 = '业务招待费其他';
update report.fin_21_expenses_base set code_type1 = '业务招待费' where code_class_fx = '业务招待费其他';







