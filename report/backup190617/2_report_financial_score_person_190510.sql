
-- 省区财务绩效模板用_1

-- 声明变量
set @dt_start = "2019-01-01";
set @dt_end = "2019-03-31";

-- 处理客户项目人 匹配大区，省份信息
drop temporary table if exists report.cusitemperson;
create temporary table if not exists report.cusitemperson
select 
    a.person_name 
    ,b.sales_region
    ,b.province 
from report.financial_sales_person as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where a.person_name != "noperson"
group by a.person_name;

-- 处理map_item 生成是否重点项目（绩效考核分用） 
drop temporary table if exists report.score_item_tem;
create temporary table if not exists report.score_item_tem
select 
    item_code 
    ,equipment
    ,case 
        when item_key in ("血清学筛查","NIPT","CMA","CNV-seq","MSMS","代谢病诊断") then "是"
        else "否"
        end as item_key_score
from edw.map_item; 
alter table report.score_item_tem add index index_score_item_tem_item_code (item_code);

-- 提取所有人名信息 是否设备 是否重点项目
drop temporary table if exists report.person_name_tem;
create temporary table if not exists report.person_name_tem
select 
    a.person_name 
    ,b.equipment
    ,b.item_key_score
from report.financial_sales_person as a 
left join report.score_item_tem as b 
on a.item_code = b.item_code 
group by a.person_name,b.equipment,b.item_key_score;
alter table report.person_name_tem add index index_person_name_tem_person_name (person_name);

-- 日期间隔内 实际收入 与 计划收入
drop temporary table if exists report.score_tem01;
create temporary table if not exists report.score_tem01
select 
    @dt_start as dt_start
    ,@dt_end as dt_end
    ,a.person_name
    ,b.equipment
    ,b.item_key_score
    ,sum(a.isum) as isum
    ,sum(a.isum_budget) as isum_budget
from report.financial_sales_person as a 
left join report.score_item_tem as b 
on a.item_code = b.item_code 
where a.ddate >= @dt_start and a.ddate <= @dt_end 
group by a.person_name,b.equipment,b.item_key_score;
alter table report.score_tem01 add index index_score_tem01_person_name (person_name);

-- 当月 实际收入 与 计划收入 
drop temporary table if exists report.score_tem02;
create temporary table if not exists report.score_tem02
select 
    @dt_end as dt_end
    ,a.person_name
    ,b.equipment
    ,b.item_key_score
    ,sum(a.isum) as isum_mon
    ,sum(a.isum_budget) as isum_budget_mon
from report.financial_sales_person as a 
left join report.score_item_tem as b 
on a.item_code = b.item_code 
where year(a.ddate) = year(@dt_end) and month(a.ddate) = month(@dt_end) 
group by a.person_name,b.equipment,b.item_key_score;
alter table report.score_tem02 add index index_score_tem02_person_name (person_name);

-- 去年同期 实际收入 月 计划收入 
drop temporary table if exists report.score_tem03;
create temporary table if not exists report.score_tem03
select 
    date_add(@dt_start,interval -1 year) as dt_start
    ,date_add(@dt_end,interval -1 year) as dt_end
    ,a.person_name
    ,b.equipment
    ,b.item_key_score
    ,sum(a.isum) as isum_lastyear
    ,sum(a.isum_budget) as isum_budget_lastyear
from report.financial_sales_person as a 
left join report.score_item_tem as b 
on a.item_code = b.item_code 
where a.ddate >= date_add(@dt_start,interval -1 year) and a.ddate <= date_add(@dt_end,interval -1 year)
group by a.person_name,b.equipment,b.item_key_score;
alter table report.score_tem03 add index index_score_tem03_person_name (person_name);

-- 组合以上数据 
drop table if exists report.score_person_1;
create table if not exists report.score_person_1
select 
    b.dt_start
    ,b.dt_end 
    ,f.sales_region
    ,f.province
    ,a.person_name
    ,a.equipment
    ,a.item_key_score
    ,e.position_name
    ,e.jobpost_name
    ,e.employeestatus
    ,e.lastworkdate
    ,c.isum_mon
    ,b.isum 
    ,b.isum_budget
    ,d.isum_lastyear
    ,d.isum_budget_lastyear
from report.person_name_tem as a 
left join report.score_tem01 as b 
on a.person_name = b.person_name and a.equipment = b.equipment and a.item_key_score = b.item_key_score
left join report.score_tem02 as c 
on a.person_name = c.person_name and a.equipment = c.equipment and a.item_key_score = c.item_key_score
left join report.score_tem03 as d 
on a.person_name = d.person_name and a.equipment = d.equipment and a.item_key_score = d.item_key_score
left join (select name,position_name,jobpost_name,employeestatus,lastworkdate from bidata.dt_15_person_ehr group by name) as e
on a.person_name = e.name
left join report.cusitemperson as f 
on a.person_name = f.person_name;

-- 计算 回款数据 与 费用数据 

