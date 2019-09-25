--


-- 处理人员

-- 取出所有主管+销售 里面有大部分是一对多 （一个主管对应多个销售） 有部分多对多（多个主管对应多个销售）需要再进一步处理
drop temporary table if exists report.oper_tem01;
create temporary table if not exists report.oper_tem01
select 
    p_sales_spe
    ,p_sales_sup 
from report.fin_12_salesbudget_person_post
where p_sales_sup is not null and p_sales_spe is not null 
group by p_sales_sup,p_sales_spe;

-- 取出多个销售对应多个主管 的  销售数据  这几个销售 通过ehr数据 匹配主管
drop temporary table if exists report.oper_tem02;
create temporary table if not exists report.oper_tem02
select 
	a.p_sales_spe 
    ,b.poidempadmin as p_sales_sup
    ,b.jobpost_name
from report.oper_tem01 as a 
left join bidata.dt_15_person_ehr as b 
on a.p_sales_spe = b.name
where p_sales_spe is not null
group by p_sales_spe
having count(*) >1;

-- 生成对应关系
drop temporary table if exists report.oper_tem03;
create temporary table if not exists report.oper_tem03
-- 取一对多的数据 
select 
	a.p_sales_spe
    ,case -- 如果职位是主管，那么对应主管是自己
		when b.jobpost_name = "主管" then a.p_sales_spe
        else a.p_sales_sup 
	end as p_sales_sup
    ,b.jobpost_name
    ,cast("one_to_many" as char(20)) as mark
from report.oper_tem01 as a 
left join bidata.dt_15_person_ehr as b 
on a.p_sales_spe = b.name
where a.p_sales_spe not in (select p_sales_spe from report.oper_tem02);

insert into report.oper_tem03 
select 
	p_sales_spe
	,case -- 如果职位是主管，那么对应主管是自己
		when jobpost_name = "主管" then p_sales_spe
        else p_sales_sup 
	end as p_sales_sup
    ,jobpost_name
    ,"many_to_many" as mark 
from report.oper_tem02;


-- 取纯主管数据 对应主管  是自己  
drop temporary table if exists report.oper_tem04;
create temporary table if not exists report.oper_tem04
select 
    a.p_sales_sup as p_sales_spe
    ,a.p_sales_sup 
    ,b.jobpost_name
    ,"sup_only" as mark 
from report.fin_12_salesbudget_person_post as a 
left join bidata.dt_15_person_ehr as b 
on a.p_sales_sup = b.name 
where a.p_sales_sup not in (select p_sales_spe from report.oper_tem03 )
group by a.p_sales_sup;

-- 加入 上述03临时表  处理费用 销售 上级主管 时 会用到这个03临时表
insert into report.oper_tem03
select 
	p_sales_spe
    ,p_sales_sup 
    ,jobpost_name
    ,mark 
from report.oper_tem04;

-- 生成一个 人员  对应省份的 数据
drop temporary table if exists report.oper_tem05;
create temporary table if not exists report.oper_tem05
select 
	aa.cpersonname
    ,aa.province
from 
	(
	select 
		a.p_sales_spe as cpersonname
		,b.province
	from report.fin_12_salesbudget_person_post as a 
	left join edw.map_customer as b 
	on a.ccuscode = b.bi_cuscode
	where a.p_sales_spe is not null
	group by a.p_sales_spe,b.province

	union all 
	select 
		p_sales_sup as cpersonname
		,b.province
	from report.fin_12_salesbudget_person_post as a 
	left join edw.map_customer as b 
	on a.ccuscode = b.bi_cuscode
	where a.p_sales_sup is not null
	group by a.p_sales_sup,b.province
	) as aa
group by aa.cpersonname
;


-- 生成向下叠加的数据  
truncate table report.operation_03_sales_person;
insert into report.operation_03_sales_person
select -- 加入收入、成本、折旧数据
    year(ddate) as year_
    ,month(ddate) as month_ 
    ,p_sales_sup as p_sales_sup
    ,p_sales_spe as p_sales_spe
    ,sum(isum) as isum 
    ,sum(itax) as itax 
    ,sum(isum) - sum(itax) as isum_notax 
    ,sum(cost_notax) as cost_notax
    ,sum(amount_depre) as amount_depre
    ,0 as md 
from report.fin_12_salesbudget_person_post a
group by year_,month_,p_sales_sup,p_sales_spe

union all 
-- 取人员费用数据 ，科目只取差旅费  以及  业务招待费  
select 
    year(a.dbill_date) as year_
    ,month(a.dbill_date ) as month_ 
    ,b.p_sales_sup 
    ,a.cpersonname as p_sales_spe
    ,0
    ,0
    ,0
    ,0
    ,0
    ,sum(a.md) as md  
from bidata.ft_81_expenses_x as a
left join report.oper_tem03 as b 
on a.cpersonname = b.p_sales_spe
left join bidata.dt_22_code_account as c 
on a.code = c.code_account
where b.p_sales_spe is not null 
and c.ccode_name_2 in ("差旅费","业务招待费")
group by year_,month_,a.cpersonname;
	
-- 生成汇总好的数据 
truncate table report.operation_03_sales_person_pivot;
insert into report.operation_03_sales_person_pivot
select 
    year_
    ,month_
    ,p_sales_sup
    ,p_sales_spe
    ,cast(null as char(20)) as province
    ,sum(isum) as isum 
    ,sum(itax) as itax 
    ,sum(isum) - sum(itax) as isum_notax 
    ,sum(cost_notax) as cost_notax
    ,sum(amount_depre) as amount_depre
    ,sum(md) as md  
from report.operation_03_sales_person 
group by year_,month_,p_sales_sup,p_sales_spe;

-- 根据05临时表 处理生成省份信息
-- 根据销售 销售非空 
update report.operation_03_sales_person_pivot as a 
left join report.oper_tem05 as b 
on a.p_sales_spe = b.cpersonname
set a.province = b.province 
where a.p_sales_spe is not null ;

-- 根据主管 主管非空 省份是空
update report.operation_03_sales_person_pivot as a 
left join report.oper_tem05 as b 
on a.p_sales_sup = b.cpersonname
set a.province = b.province 
where a.p_sales_sup is not null and a.province is null;




