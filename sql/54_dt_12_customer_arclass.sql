-- dt_12_customer_arclass

-- 临时表 应收类型 （试剂、检测、设备）
drop temporary table if exists bidata.cusar_tem;
create temporary table if not exists bidata.cusar_tem(
	ar_class varchar(20));
insert into bidata.cusar_tem values("试剂");
insert into bidata.cusar_tem values("设备");
insert into bidata.cusar_tem values("检测");

-- 临时表 获取客户编码 + 应收类型
drop temporary table if exists bidata.cusar_tem00;
create temporary table if not exists bidata.cusar_tem00
select
concat(a.true_ccuscode,b.ar_class) as ccuscode_class
,a.true_ccuscode as ccuscode
,b.ar_class as ar_class
from 
(
select 
true_ccuscode 
from bidata.ft_51_ar 
group by true_ccuscode
union 
select 
true_ccuscode
from bidata.ft_52_ar_plan
group by true_ccuscode
) as a 
left join 
	bidata.cusar_tem as b 
on 1 = 1 ;

alter table bidata.cusar_tem00 add index index_cusar_tem00_ccuscode_class (ccuscode_class);
-- 增加 启代医疗服务、健康检测  为了完善客户+应收类型 档案  不会有显示为空的内容
insert into bidata.cusar_tem00
select 
    concat(true_ccuscode,ar_class)
    ,true_ccuscode
    ,ar_class
from bidata.ft_51_ar 
where ar_class in ("启代医疗服务","健康检测")
group by true_ccuscode,ar_class;


truncate table bidata.dt_12_customer_arclass;
insert into bidata.dt_12_customer_arclass
select 
    a.ccuscode_class 
    ,a.ccuscode
    ,ifnull(b.bi_cusname,"请核查") as bi_cusname
    ,a.ar_class
    ,ifnull(b.sales_region,"其他") as sales_region
    ,ifnull(b.province,"其他") as province
    ,ifnull(b.city,"其他") as city
    ,ifnull(b.type,"其他") as type
    ,c.ddate
    ,c.cpersonname
    ,c.areadirector
    ,ifnull(c.aperiod,365) as aperiod
    ,c.aperiod_special
    ,ifnull(c.mark_aperiod,"未知") as mark_aperiod
from bidata.cusar_tem00 as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode
left join bidata.dt_16_person_ar as c 
on a.ccuscode_class = c.ccuscode_class;

alter table bidata.dt_12_customer_arclass comment = 'bi应收模块客户+应收类型维度表';


