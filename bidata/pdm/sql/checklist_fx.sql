/*
drop table if exists pdm.checklist_fx;
create table if not exists pdm.checklist_fx (
  `id` double default null,
  `ccuscode` varchar(20) character set utf8 default null comment '客户编号',
  `item_code` varchar(40) character set utf8 default null comment '项目编号',
  `ym` varchar(10) character set utf8mb4 default null,
  `inum_person` decimal(32,0) default null,
  key `index_pdm_checklist_fx_ccuscode` (`ccuscode`),
  key `index_pdm_checklist_fx_item_code` (`item_code`),
  key `index_pdm_checklist_fx_ym` (`ym`)
) engine=innodb default charset=utf8 collate=utf8_bin;
*/


-- 创建临时表，按月聚合
drop temporary table if exists pdm.checklist_fx00;
create temporary table pdm.checklist_fx00 as
select
  ccuscode
  ,item_code
  ,date_format( concat( year ( ddate ), "-", month ( ddate ), "-", "1" ), '%Y-%m-%d' ) as ym
  ,sum( inum_person ) as inum_person 
from
  bidata.ft_31_checklist 
where competitor = '否' 
and cbustype = "产品类"
and item_code != "jk0101"
and year(ddate) >= 2016
group by
  ccuscode
  ,item_code
  ,ym 
order by
  ccuscode
  ,item_code
  ,ym;
alter table pdm.checklist_fx00 add index index_pdm_checklist_fx00_ccuscode (ccuscode) ;
alter table pdm.checklist_fx00 add index index_pdm_checklist_fx00_item_code (item_code) ;
alter table pdm.checklist_fx00 add index index_pdm_checklist_fx00_ym (ym) ;


-- 获得客户项目 与 年月 笛卡尔积
drop temporary table if exists pdm.checklist_fx01;
create temporary table pdm.checklist_fx01 
select 
	a.ccuscode
	,a.item_code
	,b.ym 
from 
	(select distinct ccuscode,item_code from bidata.ft_31_checklist ) as a,
	(select distinct ym from pdm.checklist_fx00) as b 
order by a.ccuscode,a.item_code,b.ym;

alter table pdm.checklist_fx01 add index index_pdm_checklist_fx01_ccuscode (ccuscode) ;
alter table pdm.checklist_fx01 add index index_pdm_checklist_fx01_item_code (item_code) ;
alter table pdm.checklist_fx01 add index index_pdm_checklist_fx01_ym (ym) ;

-- 获取客户项目 检测量最早的月份 
drop temporary table if exists pdm.checklist_fx02;
create temporary table pdm.checklist_fx02
select 
	ccuscode
    ,item_code
    ,min(ym) as ym 
from pdm.checklist_fx00 
group by ccuscode,item_code;
alter table pdm.checklist_fx02 add index index_pdm_checklist_fx02_ccuscode (ccuscode) ;
alter table pdm.checklist_fx02 add index index_pdm_checklist_fx02_item_code (item_code) ;
alter table pdm.checklist_fx02 add index index_pdm_checklist_fx02_ym (ym) ;

-- 获取客户项目 检测量最晚的月份 
drop temporary table if exists pdm.checklist_fx03;
create temporary table pdm.checklist_fx03
select 
	ccuscode
    ,item_code
    ,max(ym) as ym 
from pdm.checklist_fx00 
group by ccuscode,item_code;
alter table pdm.checklist_fx03 add index index_pdm_checklist_fx03_ccuscode (ccuscode) ;
alter table pdm.checklist_fx03 add index index_pdm_checklist_fx03_item_code (item_code) ;
alter table pdm.checklist_fx03 add index index_pdm_checklist_fx03_ym (ym) ;

-- 删除最晚年月小于2019年的客户项目 
delete from pdm.checklist_fx03 where ym <= '2018-12-31';

-- 客户项目 补全中间为空月份
drop temporary table if exists pdm.checklist_fx04;
create temporary table pdm.checklist_fx04
select
    a.ccuscode
    ,a.item_code
    ,a.ym 
    ,d.inum_person 
from pdm.checklist_fx01 as a 
left join pdm.checklist_fx02 as b 
on a.ccuscode = b.ccuscode and a.item_code = b.item_code 
left join pdm.checklist_fx03 as c 
on a.ccuscode = c.ccuscode and a.item_code = c.item_code
left join pdm.checklist_fx00 as d 
on a.ccuscode = d.ccuscode and a.item_code = d.item_code and a.ym = d.ym 
where a.ym >= b.ym and a.ym <= c.ym;
alter table pdm.checklist_fx04 add index index_pdm_checklist_fx04_ccuscode (ccuscode) ;
alter table pdm.checklist_fx04 add index index_pdm_checklist_fx04_item_code (item_code) ;
alter table pdm.checklist_fx04 add index index_pdm_checklist_fx04_ym (ym) ;

-- 加入自增ID
truncate table pdm.checklist_fx;
insert into pdm.checklist_fx
select
    @n := @n +1 as id 
    ,a.ccuscode
    ,a.item_code
    ,a.ym 
    ,a.inum_person 
from pdm.checklist_fx04 as a ,(select @n := 1) as b ;

-- 不取连续4个月是空值的客户项目 
drop temporary table if exists pdm.checklist_fx06;
create temporary table pdm.checklist_fx06
select 
	aa.ccuscode
	,aa.item_code
	,max(aa.ym) as ym
from 
(
select 
    a.ccuscode
    ,a.item_code
    ,a.ym
from pdm.checklist_fx as a 
left join pdm.checklist_fx as b 
on a.id = b.id + 1 
left join pdm.checklist_fx as c
on a.id = c.id + 2  
left join pdm.checklist_fx as d
on a.id = d.id + 3  
where 
a.ccuscode = b.ccuscode and a.ccuscode = c.ccuscode and a.ccuscode = d.ccuscode 
and a.item_code = b.item_code and a.item_code = c.item_code and a.item_code = d.item_code 
and a.inum_person is null 
and b.inum_person is null 
and c.inum_person is null 
and d.inum_person is null 
) as aa
group by ccuscode,item_code
;
alter table pdm.checklist_fx06 add index index_pdm_checklist_fx06_ccuscode (ccuscode) ;
alter table pdm.checklist_fx06 add index index_pdm_checklist_fx06_item_code (item_code) ;
alter table pdm.checklist_fx06 add index index_pdm_checklist_fx06_ym (ym) ;

use pdm;
delete t1
from pdm.checklist_fx as t1
left join pdm.checklist_fx06 as t2
on t1.ccuscode = t2.ccuscode and t1.item_code = t2.item_code 
where t1.ym <= t2.ym; 

-- 将空值 替换成0 
update pdm.checklist_fx set inum_person = 0 where inum_person is null;


