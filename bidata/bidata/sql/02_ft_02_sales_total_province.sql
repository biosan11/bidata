-- 13_ft_02_sales_total_province
/* 
-- 建表 bidata.ft_02_sales_total_province
drop table if exists bidata.ft_02_sales_total_province;
create table if not exists bidata.ft_02_sales_total_province(
  `year` smallint default  null  comment  '年份',
  `month` smallint default null comment '月份',
  `province` varchar(60) default null comment '省份',
  `sales_region` varchar(20) DEFAULT NULL COMMENT '销售区域',
  `isum`  decimal(19,4)  default  null  comment  '原币价税合计',
  `isum_budget` decimal(19,4)  default  null  comment  '计划收入'
) engine=innodb default charset=utf8 comment='bi总体收入表（大区省份年月）';

*/


truncate table bidata.ft_02_sales_total_province;

insert into bidata.ft_02_sales_total_province 
select
year(a.ddate)
,month(a.ddate)
,ifnull(b.province,"其他")
,ifnull(b.sales_region,"其他")
,round(sum(a.isum)/1000,3)
,0
from pdm.invoice_order as a
left join edw.map_customer as b
on a.finnal_ccuscode = b.bi_cuscode
where year(a.ddate) >= 2017
and a.item_code != "jk0101"
group by year(a.ddate),month(a.ddate),b.province;

insert into bidata.ft_02_sales_total_province 
select 
year(a.ddate)
,month(a.ddate)
,ifnull(b.province,"其他")
,ifnull(b.sales_region,"其他")
,0
,round(sum(a.isum_budget)/1000,3)
from edw.x_sales_budget_18 as a
left join edw.map_customer as b
on a.true_ccuscode = b.bi_cuscode
group by year(a.ddate),month(a.ddate),b.province;

insert into bidata.ft_02_sales_total_province 
select 
year(a.ddate)
,month(a.ddate)
,ifnull(b.province,"其他")
,ifnull(b.sales_region,"其他")
,0
,round(sum(a.isum_budget)/1000,3)
from edw.x_sales_budget_19 as a
left join edw.map_customer as b
on a.bi_cuscode = b.bi_cuscode
group by year(a.ddate),month(a.ddate),b.province;


