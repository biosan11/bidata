-- CREATE TABLE `jc_abnormal_day` (
-- `db` varchar(20) DEFAULT NULL COMMENT'区分博圣和博圣以外',
-- `source` varchar(20) DEFAULT NULL COMMENT'表来源',
-- `tb_name` varchar(50) DEFAULT NULL COMMENT'表名',
-- `ddate` date DEFAULT NULL COMMENT'数据时间',
-- `err_col_id` varchar(50) DEFAULT NULL COMMENT'问题字段id',
-- `err_value` varchar(50) DEFAULT NULL COMMENT'问题值',
-- `err_value2` varchar(250) DEFAULT NULL COMMENT'问题值辅助',
-- `type` varchar(50) DEFAULT NULL COMMENT'问题类型',
-- `leve` int(2) DEFAULT NULL COMMENT'严重等级，1日常，2影响数据库，3影响bi',
-- `date` date DEFAULT NULL COMMENT'记录问题时间'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据检测历史表';

-- u8相关模型

-- 数据量的监控

-- 1、第一层是使用sys_time来判断
insert into tracking.jc_abnormal_day
select distinct 
       'ufdata'
      ,'ufdata' as source
      ,tb_name
      ,left(sys_time,10)
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  from (
select sys_time,'ap_vouch' as tb_name from ufdata.ap_vouch where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'ap_vouchs' as tb_name from ufdata.ap_vouchs where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'ar_detail' as tb_name from ufdata.ar_detail where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'cm_contract' as tb_name from ufdata.cm_contract where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'cm_contract_item' as tb_name from ufdata.cm_contract_item where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'code' as tb_name from ufdata.code where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_account_equipments' as tb_name from ufdata.crm_account_equipments where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_accounts' as tb_name from ufdata.crm_accounts where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_appointments' as tb_name from ufdata.crm_appointments where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_competitors' as tb_name from ufdata.crm_competitors where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_deptment' as tb_name from ufdata.crm_deptment where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_gantt_opportunities' as tb_name from ufdata.crm_gantt_opportunities where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_new_key_events' as tb_name from ufdata.crm_new_key_events where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_new_sale_screenings' as tb_name from ufdata.crm_new_sale_screenings where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_sales_areas' as tb_name from ufdata.crm_sales_areas where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_systemusers' as tb_name from ufdata.crm_systemusers where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'customer' as tb_name from ufdata.customer where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'department' as tb_name from ufdata.department where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'dispatchlist' as tb_name from ufdata.dispatchlist where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'dispatchlists' as tb_name from ufdata.dispatchlists where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'fa_cards' as tb_name from ufdata.fa_cards where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'fa_cards_detail' as tb_name from ufdata.fa_cards_detail where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'fa_cardssheets' as tb_name from ufdata.fa_cardssheets where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'gl_accvouch' as tb_name from ufdata.gl_accvouch where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'inventory' as tb_name from ufdata.inventory where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_fnabudgetfeetype' as tb_name from ufdata.oa_fnabudgetfeetype where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_fnabudgetinfo' as tb_name from ufdata.oa_fnabudgetinfo where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_fnabudgetinfodetail' as tb_name from ufdata.oa_fnabudgetinfodetail where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_formtable_main_112' as tb_name from ufdata.oa_formtable_main_112 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_formtable_main_183' as tb_name from ufdata.oa_formtable_main_183 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_formtable_main_183_dt1' as tb_name from ufdata.oa_formtable_main_183_dt1 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_formtable_main_6' as tb_name from ufdata.oa_formtable_main_6 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_hrmdepartment' as tb_name from ufdata.oa_hrmdepartment where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_hrmlocations' as tb_name from ufdata.oa_hrmlocations where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_hrmresource' as tb_name from ufdata.oa_hrmresource where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_hrmsubcompany' as tb_name from ufdata.oa_hrmsubcompany where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_uf_u8dykm' as tb_name from ufdata.oa_uf_u8dykm where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_workflow_requestbase' as tb_name from ufdata.oa_workflow_requestbase where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_workflow_selectitem' as tb_name from ufdata.oa_workflow_selectitem where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'person' as tb_name from ufdata.person where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'rdrecord32' as tb_name from ufdata.rdrecord32 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'rdrecords32' as tb_name from ufdata.rdrecords32 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'salebillvouch' as tb_name from ufdata.salebillvouch where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'salebillvouchs' as tb_name from ufdata.salebillvouchs where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'so_sodetails' as tb_name from ufdata.so_sodetails where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'so_somain' as tb_name from ufdata.so_somain where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'warehouse' as tb_name from ufdata.warehouse where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_inspection' as tb_name from ufdata.oa_meet_market_inspection where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_conference' as tb_name from ufdata.oa_meet_market_conference where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_salon' as tb_name from ufdata.oa_meet_market_salon where left(sys_time,10) <>CURDATE( ) or sys_time is null
) a;


-- 2、第一层和第二层监控
-- 2.1、全量的通过时间戳来进行判断
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,tb_name
      ,left(sys_time,10)
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  from (
select sys_time,'accvouch_oa' as tb_name from edw.accvouch_oa where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'accvouch_u8' as tb_name from edw.accvouch_u8 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'ar_detail' as tb_name from edw.ar_detail where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'cm_contract' as tb_name from edw.cm_contract where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_account_equipments' as tb_name from edw.crm_account_equipments where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_appointments' as tb_name from edw.crm_appointments where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_gantt_opportunities' as tb_name from edw.crm_gantt_opportunities where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_key_events' as tb_name from edw.crm_key_events where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'crm_sale_screenings' as tb_name from edw.crm_sale_screenings where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'customer' as tb_name from edw.customer where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'ehr_employee_id' as tb_name from edw.ehr_employee_id where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'fa_cards' as tb_name from edw.fa_cards where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'inventory' as tb_name from edw.inventory where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_budget_19' as tb_name from edw.oa_budget_19 where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'yj_invoince_stock' as tb_name from edw.yj_invoince_stock where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'yj_outdepot' as tb_name from edw.yj_outdepot where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_inspection' as tb_name from edw.oa_meet_market_inspection where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_conference' as tb_name from edw.oa_meet_market_conference where left(sys_time,10) <>CURDATE( ) or sys_time is null union
select sys_time,'oa_meet_market_salon' as tb_name from edw.oa_meet_market_salon where left(sys_time,10) <>CURDATE( ) or sys_time is null
) a;

-- 线下数据监控
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,table_name
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  from information_schema.tables
 where table_schema = 'edw'
   and avg_row_length = 0
   and left(table_name,2) = 'x_'
;

-- 线上的增量监控insert into tracking.jc_abnormal_day
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'outdepot_order'
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  FROM (SELECT count( * ) AS num FROM ufdata.rdrecord32 a
		LEFT JOIN edw.outdepot_order b ON a.id = b.id and a.db = b.db WHERE b.id IS NULL ) a 
WHERE a.num > 0;

insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'invoice_order'
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  FROM (SELECT count( * ) AS num FROM ufdata.salebillvouch a
		LEFT JOIN edw.invoice_order b ON a.sbvid = b.sbvid and a.db = b.db
	WHERE b.sbvid IS NULL ) a 
WHERE a.num > 0;

insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'dispatch_order'
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  FROM (SELECT count( * ) AS num FROM ufdata.dispatchlists a
		LEFT JOIN edw.dispatch_order b ON a.autoid = b.autoid and a.db = b.db
	WHERE b.autoid IS NULL ) a 
WHERE a.num > 0;

insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'sales_order'
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  FROM (SELECT count( * ) AS num FROM ufdata.so_sodetails a
		LEFT JOIN edw.sales_order b ON a.autoid = b.autoid and a.db = b.db
	WHERE b.autoid IS NULL ) a 
WHERE a.num > 0;

-- 3、第二层和第三层监控






-- 4、bi层数据量监控
insert into tracking.jc_abnormal_day
select distinct 
       'bidata'
      ,'bidata' as source
      ,table_name
      ,CURDATE( )
      ,null
      ,null
      ,null
      ,'数量监控' as type
      ,3 as leve
      ,CURDATE( ) as date
  from information_schema.tables
 where table_schema = 'bidata'
   and avg_row_length = 0
;

