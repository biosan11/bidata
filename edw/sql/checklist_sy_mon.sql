
-- CREATE TABLE `checklist_sy_mon` (
--   `province_ori` varchar(60) DEFAULT NULL COMMENT '销售省份',
--   `person_ori` varchar(60) DEFAULT NULL COMMENT '负责人',
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
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='检测量表-实验室-年月';



-- 新筛数据,采用实验时间来做判断
drop table if exists edw.checklist_sy_mon_pre;
create temporary table edw.checklist_sy_mon_pre as
select LEFT ( experiment_date, 7 ) AS y_mon
      ,hospital
      ,collection_hospital
      ,conclusion
      ,sum(amount) as amount
      ,project
  from share.neo_amount_experiment_date 
 where left(experiment_date,7) = '${y_mon}'
 group by y_mon,hospital,collection_hospital,conclusion,project
;

-- alter table edw.checklist_sy_mon_pre engine=MEMORY;  
CREATE INDEX index_checklist_sy_mon_pre_hospital ON edw.checklist_sy_mon_pre(hospital);
CREATE INDEX index_checklist_sy_mon_pre_collection ON edw.checklist_sy_mon_pre(collection_hospital);
CREATE INDEX index_checklist_sy_mon_pre_project ON edw.checklist_sy_mon_pre(project);

-- 清洗采血、实验单位、项目
drop table if exists edw.mid1_checklist_sy_mon;
create temporary table edw.mid1_checklist_sy_mon as
select a.conclusion
      ,y_mon
      ,a.hospital
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as company_id
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as company_exp
      ,a.collection_hospital
      ,case when c.ccusname is null then '请核查' else c.bi_cuscode end as bi_cuscode
      ,case when c.ccusname is null then '请核查' else c.bi_cusname end as bi_cusname
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
  from edw.checklist_sy_mon_pre a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.hospital = b.ccusname
  left join (select * from edw.dic_customer group by ccusname) c
    on a.collection_hospital = c.ccusname
;

delete from edw.checklist_sy_mon where y_mon = '${y_mon}';
insert into edw.checklist_sy_mon
select a.y_mon
      ,c.province
      ,b.p_charge
      ,a.hospital
      ,a.company_id
      ,a.company_exp
      ,a.collection_hospital
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.item_code
      ,a.item_name
      ,d.business_class
      ,a.amount
      ,a.conclusion
      ,localtimestamp()
  from edw.mid1_checklist_sy_mon a
  left join (select * from edw.map_cusitem_person group by ccuscode,item_code) b
    on a.company_id = b.ccuscode
   and a.item_code = b.item_code
  left join (select * from edw.map_customer group by bi_cuscode) c
    on a.company_id  = c.bi_cuscode
  left join (select * from edw.map_inventory group by item_code) d
    on a.item_code  = d.item_code
;

update edw.checklist_sy_mon set conclusion= '空值' where conclusion = '��';
update edw.checklist_sy_mon set conclusion= '空值' where conclusion = '�ٻ�ȷ��';
update edw.checklist_sy_mon set conclusion= '空值' where conclusion = '�ٻظ���';
update edw.checklist_sy_mon set conclusion= '空值' where conclusion = '0';
update edw.checklist_sy_mon set conclusion= '空值' where conclusion = 'nan';



