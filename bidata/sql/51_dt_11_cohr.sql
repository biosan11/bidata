-- 9_dt_11_cohr
/*
-- 建表 bidata.dt_11_cohr
use bidata;
drop table if exists bidata.dt_11_cohr;
create table if not exists bidata.dt_11_cohr(
  `cohr` varchar(50) primary key comment '子公司'
) engine=innodb default charset=utf8 comment'公司信息表';
*/

-- 更新子公司数据
truncate table bidata.dt_11_cohr;
-- 1.收入
insert into bidata.dt_11_cohr
select cohr from bidata.ft_11_sales where cohr is not null group by cohr;
-- 2.发货
replace into bidata.dt_11_cohr
select cohr from bidata.ft_21_outdepot where cohr is not null group by cohr;