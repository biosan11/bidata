
/*
-- 建表 
use bidata;
drop table if exists bidata.ft_91_gantt_opportunities;
create table if not exists bidata.ft_91_gantt_opportunities(
    opportunityid varchar(60) comment '未知',
    bi_cuscode varchar(30) comment 'bi客户编码',
    bi_cusname varchar(60) comment 'bi客户名称',
    sales_region varchar(60) comment '大区',
    province varchar(60) comment '省份',
    city varchar(60) comment'地级市',
    new_project_num varchar(60) comment '项目编号',
    name varchar(60) comment '项目名称',
    new_importance varchar(60) comment '是否重点项目',
    new_type varchar(6) comment '甘特类型',
    new_business_type varchar(3) comment '业务类型',
    new_open_date date comment '计划结束日期',
    ownerid varchar(60) comment '姓名',
    budgetamount_base float(13,3) comment '预算金额(基础)',
    finaldecisiondate date comment '项目立项时间',
    estimatedclosedate date comment '预计签约时间',
    state  varchar(20) comment'状态',
    status varchar(20) comment'状态描述',
    finish_date date comment '实际完成日期',
    key bidata_ft_91_gantt_opportunities_opportunityid (opportunityid),
    key bidata_ft_91_gantt_opportunities_bi_cuscode (bi_cuscode),
    key bidata_ft_91_gantt_opportunities_new_project_num (new_project_num)
) engine=innodb default charset=utf8 comment='CRM业务项目表';

drop table if exists bidata.ft_92_gantt_keyevents;
create table if not exists bidata.ft_92_gantt_keyevents(
    new_key_eventid varchar(120) comment '关键事件主键',
    new_opp varchar(120) comment '业务项目',
    new_contact varchar(60) comment '姓名',
    new_name text comment '业务项目',
    new_finish_time float(13,3) comment '距截至时间（天）',
    new_region_trace varchar(120) comment '大区关注节点',
    new_province_trace varchar(120) comment '省区关注节点',
    ownerid varchar(60) comment '姓名',
    new_deadline date comment '截止日期',
    new_status varchar(3) comment '事件状态',
    new_finish_date date comment '事件完成日期',
    new_deflection varchar(120) comment '偏差',
    new_memo varchar(120) comment '备注（why delay）',
    rownum tinyint comment'关键事件排序',
    key bidata_ft_92_gantt_keyevents_new_key_eventid (new_key_eventid),
    key bidata_ft_92_gantt_keyevents_new_opp (new_opp)
) engine=innodb default charset=utf8 comment='CRM关键事件表';

 */
 
truncate table bidata.ft_91_gantt_opportunities;
insert into bidata.ft_91_gantt_opportunities
select 
    opportunityid
    ,bi_cuscode
    ,bi_cusname
    ,new_area
    ,new_province
    ,new_city
    ,new_project_num
    ,name
    ,new_importance
    ,new_type
    ,new_business_type
    ,new_open_date
    ,ownerid
    ,budgetamount_base
    ,finaldecisiondate
    ,estimatedclosedate
    ,state
    ,status
    ,null as finish_date  -- 实际完成日期 暂时默认为2019-12-31  等CRM把这个处理好再接入
from edw.crm_gantt_opportunities
where left(name,4) != "其他项目"
;

truncate table bidata.ft_92_gantt_keyevents;
insert into bidata.ft_92_gantt_keyevents
select 
    new_key_eventid
    ,new_opp
    ,new_contact
    ,new_name
    ,new_finish_time
    ,new_region_trace
    ,new_province_trace
    ,ownerid
    ,new_deadline
    ,new_status
    ,new_finish_date
    ,new_deflection
    ,new_memo
    ,rownum
from edw.crm_key_events
where left(name,4) != "其他项目";

-- 有一条日期 为1905-7-11 修改掉
update bidata.ft_92_gantt_keyevents 
set new_finish_date = "2019-01-01"
where new_finish_date = "1905-07-11";


















