-- 第二层个人数据处理,处理得到个人每季度的预算总和
-- create temporary table pdm.oa_budget_19_person as
-- select budgetinfoid
--       ,cdepname_lv1
--       ,cdepname_lv2
--       ,cdepname_lv3
--       ,cdepname_lv4
--       ,cdepname_lv5
--       ,cdepname_lv6
--       ,person
--       ,name_ehr as budget_depnam
--       ,name
--       ,u8kemubm
--       ,cdlx
--       ,case when cast((budgetperiodslist-2)/3 as SIGNED) = 0 then 1
--             when cast((budgetperiodslist-2)/3 as SIGNED) = 1 then 4
--             when cast((budgetperiodslist-2)/3 as SIGNED) = 2 then 7
--             when cast((budgetperiodslist-2)/3 as SIGNED) = 3 then 10
--             end as budgetperiodslist
--       ,sum(budgetaccount) as budgetaccount
--       ,createdate
--       ,approverid
--       ,createrid
--       ,budgetremark
--       ,fnaincrement
--       ,remark
--   from edw.oa_budget_19
--  where cdepname_lv1 is null
--    and person is not null
--    and budgetperiodslist is not null
--  group by person,cast((budgetperiodslist-2)/3 as SIGNED),name;

-- 拉入部门预算数据
create temporary table pdm.oa_budget_19_pre as
select budgetinfoid
      ,cdepname_lv1
      ,cdepname_lv2
      ,cdepname_lv3
      ,cdepname_lv4
      ,cdepname_lv5
      ,cdepname_lv6
      ,person
      ,name_ehr as budget_depnam
      ,name
      ,u8kemubm
      ,cdlx
      ,case when budgetperiodslist in (1,2,3) then 1
            when budgetperiodslist in (4,5,6) then 4
            when budgetperiodslist in (7,8,9) then 7
            else 10 end as budgetperiodslist
      ,sum(budgetaccount) as budgetaccount
      ,createdate
      ,approverid
      ,createrid
      ,budgetremark
      ,fnaincrement
      ,remark
  from edw.oa_budget_19
 where cdepname_lv1 is null
   and person is  null
--   and cdlx = '部门'
 group by (case when budgetperiodslist in (1,2,3) then 1
            when budgetperiodslist in (4,5,6) then 4
            when budgetperiodslist in (7,8,9) then 7
            else 10 end),name_ehr,u8kemubm
;

-- 拉入个人预算数据
-- insert into pdm.oa_budget_19_pre
-- select *
--   from pdm.oa_budget_19_person
--  where budgetperiodslist is not null
--    and budgetaccount is not null
-- ;


-- 整合预算
create temporary table pdm.oa_budget_19_pre1 as
select budgetinfoid
      ,cdepname_lv2
      ,cdepname_lv3
      ,cdepname_lv4
      ,cdepname_lv5
      ,cdepname_lv6
      ,budget_depnam
      ,name
      ,u8kemubm
      ,sum(budgetaccount) as budgetaccount
      ,budgetperiodslist
  from pdm.oa_budget_19_pre
 group by budget_depnam,budgetperiodslist,name;


-- 实际产生的费用整合
create temporary table pdm.account_fy_all as
select a.name_u8
      ,a.u8_kemu
      ,a.u8_code
      ,a.u8_code_name
      ,case when cast((select SUBSTR(a.dbill_date,6,2)-1)/3 as SIGNED) = 0 then 1
            when cast((select SUBSTR(a.dbill_date,6,2)-1)/3 as SIGNED) = 1 then 4
            when cast((select SUBSTR(a.dbill_date,6,2)-1)/3 as SIGNED) = 2 then 7
            when cast((select SUBSTR(a.dbill_date,6,2)-1)/3 as SIGNED) = 3 then 10
            end as budgetperiodslist
      ,sum(a.md) as md
  from pdm.account_fy a
  left join edw.dic_oa_u8_dept b
    on a.name_u8 = b.true_dept
 where dbill_date >= '2019-01-01'
 group by cast((select SUBSTR(a.dbill_date,6,2)-1)/3 as SIGNED),a.name_u8,u8_code_lv2
;

-- 存在没有预算但是实际产生费用的情况
truncate table pdm.account_fy_fact;
insert into pdm.account_fy_fact
select a.budgetinfoid
      ,a.cdepname_lv2
      ,a.cdepname_lv3
      ,a.cdepname_lv4
      ,a.cdepname_lv5
      ,a.cdepname_lv6
      ,a.budget_depnam
      ,a.name
      ,a.budgetperiodslist
      ,a.budgetaccount
      ,b.md
      ,a.budgetaccount - b.md as surplus_amount 
  from pdm.oa_budget_19_pre1 a
  left join pdm.account_fy_all b
    on a.budget_depnam = b.name_u8
   and left(a.u8kemubm,6) = left(b.u8_code,6)
   and a.budgetperiodslist = b.budgetperiodslist
;

create temporary table edw.code as
select ccode,ccode_name
  from ufdata.code
 where db = 'UFDATA_111_2018'
   and iyear = "2019"
;

insert into edw.code values('640110','人员成本');


create temporary table pdm.account_fy_fact_1 as
select a.*
      ,b.ccode
  from pdm.account_fy_fact a
  left join (select * from edw.code b group by ccode_name,left(ccode,4)) b
    on left(a.name,4) = left(ccode,4)
   and right(a.name,CHAR_LENGTH(a.name)-4) = b.ccode_name
;

drop table if exists pdm.account_fy_fact_2;
create table pdm.account_fy_fact_2 as
select a.*
      ,b.ccode as code
      ,b.ccode_name
  from pdm.account_fy_fact_1 a
  left join (select * from edw.code b group by ccode) b
    on left(a.ccode,6) = b.ccode
;
