/*
-- 建表 bidata.dt_17_cusitem_person_mon
use bidata;
drop table if exists dt_17_cusitem_person_mon;
create table `dt_17_cusitem_person_mon`(
    year smallint comment'年份',
    month smallint comment'月份',
    uniqueid varchar(100) comment '唯一编码',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(120) comment '项目编码',
    cbustype varchar(120) comment '业务类型',
    equipment varchar(20) comment '是否设备',
    screen_class varchar(20) comment '筛诊类型',
    p_sup_main varchar(100) comment'主管-主要',
    p_spe_main varchar(100) comment'销售-主要',
    p_sup_second varchar(100) comment '主管-次要',
    p_spe_second varchar(100) comment '销售-次要',
    per_main float(5,2) comment '比例-主要',
    key bidata_dt_17_cusitem_person_year (year),
    key bidata_dt_17_cusitem_person_month (month),
    key bidata_dt_17_cusitem_person_uniqueid (uniqueid)
) engine=innodb default charset=utf8 comment='bi客户项目主要负责人档案-按年月分';
*/

drop temporary table if exists bidata.dt_17_cusitem_person_mon_00;
create temporary table if not exists bidata.dt_17_cusitem_person_mon_00(
    year smallint comment'年份',
    month smallint comment'月份',
    key bidata_dt_17_cusitem_person_year (year),
    key bidata_dt_17_cusitem_person_month (month)
)engine=innodb;
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,1);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,2);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,3);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,4);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,5);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,6);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,7);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,8);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,9);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,10);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,11);
insert into bidata.dt_17_cusitem_person_mon_00 values(2019,12);

drop temporary table if exists bidata.dt_17_cusitem_person_mon_01;
create temporary table if not exists bidata.dt_17_cusitem_person_mon_01
select 
    ddate_effect
    ,end_dt
    ,uniqueid
    ,ccuscode
    ,item_code
    ,cbustype
    ,equipment
    ,screen_class
    ,p_sales_sup_tec as p_sup_main
    ,p_sales_spe_tec as p_spe_main
    ,p_sales_sup_clinic as p_sup_second
    ,p_sales_spe_clinic as p_spe_second
    ,per_tec as per_main
from bidata.dt_17_cusitem_person
where per_tec >= 0.5;

insert into bidata.dt_17_cusitem_person_mon_01
select 
    ddate_effect
    ,end_dt
    ,uniqueid
    ,ccuscode
    ,item_code
    ,cbustype
    ,equipment
    ,screen_class
    ,p_sales_sup_clinic as p_sup_main
    ,p_sales_spe_clinic as p_spe_main
    ,p_sales_sup_tec as p_sup_second
    ,p_sales_spe_tec as p_spe_second
    ,1 - per_tec as per_main
from bidata.dt_17_cusitem_person
where per_tec < 0.5;
alter table bidata.dt_17_cusitem_person_mon_01 add index index_bidata_dt_17_cusitem_person_mon_01_ddate_effect (ddate_effect) ;
alter table bidata.dt_17_cusitem_person_mon_01 add index index_bidata_dt_17_cusitem_person_mon_01_end_dt (end_dt) ;
alter table bidata.dt_17_cusitem_person_mon_01 add index index_bidata_dt_17_cusitem_person_mon_01_uniqueid (uniqueid) ;

drop temporary table if exists bidata.dt_17_cusitem_person_mon_02;
create temporary table if not exists bidata.dt_17_cusitem_person_mon_02
select distinct 
    a.uniqueid
    ,b.year 
    ,b.month
    ,str_to_date(concat(b.year,"-",b.month,"-",1),'%Y-%m-%d') as ddate
from bidata.dt_17_cusitem_person_mon_01 as a 
left join bidata.dt_17_cusitem_person_mon_00 as b 
on 1 = 1;
alter table bidata.dt_17_cusitem_person_mon_02 add index index_bidata_dt_17_cusitem_person_mon_02_uniqueid (uniqueid) ;
alter table bidata.dt_17_cusitem_person_mon_02 add index index_bidata_dt_17_cusitem_person_mon_02_ddated (ddate) ;



truncate table bidata.dt_17_cusitem_person_mon;
insert into bidata.dt_17_cusitem_person_mon
select 
    a.year
    ,a.month
    ,a.uniqueid
    ,b.ccuscode 
    ,b.item_code 
    ,b.cbustype 
    ,b.equipment 
    ,b.screen_class 
    ,b.p_sup_main 
    ,b.p_spe_main 
    ,b.p_sup_second 
    ,b.p_spe_second 
    ,b.per_main 
from bidata.dt_17_cusitem_person_mon_02 as a 
left join  bidata.dt_17_cusitem_person_mon_01 as b 
on a.uniqueid = b.uniqueid 
and replace(a.ddate,left(a.ddate,4),2019) >= b.ddate_effect and replace(a.ddate,left(a.ddate,4),2019) <= b.end_dt
where b.uniqueid is not null;


