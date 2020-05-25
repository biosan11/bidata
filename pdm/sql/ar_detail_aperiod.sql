-- ----------------------------------程序头部----------------------------------------------
-- 功能：生成客户账期表
-- 说明：取自edw层x_ar_plan生成客户应收类型账期数据
-- ----------------------------------------------------------------------------------------
-- 程序名称：ar_detail_aperiod.sql
-- 目标模型：ar_detail_aperiod
-- 源    表：edw.x_ar_plan
-- ---------------------------------------------------------------------------------------
-- 加载周期:日
-- ----------------------------------------------------------------------------------------
-- 作者: jinj
-- 开发日期：2020-03-18
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法　python /home/pdm/py/ar_detail_aperiod.py
-- 
-- 调用方法　
-- 建表脚本
-- use pdm;
-- drop table if exists pdm.ar_customer_aperiod;
-- create table if not exists pdm.ar_customer_aperiod(
--     ccuscode_class varchar(20) comment '客户编码+应收类型(试剂-检测-设备)',
--     ccuscode varchar(20) comment '客户编码',
--     bi_cusname varchar(120) comment '客户名称',
--     ar_class varchar(20) comment '应收类型',
--     sales_dept varchar(20) comment '销售部门',
--     sales_region_new varchar(20) comment '销售区域',
--     province varchar(20) comment '省份',
--     city varchar(20) comment '地级市',
--     type varchar(20) comment '客户类型',
--     ddate date comment '最新账期日期',
--     aperiod smallint comment '账期(处理后)',
--     aperiod_ori varchar(50) comment '原始账期',
--     mark_aperiod varchar(20) comment '是否常规账期',
--     key pdm_ar_customer_aperiod_ccuscode_class (ccuscode_class),
--     key pdm_ar_customer_aperiod_ccuscode (ccuscode),
--     key pdm_ar_customer_aperiod_ar_class (ar_class)
-- ) engine=innodb default charset=utf8 comment='应收模块-客户应收类型账期数据';

-- 临时表 应收类型 （试剂、检测、设备）
drop temporary table if exists pdm.cusar_tem;
create temporary table if not exists pdm.cusar_tem(
	ar_class varchar(20));
insert into pdm.cusar_tem values("试剂");
insert into pdm.cusar_tem values("设备");
insert into pdm.cusar_tem values("检测");

-- 临时表 获取客户编码 + 应收类型
drop temporary table if exists pdm.cusar_tem00;
create temporary table if not exists pdm.cusar_tem00
select
    concat(a.true_ccuscode,b.ar_class) as ccuscode_class
    ,a.true_ccuscode as ccuscode
    ,b.ar_class as ar_class
from 
    (
    select 
    true_ccuscode 
    from edw.ar_detail
    group by true_ccuscode
    union 
    select 
    true_ccuscode
    from edw.x_ar_plan
    group by true_ccuscode
    ) as a 
left join 
	pdm.cusar_tem as b 
on 1 = 1 ;

alter table pdm.cusar_tem00 add index index_cusar_tem00_ccuscode_class (ccuscode_class);
-- 增加 启代医疗服务、健康检测  为了完善客户+应收类型 档案  不会有显示为空的内容
insert into pdm.cusar_tem00
select 
    concat(true_ccuscode,ar_class)
    ,true_ccuscode
    ,ar_class
from edw.ar_detail 
where ar_class in ("启代医疗服务","健康检测")
group by true_ccuscode,ar_class;


-- 建临时表 并排序
drop temporary table if exists pdm.dt_16_person_ar_tem;
create temporary table if not exists pdm.dt_16_person_ar_tem
select 
    true_ccuscode as ccuscode 
    ,true_ccusname as ccusname
    ,ar_class 
    ,ddate 
    ,aperiod_ori
    ,aperiod
    ,mark_aperiod
from edw.x_ar_plan
where mark_aperiod != '未知'  -- 200522更新, 优化脚本不取未知的 , 因为edw.x_ar_plan数据有 db 有的账套有账期 有的账套是 未知 
order by true_ccuscode,ar_class,ddate desc;

drop temporary table if exists pdm.dt_16_person_ar_tem_2;
create temporary table if not exists pdm.dt_16_person_ar_tem_2
select 
    concat(ccuscode,ar_class) as ccuscode_class
    ,ccuscode
    ,ccusname
    ,ar_class 
    ,ddate  
    ,aperiod_ori
    ,aperiod
    ,mark_aperiod
from pdm.dt_16_person_ar_tem
group by ccuscode,ar_class;

truncate table pdm.ar_detail_aperiod;
insert into pdm.ar_detail_aperiod
select 
    a.ccuscode_class 
    ,a.ccuscode
    ,ifnull(b.bi_cusname,"请核查") as bi_cusname
    ,a.ar_class
    ,ifnull(b.sales_dept,"其他") as sales_dept
    ,ifnull(b.sales_region_new,"其他") as sales_region_new
    ,ifnull(b.province,"其他") as province
    ,ifnull(b.city,"其他") as city
    ,ifnull(b.type,"其他") as type
    ,c.ddate
    ,ifnull(c.aperiod,3) as aperiod  -- 未提供账期, 默认3个月
    ,c.aperiod_ori
    ,ifnull(c.mark_aperiod,"未知") as mark_aperiod
from pdm.cusar_tem00 as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode
left join pdm.dt_16_person_ar_tem_2 as c 
on a.ccuscode_class = c.ccuscode_class;

-- 200520 增加逻辑 对于 mark_aperiod 是 未知的 客户, 终端客户 账期3个月  代理商和个人客户 账期0
update pdm.ar_detail_aperiod 
set aperiod = 0 
where mark_aperiod = "未知" and left(ccuscode,2) != 'ZD';

