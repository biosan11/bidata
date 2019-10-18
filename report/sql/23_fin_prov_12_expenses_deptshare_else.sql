/*
drop table if exists report.fin_prov_12_expenses_deptshare_else;
create table if not exists report.fin_prov_12_expenses_deptshare_else (
  `year_` int(20) default null,
  `month_` int(20) default null,
  `dept_share` varchar(60) default null,
  `code` varchar(60) default null,
  `province_` varchar(60) default null,
  `md_share` double default null
) engine=innodb default charset=utf8 comment'部门费用分摊表';
*/


-- report_fin_prov_12_expenses_deptshare_else
truncate table report.fin_prov_12_expenses_deptshare_else;
insert into report.fin_prov_12_expenses_deptshare_else
select 
    a.year_
    ,a.month_ 
    ,a.dept_share
    ,a.code
    ,b.province_ 
    ,a.md*ifnull(b.per_all,1) as md_share
from 
    (
    select 
        year_
        ,month_
        ,dept_share
        ,code
        ,sum(md) as md 
    from report.fin_prov_08_expense_base
    group by year_,month_,dept_share,code
    ) as a 
left join report.auxi_01_province_per as b 
on a.year_ = b.year_ and a.month_ = b.month_ ;