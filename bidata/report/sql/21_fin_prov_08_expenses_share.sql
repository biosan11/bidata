/*
drop table if exists report.fin_prov_08_expenses_share;
create table if not exists report.fin_prov_08_expenses_share (
    `fy_share_mk2` varchar(30) default null,
    `fy_share_mk3` varchar(30) default null,
    `province_confirm` varchar(60) default null,
    `mark_insert` varchar(20) default null,
    `act_budget` varchar(20) default null,
    `year_` smallint(20) default null,
    `month_` smallint(20) default null,
    `name_ehr_id` varchar(60) default null,
    `second_dept` varchar(120) default null,
    `third_dept` varchar(120) default null,
    `fourth_dept` varchar(120) default null,
    `fifth_dept` varchar(120) default null,
    `province` varchar(60) default null,
    `second_dept_old` varchar(120) default null,
    `third_dept_old` varchar(120) default null,
    `fourth_dept_old` varchar(120) default null,
    `fifth_dept_old` varchar(120) default null,
    `province_old` varchar(60) default null,
    `code` varchar(60) default null,
    `ccode_name` varchar(20) default null,
    `ccode_name_2` varchar(20) default null,
    `ccode_name_3` varchar(20) default null,
    `md` double default null,
    `amount_budget` float(14,5) default null,
    `fy_share_m1` varchar(60) default null,
    `name_ehr_id2` varchar(80) default null,
key `index_report_fin_prov_08_expenses_share_province_confirm` (`province_confirm`),
key `index_report_fin_prov_08_expenses_share_name_ehr_id` (`name_ehr_id`),
key `index_report_fin_prov_08_expenses_share_year_` (`year_`),
key `index_report_fin_prov_08_expenses_share_month_` (`month_`),
key `index_report_fin_prov_08_expenses_share_name_ehr_id2` (`name_ehr_id2`),
key `index_report_fin_prov_08_expenses_share_fy_share_m1` (`fy_share_m1`)
) engine=innodb default charset=utf8;
*/



-- 1.只取营销中心费用（省区直接费用+营销中心内费用分摊）
drop temporary table if exists report.fin_prov_08_expenses_tem11;
create temporary table if not exists report.fin_prov_08_expenses_tem11
select 
    case 
        when year_ = 2018 and fy_share_m1 is not null and substring_index(fy_share_m1,"-",1) = "其他" then null -- 2018年时 公卫、市场部数据 能直接区分省份
        when year_ = 2018 and fy_share_m1 is not null then substring_index(fy_share_m1,"-",1) -- 2018年时 公卫、市场部数据 能直接区分省份
        when year_ = 2018 then province_old
        when year_ = 2019 and fy_share_m1 is not null then left(fy_share_m1,4) -- 2019年 市场与公卫数据 能分到大区
        when year_ = 2019 and month_ <= 7 then province_old
        else province 
    end as province_confirm
    ,cast("ori" as char(20)) as mark_insert
    ,act_budget
    ,year_
    ,month_
    ,name_ehr_id
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,province
    ,second_dept_old
    ,third_dept_old
    ,fourth_dept_old
    ,fifth_dept_old
    ,province_old
    ,code
    ,ccode_name
    ,ccode_name_2
    ,ccode_name_3
    ,md
    ,amount_budget
    ,fy_share_m1
    ,name_ehr_id2
from report.fin_prov_08_expense_base
where (second_dept = "营销中心" or second_dept_old = "营销中心" )
;
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_province_confirm (province_confirm);
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_name_ehr_id (name_ehr_id);
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_year_ (year_);
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_month_ (month_);
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_name_ehr_id2 (name_ehr_id2);
alter table report.fin_prov_08_expenses_tem11 add index index_report_fin_prov_08_expenses_tem11_fy_share_m1 (fy_share_m1);

-- alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_dbill_date (dbill_date);

-- 2.设置标签以及其他标记字段
truncate table report.fin_prov_08_expenses_share;
insert into report.fin_prov_08_expenses_share
select 
    cast(
    case 
        when province_confirm is not null and left(province_confirm,2) != "销售" then "fy_province"  -- 颗粒度 到省份的费用 省份字段用 province_confirm
        when province_confirm is not null and left(province_confirm,2) = "销售" then "fy_salesregion" -- 颗粒度 到大区的费用 （只有销售三、四、五、六区）
        when name_ehr_id2 = "A待定销售二区" then "fy_salesregion" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售三区" then "fy_salesregion" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售四区" then "fy_salesregion" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售五区" then "fy_salesregion" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售六区" then "fy_salesregion" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售八区" then "fy_salesregion" -- A待定 到大区部分
        when year_ = 2018 and left(fourth_dept_old,2) = "销售" then "fy_salesregion"
        when year_ = 2019 and month_ <= 7 and left(fourth_dept_old,2) = "销售" then "fy_salesregion"
        when year_ = 2019 and month_ >= 8 and left(fourth_dept,2) = "销售" then "fy_salesregion"
        when year_ = 2019 and month_ >= 8 and left(third_dept,2) = "销售" then "fy_salesdept"
        else "fy_yxzx"
    end as char(30) ) as fy_share_mk2
    ,cast(
    case 
        when province_confirm is not null and left(province_confirm,2) != "销售" then null 
        when province_confirm is not null and left(province_confirm,2) = "销售" then province_confirm
        when name_ehr_id2 = "A待定销售二区" then "销售二区" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售三区" then "销售三区" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售四区" then "销售四区" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售五区" then "销售五区" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售六区" then "销售六区" -- A待定 到大区部分
        when name_ehr_id2 = "A待定销售八区" then "销售八区" -- A待定 到大区部分
        when year_ = 2018 and left(fourth_dept_old,2) = "销售" then fourth_dept_old
        when year_ = 2019 and month_ <= 7 and left(fourth_dept_old,2) = "销售" then fourth_dept_old
        when year_ = 2019 and month_ >= 8 and left(fourth_dept,2) = "销售" then fourth_dept
        when year_ = 2019 and month_ >= 8 and left(third_dept,2) = "销售" then third_dept
        else "fy_yxzx"
    end as char(30) ) as fy_share_mk3
    ,province_confirm
    ,mark_insert
    ,act_budget
    ,year_
    ,month_
    ,name_ehr_id
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,province
    ,second_dept_old
    ,third_dept_old
    ,fourth_dept_old
    ,fifth_dept_old
    ,province_old
    ,code
    ,ccode_name
    ,ccode_name_2
    ,ccode_name_3
    ,md
    ,amount_budget
    ,fy_share_m1
    ,name_ehr_id2
from report.fin_prov_08_expenses_tem11;
