-- 32_dt_21_deptment

/*
-- 建表 bidata.dt_21_deptment
use bidata;
drop table if exists bidata.dt_21_deptment;
create table if not exists bidata.dt_21_deptment(
    cdept_id_ehr varchar(20) comment 'ehr部门编号',
    name_ehr varchar(120) comment 'ehr名称',
    second_dept varchar(120) comment '一级中心',
    third_dept varchar(120) comment '二级中心',
    fourth_dept varchar(120) comment '一级部门',
    fifth_dept varchar(120) comment '二级部门',
    province varchar(20) comment '修正省区',
    sixth_dept varchar(120) comment '一级组织',
key bidata_dt_21_deptment_cdept_id_ehr (cdept_id_ehr)
) engine=innodb default charset=utf8 comment='bi部门表_ehr';
 */

-- 导入数据

truncate table bidata.dt_21_deptment;
insert into bidata.dt_21_deptment 
select 
    cdept_id_ehr
    ,name_ehr
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,case 
        when second_dept != "营销中心" then null 
        when third_dept not in ("销售一部","销售二部") then null 
        when fourth_dept = "浙江省区" then "浙江省"
        when fourth_dept = "福建省区" then "福建省"
        when fourth_dept = "山东省区" then "山东省"
        when fourth_dept = "河南省区" then "河南省"
        when fourth_dept = "安徽省区" then "安徽省"
        when fourth_dept = "江苏省区" then "江苏省"
        when fifth_dept = "上海区" then "上海市"
        when right(fifth_dept,1) = "区" then substring_index(fifth_dept,"区",1)
        else null 
    end as province
    ,sixth_dept
from edw.dic_deptment 
where cdept_id_ehr is not null
group by cdept_id_ehr;