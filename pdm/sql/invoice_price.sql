
-- 得到18年以后负票
drop temporary table if exists pdm.invoice_order_tem;
create temporary table if not exists pdm.invoice_order_tem
select concat(db,autoid) as concatid
      ,ccuscode
      ,ccusname
      ,finnal_ccuscode
      ,finnal_ccusname
      ,cinvcode
      ,cinvname
      ,ddate
      ,round(itaxunitprice,2) as itaxunitprice
      ,cinvbrand
      ,province
      ,db
      ,autoid
      ,isosid
      ,isum 
      ,iquantity
  from pdm.invoice_order 
 where year(ddate) >=2018
   and  isum < 0
;

-- 得到时间差
drop table if exists pdm.invoice_order_tem1;
create temporary table if not exists pdm.invoice_order_tem1
select a.*
      ,datediff(b.ddate,a.ddate) as date_diff
      ,b.ddate as ddate_
  from pdm.invoice_order a
  left join pdm.invoice_order_tem b
    on left(a.db,10) = left(b.db,10)
   and a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and round(a.itaxunitprice,2) = round(b.itaxunitprice,2)
 where a.ddate <= b.ddate
   and b.ccuscode is not null
   and a.isum > 0
;

-- 先取当天存在0的记录
drop table if exists pdm.invoice_order_tem2;
create temporary table if not exists pdm.invoice_order_tem2
select *
  from pdm.invoice_order_tem1
 where date_diff = 0
 group by ccuscode,finnal_ccuscode,cinvcode,db,ddate_
;

-- 取不等于0的记录数
drop table if exists pdm.invoice_order_tem3;
create table if not exists pdm.invoice_order_tem3
select *
  from (select * from pdm.invoice_order_tem1 order by ddate_) a
 where date_diff <> 0
 group by ccuscode,finnal_ccuscode,cinvcode,db,ddate_
;

-- 这里先去之前存在相同的正票，没有在取今天的正票
insert into pdm.invoice_order_tem3
select a.* 
  from pdm.invoice_order_tem2 a
  left join pdm.invoice_order_tem3 b
    on left(a.db,10) = left(b.db,10)
   and a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.ddate_ = b.ddate_
 where b.db is null
;
alter table pdm.invoice_order_tem3 add index pdm_invoice_order_tem3_db (db);
alter table pdm.invoice_order_tem3 add index pdm_invoice_order_tem3_autoid (autoid);

drop temporary table if exists pdm.invoice_order_tem;
create temporary table if not exists pdm.invoice_order_tem
select a.*
  from pdm.invoice_order a
  left join pdm.invoice_order_tem3 b
    on a.autoid = b.autoid
   and a.db = b.db
 where year(a.ddate) >=2018
   and a.isum >= 0
   and b.autoid is null
;

drop table pdm.invoice_order_tem3;


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
    start_dt datetime,
    end_dt datetime,
    itaxunitprice decimal(10,2),
    specification_type varchar(120),
    cinvbrand varchar(60) DEFAULT NULL COMMENT '品牌',
    inum_unit_person varchar(60),
    state varchar(20),
    key price_vary_ccuscode (ccuscode),
    key price_vary_cinvcode (cinvcode),
    key price_vary_finnal_ccuscode (finnal_ccuscode)
)ENGINE=InnoDB DEFAULT CHARSET=utf8;

