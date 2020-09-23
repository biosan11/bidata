-- 425项目客单价

-- 关于有集中送样情况的, 来源分 本院 送样医院 
-- CRM检测量填写规则记录:   
-- 浙江全部: 本院
-- 安徽NIPT: 本院
-- 湖北宜昌新筛: 本院  (恩施送样)
-- 其余所有: 本院+送样医院


-- 1. 先处理人口数据 (TSH,或人口) 
-- 1.1 获取7省所有省份+地级市
drop temporary table if exists report.c425_citys_tem01;
create temporary table if not exists report.c425_citys_tem01
select 
	province
	,city
from edw.map_customer 
where province in ('浙江省','江苏省','安徽省','福建省','山东省','湖南省','湖北省')
group by province,city;

-- 1.2 生成年月基础表 从 ufdata.x_calendar取数, 2017年开始 暂定到20年 
drop temporary table if exists report.c425_months_tem01;
create temporary table if not exists report.c425_months_tem01
select 
	year(ddate) as year_
	,month(ddate) as month_
from ufdata.x_calendar
where year(ddate) >= 2017 and year(ddate) <= 2020
group by year(ddate),month(ddate);

-- 1.3 组合生成425地级市年月基础表  生成concatid用于jion
drop temporary table if exists report.c425_city_month_tem01;
create temporary table if not exists report.c425_city_month_tem01
select 
	concat(a.province,a.city,b.year_,b.month_) as concatid
	,a.province,a.city,b.year_,b.month_
from report.c425_citys_tem01 as a 
left join report.c425_months_tem01 as b 
on 1 = 1;
alter table report.c425_city_month_tem01 add index(concatid);  -- concatid: a.province,a.city,b.year_,b.month_


-- 1.4 通过上面基础表关联   1.pdm检测量checklist中TSH与17羟原始数据 2. 宏观人口数据 3.集中送样中tsh与17羟数据
-- 1.4.1 tsh与17羟检测量
drop temporary table if exists report.c425_checklist_tsh_17;
create temporary table if not exists report.c425_checklist_tsh_17
select 
	concat(b.province,b.city,year(a.ddate),month(a.ddate)) as concatid
	,b.province
	,b.city 
	,year(a.ddate) as year_
	,month(a.ddate) as month_
	,sum(case when a.item_name = 'TSH' then inum_person else 0 end) as inum_ori_tsh
	,sum(case when a.item_name = '17α-OH-P' then inum_person else 0 end) as inum_ori_17
from pdm.checklist as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where year(a.ddate) >= 2017 
group by b.province,b.city,year(a.ddate),month(a.ddate);
alter table report.c425_city_month_tem01 add index(concatid);

-- 1.4.2 宏观人口数据, 来源edw.x_macrodata  取总人口 乘以 出生率 算出每年的出生人口 除以12估算每月每月的出生人口(单位:人)
drop temporary table if exists report.c425_macrodata;
create temporary table if not exists report.c425_macrodata
select 
	province
	,city
	,year_
	,round(tp*natality*10/12,0) as newborn_popu-- tp:总人口(万人) natality:出生率(千分之一), 不保留小数
from edw.x_macrodata 
where year_ >= 2017;

-- 1.4.3 集中送样中tsh与17羟数据  省份地级市收样数据
drop temporary table if exists report.c425_delivery_shouyang;
create temporary table if not exists report.c425_delivery_shouyang
select 
	concat(province_get,city_get,year(ddate),month(ddate)) as concatid
	,province_get as province
	,city_get
	,year(ddate) as year_ 
	,month(ddate) as month_ 
	,sum(case when item_name = 'TSH' then inum_person else 0 end) as inum_shouyang_tsh
	,sum(case when item_name = '17α-OH-P' then inum_person else 0 end) as inum_shouyang_17
from edw.x_ccus_delivery_new 
where year(ddate) >= 2017 
group by province_get,city_get,year_,month_;
alter table report.c425_delivery_shouyang add index(concatid);


-- 1.4.4 集中送样中tsh与17羟数据  省份地级市送样数据
drop temporary table if exists report.c425_delivery_songyang;
create temporary table if not exists report.c425_delivery_songyang
select 
	concat(b.province,a.city_give,year(a.ddate),month(a.ddate)) as concatid
	,b.province
	,a.city_give
	,year(a.ddate) as year_ 
	,month(a.ddate) as month_ 
	,sum(case when a.item_name = 'TSH' then inum_person else 0 end) as inum_songyang_tsh
	,sum(case when a.item_name = '17α-OH-P' then inum_person else 0 end) as inum_songyang_17
from edw.x_ccus_delivery_new as a 
left join (select province,city from edw.map_customer group by city) as b  -- 目前没有发现跨省送样情况, 保险起见通过客户档案关联得到送样地级市对应省份
on a.city_give = b.city
where year(ddate) >= 2017 
group by b.province,a.city_give,year_,month_;
alter table report.c425_delivery_songyang add index(concatid);

