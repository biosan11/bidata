/*
drop table if exists report.fin_prov_11_expenses_fw;
create table if not exists report.fin_prov_11_expenses_fw (
  `year_` smallint ,
  `month_` smallint ,
  `province` varchar(60) default null comment '销售省份',
  `sy_md` float(13,4) default null,
  `bx_md` float(13,4) default null,
  `xxzx_md` float(13,4) default null,
  `jsbz_md` float(13,4) default null,
  `wb_md` float(13,4) default null,
  `wl_md` float(13,4) default null,
  `nosy_md` float(13,4) default null
) engine=innodb default charset=utf8 comment'实验员、物流、保险等费用到客户表';
*/

-- 
truncate table report.fin_prov_11_expenses_fw;
insert into report.fin_prov_11_expenses_fw
select 
    left(a.y_mon,4) as year_
    ,right(a.y_mon,2) as month_
    ,b.province
    ,sum(a.sy_md)
    ,sum(a.bx_md)
    ,sum(a.xxzx_md)
    ,sum(a.jsbz_md)
    ,sum(a.wb_md)
    ,sum(a.wl_md)
    ,sum(a.bx_md) + sum(a.xxzx_md) + sum(a.jsbz_md) + sum(a.wb_md) + sum(a.wl_md)as nosy_md
from report.fin_prov_10_expense_all as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
group by y_mon,b.province;
