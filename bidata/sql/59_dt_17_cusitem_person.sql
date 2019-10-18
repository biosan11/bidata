
/*
-- 建表 bidata.dt_17_cusitem_person
use bidata;
drop table if exists dt_17_cusitem_person;
create table `dt_17_cusitem_person`(
    ddate_effect date comment '生效日期',
    end_dt date comment '失效时间',
    uniqueid varchar(100) comment '唯一编码',
    ccuscode varchar(20) comment '客户编码',
    item_code varchar(120) comment '项目编码',
    cbustype varchar(120) comment '业务类型',
    equipment varchar(20) comment '是否设备',
    screen_class varchar(20) comment '筛诊类型',
    p_charge varchar(100) comment '客户项目直接负责人',
    p_sales_sup_tec varchar(100) comment '技术销售主管',
    p_sales_spe_tec varchar(100) comment '技术销售',
    p_sales_sup_clinic varchar(100) comment '临床销售主管',
    p_sales_spe_clinic varchar(100) comment '临床销售',
    per_tec float(5,2) comment '技术线比例',
    key bidata_dt_17_cusitem_person_ddate_effect (ddate_effect),
    key bidata_dt_17_cusitem_person_end_dt (end_dt),
    key bidata_dt_17_cusitem_person_ccuscode (ccuscode),
    key bidata_dt_17_cusitem_person_item_code (item_code),
    key bidata_dt_17_cusitem_person_cbustype (cbustype)
) engine=innodb default charset=utf8 comment='bi客户项目负责人档案';
*/
-- 来自edw.map_cusitem_person  并做相应处理  添加2:8比例
truncate table bidata.dt_17_cusitem_person;
insert into bidata.dt_17_cusitem_person
select 
--     concat(ccuscode,item_code,cbustype) as matchid
    a.ddate_effect
    ,a.end_dt 
    ,a.uniqueid
    ,a.ccuscode
    ,a.item_code
    ,a.cbustype
    ,b.equipment
    ,b.screen_class
    ,a.p_charge as p_charge
    ,a.p_sales_sup_tec as p_sales_sup_tec
    ,case 
        when a.p_sales_spe_tec = a.p_sales_sup_tec and a.p_sales_sup_tec is not null then null 
        else a.p_sales_spe_tec
        end as p_sales_spe_tec
    ,a.p_sales_sup_clinic as p_sales_sup_clinic
    ,case 
        when a.p_sales_spe_clinic = a.p_sales_sup_clinic and a.p_sales_sup_clinic is not null then null 
        else a.p_sales_spe_clinic 
        end as p_sales_spe_clinic
    ,case 
        when a.cbustype = "ldt" and a.p_sales_sup_tec is null and a.p_sales_spe_tec is null 
            then 0 
        when a.cbustype = "ldt" and a.p_sales_sup_clinic is null and a.p_sales_spe_clinic is null
            then 1 
        when a.cbustype = "ldt" 
            then 0.2
        when a.cbustype != "ldt" and b.screen_class = "筛查" 
            then 1 
        when a.cbustype != "ldt" and b.screen_class != "筛查" and a.p_sales_sup_tec is null and a.p_sales_spe_tec is null 
            then 0 
        when a.cbustype != "ldt" and b.screen_class != "筛查" and a.p_sales_sup_clinic is null and a.p_sales_spe_clinic is null
            then 1 
        when a.cbustype != "ldt" and b.screen_class != "筛查" and b.equipment = "是"
            then 0.8
        when a.cbustype != "ldt" and b.screen_class != "筛查" and b.equipment = "否"
            then 0.2
        else 0.5 end as per_tec 
from edw.map_cusitem_person as a 
left join edw.map_item as b 
on a.item_code = b.item_code;