-- 1.4.5 通过基础表关联以上所有 
drop temporary table if exists report.new425_population_tem01;
create temporary table if not exists report.new425_population_tem01
select 
	a.*
	,case 
		when a.province = '浙江省' then 'CRM填本院'
		when a.province = '湖北省' and a.city = '宜昌市' then 'CRM填本院' 
		else 'CRM填本院+送样医院'
	end as rules_crm
	,b.inum_ori_tsh 
	,d.inum_shouyang_tsh
	,e.inum_songyang_tsh
	,case 
		when a.province = '浙江省' then b.inum_ori_tsh 
		when a.province = '湖北省' and a.city = '宜昌市' then b.inum_ori_tsh 
		else ifnull(b.inum_ori_tsh,0) - ifnull(d.inum_shouyang_tsh,0) + ifnull(e.inum_songyang_tsh,0)
	end as inum_confirm_tsh
	,b.inum_ori_17
	,d.inum_shouyang_17
	,e.inum_songyang_17
	,case 
		when a.province = '浙江省' then b.inum_ori_17
		when a.province = '湖北省' and a.city = '宜昌市' then b.inum_ori_17
		else ifnull(b.inum_ori_17,0) - ifnull(d.inum_shouyang_17,0) + ifnull(e.inum_songyang_17,0)
	end as inum_confirm_17
	,c.newborn_popu
from report.c425_city_month_tem01 as a 
left join report.c425_checklist_tsh_17 as b 
on a.concatid = b.concatid
left join report.c425_macrodata as c 
on a.province = c.province and a.city = c.city and a.year_ = c.year_
left join report.c425_delivery_shouyang as d 
on a.concatid = d.concatid
left join report.c425_delivery_songyang as e
on a.concatid = e.concatid
;

-- 1.4.6 判断用哪个金额做为人口分母 
truncate table report.new425_01_population;
insert into report.new425_01_population
select 
	province
	,city
	,year_
	,month_ 
	,rules_crm
	,inum_ori_tsh
	,inum_shouyang_tsh
	,inum_songyang_tsh
	,inum_confirm_tsh
	,inum_ori_17
	,inum_shouyang_17
	,inum_songyang_17
	,inum_confirm_17
	,newborn_popu
	,case  
		when ifnull(inum_confirm_tsh,0) > 50 then inum_confirm_tsh  -- 避免异常数据 例如潜江2020年3月TSH检测量5 (来源送样)
		when ifnull(inum_confirm_tsh,0) < 50 and ifnull(inum_confirm_17,0) > 50 then inum_confirm_17 -- 无TSH时用 17羟的检测量
		when ifnull(inum_confirm_tsh,0) < 50 and ifnull(inum_confirm_17,0) < 50 then newborn_popu  -- TSH与17羟都无数据, 用出生人口 
		else newborn_popu
	end as population_fenmu
	,case  
		when ifnull(inum_confirm_tsh,0) > 50 then 'tsh'  -- 避免异常数据 例如潜江2020年3月TSH检测量5 (来源送样)
		when ifnull(inum_confirm_tsh,0) < 50 and ifnull(inum_confirm_17,0) > 50 then '17α' -- 无TSH时用 17羟的检测量
		when ifnull(inum_confirm_tsh,0) < 50 and ifnull(inum_confirm_17,0) < 50 then 'newborn_popu'  -- TSH与17羟都无数据, 用出生人口 
		else 'newborn_popu'
	end as mark_result
from report.new425_population_tem01;

-- 补充: 处理中间是空的或者未填写的部门 以平均值暂估
-- 1.5.0 先将population_fenmu = 0 的 改为null 方便计数
update report.new425_01_population set population_fenmu = null where population_fenmu = 0;

-- 1.5.1 取2019-2020年各省份地级市平均值 
drop temporary table if exists report.new425_chulikong_tem01;
create temporary table if not exists report.new425_chulikong_tem01
select 
	province 
	,city
	,sum(ifnull(population_fenmu,0)) as population_fenmu_sum 
	,count(population_fenmu) as population_fenmu_sum_count
	,ifnull(sum(ifnull(population_fenmu,0)),0) / ifnull(count(population_fenmu),1) as population_fenmu_cal
from report.new425_01_population 
where year_ >= 2019
group by province,city;

-- 1.5.2 全部年份 各省份地级市平均值 
drop temporary table if exists report.new425_chulikong_tem02;
create temporary table if not exists report.new425_chulikong_tem02
select 
	province 
	,city
	,sum(ifnull(population_fenmu,0)) as population_fenmu_sum 
	,count(population_fenmu) as population_fenmu_sum_count
	,ifnull(sum(ifnull(population_fenmu,0)),0) / ifnull(count(population_fenmu),1) as population_fenmu_cal
from report.new425_01_population 
group by province,city;
	
-- 1.5.3 用2019-2020 代替null
update report.new425_01_population as a
inner join report.new425_chulikong_tem01 as b 
on a.province = b.province and a.city = b.city 
set a.population_fenmu = b.population_fenmu_cal ,mark_result = '用19-20年数据暂估'
where population_fenmu is null ;

-- 1.5.4 用全部年份 代替null
update report.new425_01_population as a
inner join report.new425_chulikong_tem02 as b 
on a.province = b.province and a.city = b.city 
set a.population_fenmu = b.population_fenmu_cal ,mark_result = '用全部年份数据暂估'
where population_fenmu is null ;
	
	
	
	
	
	
	
	
	
	
	
	
	
	

