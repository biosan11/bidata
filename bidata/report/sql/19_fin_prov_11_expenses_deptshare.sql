/*
drop table if exists report.fin_prov_11_expenses_deptshare;
create table if not exists report.fin_prov_11_expenses_deptshare (
  `year_` smallint ,
  `month_` smallint ,
  `dept_share` varchar(40) comment '部门名称',
  `code` varchar(20) comment '科目',
  `province` varchar(60) default null comment '销售省份',
  `md_share` float(13,4) default null
) engine=innodb default charset=utf8 comment '其他部门间接销售费用分摊表';
*/



-- 



truncate table report.fin_prov_11_expenses_deptshare;
insert into report.fin_prov_11_expenses_deptshare
select 
    left(a.y_mon,4) as year_
    ,right(a.y_mon,2) as month_
    ,a.dept_name 
    ,null
    ,b.province
    ,sum(a.cc_md + a.zx_md ) as md_share 
from report.fin_prov_10_expense_all as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where a.cohr != "hzbs"
group by y_mon,b.province,a.dept_name;