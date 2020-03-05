------------------------------------程序头部----------------------------------------------
--功能：科目表
------------------------------------------------------------------------------------------
--程序名称：account_fy_code.sql
--目标模型：account_fy_code
--源    表：pdm.account_fy,edw.x_account_fy
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-02-26
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2020-02-26   开发上线
--调用方法　python /home/bidata/report/python/account_fy_code.py
------------------------------------开始处理逻辑------------------------------------------


-- 建表 pdm.account_fy_code
-- drop table if exists pdm.account_fy_code;
-- create table if not exists pdm.account_fy_code(
--     code_account varchar(20) comment '费用科目编码1',
--     ccode_name varchar(20) comment '费用科目名称1',
--     code_account_2 varchar(20) comment '费用科目编码2',
--     ccode_name_2 varchar(20) comment '费用科目名称2',
--     code_account_3 varchar(20) comment '费用科目编码3',
--     ccode_name_3 varchar(20) comment '费用科目名称3',
--     key index_account_fy_code_code_account (code_account),
--     key index_account_fy_code_code_account_2 (code_account_2),
--     key index_account_fy_code_code_account_3 (code_account_3)
-- ) engine=innodb default charset=utf8 comment='费用科目表';


-- 建临时表1 提取所有科目编码 非甄元账套
drop temporary table if exists pdm.mid1_account_fy_code;
create temporary table if not exists pdm.mid1_account_fy_code
select code as code_account
  from pdm.account_fy 
 where left(db,10) != "UFDATA_007"
   and status = '取'
   and dbill_date >= '2019-01-01' 
 group by code 
union  
select u8_code as code_account 
  from edw.x_expenses_budget_19
 where amount_budget !="" 
   and amount_budget is not null
   and u8_code is not null
 group by u8_code 
union 
select u8_code as code_account 
  from edw.x_expenses_budget_19
 where u8_code is not null
group by u8_code
;

-- 建临时表2 提取所有科目编码 甄元账套
drop temporary table if exists pdm.mid2_account_fy_code;
create temporary table if not exists pdm.mid2_account_fy_code
select code as code_account
  from pdm.account_fy 
 where left(db,10) = "UFDATA_007"
   and status = '取'
   and dbill_date >= '2019-01-01' 
 group by code 
;


truncate table pdm.account_fy_code;
-- 导入正式表  甄元账套
insert into pdm.account_fy_code
select a.code_account 
      ,case 
          when a.code_account = "640110" then "人员成本"
          else b.ccode_name 
          end as ccode_name -- 640110  是启代库的人员成本数据
      ,left(a.code_account,8) as code_account_2 
      ,case 
          when a.code_account = "640110" then "人员成本"
          else c.ccode_name 
          end as ccode_name_2 -- 640110  是启代库的人员成本数据
      ,left(a.code_account,4) as code_account_3 
      ,d.ccode_name as ccode_name_3
  from pdm.mid2_account_fy_code as a 
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_007_2019"
              group by ccode) as b 
    on a.code_account = b.ccode
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_007_2019"
              group by ccode) as c 
    on left(a.code_account,8) = c.ccode
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_007_2019"
              group by ccode) as d
    on left(a.code_account,4) = d.ccode
  ;


-- 导入正式表  非甄元账套
replace into pdm.account_fy_code
select 
    a.code_account 
    ,case 
        when a.code_account = "640110" then "人员成本"
        else b.ccode_name 
        end as ccode_name -- 640110  是启代库的人员成本数据
    ,left(a.code_account,6) as code_account_2 
    ,case 
        when a.code_account = "640110" then "人员成本"
        else c.ccode_name 
        end as ccode_name_2 -- 640110  是启代库的人员成本数据
    ,left(a.code_account,4) as code_account_3 
    ,d.ccode_name as ccode_name_3
  from pdm.mid1_account_fy_code as a 
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_111_2018"
              group by ccode) as b 
    on a.code_account = b.ccode
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_111_2018"
              group by ccode) as c 
    on left(a.code_account,6) = c.ccode
  left join (select ccode,ccode_name 
               from ufdata.code
              where iyear = "2019"
                and db = "UFDATA_111_2018"
              group by ccode) as d 
    on left(a.code_account,4) = d.ccode
;

-- 当费用科目无法在第一层费用表中找到对应时，改名称为其他
update pdm.account_fy_code
set ccode_name = "其他" where ccode_name is null;

update pdm.account_fy_code
set ccode_name_2 = "其他" where ccode_name_2 is null;


