-- report.fin_prov_08_expenses_base
/*
drop table if exists report.fin_prov_08_expense_base;
CREATE TABLE if not exists report.fin_prov_08_expense_base (
  `act_budget` varchar(20) ,
  `year_` int(20) DEFAULT NULL,
  `month_` int(20) DEFAULT NULL,
  `dept_share` varchar(60) DEFAULT NULL,
  `name_ehr_id` varchar(60) DEFAULT NULL,
  `second_dept` varchar(120) DEFAULT NULL,
  `third_dept` varchar(120) DEFAULT NULL,
  `fourth_dept` varchar(120) DEFAULT NULL,
  `fifth_dept` varchar(120) DEFAULT NULL,
  `province` varchar(60),
  `second_dept_old` varchar(120) DEFAULT NULL,
  `third_dept_old` varchar(120) DEFAULT NULL,
  `fourth_dept_old` varchar(120) DEFAULT NULL,
  `fifth_dept_old` varchar(120) DEFAULT NULL,
  `province_old` varchar(60),
  `code` varchar(60) DEFAULT NULL,
  `ccode_name` varchar(20) DEFAULT NULL,
  `ccode_name_2` varchar(20) DEFAULT NULL,
  `ccode_name_3` varchar(20) DEFAULT NULL,
  `md` double DEFAULT NULL,
  `amount_budget` float(14,5) DEFAULT NULL,
  `fy_share_m1` varchar(60),
  `name_ehr_id2` varchar(80) DEFAULT NULL,
KEY `report_fin_prov_08_expense_base_year_` (`year_`),
KEY `report_fin_prov_08_expense_base_month_` (`month_`),
KEY `report_ft_fin_prov_08_expense_base_name_ehr_id` (`name_ehr_id`),
KEY `report_ft_fin_prov_08_expense_base_name_ehr_id2` (`name_ehr_id2`),
KEY `report_fin_prov_08_expense_base_code` (`code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;
*/


-- 1. 费用基础数据（市场、公卫用之前的架构，为了费用分摊）
drop temporary table if exists report.fin_prov_ex001;
create temporary table if not exists report.fin_prov_ex001
select 
	db
    ,cohr
    ,dbill_date
    ,ccuscode
    ,name_ehr_id
    ,code
    ,md
    ,fy_share_m1
    ,concat(ifnull(fy_share_m1,""),name_ehr_id) as name_ehr_id2
from bidata.ft_81_expenses;
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_dbill_date (dbill_date);
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_name_ehr_id (name_ehr_id);
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_code (code);
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_name_ehr_id2(name_ehr_id2);

-- 2. 根据年月 部门id（新） 科目code 分组 加入预算费用数据 
truncate report.fin_prov_08_expense_base;
insert into report.fin_prov_08_expense_base
select 
    "act" as act_budget
    ,year(a.dbill_date) as year_
    ,month(a.dbill_date) as month_
    ,case 
        when b.second_dept = "营销中心" then "营销中心"
        when b.second_dept = "启代医疗中心" then "启代"
        when b.third_dept = "供应链中心" then "供应链中心"
        when b.third_dept = "技术保障中心" then "技术保障中心"
        when b.third_dept = "信息中心" then "信息中心"
        when b.third_dept = "杭州贝生" then "杭州贝生"
        when b.fourth_dept = "400客服部" then "400客服部"
        else "其他待分摊部门"
    end
    ,a.name_ehr_id
    ,b.second_dept
    ,b.third_dept
    ,b.fourth_dept
    ,b.fifth_dept
    ,b.province 
    ,d.second_dept as second_dept_old
    ,d.third_dept as third_dept_old
    ,d.fourth_dept as fourth_dept_old
    ,d.fifth_dept as fifth_dept_old
    ,d.province as province_old
    ,a.code 
    ,c.ccode_name
    ,c.ccode_name_2
    ,c.ccode_name_3 
    ,sum(a.md) as md
    ,0 as amount_budget
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_ex001 as a 
left join bidata.dt_21_deptment as b 
on a.name_ehr_id = b.cdept_id_ehr
left join bidata.dt_22_code_account as c 
on a.code = c.code_account
left join bidata.dt_21_deptment_old as d 
on a.name_ehr_id = d.cdept_id_ehr
where year(a.dbill_date) >= 2018
and cohr != "杭州贝生"
group by 
    year(a.dbill_date)
    ,month(a.dbill_date)
    ,a.name_ehr_id2
    ,a.code
    
union all 

select 
    "budget" as act_budget
    ,year(a.ddate) as year_
    ,month(a.ddate) as month_
    ,case 
        when b.second_dept = "营销中心" then "营销中心"
        when b.second_dept = "启代医疗中心" then "启代"
        when b.third_dept = "供应链中心" then "供应链中心"
        when b.third_dept = "技术保障中心" then "技术保障中心"
        when b.third_dept = "信息中心" then "信息中心"
        when b.third_dept = "杭州贝生" then "杭州贝生"
        when b.fourth_dept = "400客服部" then "400客服部"
        else "其他待分摊部门"
    end
    ,a.cdept_id_ehr
    ,b.second_dept
    ,b.third_dept
    ,b.fourth_dept
    ,b.fifth_dept
    ,b.province
    ,d.second_dept as second_dept_old
    ,d.third_dept as third_dept_old
    ,d.fourth_dept as fourth_dept_old
    ,d.fifth_dept as fifth_dept_old
    ,d.province
    ,a.u8_code 
    ,c.ccode_name
    ,c.ccode_name_2
    ,c.ccode_name_3 
    ,0 as md 
	,sum(a.amount_budget) as amount_budget
    ,null 
    ,null
from bidata.ft_82_expenses_budget_x as a 
left join bidata.dt_21_deptment as b 
on a.cdept_id_ehr = b.cdept_id_ehr
left join bidata.dt_22_code_account as c 
on a.u8_code = c.code_account
left join bidata.dt_21_deptment_old as d 
on a.cdept_id_ehr = d.cdept_id_ehr
where year(a.ddate) >= 2018
and cohr != "杭州贝生"
group by 
    year(a.ddate)
    ,month(a.ddate)
    ,a.cdept_id_ehr
    ,a.u8_code;