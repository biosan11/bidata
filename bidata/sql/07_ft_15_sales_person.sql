/*
use bidata;
drop table if exists bidata.ft_15_sales_person;
create table if not exists bidata.ft_15_sales_person(
    uniqueid varchar(50),
    p_charge varchar(100) comment '客户项目直接负责人',
    p_sales_sup_tec varchar(100) comment '技术销售主管',
    p_sales_spe_tec varchar(100) comment '技术销售',
    p_sales_sup_clinic varchar(100) comment '临床销售主管',
    p_sales_spe_clinic varchar(100) comment '临床销售',
    per_tec float(5,2) comment '技术线比例',
    per_clinic float(5,2) comment '临床线比例',
    ddate date,
    ccuscode varchar(20),
    item_code varchar(50),
    cinvcode varchar(30),
    equipment varchar(10),
    screen_class varchar(20),
    cbustype varchar(20),
    itaxunitprice float(13,3),
    isum float(13,3),
    itax float(13,3),
    inum_budget float(13,3),
    isum_budget float(13,3),
    key ft_15_sales_person_ccuscode (ccuscode),
    key ft_15_sales_person_item_code (item_code),
    key ft_15_sales_person_cbustype (cbustype)
)engine=innodb default charset=utf8 comment='bi收入人员表_拆分技术临床';

drop table if exists bidata.ft_16_sales_person_post;
create table if not exists bidata.ft_16_sales_person_post(
	mark varchar(100) comment '分类1',
	post varchar(20) comment '岗位',
	p_charge varchar(100) comment '客户项目直接负责人',
	p_sales_sup varchar(100) comment '主管（技术or临床）',
	p_sales_spe varchar(100) comment '销售（技术or临床）',
	ddate date comment '日期',
	ccuscode varchar(20) comment '客户编码',
	item_code varchar(50) comment '项目编码',
    cinvcode varchar(30) ,
	equipment varchar(10) comment '是否设备',
	screen_class varchar(20) comment '筛查诊断分类',
	cbustype varchar(20) comment '业务类型',
    itaxunitprice float(13,3),
	isum float(13,3) comment '实际收入',
    itax float(13,3) comment '实际税额',
	inum_budget float(13,3) comment '预算发货人份数',
	isum_budget float(13,3) comment '预算收入',
	key bidata_16_sales_person_post_mark (mark),
	key bidata_16_sales_person_post_ccuscode (ccuscode),
	key bidata_16_sales_person_post_item_code (item_code),
	key bidata_16_sales_person_post_cbustype (cbustype)
)engine=innodb default charset=utf8 comment='bi收入人员表_人汇总';
*/

-- -- 声明变量
-- -- 2#ldt
-- set @per_ldt_tec = 0.2;
-- set @per_ldt_clinic = 0.8;
-- -- 4#eq
-- set @per_eq_tec = 0.8;
-- set @per_eq_clinic = 0.2;
-- -- 5#uneq
-- set @per_uneq_tec = 0.2;
-- set @per_uneq_clinic = 0.8;

-- 汇总开票列表收入数据 bi_sales
drop temporary table if exists bidata.sales_person_tem01;
create temporary table if not exists bidata.sales_person_tem01(
    ddate date,
    ccuscode varchar(20),
    cinvcode varchar(20),
    item_code varchar(50),
    cbustype varchar(20),
    itaxunitprice float(13,3),
    isum float(13,3),
    itax float(13,3),
    inum_budget float(13,3),
    isum_budget float(13,3),
    key sales_person_tem01_ccuscode (ccuscode),
    key sales_person_tem01_item_code (item_code),
    key sales_person_tem01_cbustype (cbustype),
    key sales_person_tem01_ddate (ddate)
)engine=innodb default charset=utf8;

-- 加入开票收入数据
insert into bidata.sales_person_tem01
select 
    ddate
    ,finnal_ccuscode as ccuscode
    ,cinvcode
    ,item_code
    ,cbustype
    ,itaxunitprice
    ,isum 
    ,itax
    ,0 as inum_budget
    ,0 as isum_budget
from bidata.ft_11_sales 
where year(ddate) >= 2018
and isum != 0 
and cohr != "杭州贝生";

-- 加入预算数据
insert into bidata.sales_person_tem01
select 
ddate
,true_ccuscode as ccuscode
,null as cinvcode
,true_item_code as item_code
,business_class as cbustype
,0 as itaxunitprice 
,0 as isum
,0 as itax 
,inum_budget
,isum_budget
from bidata.ft_12_sales_budget 
where cohr = "博圣"
and (isum_budget != 0 or inum_budget != 0) ;


