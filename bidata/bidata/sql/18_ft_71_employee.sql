-- 25_ft_71_employee

/*
-- 建表 bidata.ft_71_employee
use bidata;
drop table if exists bidata.ft_71_employee;
create table bidata.ft_71_employee(
    userid varchar(20) comment 'BeisenUserID',
    name varchar(120) comment '姓名',
    poidempadmin varchar(120) comment '直接经理',
    age smallint comment '年龄',
    gender varchar(2) comment '性别',
    major varchar(255) comment '专业',
    educationlevel varchar(12) comment '学历',
    workyeartotal float(4,1) comment '累计工龄',
    workyearcompanytotal float(4,1) comment '累计司龄',
    first_dept varchar(120) comment '一级部门',
    second_dept varchar(120) comment '二级部门',
    third_dept varchar(120) comment '三级部门',
    fourth_dept varchar(120) comment '四级部门',
    fifth_dept varchar(120) comment '五级部门',
    sixth_dept varchar(120) comment '',
    position_name varchar(120) comment '职位名称',
    position_main varchar(120) comment '主要职位',
    jobpost_name varchar(120) comment '职务名称',
    oidjoblevel varchar(120) comment '职级名称',
    entrydate date comment '入职日期',
    startdate date comment '生效日期',
    stopdate date comment '失效日期',
    TransitionType varchar(120) comment '异动类型',
    employeestatus varchar(20) comment '是否在职',
    employmenttype varchar(20) comment '员工类型',
    extlizhireason_107502_632202192 text comment '离职原因说明',
    educationlevel_ varchar(20) comment '学历分段',
    age_ varchar(20) comment '年龄分段',
    workyear1_ varchar(20) comment '司龄分段',
    workyear2_ varchar(20) comment '工龄分段',
    sort_workyear2 smallint comment '排序辅助_工龄',
    sort_workyear1 smallint comment '排序辅助_司龄',
    sort_edu smallint comment '排序辅助_学历',
    sort_age smallint comment '排序辅助_年龄',
    key bidata_ft_71_employee_userid (userid),
    key bidata_ft_71_employee_name (name)
) engine=innodb default charset=utf8 comment='EHR人事信息表';

drop table if exists bidata.ft_71_employee_id;
create table bidata.ft_71_employee_id(
    userid varchar(20) comment 'BeisenUserID',
    name varchar(120) comment '姓名',
    poidempadmin varchar(120) comment '直接经理',
    age smallint comment '年龄',
    gender varchar(2) comment '性别',
    major varchar(255) comment '专业',
    educationlevel varchar(12) comment '学历',
    workyeartotal float(4,1) comment '累计工龄',
    workyearcompanytotal float(4,1) comment '累计司龄',
    first_dept varchar(120) comment '一级部门',
    second_dept varchar(120) comment '二级部门',
    third_dept varchar(120) comment '三级部门',
    fourth_dept varchar(120) comment '四级部门',
    fifth_dept varchar(120) comment '五级部门',
    sixth_dept varchar(120) comment '',
    position_name varchar(120) comment '职位名称',
    position_main varchar(120) comment '主要职位',
    jobpost_name varchar(120) comment '职务名称',
    oidjoblevel varchar(120) comment '职级名称',
    entrydate date comment '入职日期',
    startdate date comment '生效日期',
    stopdate date comment '失效日期',
    TransitionType varchar(120) comment '异动类型',
    employeestatus varchar(20) comment '是否在职',
    employmenttype varchar(20) comment '员工类型',
    extlizhireason_107502_632202192 text comment '离职原因说明',
    educationlevel_ varchar(20) comment '学历分段',
    age_ varchar(20) comment '年龄分段',
    workyear1_ varchar(20) comment '司龄分段',
    workyear2_ varchar(20) comment '工龄分段',
    sort_workyear2 smallint comment '排序辅助_工龄',
    sort_workyear1 smallint comment '排序辅助_司龄',
    sort_edu smallint comment '排序辅助_学历',
    sort_age smallint comment '排序辅助_年龄',
    key bidata_ft_71_employee_id_userid (userid),
    key bidata_ft_71_employee_id_name (name)
) engine=innodb default charset=utf8 comment='EHR人事信息表(异动)';
 */
 
