-- 08_ft_18_person_kpi_score
/*建表
use bidata;
drop table if exists bidata.ft_18_person_kpi_score;
create table if not exists bidata.ft_18_person_kpi_score(
  `year` smallint(6) DEFAULT NULL COMMENT '年份',
  `quarter` smallint(6) DEFAULT NULL COMMENT '季度',
  `person_name` varchar(60) DEFAULT NULL COMMENT '姓名',
  `userid_ehr` varchar(30) DEFAULT NULL COMMENT 'userid_ehr',
  `employeestatus` varchar(30) DEFAULT NULL COMMENT '是否在职',
  `lastworkdate` date comment '最后工作日',
  `province_ori` varchar(60) DEFAULT NULL COMMENT '省份_线下表中',
  `position_name` varchar(60) DEFAULT NULL COMMENT '职位_线下表中',
  `1_sj_rate` float(8,5) DEFAULT NULL COMMENT '1_试剂业务完成率',
  `2_key_sj_rate` float(8,5) DEFAULT NULL COMMENT '2_重点产品完成率',
  `3_collection_rate` float(8,5) DEFAULT NULL COMMENT '3_回款完成率',
  `1_sj_score` float(8,5) DEFAULT NULL COMMENT '1_试剂业务得分',
  `2_key_sj_score` float(8,5) DEFAULT NULL COMMENT '2_重点产品得分',
  `3_collection_score` float(8,5) DEFAULT NULL COMMENT '3_回款得分',
  `4_expense_score` float(8,5) DEFAULT NULL COMMENT '4_费用控制得分',
  `5_superiors_score` float(8,5) DEFAULT NULL COMMENT '5_直接上级评分',
  `kpi_score` float(8,5) DEFAULT NULL COMMENT '季度业务考核得分',
  KEY `bidata_person_kpi_score_year` (`year`),
  KEY `bidata_person_kpi_score_quarter` (`quarter`),
  KEY `bidata_person_kpi_score_person_name` (`person_name`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='bi人员业务考核得分表（线下核算）';
*/

truncate table bidata.ft_18_person_kpi_score;
insert into bidata.ft_18_person_kpi_score
select 
    a.year
    ,a.quarter
    ,a.person_name
    ,a.userid_ehr
    ,b.employeestatus
    ,b.lastworkdate
    ,a.province_ori
    ,a.position_name
    ,a.1_sj_rate
    ,a.2_key_sj_rate
    ,a.3_collection_rate
    ,a.1_sj_score
    ,a.2_key_sj_score
    ,a.3_collection_score
    ,a.4_expense_score
    ,a.5_superiors_score
    ,a.kpi_score
from ufdata.x_person_kpi_score as a 
left join bidata.ft_71_employee as b 
on a.userid_ehr = b.userid;