-- 31_dt_22_code_account

/*
-- 建表 bidata.dt_22_code_account
use bidata;
drop table if exists bidata.dt_22_code_account;
create table if not exists bidata.dt_22_code_account(
    code_account varchar(20) comment '费用科目编码1',
    ccode_name varchar(20) comment '费用科目名称1',
    code_account_2 varchar(20) comment '费用科目编码2',
    ccode_name_2 varchar(20) comment '费用科目名称2',
    code_account_3 varchar(20) comment '费用科目编码3',
    ccode_name_3 varchar(20) comment '费用科目名称3',
    key bidata_dt_22_code_account_code_account (code_account),
    key bidata_dt_22_code_account_code_account_2 (code_account_2),
    key bidata_dt_22_code_account_code_account_3 (code_account_3)
) engine=innodb default charset=utf8 comment='bi费用科目表';
 */


-- 建临时表1 提取所有科目编码 非甄元账套
drop temporary table if exists bidata.expenses_tem01;
create temporary table if not exists bidata.expenses_tem01
select 
    code as code_account
from bidata.ft_81_expenses 
where left(db,10) != "UFDATA_007"
group by code 
union 
-- select 
--     u8kemubm as code_account
-- from bidata.ft_82_expenses_budget_oa
-- group by u8kemubm
-- union 
select 
    u8_code as code_account 
from bidata.ft_82_expenses_budget_x 
where u8_code is not null
group by u8_code 
union 
select 
    code as code_account 
from bidata.ft_81_expenses_x 
where code is not null
group by code
;

-- 建临时表2 提取所有科目编码 甄元账套
drop temporary table if exists bidata.expenses_tem02;
create temporary table if not exists bidata.expenses_tem02
select 
    code as code_account
from bidata.ft_81_expenses 
where left(db,10) = "UFDATA_007"
group by code 
;

-- 导入正式表  非甄元账套
truncate table bidata.dt_22_code_account;
insert into bidata.dt_22_code_account
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
from bidata.expenses_tem01 as a 
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_111_2018"
group by ccode) as b 
on a.code_account = b.ccode
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_111_2018"
group by ccode) as c 
on left(a.code_account,6) = c.ccode
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_111_2018"
group by ccode) as d
on left(a.code_account,4) = d.ccode
;

-- 甄元账套
insert into bidata.dt_22_code_account
select 
    a.code_account 
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
from bidata.expenses_tem02 as a 
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_007_2019"
group by ccode) as b 
on a.code_account = b.ccode
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_007_2019"
group by ccode) as c 
on left(a.code_account,8) = c.ccode
left join 
(select 
ccode
,ccode_name 
from ufdata.code
where iyear = "2019"
and db = "UFDATA_007_2019"
group by ccode) as d
on left(a.code_account,4) = d.ccode
;