-- 23_dt_16_person_ar

/*
-- 建表 bidata.dt_16_person_ar
use bidata;
drop table if exists bidata.dt_16_person_ar;
create table if not exists bidata.dt_16_person_ar (
    ccuscode_class varchar(30) comment '客户与账款类型组合',
    ccuscode varchar(20) comment '客户编码',
    ccusname varchar(255) comment '客户名称',
    class varchar(20) comment '类型',
    ddate date comment '日期',
    cpersonname varchar(20) comment '直接负责人',
    areadirector varchar(20) comment '主管',
    aperiod smallint(6) DEFAULT NULL COMMENT '账期',
    aperiod_special varchar(50) DEFAULT NULL COMMENT '特殊账期',
    mark_aperiod varchar(20) DEFAULT NULL COMMENT '是否常规账期标记',
    key bidata_dt_16_person_ar_ccuscode (ccuscode),
    key bidata_dt_16_person_ar_class (class),
    key bidata_dt_16_person_ar_ehr_cpersonname (cpersonname)
 ) engine=innodb default charset=utf8 comment'应收模块客户维护人员表';
*/

-- 建临时表 并排序
drop temporary table if exists bidata.dt_16_person_ar_tem;
create temporary table if not exists bidata.dt_16_person_ar_tem
select 
    true_ccuscode as ccuscode 
    ,true_ccusname as ccusname
    ,class 
    ,ddate 
    ,if(cpersonname = "空",null,cpersonname) as cpersonname
    ,if(areadirector = "空",null,areadirector) as areadirector
    ,aperiod
    ,aperiod_special
    ,mark_aperiod
from bidata.ft_52_ar_plan 
order by true_ccuscode,class,ddate desc;



-- 取数据
truncate table bidata.dt_16_person_ar;

insert into bidata.dt_16_person_ar
select 
    concat(ccuscode,class)
    ,ccuscode
    ,ccusname
    ,class 
    ,ddate 
    ,cpersonname 
    ,areadirector 
    ,aperiod
    ,aperiod_special
    ,mark_aperiod
from bidata.dt_16_person_ar_tem
group by ccuscode,class;