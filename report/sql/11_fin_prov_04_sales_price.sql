-- 

drop table if exists report.price_vary;
create table if not exists report.price_vary(
    id int primary  key auto_increment,
    ccuscode varchar(30),
    cinvcode varchar(60),
    ddate datetime,
    itaxunitprice decimal(30,10),
    key price_vary_ccuscode (ccuscode),
    key price_vary_cinvcode (cinvcode)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- 来源 pdm.invoice_price 提取基础数据 （七省） 终端客户  非赠送  主试剂  非设备
insert into report.price_vary (ccuscode,cinvcode,ddate,itaxunitprice)
select 
    a.ccuscode
    ,a.cinvcode
    ,a.ddate
    ,a.itaxunitprice
from pdm.invoice_price as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode 
where a.province in ("浙江省","江苏省","安徽省","福建省","山东省","湖南省","湖北省","上海市")
and b.level_one != "服务类" and b.level_two not in ("辅助试剂耗材","遗传病诊断耗材") and b.equipment = "否" and b.business_class != "ldt"
and state != "存在赠送记录"
and left(a.ccuscode,2) = "zd"
group by a.ccuscode,a.cinvcode,a.ddate,a.itaxunitprice
order by a.ccuscode,a.cinvcode,a.ddate asc; 

-- 根据自增id 自己join自己  
drop temporary table if exists report.price_tem0;
create temporary table if not exists report.price_tem0
select 
    a.id as id_a
    ,a.ccuscode as ccuscode_a
    ,a.cinvcode as cinvcode_a
    ,a.ddate as ddate_a
    ,a.itaxunitprice as itaxunitprice_a
    ,b.id as id_b
    ,b.ccuscode as ccuscode_b
    ,b.cinvcode as cinvcode_b
    ,b.ddate as ddate_b
    ,b.itaxunitprice as itaxunitprice_b
    ,if(a.ccuscode = b.ccuscode and a.cinvcode = b.cinvcode and a.itaxunitprice = b.itaxunitprice,"0","1") as mark
from report.price_vary as a
left join report.price_vary as b
on a.id = b.id+1;

drop table if exists report.price_vary;
create table if not exists report.price_vary(
    id int primary  key auto_increment,
    ccuscode varchar(30),
    cinvcode varchar(60),
    ddate datetime,
    itaxunitprice decimal(30,10),
    key price_vary_ccuscode (ccuscode),
    key price_vary_cinvcode (cinvcode)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 再次导入这张表  保证是价格的变动过程
insert into report.price_vary (ccuscode,cinvcode,ddate,itaxunitprice)
select 
    ccuscode_a
    ,cinvcode_a
    ,ddate_a
    ,itaxunitprice_a
from report.price_tem0
where mark = "1"
order by ccuscode_a,cinvcode_a,ddate_a asc ;

-- 找出价格变动记录
drop temporary table if exists report.price_tem1;
create temporary table if not exists report.price_tem1
select 
    a.id as id_a
    ,a.ccuscode as ccuscode_a
    ,a.cinvcode as cinvcode_a
    ,a.ddate as ddate_a
    ,a.itaxunitprice as itaxunitprice_a
    ,b.id as id_b
    ,b.ccuscode as ccuscode_b
    ,b.cinvcode as cinvcode_b
    ,b.ddate as ddate_b
    ,b.itaxunitprice as itaxunitprice_b
    ,if(a.ccuscode = b.ccuscode and a.cinvcode = b.cinvcode,"0","1") as mark_1  -- 0表示 客户 产品 相同
    ,if(abs(a.itaxunitprice-b.itaxunitprice)>=b.itaxunitprice*0.01,"0","1") as mark_2 -- 0表示 客户产品 单价变动超过1% 
from report.price_vary as a
left join report.price_vary as b
on a.id = b.id+1;


-- 19年预算 提取数据（客户，产品，日期，预估人份——预估发货）
drop temporary table if exists report.price_tem2;
create temporary table if not exists report.price_tem2
select 
    a.ccuscode
    ,a.cinvcode 
    ,a.ddate
    ,sum(a.inum_person) as inum_person
    ,sum(b.inum_unit_person) as inum_unit_person
    ,sum(a.inum_person)/sum(b.inum_unit_person) as iquantity
from edw.x_sales_budget_19 as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode 
group by a.ccuscode,a.cinvcode,a.ddate;
alter table report.price_tem2 add index index_price_tem2_ccuscode (ccuscode);
alter table report.price_tem2 add index index_price_tem2_cinvcode (cinvcode);
alter table report.price_tem2 add index index_price_tem2_ddate (ddate);

-- 建表，输出结果数据
truncate table report.fin_prov_04_sales_price;
insert into report.fin_prov_04_sales_price
select 
    b.province as province 
    ,b.bi_cusname as ccusname
    ,c.bi_cinvname as cinvname
    ,a.ddate_a
    ,a.itaxunitprice_a
    ,a.ddate_b
    ,a.itaxunitprice_b
    ,sum(d.iquantity) as iquantity
    ,a.ccuscode_a as ccuscode
    ,b.sales_region as sales_region
    ,a.cinvcode_a as cinvcode 
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one 
from report.price_tem1 as a 
left join edw.map_customer as b 
on a.ccuscode_a = b.bi_cuscode 
left join edw.map_inventory as c 
on a.cinvcode_a = c.bi_cinvcode 
left join report.price_tem2 as d 
on a.ccuscode_a = d.ccuscode and a.cinvcode_a = d.cinvcode and a.ddate_a <= d.ddate
where a.mark_1 = "0" and a.mark_2 = "0"
group by 
    a.ddate_a
    ,a.itaxunitprice_a
    ,a.ddate_b
    ,a.itaxunitprice_b
    ,a.ccuscode_a
    ,a.cinvcode_a
order by a.ccuscode_a,a.cinvcode_a,a.ddate_a desc ;
drop table if exists report.price_vary;