-- 临时表4 用于计算回款考核分
drop temporary table if exists report.bonus_tem04;
create temporary table if not exists report.bonus_tem04
select 
    @dt_end as dt_start
    ,@dt_end as dt_end
    ,cpersonname as person_name
    ,sum(amount_plan) as amount_plan
    ,sum(amount_act) as amount_act
from bidata.ft_52_ar_plan
-- where ddate >= @dt_start and ddate <= @dt_end 
where year(ddate) = year(@dt_end) and month(ddate) = month(@dt_end)
group by cpersonname;

insert into report.bonus_tem04
select 
    @dt_end as dt_start
    ,@dt_end as dt_end
    ,b.poidempadmin as person_name
    ,sum(amount_plan) as amount_plan
    ,sum(amount_act) as amount_act
from bidata.ft_52_ar_plan as a 
left join (select name,poidempadmin,position_name,jobpost_name,employeestatus,lastworkdate from bidata.dt_15_person_ehr group by name) as b
on a.cpersonname  = b.name 
-- where ddate >= @dt_start and ddate <= @dt_end 
where year(ddate) = year(@dt_end) and month(ddate) = month(@dt_end)
group by b.poidempadmin;

-- 导入临时表  用于计算回款考核分
drop temporary table if exists report.bonus_tem04_;
create temporary table if not exists report.bonus_tem04_
select 
    a.dt_start
    ,a.dt_end
    ,a.person_name
    ,sum(amount_act) as amount_act
    ,sum(amount_plan) as amount_plan
--     ,if(a.isum_budget = 0,1,a.isum/a.isum_budget) as rate_com
    ,b.position_name
    ,b.jobpost_name
    ,b.employeestatus
    ,b.lastworkdate
from report.bonus_tem04 as a 
left join (select name,position_name,jobpost_name,employeestatus,lastworkdate from bidata.dt_15_person_ehr group by name) as b
on a.person_name = b.name
group by a.person_name;

-- 临时表5 用于计算费用考核分
-- 来源 edw.oa_budget_19 人取person字段 科目取name字段 取"6601业务招待费","6601交通费（其他）"
drop temporary table if exists report.bonus_tem05;
create temporary table if not exists report.bonus_tem05
select 
    @dt_start as dt_start
    ,@dt_end as dt_end
    ,cast(name as char(100)) as code_name 
    ,cast(person as char(100)) as person_name 
    ,sum(budgetaccount) as budgetaccount
    ,cast(0 as DECIMAL(10,2)) as md
from edw.oa_budget_19 
where budgetperiodslist >= month(@dt_start) and budgetperiodslist <= month(@dt_end)
and name in ("6601业务招待费","6601交通费（其他）")
group by name,person;
-- 来源 pdm.account_fy_mon 人取 cpersonname 字段 科目取 u8_code_name_lv2 字段 取"业务招待费","差旅费"
insert into report.bonus_tem05
select 
    @dt_start as dt_start
    ,@dt_end as dt_end
    ,cast(u8_code_name_lv2 as char(100)) as code_name 
    ,cast(cpersonname as char(100)) as person_name
    ,0 as budgetaccount
    ,sum(md) as md 
from pdm.account_fy_mon
where dbill_date >= @dt_start and dbill_date <= @dt_end 
and u8_code_name_lv2 in ("业务招待费","差旅费")
group by u8_code_name_lv2,cpersonname; 

-- 导入临时表 用于计算费用考核费 
drop temporary table if exists report.bonus_tem05_;
create temporary table if not exists report.bonus_tem05_
select 
    a.dt_start
    ,a.dt_end
    ,a.person_name
    ,sum(md) as md
    ,sum(budgetaccount) as budgetaccount
    ,b.position_name
    ,b.jobpost_name
    ,b.employeestatus
    ,b.lastworkdate
from report.bonus_tem05 as a 
left join (select name,position_name,jobpost_name,employeestatus,lastworkdate from bidata.dt_15_person_ehr group by name) as b
on a.person_name = b.name
group by a.person_name;

-- 组合以上数据 
drop table if exists report.score_person_2;
create table if not exists report.score_person_2
select 
    b.dt_start
    ,b.dt_end 
    ,f.sales_region
    ,f.province
    ,a.person_name
    ,e.position_name
    ,e.jobpost_name
    ,e.employeestatus
    ,e.lastworkdate
    ,b.amount_act as amount_act
    ,b.amount_plan as amount_plan
    ,c.md as md
    ,c.budgetaccount as budgetaccount
from (select person_name from report.person_name_tem group by person_name)as a 
left join report.bonus_tem04_ as b 
on a.person_name = b.person_name 
left join report.bonus_tem05_ as c 
on a.person_name = c.person_name
left join (select name,position_name,jobpost_name,employeestatus,lastworkdate from bidata.dt_15_person_ehr group by name) as e
on a.person_name = e.name
left join report.cusitemperson as f 
on a.person_name = f.person_name;


