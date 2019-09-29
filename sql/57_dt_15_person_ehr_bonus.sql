
-- dt_16_person_ehr_bonus

-- 营销中心人员信息表
truncate table bidata.dt_15_person_ehr;
insert into bidata.dt_15_person_ehr
select 
    userid
    ,jobnumber
    ,name
    ,poidempadmin
    ,poidempreserve2
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    -- ,replace(substring_index(substring_index(position_name,"兼",1),"区",-1),"，","") -- 按 兼  区  分字段
    ,substring_index(position_name,"兼",1) as position_main-- 按 兼  分字段
    ,case 
        when locate("省区经理",substring_index(position_name,"兼",1))>0 then "省区经理"
        when locate("实验员",substring_index(position_name,"兼",1))>0 then "实验员"
        when locate("技术销售主管",substring_index(position_name,"兼",1))>0 then "技术销售主管"
        when locate("大区总监助理",substring_index(position_name,"兼",1))>0 then "大区总监助理"
        when locate("区域主管",substring_index(position_name,"兼",1))>0 then "区域主管"
        else substring_index(position_name,"兼",1)
    end as position_adjust
    ,jobpost_name
    ,oidjoblevel
    ,entrydate
    ,startdate
    ,employeestatus
    ,lastworkdate
from pdm.ehr_employee
where second_dept = "营销中心"
and employeestatus in ("离职","试用","正式")
group by name ;

alter table bidata.dt_15_person_ehr comment '营销中心人员信息表';
-- alter table bidata.dt_15_person_ehr add index index_bidata_dt_15_person_ehr_name(name);


-- 计算奖金用到的人员

truncate table bidata.dt_15_person_ehr_bonus;
insert into bidata.dt_15_person_ehr_bonus
select 
    userid
    ,jobnumber
    ,name
    ,poidempadmin
    ,poidempreserve2
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    -- ,replace(substring_index(substring_index(position_name,"兼",1),"区",-1),"，","") -- 按 兼  区  分字段
    ,substring_index(position_name,"兼",1) as position_main-- 按 兼  分字段
    ,jobpost_name
    ,oidjoblevel
    ,entrydate
    ,startdate
    ,employeestatus
    ,lastworkdate
from pdm.ehr_employee
where name in 
(select person_name from bidata.ft_17_personscore_sales group by person_name )
group by name ;

alter table bidata.dt_15_person_ehr_bonus comment '奖金计算用到的营销中心人员信息表';
