-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2019年以后EHR部门档案表
-- 说明：取自pdm层employee_id,通过日期参数筛选计算
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者:
-- 开发日期：
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 
-- 调用方法　
/* 建表脚本
use report;
drop table if exists report.fin_41_ehr_employee_base;
create table if not exists report.fin_41_ehr_employee_base(
    `ddate` date comment '截止日期',
    `userid` varchar(20)  comment 'beisenuserid',
    `jobnumber` varchar(120)  comment '工号',
    `name` varchar(255)  comment '姓名',
    `poidempadmin` varchar(255)  comment '直接经理',
    `poidempreserve2` varchar(255)  comment '虚线经理',
    `age` varchar(20)  comment '年龄',
    `gender` varchar(2)  comment '性别',
    `workyeartotal` varchar(20)  comment '累计工龄',
    `workyearcompanytotal` varchar(20)  comment '累计司龄',
    `cdept_id` varchar(11)  comment '部门编号',
    `cdept_name` varchar(255)  comment '部门名称',
    `first_dept` varchar(120)  comment '一级部门',
    `second_dept` varchar(120)  comment '二级部门',
    `third_dept` varchar(120)  comment '三级部门',
    `fourth_dept` varchar(120)  comment '四级部门',
    `fifth_dept` varchar(120)  comment '五级部门',
    `sixth_dept` varchar(120)  comment '六级部门',
    `position_name` varchar(120)  comment '职位名称',
    `jobpost_name` varchar(120)  comment '职务名称',
    `oidjoblevel` varchar(120)  comment '职级名称',
    `entrydate` date  comment '入职日期',
    `startdate` date  comment '生效日期',
    `stopdate` date  comment '失效日期',
    `employeestatus` varchar(20)  comment '是否在职',
    `employmenttype` varchar(20)  comment '员工类型',
    `regularizationdate` date  comment '转正日期',
    `lastworkdate` date  comment '最后工作日',
    `if_regular_employee` varchar(20) comment '是否在编',
key fin_41_ehr_employee_base_userid (userid),
key fin_41_ehr_employee_base_name (name),
key fin_41_ehr_employee_base_cdept_id (cdept_id),
key fin_41_ehr_employee_base_position_name (position_name)
)engine=innodb default charset=utf8 comment='2019年以后部门档案表';
*/

-- 创建存储过程
use report;
drop procedure if exists report.fin_41_ehr_employee_base_pro;
delimiter $$
create procedure report.fin_41_ehr_employee_base_pro(in dt date)
begin
insert into report.fin_41_ehr_employee_base 
select 
    @dt as ddate
    ,userid
    ,jobnumber
    ,name
    ,poidempadmin
    ,poidempreserve2
    ,age
    ,gender
    ,workyeartotal
    ,workyearcompanytotal
    ,cdept_id
    ,cdept_name
    ,first_dept
    ,second_dept
    ,third_dept
    ,fourth_dept
    ,fifth_dept
    ,sixth_dept
    ,position_name
    ,jobpost_name
    ,oidjoblevel
    ,entrydate
    ,startdate
    ,stopdate
    ,employeestatus
    ,employmenttype
    ,regularizationdate
    ,lastworkdate
    ,case 
        when employmenttype in ('正式','兼职') then '正式编制'
        else '非编制'
    end as if_regular_employee
from pdm.ehr_employee_id  
where 
employeestatus in("正式","试用") and 
startdate <= @dt and 
stopdate >= @dt
;
end
$$
delimiter ;

-- 先清空
truncate table report.fin_41_ehr_employee_base;

-- 导入加日期参数导入
set @dt = '2019-01-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-02-28';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-03-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-04-30';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-05-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-06-30';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-07-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-08-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-09-30';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-10-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-11-30';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2019-12-31';
call report.fin_41_ehr_employee_base_pro(@dt);

-- 20年
delete from report.fin_41_ehr_employee_base where ddate >= '2020-01-01';
set @dt = '2020-01-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2020-02-29';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2020-03-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2020-04-30';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2020-05-31';
call report.fin_41_ehr_employee_base_pro(@dt);
set @dt = '2020-06-30';
call report.fin_41_ehr_employee_base_pro(@dt);

