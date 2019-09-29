
-- CREATE TABLE `checklist_sy` (
--   `province_ori` varchar(60) DEFAULT NULL COMMENT '销售省份',
--   `person_ori` varchar(60) DEFAULT NULL COMMENT '负责人',
--   `ddate_sample` date DEFAULT NULL COMMENT '实验日期',
--   `hospital` varchar(20) DEFAULT NULL COMMENT '实验单位',
--   `company_id` varchar(120) DEFAULT NULL COMMENT '实验单位编号',
--   `company_exp` varchar(120) DEFAULT NULL COMMENT '实验单位名称',
--   `ddate` date DEFAULT NULL COMMENT '日期',
--   `collection_hospital` varchar(120) DEFAULT NULL COMMENT '采血单位',
--   `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编号',
--   `ccusname` varchar(120) DEFAULT NULL COMMENT '客户名称',
--   `item_code` varchar(40) DEFAULT NULL COMMENT '项目编号',
--   `item_name` varchar(255) DEFAULT NULL COMMENT '项目名称',
--   `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
--   `inum_person` int(6) DEFAULT NULL COMMENT '检测量',
--   `conclusion` varchar(60) DEFAULT NULL COMMENT '实验结论',
--   `sys_time` datetime DEFAULT NULL COMMENT '数据时间戳',
--   KEY `index_checklist_ccuscode` (`ccuscode`),
--   KEY `index_checklist_item_code` (`item_code`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='检测量表-实验室';



-- 新筛数据,采用实验时间来做判断
drop table if exists edw.checklist_sy_pre;
create temporary table edw.checklist_sy_pre as
select * 
  from share.neo_amount_experiment_date 
 where experiment_date = '${start_dt}'
;

-- alter table edw.checklist_sy_pre engine=MEMORY;  
-- CREATE INDEX index_checklist_sy_pre_hospital ON edw.checklist_sy_pre(hospital);
-- CREATE INDEX index_checklist_sy_pre_collection ON edw.checklist_sy_pre(collection_hospital);
-- CREATE INDEX index_checklist_sy_pre_project ON edw.checklist_sy_pre(project);

-- 清洗采血、实验单位、项目
drop table if exists edw.mid1_checklist_sy;
create temporary table edw.mid1_checklist_sy as
select a.conclusion
      ,a.experiment_date
      ,a.hospital
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as company_id
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as company_exp
      ,a.collection_hospital
      ,case when c.ccusname is null then (case when d.ccusname is null then '请核查' else d.bi_cuscode end) else c.bi_cuscode end as bi_cuscode
      ,case when c.ccusname is null then (case when d.ccusname is null then '请核查' else d.bi_cusname end) else c.bi_cusname end as bi_cusname
      ,a.amount
      ,case when a.project = 'G6PD检测' then 'XS0104'
            when a.project = 'OHP检测' then 'XS0103'
            when a.project = 'PHE检测' then 'XS0106'
            when a.project = 'TSH检测' then 'XS0108'
            else 'XS0301' end as item_code
      ,case when a.project = 'G6PD检测' then 'G6PD'
            when a.project = 'OHP检测' then '17α-OH-P'
            when a.project = 'PHE检测' then 'PKU'
            when a.project = 'TSH检测' then 'TSH'
            else '串联试剂' end as item_name
  from edw.checklist_sy_pre a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.collection_hospital = c.ccusname
  left join (select * from edw.dic_customer group by ccusname) d
    on concat(a.hospital,'-',a.collection_hospital) = d.ccusname
;

delete from edw.checklist_sy where ddate = '${start_dt}';
insert into edw.checklist_sy
select c.province
      ,b.p_charge
      ,a.experiment_date
      ,a.hospital
      ,a.company_id
      ,a.company_exp
      ,a.experiment_date
      ,a.collection_hospital
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.item_code
      ,a.item_name
      ,d.business_class
      ,a.amount
      ,a.conclusion
      ,localtimestamp()
  from edw.mid1_checklist_sy a
  left join (select * from edw.map_cusitem_person group by ccuscode,item_code) b
    on a.bi_cuscode = b.ccuscode
   and a.item_code = b.item_code
  left join (select * from edw.map_customer group by bi_cuscode) c
    on a.bi_cuscode  = c.bi_cuscode
  left join (select * from edw.map_inventory group by item_code) d
    on a.item_code  = d.item_code
;






