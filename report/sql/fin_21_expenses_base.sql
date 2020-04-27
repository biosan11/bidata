------------------------------------程序头部----------------------------------------------
--功能：report层费用整合表
------------------------------------------------------------------------------------------
--程序名称：fin_21_expenses_base.sql
--目标模型：fin_21_expenses_base
--源    表：edw.x_account_fy
-----------------------------------------------------------------------------------------
--加载周期：日全
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-04-127
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-04-127   开发上线
--调用方法　python /home/bidata/report/py/fin_21_expenses_base.py
------------------------------------开始处理逻辑------------------------------------------

-- 这里是19年开始截至上个月所有的费用数据
truncate table report.fin_21_expenses_base;
insert into report.fin_21_expenses_base
select a.cohr
      ,a.y_mon
      ,a.dbill_date
      ,a.bi_cuscode
      ,a.bi_cusname
      ,b.sales_dept
      ,b.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.region
      ,b.city
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
      ,a.cd_name
      ,a.u8_liuchengbh
      ,a.md
  from edw.x_account_fy a
  left join (select * from edw.map_customer group by bi_cuscode) b
    on a.bi_cuscode = b.bi_cuscode
  left join (select * from ufdata.code group by ccode) c
    on left(code,4) = c.ccode
 where a.dbill_date >= '2019-01-01'
;






