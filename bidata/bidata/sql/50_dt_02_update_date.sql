-- 8_dt_02_update_date
/*
-- 建表 bidata.dt_02_update_date
use bidata;
drop table if exists bidata.dt_02_update_date;
create table if not exists bidata.dt_02_update_date(
  `table_name` varchar(50) not null comment '表名',
  `ddate` date not null comment '更新日期'
) engine=innodb default charset=utf8 comment'各表最新更新日期';
*/


-- 更新日期数据
truncate table bidata.dt_02_update_date;
insert into bidata.dt_02_update_date
select "bi_sales",max(ddate) from bidata.ft_11_sales 
where isum > 0;

insert into bidata.dt_02_update_date
select "bi_outdepot",max(ddate) from bidata.ft_21_outdepot
where iquantity > 0;

insert into bidata.dt_02_update_date
select "ft_51_ar",max(dvouchdate) from bidata.ft_51_ar;

insert into bidata.dt_02_update_date 
select "ft_71_employee",max(start_dt) from pdm.ehr_employee;

insert into bidata.dt_02_update_date 
select "ft_81_expenses_x",max(dbill_date) from bidata.ft_81_expenses_x;

insert into bidata.dt_02_update_date 
select "ft_41_cusitem_occupy",max(last_invoice_dt) from bidata.ft_41_cusitem_occupy;
