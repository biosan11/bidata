


truncate ufdata.x_sales_budget_19_new;

-- 1. 导入2019年1月更新后计划（取值为2019年实际收入金额）
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,cinvcode,item_code,cbustype,isum_budget_1901)
select 
'博圣体系'
,finnal_ccuscode
,cinvcode
,item_code
,cbustype
,sum(isum) 
from pdm.invoice_order 
where year(ddate) = 2019 and month(ddate) = 1
and item_code != "jk0101"
group by finnal_ccuscode,cinvcode,item_code,cbustype;
-- 2. 导入2019年2月更新后计划（取值为2019年实际收入金额）
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,cinvcode,item_code,cbustype,isum_budget_1902)
select 
'博圣体系'
,finnal_ccuscode
,cinvcode
,item_code
,cbustype
,sum(isum) 
from pdm.invoice_order 
where year(ddate) = 2019 and month(ddate) = 2
and item_code != "jk0101"
group by finnal_ccuscode,cinvcode,item_code,cbustype;

-- 3. 导入2019年3月更新后计划
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,item_code,cinvcode,inum_person_1903,isum_budget_1903)
select
	'博圣体系'
	,ccuscode
	,item_code
	,cinvcode
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1903;

-- 4. 导入2019年4月更新后计划
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,item_code,cinvcode,iquantity_budget_1904,inum_person_1904,isum_budget_1904)
select
	 cohr
	,ccuscode
	,item_code
	,cinvcode
	,iquantity_budget_tem
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1904;

-- 5. 导入2019年5月更新后计划
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,item_code,cinvcode,iquantity_budget_1905,inum_person_1905,isum_budget_1905)
select
	 cohr
	,ccuscode
	,item_code
	,cinvcode
	,iquantity_budget_tem
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1905;

-- 6. 导入2019年6月更新后计划
insert into ufdata.x_sales_budget_19_new (cohr,ccuscode,item_code,cinvcode,iquantity_budget_1906,inum_person_1906,isum_budget_1906)
select
	 cohr
	,ccuscode
	,item_code
	,cinvcode
	,iquantity_budget_tem
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1906;

-- 7. 导入2019年7月更新后计划
insert into ufdata.x_sales_budget_19_new_copy1 (cohr,ccuscode,item_code,cinvcode,iquantity_budget_1907,inum_person_1907,isum_budget_1907)
select
	 cohr
	,ccuscode
	,item_code
	,cinvcode
	,iquantity_budget_tem
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1907;

-- 8. 导入2019年8月更新后计划
insert into ufdata.x_sales_budget_19_new_copy1 (cohr,ccuscode,item_code,cinvcode,iquantity_budget_1908,inum_person_1908,isum_budget_1908)
select
	 cohr
	,ccuscode
	,item_code
	,cinvcode
	,iquantity_budget_tem
	,inum_person_tem
	,isum_budget_tem
from ufdata.sales_budget_new_1908;
-- 9. 导入2019年9月更新后计划
-- 10. 导入2019年10月更新后计划
-- 11. 导入2019年11月更新后计划
-- 12. 导入2019年12月更新后计划








