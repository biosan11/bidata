
-- 数据第二层19年预算
truncate table pdm.oa_budget_19;
insert into pdm.oa_budget_19
select a.budgetinfoid
      ,a.name_ehr_id
      ,a.name_ehr
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.person
      ,a.name
      ,a.u8kemubm
      ,a.cdlx
      ,cast(concat('2019-',a.budgetperiodslist,'-01') as date) as budgetperiodslist
      ,a.budgetaccount
      ,a.createdate
      ,a.approverid
      ,a.createrid
      ,a.budgetremark
      ,a.fnaincrement
      ,a.remark
  from edw.oa_budget_19 a
 where a.cdepname_lv1 is null;












