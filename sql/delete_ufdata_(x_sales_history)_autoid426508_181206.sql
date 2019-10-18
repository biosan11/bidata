-- 处理x_sales_history 中 auto_id = 44387


-- 最终客户 东营市 GSP设备 2017年9月 
delete from ufdata.x_sales_history where auto_id = 44387;


-- 在历史数据中 加入17年7月-17年12月贝康个人

-- 提取贝康个人收入 17年7月-17年12月 并做相应处理
drop temporary table if exists ufdata.tem_1205_pre;
create temporary table if not exists ufdata.tem_1205_pre
select 
"贝康" as db
,a.ddate as ddate
,"未提取数据"
,"ldt" as business_class
,a.product_ori as product_ori
,b.bi_cinvcode as cinvcode_ori
,a.isum as isum
,concat("个人（",a.true_ccusname,"）") as ccusname
,a.true_ccusname as finnal_ccusname
from edw.x_sales_bkgr as a
left join (select cinvname,bi_cinvcode from edw.dic_inventory group by cinvname) as b
on a.product_ori = b.cinvname
where a.method_settlement = "个人" 
and a.accounts like"%贝康%"
and year(a.ddate)=2017 
and month(a.ddate) in (7,8,9,10,11,12);

update ufdata.tem_1205_pre set product_ori = "SNP 750K" where product_ori = "SNP750K";
update ufdata.tem_1205_pre set product_ori = "全外显子组测序" where product_ori = "DNA测序";
update ufdata.tem_1205_pre as a
inner join (select cinvname,bi_cinvcode from edw.dic_inventory group by cinvname) as b
on a.product_ori = b.cinvname
set a.cinvcode_ori = b.bi_cinvcode;

-- 将提取后的数据 加入到ufdata.x_sales_history
insert into ufdata.x_sales_history 
(db,ddate,invoice_num,business_class,product_ori,cinvcode_ori,isum,ccusname,finnal_ccusname)
select * from ufdata.tem_1205_pre;


update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 28560;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 28561;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 28562;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 28563;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="德阳市旌阳区妇幼保健计划生育服务中心", ccusname = "德阳市旌阳区妇幼保健计划生育服务中心", finnal_ccusname = "德阳市旌阳区妇幼保健计划生育服务中心" where auto_id = 29158;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 29206;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 29208;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30339;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30631;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30635;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30636;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30755;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 30756;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="德阳市旌阳区妇幼保健计划生育服务中心", ccusname = "德阳市旌阳区妇幼保健计划生育服务中心", finnal_ccusname = "德阳市旌阳区妇幼保健计划生育服务中心" where auto_id = 30758;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "015101002", finnal_ccuscode_ori = "015101002",ccusname_ori ="四川大学华西第二医院", ccusname = "四川大学华西第二医院", finnal_ccusname = "四川大学华西第二医院" where auto_id = 30759;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 32212;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 32213;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 32221;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="德阳市旌阳区妇幼保健计划生育服务中心", ccusname = "德阳市旌阳区妇幼保健计划生育服务中心", finnal_ccusname = "德阳市旌阳区妇幼保健计划生育服务中心" where auto_id = 33037;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33274;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33275;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33298;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33301;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33302;
update ufdata.x_sales_history set db = "四川美博特",ccuscode_ori = "0", finnal_ccuscode_ori = "0",ccusname_ori ="成都亚蔓科技有限公司", ccusname = "成都亚蔓科技有限公司", finnal_ccusname = "宜宾市妇幼保健院" where auto_id = 33888;


-- 处理x_sales_history 中 ccusname 为空
create temporary table if not exists x_sales_history_tem
select auto_id
from ufdata.x_sales_history
where ccusname is null;

update ufdata.x_sales_history set ccusname = ccusname_ori
where auto_id in 
(select auto_id from x_sales_history_tem);

-- 处理x_sales_history 中 finnal_ccusname 为空
create temporary table if not exists x_sales_history_tem2
select a.auto_id,a.ccusname_ori,
b.bi_cusname,b.bi_cuscode,c.finnal_ccusname
from ufdata.x_sales_history as a
left join
(select ccusname,bi_cusname,bi_cuscode from edw.dic_customer group by ccusname )as b
on a.ccusname_ori = b.ccusname
left join 
edw.map_customer as c
on b.bi_cuscode = c.bi_cuscode
where a.finnal_ccusname is null;

update ufdata.x_sales_history as a inner join 
x_sales_history_tem2 as b
on a.auto_id = b.auto_id
set a.finnal_ccusname = b.finnal_ccusname;

update ufdata.x_sales_history set finnal_ccusname = "威海市妇女儿童医院（威海市妇幼保健院）"
where auto_id = 56490;

