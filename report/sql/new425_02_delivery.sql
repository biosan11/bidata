
-- 处理集中送样分摊比例 

-- 1. 处理出收样地级市的本院检测量 与 收样检测量 
-- 1.1 获取原始检测量数据 省份+地级市+项目 2018年开始按年月聚合 检测量  产品类 非竞争对手的 
drop temporary table if exists report.n425_checklist_gb;
create temporary table if not exists report.n425_checklist_gb
select 
	concat(b.city,a.item_code,year(a.ddate),month(a.ddate)) as concatid
	,b.province
	,b.city
	,a.item_code
	,a.item_name
	,year(a.ddate) as year_ 
	,month(a.ddate) as month_ 
	,sum(inum_person) as inum_person_ori
from pdm.checklist as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
where year(a.ddate) >= 2018 and a.competitor = '否' and a.cbustype = '产品类' -- 2018年开始, 集中送样只有2018年开始有数据
-- and a.item_code in (select item_code from edw.x_ccus_delivery_new group by item_code) -- 只获取集中送样里的项目 减少数据量
-- and b.city in (select city_get from edw.x_ccus_delivery_new group by city_get)  -- 只获取集中送样里的收样地级市 减少数据量
group by b.province,b.city,a.item_code,year(a.ddate),month(a.ddate);
alter table report.n425_checklist_gb add index(concatid);

-- select count(*) from report.n425_checklist_gb;

-- 1.2 生成集中送样基础表 收样省份,地级市, 项目,收样量
drop temporary table if exists report.n425_delivery_tem00;
create temporary table if not exists report.n425_delivery_tem00
select 
	concat(city_get,item_code,year(ddate),month(ddate)) as concatid
	,province_get as province
	,city_get as city
	,item_code
	,item_name
	,year(ddate) as year_
	,month(ddate) as month_
	,sum(inum_person) as inum_person_shouyang
from edw.x_ccus_delivery_new 
group by city_get,item_code,item_name,year(ddate),month(ddate);
alter table report.n425_delivery_tem00 add index(concatid);

-- 1.3 通过report.n425_delivery_tem00  关联 report.n425_checklist_gb  获取收样地级市原始检测量
drop temporary table if exists report.n425_delivery_tem01;
create temporary table if not exists report.n425_delivery_tem01
select 
	a.province
	,a.city
	,a.item_code 
	,a.item_name
	,a.year_
	,a.month_
	,case 
		when a.province = '浙江省' then 'CRM填本院'
		when a.province = '湖北省' and a.city = '宜昌市' then 'CRM填本院' 
		when a.province = '安徽省' and a.item_name = 'NIPT' then 'CRM填本院'  -- 填报规则见上个脚本 
		else 'CRM填本院+送样医院'
	end as rules_crm
	,a.inum_person_shouyang
	,b.inum_person_ori
from report.n425_delivery_tem00 as a 
left join report.n425_checklist_gb as b 
on a.concatid = b.concatid;

-- 1.4 通过规则标签 判断本院检测量 与 全部检测量 
drop temporary table if exists report.n425_delivery_tem02;
create temporary table if not exists report.n425_delivery_tem02
select 
	concat(city,item_code,year_,month_) as concatid
	,province
	,city
	,item_code 
	,item_name
	,year_
	,month_
	,rules_crm
	,inum_person_shouyang
	,inum_person_ori
	,case 
		when rules_crm = 'CRM填本院' then inum_person_ori
		else ifnull(inum_person_ori,0) - ifnull(inum_person_shouyang,0)
	end as inum_person_benyuan
	,case 
		when rules_crm = 'CRM填本院' then ifnull(inum_person_ori,0) + ifnull(inum_person_shouyang,0)
		else ifnull(inum_person_ori,0)
	end as inum_person_all 
from report.n425_delivery_tem01;
alter table report.n425_delivery_tem02 add index(concatid);

-- 2. 关联送样关系表 获取每月的 收样 与 送样数据  
-- 2.1 获取集中送样基础表 
drop temporary table if exists report.n425_delivery_tem10;
create temporary table if not exists report.n425_delivery_tem10
select 
	concat(city_get,item_code,year(ddate),month(ddate)) as concatid
	,province_get 
	,city_get 
	,city_give
	,item_code
	,item_name
	,year(ddate) as year_
	,month(ddate) as month_
	,sum(inum_person) as inum_person_songyang
from edw.x_ccus_delivery_new 
group by city_get,city_give,item_code,item_name,year(ddate),month(ddate);
alter table report.n425_delivery_tem10 add index(concatid);

-- 2.2 获取每月的 收样 与 送样数据   这里收样地级市的数据会重复, 调用时需要去重 
drop table if exists report.new425_02_delivery;
create table if not exists report.new425_02_delivery
select 
	a.concatid 
	,a.province_get 
	,a.city_get 
	,a.city_give
	,a.item_code
	,a.item_name
	,a.year_
	,a.month_ 
	,a.inum_person_songyang
	,b.rules_crm
	,b.inum_person_shouyang
	,b.inum_person_ori
	,b.inum_person_benyuan
	,b.inum_person_all 
from report.n425_delivery_tem10 as a 
left join report.n425_delivery_tem02 as b 
on a.concatid = b.concatid;










