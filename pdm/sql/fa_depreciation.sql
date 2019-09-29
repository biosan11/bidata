-- drop table if exists pdm.fa_depreciation;
-- create table if not exists pdm.fa_depreciation (
--     date_ date comment '',
--     sdeptnum varchar(20) comment '部门编码串',
--     db varchar(20) comment '来源',
--     scardid int comment '卡片记录标识',
--     scardnum varchar(10) comment '卡片编号',
--     sassetnum varchar(37) comment '资产编码',
--     sassetname varchar(255) comment '资产名称',
--     stypenum varchar(20) comment '资产类型编码',
--     ssite varchar(50) comment '存放地点',
--     llife smallint comment '可使用月份',
--     lusedmonths smallint comment '已使用月份',
--     dstartdate date comment '开始使用日期',
--     dinputdate date comment '录入日期',
--     dtransdate date comment '变动日期',
--     ddisposedate date comment '注销日期',
--     dblvalue float(13,3) comment '原值',
--     dblbv float(13,3) comment '净残值',
--     dblinputvalue float(13,3) comment '录入时原值',
--     dblmonthvalue float(13,3) comment '月初原值',
--     dblperiodvalue float(13,3) comment '期初原值',
--     dblinputdeprtotal float(13,3) comment '录入时累计折旧',
--     linputlife smallint comment '录入时可使用月份',
--     linputdeprmonths smallint comment '录入时已计提月份',
--     dbldeprt float(13,3) comment '累计折旧额',
--     dbldeprt_lm float(13,3) comment '累计上约折旧'
-- ) engine=innodb default charset=utf8 comment='投放设备折旧表';

use pdm;

drop temporary table if exists pdm.fa_tem01;
create temporary table if not exists pdm.fa_tem01
select
    a.sdeptnum
    ,a.db
    ,a.scardid
    ,a.scardnum
    ,a.sassetnum
    ,a.sassetname
    ,a.stypenum
    ,a.ssite
    ,a.llife
    ,a.lusedmonths
    ,a.dstartdate
    ,a.dinputdate
    ,a.dtransdate
    ,a.ddisposedate
    ,a.dblValue
    ,a.dblBV
from ufdata.fa_cards as a left join 
(
select 
    db
    ,max(scardid) as scardid 
from ufdata.fa_cards 
where (
(dinputdate <= '${end_dt}') and 
(dtransdate < '${end_dt}'  or  dtransdate is null) and 
(ddisposedate < '${end_dt}'  or  ddisposedate is null)
)
group by db,scardnum
) as b 
on a.db = b.db and a.scardid = b.scardid 
where b.scardid is not null
;

-- 2 取数
-- 先删除当月数据
delete from pdm.fa_depreciation where left(date_,7) = left('${end_dt}',7);
DELETE 
FROM
	pdm.fa_depreciation 
WHERE YEAR ( date_ ) = YEAR ('${end_dt}')
  and MONTH(date_) = MONTH('${end_dt}');



drop table if exists pdm.fa_depreciation_pre;
create table pdm.fa_depreciation_pre as 
select 
     '${end_dt}' as date_
    ,a.* 
    ,b.dblinputvalue
    ,b.dblmonthvalue
    ,b.dblperiodvalue
    ,b.dblinputdeprtotal
    ,b.linputlife
    ,b.linputdeprmonths
    ,case month('${end_dt}') 
    when 1 then dblDeprT1
        when 2 then dblDeprT2
        when 3 then dblDeprT3
        when 4 then dblDeprT4
        when 5 then dblDeprT5
        when 6 then dblDeprT6
        when 7 then dblDeprT7
        when 8 then dblDeprT8
        when 9 then dblDeprT9
        when 10 then dblDeprT10
        when 11 then dblDeprT11
        when 12 then dblDeprT12
    else 0 
  end as dbl
from pdm.fa_tem01 as a 
left join ufdata.fa_deprtransactions as b 
on a.db = b.db and a.scardnum = b.scardnum 
where b.iyear = year('${end_dt}')
-- 先取博圣体系（博圣、卓恩、恩允） 不取（宝荣222，启代666，云鼎169
and (
(a.db in ("UFDATA_111_2018","UFDATA_118_2018","UFDATA_123_2018") and a.stypenum = "07") or
(a.db in ("UFDATA_333_2018","UFDATA_588_2019") and a.stypenum = "01"));


-- 计算上月折旧
insert into pdm.fa_depreciation
select a.*
      ,case when b.db is null then 0 else b.dbldeprt end
  from pdm.fa_depreciation_pre a
  left join pdm.fa_depreciation b
    on DATE_SUB(a.date_,INTERVAL day(a.date_) day) = b.date_
   and a.db = b.db
   and a.scardnum = b.scardnum
;
-- DATE_SUB(str_to_date(CONCAT(year(b.date_),'-',month(b.date_),'-01'),'%Y-%m-%d'),INTERVAL 1 day)

drop table if exists pdm.fa_depreciation_pre;



