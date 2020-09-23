use report;

-- 处理分摊比例 计算YTD数据与比例 

-- 1. 处理YTD 送样数据 
drop temporary table if exists report.new425_03_delivery_tem00;
create temporary table if not exists report.new425_03_delivery_tem00(
	concatid varchar(255),
	province_get varchar(60),
	city_get varchar(60),
	city_give varchar(60),
	item_code varchar(60),
	item_name varchar(90),
	year_ smallint,
	month_ smallint,
	inum_person_songyang decimal(30,0),
	key index_tem00_concatid (concatid)
)engine=innodb default charset=utf8;

-- 创建存储过程提取送样TYD数据
drop procedure if exists report.n425_pro;
delimiter $$
create procedure report.n425_pro()
begin
	declare i int default 1;
	while i <= 12 do
		insert into report.new425_03_delivery_tem00
		select 
			concat(city_get,item_code,year_,i) as concatid
			,province_get
			,city_get
			,city_give
			,item_code
			,item_name
			,year_
			,i as month_
			,sum(inum_person_songyang) as inum_person_songyang
		from new425_02_delivery 
		where month_ <= i
		group by city_get,city_give,item_code,year_;
	set i=i+1;
	end while;
  commit;
end
$$
delimiter ;

call report.n425_pro();

-- 2. 处理YTD 收样地级市 检测量
-- 2.1 先生成基础数据 
drop temporary table if exists report.new425_03_delivery_tem01;
create temporary table if not exists report.new425_03_delivery_tem01
select 
	city_get
	,item_code
	,year_
	,month_
	,inum_person_all
from new425_02_delivery 
group by city_get,item_code,year_,month_;

-- 2.2 处理YTD数据
drop temporary table if exists report.new425_03_delivery_tem02;
create temporary table if not exists report.new425_03_delivery_tem02(
	concatid varchar(255),
	city_get varchar(60),
	item_code varchar(60),
	year_ smallint,
	month_ smallint,
	inum_person_all decimal(30,0),
	key index_tem02_concatid (concatid)
)engine=innodb default charset=utf8;

-- 创建存储过程提取送样YTD数据
drop procedure if exists report.n425_pro_2;
delimiter $$
create procedure report.n425_pro_2()
begin
	declare i int default 1;
	while i <= 12 do
		insert into report.new425_03_delivery_tem02
		select 
			concat(city_get,item_code,year_,i) as concatid
			,city_get
			,item_code
			,year_
			,i as month_
			,sum(inum_person_all) as inum_person_all
		from new425_03_delivery_tem01 
		where month_ <= i
		group by city_get,item_code,year_;
	set i=i+1;
	end while;
  commit;
end
$$
delimiter ;

call report.n425_pro_2();
	
-- 生成临时表 地级市各月份各项目的销售额 来源 pdm.invoice_order 只取销售中心的数据 (非YTD销售额)
drop temporary table if exists report.new425_city_sales_tem00;
create temporary table if not exists report.new425_city_sales_tem00
select 
	concat(b.city ,c.item_code ,year(a.ddate),month(a.ddate)) as concatid
	,b.city 
	,c.item_code 
	,year(a.ddate) as year_ 
	,month(a.ddate) as month_ 
	,sum(a.isum) as isum 
from pdm.invoice_order as a 
left join edw.map_customer as b on a.finnal_ccuscode = b.bi_cuscode 
left join edw.map_inventory as c on a.cinvcode = c.bi_cinvcode
where a.item_code != 'JK0101' and year(ddate) >= 2018 and cohr != '杭州贝生' 
and b.sales_dept in('销售一部','销售二部')
group by b.city,year(a.ddate),month(a.ddate),c.item_code;
alter table report.new425_city_sales_tem00 add index(concatid);

-- 创建临时表 new425_city_sales_tem00  放销售YTD数据
drop temporary table if exists report.new425_city_sales_tem01;
create temporary table if not exists report.new425_city_sales_tem01(
	concatid varchar(255),
	city varchar(60),
	item_code varchar(60),
	year_ smallint,
	month_ smallint,
	isum_ytd decimal(30,0),
	key index_tem01_concatid (concatid)
)engine=innodb default charset=utf8;


-- 创建存储过程提取YTD销售数据
drop procedure if exists report.n425_pro_3;
delimiter $$
create procedure report.n425_pro_3()
begin
	declare i int default 1;
	while i <= 12 do
		insert into report.new425_city_sales_tem01
		select 
			concat(city,item_code,year_,i) as concatid
			,city
			,item_code
			,year_
			,i as month_
			,sum(isum) as isum_ytd
		from new425_city_sales_tem00 
		where month_ <= i
		group by city,item_code,year_;
	set i=i+1;
	end while;
  commit;
end
$$
delimiter ;

call report.n425_pro_3();


-- 关联获取比例数据 
drop table if exists report.new425_03_delivery_ytd;
create table if not exists report.new425_03_delivery_ytd
select 
	a.province_get
	,a.city_get
	,a.city_give
	,a.item_code
	,a.item_name
	,a.year_
	,a.month_
	,a.inum_person_songyang
	,b.inum_person_all
	,case 
		when b.inum_person_all = 0 then 0 
		else round(a.inum_person_songyang/b.inum_person_all,4) 
	end as rate_fentan  -- 分摊比例
	,c.isum as isum_city_get -- 收样地级市当月销售额
	,case 
		when b.inum_person_all = 0 then 0 
		else round(a.inum_person_songyang/b.inum_person_all,4) * c.isum
	end as isum_fentan  -- 收样地级市当月销售额分摊
	,d.isum_ytd as isum_ytd_city_get -- 收样地级市YTD销售额
	,case 
		when b.inum_person_all = 0 then 0 
		else round(a.inum_person_songyang/b.inum_person_all,4) * d.isum_ytd
	end as isum_ytd_fentan  -- 收样地级市YTD销售额分摊
from new425_03_delivery_tem00 as a 
left join new425_03_delivery_tem02 as b 
on a.concatid = b.concatid
left join report.new425_city_sales_tem00 as c 
on a.concatid = c.concatid
left join report.new425_city_sales_tem01 as d
on a.concatid = d.concatid

-- select * from report.new425_03_delivery_ytd;
	
	
	
	
	
	