drop table if exists pdm.invoice_price_pre;
create table if not exists pdm.invoice_price_pre(
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
from (select * from pdm.invoice_order_tem order by cinvbrand,province) a
where year(ddate) >= 2018
and itaxunitprice > 0
and isum > 0
group by ddate,ccuscode,finnal_ccuscode,cinvcode,round(itaxunitprice,2)
order by ccuscode,finnal_ccuscode,cinvcode,ddate ASC,round(itaxunitprice,2);

-- 全部非零数据
create temporary table pdm.mid3_invoice_price
select c.id
    ,c.ccuscode
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
  from pdm.invoice_order_tem a
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

-- 一天之内出现2个价格对于最后一次价格的判断
drop table if exists pdm.mid4_invoice_price;
create temporary table pdm.mid4_invoice_price
select max(id) as id
      ,ddate
      ,ccuscode
      ,cinvcode
      ,finnal_ccuscode
  from pdm.mid3_invoice_price
 group by ccuscode,cinvcode,finnal_ccuscode,ddate
having count(*) > 1
;

-- 获取下一次价格
drop table if exists pdm.mid5_invoice_price;
create temporary table pdm.mid5_invoice_price
select a.id
      ,a.ccuscode
      ,a.cinvcode
      ,a.finnal_ccuscode
      ,b.ddate
      ,a.itaxunitprice
  from pdm.invoice_price_temp a
  left join pdm.mid4_invoice_price b
    on a.id -1 = b.id
   and a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
 where b.id is not null
;


drop table if exists pdm.mid6_invoice_price;
create temporary table pdm.mid6_invoice_price
select a.id
      ,a.ccuscode
      ,a.cinvcode
      ,a.finnal_ccuscode
      ,a.ddate
      ,a.itaxunitprice
  from pdm.mid5_invoice_price a
  left join pdm.mid2_invoice_price b
     on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.ddate = b.ddate
 where b.ccuscode is not null
;

-- 插入数据
truncate table pdm.invoice_price_pre;
insert into pdm.invoice_price_pre
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

insert into pdm.invoice_price_pre
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

update pdm.invoice_price_pre a
 inner join pdm.mid6_invoice_price b
     on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.ddate = b.ddate
   set a.state = '过程中价格'
;

update pdm.invoice_price_pre a
 inner join pdm.mid6_invoice_price b
     on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and a.ddate = b.ddate
   and ROUND(a.itaxunitprice,2) = ROUND(b.itaxunitprice,2)
   set a.state = '最后一次价格'
;

-- 这里调整价格区间
set @n = 1;
drop table if exists pdm.invoice_price_pre_1;
create table pdm.invoice_price_pre_1
select (@n := @n + 1) as id
      ,a.*
  from pdm.invoice_price_pre a
 where itaxunitprice <> 0
 order by ccuscode,finnal_ccuscode,cinvcode,ddate,state desc
;

CREATE INDEX index_invoice_price_pre_1_id ON pdm.invoice_price_pre_1(id);
CREATE INDEX index_invoice_price_pre_1_ccuscode ON pdm.invoice_price_pre_1(ccuscode);
CREATE INDEX index_invoice_price_pre_1_finnal_ccuscode ON pdm.invoice_price_pre_1(finnal_ccuscode);
CREATE INDEX index_invoice_price_pre_1_cinvcode ON pdm.invoice_price_pre_1(cinvcode);

-- 取最后一次不为0的价格
-- truncate table pdm.invoice_price;
-- insert into pdm.invoice_price
drop table if exists pdm.invoice_price_fin;
create temporary table pdm.invoice_price_fin
select a.province
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.ddate as start_dt
      ,b.ddate as end_dt
      ,a.itaxunitprice
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,a.state
  from pdm.invoice_price_pre_1 a
  left join pdm.invoice_price_pre_1 b
    on a.id  = b.id - 1
   and a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
;

-- 取最后一次非0价格
drop table if exists pdm.invoice_price_pre_2;
create temporary table pdm.invoice_price_pre_2
select ccuscode,finnal_ccuscode,cinvcode,max(ddate) as ddate
  from pdm.invoice_price_temp
 where itaxunitprice <> 0
 group by ccuscode,finnal_ccuscode,cinvcode
;

update pdm.invoice_price_fin a
 inner join pdm.invoice_price_pre_2 b
    on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   set a.end_dt = b.ddate
 where a.end_dt is null
;

-- 插入价格为0的数据
insert into pdm.invoice_price_fin
select a.province
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.ddate
      ,a.ddate
      ,a.itaxunitprice
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,a.state
  from pdm.invoice_price_pre a
 where state = '存在赠送记录'
;

-- drop table if exists pdm.invoice_price;
drop table if exists pdm.invoice_price_temp;
drop table if exists pdm.invoice_price_pre;
drop table if exists pdm.invoice_price_pre_1;

-- 这里针对只出现一次且没有其他开票记录的，更新end_date为当天
drop table if exists pdm.mid1_invoice_price_end;
create temporary table pdm.mid1_invoice_price_end
SELECT ccuscode,finnal_ccuscode,cinvcode,itaxunitprice 
  FROM pdm.invoice_order
 where isum >0 and itaxunitprice > 0
group by ccuscode,finnal_ccuscode,cinvcode,itaxunitprice
having count(*) = 1
;

drop table if exists pdm.mid2_invoice_price_end;
create temporary table pdm.mid2_invoice_price_end
SELECT ccuscode,finnal_ccuscode,cinvcode 
  FROM pdm.invoice_order
 where isum >0 and itaxunitprice > 0
group by ccuscode,finnal_ccuscode,cinvcode
having count(*) = 1
;

drop table if exists pdm.mid3_invoice_price_end;
create temporary table pdm.mid3_invoice_price_end
select a.* 
  from pdm.mid1_invoice_price_end a
  left join pdm.mid2_invoice_price_end b
    on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
 where b.ccuscode is null
;

update pdm.invoice_price_fin a
 inner join pdm.mid3_invoice_price_end b
    on a.ccuscode = b.ccuscode
   and a.finnal_ccuscode = b.finnal_ccuscode
   and a.cinvcode = b.cinvcode
   and round(a.itaxunitprice,2) = round(b.itaxunitprice,2)
   set a.end_dt = a.start_dt
;

-- 增加序号
truncate table invoice_price;
insert into invoice_price
select @r:= case when @ccuscode=a.ccuscode and @cinvcode = a.cinvcode and @finnal_ccuscode = a.finnal_ccuscode then @r+1 else 1 end as rownum
      ,a.province
      ,@ccuscode:=a.ccuscode as ccuscode
      ,a.ccusname
      ,@finnal_ccuscode:=a.finnal_ccuscode as finnal_ccuscode
      ,a.finnal_ccusname
      ,@cinvcode:=a.cinvcode as cinvcode
      ,a.cinvname
      ,a.start_dt
      ,a.end_dt
      ,a.itaxunitprice
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,a.state
      ,null
  from (select * from pdm.invoice_price_fin where itaxunitprice <> 0 order by ccuscode,finnal_ccuscode,cinvcode,start_dt,end_dt) a
,(select @r:=0,@ccuscode:='',@finnal_ccuscode:='',@cinvcode:='') b
;

insert into invoice_price
select 0
      ,a.province
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.cinvcode
      ,a.cinvname
      ,a.start_dt
      ,a.end_dt
      ,a.itaxunitprice
      ,a.specification_type
      ,a.cinvbrand
      ,a.inum_unit_person
      ,a.state
      ,null
  from pdm.invoice_price_fin a
 where itaxunitprice = 0
;

-- 更新金额可能存在问题的记录
update pdm.invoice_price a
 inner join pdm.sales_dis_out_inv b
    on a.ccuscode = b.ccuscode_fp
   and a.finnal_ccuscode = b.finnal_ccuscode_fp
   and a.cinvcode = b.cinvcode_fp
   and a.start_dt = b.ddate_fp
   set a.status = b.err_md
 where b.err_md <> ''
   and a.itaxunitprice <> 0
;

