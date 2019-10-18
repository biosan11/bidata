drop table if exists pdm.invoice_price_temp;
create table if not exists pdm.invoice_price_temp(
    id int primary  key auto_increment,
    ccuscode varchar(30),
    ccusname varchar(60),
    finnal_ccuscode varchar(30),
    finnal_ccusname varchar(60),
    cinvcode varchar(60),
    cinvname varchar(60),
    ddate datetime,
    itaxunitprice decimal(10,2),
    cinvbrand varchar(60) DEFAULT NULL COMMENT '品牌',
    province varchar(60) DEFAULT NULL COMMENT '销售省份',
    key price_vary_ccuscode (ccuscode),
    key price_vary_cinvcode (cinvcode),
    key price_vary_finnal_ccuscode (finnal_ccuscode)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists pdm.invoice_price;
create table if not exists pdm.invoice_price(
    province varchar(60) DEFAULT NULL COMMENT '销售省份',
    ccuscode varchar(30),
    ccusname varchar(60),
    finnal_ccuscode varchar(30),
    finnal_ccusname varchar(60),
    cinvcode varchar(60),
    cinvname varchar(60),
    ddate datetime,
    itaxunitprice decimal(10,2),
    specification_type varchar(120),
    cinvbrand varchar(60) DEFAULT NULL COMMENT '品牌',
    inum_unit_person varchar(60),
    state varchar(20),
    key price_vary_ccuscode (ccuscode),
    key price_vary_cinvcode (cinvcode),
    key price_vary_finnal_ccuscode (finnal_ccuscode),
    key price_vary_ddate_a (ddate)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 取数并排序
truncate table pdm.invoice_price_temp;
insert into pdm.invoice_price_temp (ccuscode,ccusname,finnal_ccuscode,finnal_ccusname,cinvcode,cinvname,ddate,itaxunitprice,cinvbrand,province)
select ccuscode,ccusname,finnal_ccuscode,finnal_ccusname,cinvcode,cinvname,ddate,round(itaxunitprice,2),cinvbrand,province
from (select * from pdm.invoice_order order by cinvbrand,province) a
where year(ddate) >= 2018
and itaxunitprice > 0
and isum > 0
group by ddate,ccuscode,finnal_ccuscode,cinvcode,round(itaxunitprice,2)
order by ccuscode,finnal_ccuscode,cinvcode,ddate ASC,round(itaxunitprice,2);

-- 全部非零数据
create temporary table pdm.mid3_invoice_price
select
     c.ccuscode
    ,c.ccusname
    ,c.finnal_ccuscode
    ,c.finnal_ccusname
    ,c.cinvcode
    ,c.cinvname
    ,c.ddate
    ,c.itaxunitprice
    ,c.cinvbrand
    ,c.province
    ,d.specification_type
    ,d.inum_unit_person
from(
select
     a.id
    ,a.ccuscode
    ,a.ccusname
    ,a.finnal_ccuscode
    ,a.finnal_ccusname
    ,a.cinvcode
    ,a.cinvname
    ,a.ddate
    ,a.itaxunitprice
    ,a.cinvbrand
    ,a.province
    ,case when a.itaxunitprice = b.itaxunitprice then 0 else 1 end as state
from pdm.invoice_price_temp as a
left join pdm.invoice_price_temp as b
  on a.id = b.id+1
and a.ccuscode = b.ccuscode
and a.cinvcode = b.cinvcode
and a.finnal_ccuscode = b.finnal_ccuscode
) c
  left join edw.map_inventory d
    on c.cinvcode = d.bi_cinvcode
where c.state = 1;

-- 把存在赠送的数据导入进去
create temporary table pdm.mid1_invoice_price
select a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.cinvbrand
      ,a.province
      ,max(a.ddate) as ddate
      ,0 as price
      ,b.specification_type
      ,b.inum_unit_person
  from pdm.invoice_order a
  left join edw.map_inventory b
    on a.cinvcode = b.bi_cinvcode
where itaxunitprice = 0
   and ddate >= '2018-01-01'
    group by ccuscode,cinvcode,finnal_ccuscode
;


-- 取出最后一条记录的操作时间
create temporary table pdm.mid2_invoice_price
select a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,max(a.ddate) as ddate
      ,ROUND(a.itaxunitprice,2) as price
  from (select * from pdm.mid3_invoice_price order by ddate desc) a
    group by ccuscode,cinvcode,finnal_ccuscode
;

-- 插入数据
truncate table pdm.invoice_price;
insert into pdm.invoice_price
select a.province
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.ddate
      ,a.itaxunitprice
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,case when b.ccuscode is not null then '最后一次价格' else '过程中价格' end
  from pdm.mid3_invoice_price a
  left join pdm.mid2_invoice_price b
    on ROUND(a.itaxunitprice,2) = b.price
   and a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.ddate = b.ddate
;

insert into pdm.invoice_price
select a.province
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.ddate
      ,a.price
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,'存在赠送记录'
  from pdm.mid1_invoice_price a
;

-- drop table if exists pdm.invoice_price;
drop table if exists pdm.invoice_price_temp;