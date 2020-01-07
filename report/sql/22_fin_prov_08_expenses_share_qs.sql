-- 开始费用分摊
truncate table report.fin_prov_08_expenses_share_qs;
-- 将七省一市的直接费用 导入 (不取健康保险费)
insert into report.fin_prov_08_expenses_share_qs
select * from report.fin_prov_08_expenses_share 
where fy_share_mk2 = "fy_province";
-- and province_confirm in ("浙江省","江苏省","安徽省","福建省","湖南省","湖北省","山东省","上海市")
-- and ccode_name != "健康保险费";


-- 2019年8月之前的架构
insert into report.fin_prov_08_expenses_share_qs
select 
    "insert_dq"
    ,a.fy_share_mk3
    ,b.province_
    ,"insert"
    ,a.act_budget
    ,a.year_
    ,a.month_
    ,a.name_ehr_id
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.province
    ,a.second_dept_old
    ,a.third_dept_old
    ,a.fourth_dept_old
    ,a.fifth_dept_old
    ,a.province_old
    ,a.code
    ,a.ccode_name
    ,a.ccode_name_2
    ,a.ccode_name_3
    ,(a.md * ifnull(b.per_salesregion,1))
    ,(a.amount_budget * ifnull(b.per_salesregion,1))
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_08_expenses_share as a 
left join report.auxi_01_province_per as b
on a.year_ = b.year_ and a.month_ = b.month_ and a.fy_share_mk3 = b.sales_region
where a.fy_share_mk2 = "fy_salesregion";
-- and ccode_name != "健康保险费";;
-- and (a.year_ = 2018 or (a.year_ = 2019 and a.month_ <= 7))
-- and a.fy_share_mk3 in ("销售三区","销售四区","销售五区","销售六区","销售八区");

update report.fin_prov_08_expenses_share_qs set province_confirm = "上海市" 
where province_confirm is null 
and fy_share_mk3 = "销售八区"
and (year_ = 2018 or (year_ = 2019 and month_ <= 7));

-- 2019年8月之后的架构, 到销售部门的费用分摊
insert into report.fin_prov_08_expenses_share_qs
select 
    "insert_salesdept"
    ,a.fy_share_mk3
    ,b.province_
    ,"insert"
    ,a.act_budget
    ,a.year_
    ,a.month_
    ,a.name_ehr_id
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.province
    ,a.second_dept_old
    ,a.third_dept_old
    ,a.fourth_dept_old
    ,a.fifth_dept_old
    ,a.province_old
    ,a.code
    ,a.ccode_name
    ,a.ccode_name_2
    ,a.ccode_name_3
    ,(a.md * ifnull(b.per_dept,1))
    ,(a.amount_budget * ifnull(b.per_dept,1))
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_08_expenses_share as a 
left join report.auxi_01_province_per as b
on a.year_ = b.year_ and a.month_ = b.month_ and a.fy_share_mk3 = b.sales_dept
where a.fy_share_mk2 = "fy_salesdept";



insert into report.fin_prov_08_expenses_share_qs
select 
    "insert_yxzx"
    ,a.fy_share_mk3
    ,b.province_
    ,"insert"
    ,a.act_budget
    ,a.year_
    ,a.month_
    ,a.name_ehr_id
    ,a.second_dept
    ,a.third_dept
    ,a.fourth_dept
    ,a.fifth_dept
    ,a.province
    ,a.second_dept_old
    ,a.third_dept_old
    ,a.fourth_dept_old
    ,a.fifth_dept_old
    ,a.province_old
    ,a.code
    ,a.ccode_name
    ,a.ccode_name_2
    ,a.ccode_name_3
    ,(a.md * ifnull(b.per_allexcepthzbs,1))
    ,(a.amount_budget * ifnull(b.per_allexcepthzbs,1))
    ,a.fy_share_m1
    ,a.name_ehr_id2
from report.fin_prov_08_expenses_share as a 
left join (select year_, month_, province_, per_allexcepthzbs from  report.auxi_01_province_per where province_ != "杭州贝生")as b
on a.year_ = b.year_ and a.month_ = b.month_
where a.fy_share_mk2 = "fy_yxzx";
-- and ccode_name != "健康保险费";
-- and (a.year_ = 2018 or (a.year_ = 2019 and a.month_ <= 7))
;

-- 导入聚合数据 
truncate table report.fin_prov_08_expenses_share_qs_groupby;
insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province_confirm
    ,year_
    ,month_
    ,ccode_name_2
    ,sum(md)
    ,sum(amount_budget)
from report.fin_prov_08_expenses_share_qs 
group by province_confirm,year_,month_,ccode_name_2;

-- 需要删掉 线下实验员  线下保险费用 
insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province
    ,year_
    ,month_
    ,"人员成本"
    ,-1 * sy_md
    ,0
from report.fin_prov_11_expenses_fw 
where sy_md != 0
 and (year_ = 2018 or (year_ = 2019 and month_ < 9))
;

insert into report.fin_prov_08_expenses_share_qs_groupby
select 
    province
    ,year_
    ,month_
    ,"健康保险费"
    ,-1 * bx_md
    ,0
from report.fin_prov_11_expenses_fw
where bx_md != 0;