-- 汇总生成总表
truncate table bidata.ft_15_sales_person;
insert into bidata.ft_15_sales_person
select
    b.uniqueid
    ,b.p_charge
    ,case 
        when b.p_sales_sup_tec = "曾守鑫" then concat(b.p_sales_sup_tec,'-',c.province)
        when b.p_sales_sup_tec = "陈阳春" then concat(b.p_sales_sup_tec,'-',c.province)
        else b.p_sales_sup_tec
        end as p_sales_sup_tec
    ,case 
        when b.p_sales_spe_tec = "曾守鑫" then concat(b.p_sales_spe_tec,'-',c.province)
        when b.p_sales_spe_tec = "陈阳春" then concat(b.p_sales_spe_tec,'-',c.province)
        else b.p_sales_spe_tec
        end as p_sales_spe_tec
    ,case 
        when b.p_sales_sup_clinic = "曾守鑫" then concat(b.p_sales_sup_clinic,'-',c.province)
        when b.p_sales_sup_clinic = "陈阳春" then concat(b.p_sales_sup_clinic,'-',c.province)
        else b.p_sales_sup_clinic
        end as p_sales_sup_clinic
    ,case 
        when b.p_sales_spe_clinic = "曾守鑫" then concat(b.p_sales_spe_clinic,'-',c.province)
        when b.p_sales_spe_clinic = "陈阳春" then concat(b.p_sales_spe_clinic,'-',c.province)
        else b.p_sales_spe_clinic
        end as p_sales_spe_clinic
    ,b.per_tec
    ,1-b.per_tec as per_clinic
    ,a.ddate
    ,a.ccuscode
    ,a.item_code
    ,a.cinvcode 
    ,b.equipment
    ,b.screen_class
    ,a.cbustype
    ,a.itaxunitprice 
    ,a.isum
    ,a.itax
    ,a.inum_budget
    ,a.isum_budget
from bidata.sales_person_tem01 as a
left join bidata.dt_17_cusitem_person as b
on a.ccuscode = b.ccuscode and a.item_code = b.item_code and a.cbustype = b.cbustype
and replace(a.ddate,left(a.ddate,4),2019) >= b.ddate_effect and replace(a.ddate,left(a.ddate,4),2019) <= b.end_dt;
-- and month(a.ddate) >= month(b.ddate_effect) and month(a.ddate) < month(b.end_dt);

-- 更新 ft_15_sales_person 中 equipment,screen_class 字段 
update bidata.ft_15_sales_person as a 
left join edw.map_item as b 
on a.item_code = b.item_code
set a.equipment = b.equipment ,a.screen_class = b.screen_class 
where a.equipment is null and a.screen_class is null;

-- 更新 ft_15_sales_person 中 inum_budget,isum_budget 字段 
update bidata.ft_15_sales_person 
set isum = 0 
where isum is null ;
update bidata.ft_15_sales_person 
set itax = 0 
where itax is null;
update bidata.ft_15_sales_person 
set inum_budget = 0 
where inum_budget is null ;
update bidata.ft_15_sales_person 
set isum_budget = 0 
where isum_budget is null ;

-- 将 ft_15_sales_person 数据 导入 ft_16_sales_person_post
truncate table bidata.ft_16_sales_person_post;
insert into bidata.ft_16_sales_person_post
select 
    "noperson" 
    ,"noperson"
    ,"noperson"
    ,"noperson"
    ,"noperson"
    ,ddate
    ,ccuscode
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itaxunitprice
    ,isum
    ,itax
    ,inum_budget
    ,isum_budget
from bidata.ft_15_sales_person
where uniqueid is null ;

insert into bidata.ft_16_sales_person_post
select 
    "tec"
    ,"tec"
    ,p_charge
    ,p_sales_sup_tec
    ,p_sales_spe_tec 
    ,ddate
    ,ccuscode
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itaxunitprice
    ,isum * ifnull(per_tec,0)
    ,itax * ifnull(per_tec,0)
    ,inum_budget * ifnull(per_tec,0)
    ,isum_budget * ifnull(per_tec,0)
from bidata.ft_15_sales_person
where uniqueid is not null ;

insert into bidata.ft_16_sales_person_post
select 
    "clinic"
    ,"clinic"
    ,p_charge
    ,p_sales_sup_clinic
    ,p_sales_spe_clinic
    ,ddate
    ,ccuscode
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itaxunitprice
    ,isum * ifnull(per_clinic,0)
    ,itax * ifnull(per_clinic,0)
    ,inum_budget * ifnull(per_clinic,0)
    ,isum_budget * ifnull(per_clinic,0)
from bidata.ft_15_sales_person
where uniqueid is not null ;

delete from bidata.ft_16_sales_person_post
where isum = 0 and inum_budget = 0 and isum_budget = 0;