-- 加工并导入第三层数据
truncate table bidata.ft_71_employee;
insert into bidata.ft_71_employee
select
    userid
    ,name
    ,poidempadmin
    ,age
    ,gender
    ,major
    ,educationlevel
    ,workyeartotal
    ,workyearcompanytotal
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    ,substring_index(position_name,"兼",1) as position_main
    ,jobpost_name
    ,oidjoblevel
    ,entrydate
    ,startdate
    ,stopdate
    ,TransitionType
    ,employeestatus
    ,employmenttype
    ,extlizhireason_107502_632202192
    ,case 
        when educationlevel = "博士研究生" then "博士研究生"
        when educationlevel = "mba" or educationlevel = "硕士研究生" then "硕士研究生"
        when educationlevel = "本科" then "本科"
        when educationlevel = "大专" then "大专"
        else "高中及以下"
        end as educationlevel_
    ,case 
        when age <= 25 then "小于25(含)岁"
        when age <= 30 then "25-30(含)岁"
        when age <= 40 then "30-40(含)岁"
        else "大于40岁"
        end as age_
     ,case 
        when workyearcompanytotal <= 0.5 then "0.5年(含)以下"
        when workyearcompanytotal <= 1 then "0.5-1(含)年"
        when workyearcompanytotal <= 2 then "1-2(含)年"
        when workyearcompanytotal <= 5 then "2-5(含)年"
        else "5年以上"
        end as workyear1_
    ,case 
        when workyeartotal <= 0.5 then "0.5年(含)以下"
        when workyeartotal <= 1 then "0.5-1(含)年"
        when workyeartotal <= 2 then "1-2(含)年"
        when workyeartotal <= 5 then "2-5(含)年"
        when workyeartotal <= 10 then "5-10(含)年"
        when workyeartotal <= 20 then "10-20(含)年"
        else "20年以上"
        end as workyear2_
    ,case 
        when workyeartotal <= 0.5 then 1
        when workyeartotal <= 1 then 2
        when workyeartotal <= 2 then 3
        when workyeartotal <= 5 then 4
        when workyeartotal <= 10 then 5
        when workyeartotal <= 20 then 6
        else 7
        end as sort_workyear2
     ,case 
        when workyearcompanytotal <= 0.5 then 1
        when workyearcompanytotal <= 1 then 2
        when workyearcompanytotal <= 2 then 3
        when workyearcompanytotal <= 5 then 4
        else 5
        end as workyear1_
    ,case 
        when educationlevel = "博士研究生" then 1
        when educationlevel = "mba" or educationlevel = "硕士研究生" then 2
        when educationlevel = "本科" then 3
        when educationlevel = "大专" then 4
        else 5
        end as sort_edu
    ,case 
        when age <= 25 then 1
        when age <= 30 then 2
        when age <= 40 then 3
        else 4
        end as sort_age
from pdm.ehr_employee
;

truncate table bidata.ft_71_employee_id;
insert into bidata.ft_71_employee_id
select
    userid
    ,name
    ,poidempadmin
    ,age
    ,gender
    ,major
    ,educationlevel
    ,workyeartotal
    ,workyearcompanytotal
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    ,substring_index(position_name,"兼",1) as position_main
    ,jobpost_name
    ,oidjoblevel
    ,entrydate
    ,startdate
    ,stopdate
    ,TransitionType
    ,employeestatus
    ,employmenttype
    ,null
    ,case 
        when educationlevel = "博士研究生" then "博士研究生"
        when educationlevel = "mba" or educationlevel = "硕士研究生" then "硕士研究生"
        when educationlevel = "本科" then "本科"
        when educationlevel = "大专" then "大专"
        else "高中及以下"
        end as educationlevel_
    ,case 
        when age <= 25 then "小于25(含)岁"
        when age <= 30 then "25-30(含)岁"
        when age <= 40 then "30-40(含)岁"
        else "大于40岁"
        end as age_
     ,case 
        when workyearcompanytotal <= 0.5 then "0.5年(含)以下"
        when workyearcompanytotal <= 1 then "0.5-1(含)年"
        when workyearcompanytotal <= 2 then "1-2(含)年"
        when workyearcompanytotal <= 5 then "2-5(含)年"
        else "5年以上"
        end as workyear1_
    ,case 
        when workyeartotal <= 0.5 then "0.5年(含)以下"
        when workyeartotal <= 1 then "0.5-1(含)年"
        when workyeartotal <= 2 then "1-2(含)年"
        when workyeartotal <= 5 then "2-5(含)年"
        when workyeartotal <= 10 then "5-10(含)年"
        when workyeartotal <= 20 then "10-20(含)年"
        else "20年以上"
        end as workyear2_
    ,case 
        when workyeartotal <= 0.5 then 1
        when workyeartotal <= 1 then 2
        when workyeartotal <= 2 then 3
        when workyeartotal <= 5 then 4
        when workyeartotal <= 10 then 5
        when workyeartotal <= 20 then 6
        else 7
        end as sort_workyear2
     ,case 
        when workyearcompanytotal <= 0.5 then 1
        when workyearcompanytotal <= 1 then 2
        when workyearcompanytotal <= 2 then 3
        when workyearcompanytotal <= 5 then 4
        else 5
        end as workyear1_
    ,case 
        when educationlevel = "博士研究生" then 1
        when educationlevel = "mba" or educationlevel = "硕士研究生" then 2
        when educationlevel = "本科" then 3
        when educationlevel = "大专" then 4
        else 5
        end as sort_edu
    ,case 
        when age <= 25 then 1
        when age <= 30 then 2
        when age <= 40 then 3
        else 4
        end as sort_age
from pdm.ehr_employee_id
;
