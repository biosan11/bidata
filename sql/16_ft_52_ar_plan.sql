-- 18_ft_52_ar_plan

/*
-- 建表
use bidata;
drop table if exists bidata.ft_52_ar_plan;
create table if not exists bidata.ft_52_ar_plan (
  `ccuscode_class` varchar(30) default null comment '客户与账款类型组合',
  `auto_id` int(11) default null comment '第一层主键',
  `company` varchar(60) default null comment '公司',
  `ccusname` varchar(120) default null comment '客户名称',
  `ccuscode` varchar(60) not null comment '客户编码',
  `true_ccuscode` varchar(60) not null comment '正确客户编码',
  `true_ccusname` varchar(120) not null comment '正确客户名称',
  `cpersonname` varchar(60) default null comment '负责人',
  `areadirector` varchar(60) default null comment '区域主管',
  `aperiod` smallint(6) default null comment '账期',
  `aperiod_special` varchar(50) default null comment '特殊账期',
  `mark_aperiod` varchar(20) default null comment '是否常规账期标记',
  `ddate` date default null comment '日期',
  `class` varchar(20) default null comment '产品类型',
  `amount_plan` float(12,2) default null comment '计划回款',
  `amount_act` float(12,2) default null comment '实际回款',
  key `index_edw_arp_auto_id` (`auto_id`),
  key `index_edw_arp_true_ccuscode` (`true_ccuscode`),
  key `index_edw_arp_true_ccusname` (`true_ccusname`)
) engine=innodb default charset=utf8 comment='计划回款表';
*/

-- 导入数据
truncate table bidata.ft_52_ar_plan;
insert into bidata.ft_52_ar_plan
select 
concat(true_ccuscode,class)
,auto_id
,company
,ccusname
,ccuscode
,true_ccuscode
,true_ccusname
,cpersonname
,areadirector
,ifnull(if((aperiod REGEXP '[^0-9.]')=1,365,aperiod),365) as aperiod
,if((aperiod REGEXP '[^0-9.]')=1,aperiod,null) as aperiod_special
,case 
    when (aperiod REGEXP '[^0-9.]')=1 then "否" 
    when aperiod is null then "否"
    else "是"
    end as mark_aperiod   -- 是否常规账期标记
,ddate
,class
,round(amount_plan/1000,2)
,round(amount_act/1000,2)
from edw.x_ar_plan
where date_add(current_date(),interval -24 month) <= ddate;