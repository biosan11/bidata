-- CREATE TABLE `jc_abnormal_day` (
--  `db` varchar(20) DEFAULT NULL COMMENT '区分博圣和博圣以外',
--  `source` varchar(20) DEFAULT NULL COMMENT '表来源',
--  `tb_name` varchar(50) DEFAULT NULL COMMENT '表名',
--   `ddate` date DEFAULT NULL COMMENT '数据时间',
--  `err_col_id` varchar(50) DEFAULT NULL COMMENT '问题字段id',
--  `err_value` varchar(50) DEFAULT NULL COMMENT '问题值',
--  `err_value2` varchar(250) DEFAULT NULL COMMENT '问题值辅助',
--  `type` varchar(50) DEFAULT NULL COMMENT '问题类型',
--  `leve` int(2) DEFAULT NULL COMMENT '严重等级，1日常，2影响数据库，3影响bi',
--  `date` date DEFAULT NULL COMMENT '记录问题时间'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据检测历史表';
--
--
-- CREATE TABLE `jc_abnormal_all` (
--   `db` varchar(20) DEFAULT NULL COMMENT '区分博圣和博圣以外',
--   `source` varchar(20) DEFAULT NULL COMMENT '表来源',
--   `tb_name` varchar(50) DEFAULT NULL COMMENT '表名',
--   `ddate` date DEFAULT NULL COMMENT '数据时间',
--   `err_col_id` varchar(50) DEFAULT NULL COMMENT '问题字段id',
--   `err_value` varchar(50) DEFAULT NULL COMMENT '问题值',
--   `err_value2` varchar(250) DEFAULT NULL COMMENT '问题值辅助',
--   `type` varchar(50) DEFAULT NULL COMMENT '问题类型',
--   `leve` int(2) DEFAULT NULL COMMENT '严重等级，1日常，2影响数据库，3影响bi',
--   `date` date DEFAULT NULL COMMENT '记录问题时间'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='数据检测历史表';

-- 清空表，每日新增
truncate table tracking.jc_abnormal_day;

-- 客户相关监测,crm相关模型
insert into tracking.jc_abnormal_day
select distinct 'crm'
      ,'edw' as source
      ,'accvouch_u8' as tb_name
      ,dbill_date
      ,'ccus_id' as err_col_id
      ,ccus_id as err_value
      ,'' as err_value2
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.accvouch_u8 where bi_cuscode = '请核查'
;

-- 增加oa费用客户的监控,这家客户不知道什么情况
insert into tracking.jc_abnormal_day
select distinct 'crm'
      ,'edw' as source
      ,'accvouch_oa' as tb_name
      ,pingzhengscrq
      ,'kehumc' as err_col_id
      ,'' as err_value
      ,kehumc as err_value2
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.accvouch_oa where bi_cuscode = '请核查' and kehumc <> 'Hamilton'
;

insert into tracking.jc_abnormal_day
select distinct 'crm'
      ,'edw' as source
      ,'crm_key_events' as tb_name
      ,null
      ,'cuscode' as err_col_id
      ,cuscode as err_value
      ,cusname as err_value2
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.crm_key_events where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 'crm'
      ,'edw' as source
      ,'crm_sale_screenings' as tb_name
      ,null
      ,'cuscode' as err_col_id
      ,cuscode as err_value
      ,cusname as err_value2
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.crm_sale_screenings where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'crm_gantt_opportunities' as tb_name
      ,null
      ,'cuscode' as err_col_id
      ,cuscode as err_value
      ,cusname as err_value2
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.crm_gantt_opportunities where bi_cuscode = '请核查'
;

-- u8相关模型
insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_666' then 'UFDATA_666' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'ar_detail' as tb_name
      ,null
      ,'cdwcode' as err_col
      ,cdwcode as err_value
      ,cDefine2 as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.ar_detail where true_ccuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_666' then 'UFDATA_666' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'invoice_order' as tb_name
      ,ddate
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.invoice_order where true_ccuscode = '请核查' order by ddate asc) a
 group by ccuscode 
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_666' then 'UFDATA_666' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'outdepot_order' as tb_name
      ,ddate
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.outdepot_order where true_ccuscode = '请核查' order by ddate asc) a
 group by ccuscode 
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_666' then 'UFDATA_666' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'sales_order' as tb_name
      ,ddate
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.sales_order where true_ccuscode = '请核查' order by ddate asc) a
 group by ccuscode 
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_666' then 'UFDATA_666' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'dispatch_order' as tb_name
      ,ddate
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.dispatch_order where true_ccuscode = '请核查' order by ddate asc) a
 group by ccuscode 
;

-- 线下客户清洗
insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_detection_table' as tb_name
      ,null
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_detection_table where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_competitor_item' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_competitor_item where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_account_sy' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_account_sy where bi_cuscode = '请核查'
;

-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'excel'
--       ,'edw' as source
--       ,'x_ccus_seniority' as tb_name
--       ,null
--       ,'ccusname' as err_col
--       ,null as err_value
--       ,ccusname as err_col_name
--       ,'客户清洗' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from edw.x_ccus_seniority where bi_cuscode = '请核查'
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_depreciation_18' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_18 where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_cusitem_enddate' as tb_name
      ,null
      ,'ccusname' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_cusitem_enddate where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_depreciation_19' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_19 where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_launch' as tb_name
      ,null
      ,'ccusname_ori' as err_col
      ,null as err_value
      ,ccusname_ori as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_launch where ccuscode = '请核查'
;

-- 19年预算表客户清洗存在问题
-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'excel'
--       ,'edw' as source
--       ,'x_expenses_budget_19' as tb_name
--       ,null
--       ,'ccusname_ori' as err_col
--       ,null as err_value
--       ,ccusname_ori as err_col_name
--       ,'客户清洗' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from edw.x_expenses_budget_19 where bi_cuscode = '请核查'
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_budget_19' as tb_name
      ,null
      ,'ccusname' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_budget_19 where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_hospital' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_hospital where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_ar_plan' as tb_name
      ,null
      ,'ccusname' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ar_plan where true_ccuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_hospital' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_hospital where bi_cuscode = '请核查'
;

-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'excel'
--       ,'edw' as source
--       ,'x_account_fy' as tb_name
--       ,null
--       ,'kehumc' as err_col
--       ,null as err_value
--       ,kehumc as err_col_name
--       ,'客户清洗' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from edw.x_account_fy where bi_cuscode = '请核查'
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_ldt_bk' as tb_name
      ,null
      ,'ccusname' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_bk where bi_cuscode = '请核查'
;


-- crm线上导出的装机档案，停用
-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'excel'
--       ,'edw' as source
--       ,'x_cuspro_archives' as tb_name
--       ,null
--       ,'ccusname' as err_col
--       ,ccuscode as err_value
--       ,ccusname as err_col_name
--       ,'客户清洗' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from edw.x_cuspro_archives where true_ccuscode = '请核查'
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_bk' as tb_name
      ,null
      ,'ccusname_ori' as err_col
      ,null as err_value
      ,ccusname_ori as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bk where true_ccuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_bkgr' as tb_name
      ,null
      ,'old_finnal_ccusname' as err_col
      ,null as err_value
      ,old_finnal_ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bkgr where finnal_ccuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_bkgr' as tb_name
      ,null
      ,'ccusname_ori' as err_col
      ,null as err_value
      ,ccusname_ori as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bkgr where true_ccuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_ldt_list_before' as tb_name
      ,null
      ,'true_ccusname_ori' as err_col
      ,null as err_value
      ,true_ccusname_ori as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_list_before where true_ccuscode = '请核查'
;

-- 药监数据客户清洗
insert into tracking.jc_abnormal_day
select distinct 
       'yj'
      ,'edw' as source
      ,'yj_outdepot' as tb_name
      ,null
      ,'ccusname' as err_col
      ,null as err_value
      ,ccusname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.yj_outdepot where bi_cuscode = '请核查'
;

-- oa营销会议记录
insert into tracking.jc_abnormal_day
select distinct 
       'oa'
      ,'edw' as source
      ,'oa_meet_market_salon' as tb_name
      ,null
      ,'kehumc' as err_col
      ,null as err_value
      ,kehumc as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.oa_meet_market_salon where bi_cuscode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'oa'
      ,'edw' as source
      ,'oa_meet_market_inspection' as tb_name
      ,null
      ,'kehumc' as err_col
      ,null as err_value
      ,kehumc as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.oa_meet_market_inspection where bi_cuscode = '请核查'
;

-- crm相关数据
insert into tracking.jc_abnormal_day
select distinct 
       'crm'
      ,'edw' as source
      ,'crm_account_equipments' as tb_name
      ,null
      ,'custname' as err_col
      ,null as err_value
      ,custname as err_col_name
      ,'客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.crm_account_equipments where bi_cuscode = '请核查'
;





-- 最终客户清洗
insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_launch' as tb_name
      ,null
      ,'finnal_ccuaname_ori' as err_col
      ,null as err_value
      ,finnal_ccuaname_ori as err_col_name
      ,'最终客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_launch where finnal_ccuscode = '请核查'
;

-- 这里需要判断编码和名称
-- 注解，最终客户名称没有清洗出来的，先判断客户是否清洗出来，没有提示先清洗客户，然后在判断编号是否在名称的基础上清洗出来
insert into tracking.jc_abnormal_day
select distinct 
       'UFDATA_111'
      ,'edw' as source
      ,'invoice_order' as tb_name
      ,ddate
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then 'true_ccuscode'
            else 'true_finnal_ccusname2' end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccuscode
            else null end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccusname
            when true_finnal_ccusname2 = '请核查' then finnal_ccusname
            else true_finnal_ccusname2 end
      ,'最终客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.invoice_order 
 where true_finnal_ccuscode = '请核查' or true_finnal_ccusname2 = '请核查'
;


insert into tracking.jc_abnormal_day
select distinct 
       'UFDATA_111'
      ,'edw' as source
      ,'dispatch_order' as tb_name
      ,ddate
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then 'true_ccuscode'
            else 'true_finnal_ccusname2' end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccuscode
            else null end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccusname
            when true_finnal_ccusname2 = '请核查' then finnal_ccusname
            else true_finnal_ccusname2 end
      ,'最终客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.dispatch_order 
 where true_finnal_ccuscode = '请核查' or true_finnal_ccusname2 = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'UFDATA_111'
      ,'edw' as source
      ,'sales_order' as tb_name
      ,ddate
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then 'true_ccuscode'
            else 'true_finnal_ccusname2' end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccuscode
            else null end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccusname
            when true_finnal_ccusname2 = '请核查' then finnal_ccusname
            else true_finnal_ccusname2 end
      ,'最终客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.sales_order 
 where true_finnal_ccuscode = '请核查' or true_finnal_ccusname2 = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'UFDATA_111'
      ,'edw' as source
      ,'outdepot_order' as tb_name
      ,ddate
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then 'true_ccuscode'
            else 'true_finnal_ccusname2' end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccuscode
            else null end
      ,case when true_finnal_ccusname2 = '请核查'  and true_ccuscode = '请核查' then '请先清洗客户'
            when true_finnal_ccusname2 = '请核查' and finnal_ccusname is null then true_ccusname
            when true_finnal_ccusname2 = '请核查' then finnal_ccusname
            else true_finnal_ccusname2 end
      ,'最终客户清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.outdepot_order 
 where true_finnal_ccuscode = '请核查' or true_finnal_ccusname2 = '请核查'
;




-- 以下逻辑可采用视图模式展示
-- 去重，u8的账户要是没有名称补全
-- 按照编号清洗的编号去重
-- insert into tracking.jc_abnormal_day
-- select *
--   from tracking.jc_abnormal_day
--  where db in ('UFDATA_111','mbt','crm')
--  group by err_value,db,tb_name
-- ;
-- 
-- -- 按照名称清洗的按名称去重
-- insert into tracking.jc_abnormal_day
-- select *
--   from tracking.jc_abnormal_day
--  where db in ('excel')
--  group by err_value2,db,tb_name
-- ;

-- 更新只有编号没有名称的用户
update tracking.jc_abnormal_day a
 inner join (select * from ufdata.customer where db = 'UFDATA_889_2019') b
    on a.err_value = b.ccuscode
   set a.err_value2 = b.ccusname
 where a.err_value2 is null
   and a.db = 'mbt'
;

update tracking.jc_abnormal_day a
 inner join (select * from ufdata.customer where db <> 'UFDATA_889_2019' group by ccuscode) b
    on a.err_value = b.ccuscode
   set a.err_value2 = b.ccusname
 where a.err_value2 is null
   and a.db = 'UFDATA_111'
;



-- 这里新增对层面的客户监控
insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_11_sales' as tb_name
      ,null
      ,'ccuscode' as err_col
      ,null as err_value
      ,ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_11_sales a
  left join bidata.dt_12_customer b
    on a.ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;


insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_11_sales' as tb_name
      ,null
      ,'finnal_ccuscode' as err_col
      ,null as err_value
      ,finnal_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_11_sales a
  left join bidata.dt_12_customer b
    on a.finnal_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_12_sales_budget' as tb_name
      ,null
      ,'true_ccuscode' as err_col
      ,null as err_value
      ,true_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_12_sales_budget a
  left join bidata.dt_12_customer b
    on a.true_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_13_sales_budget_new' as tb_name
      ,null
      ,'true_ccuscode' as err_col
      ,null as err_value
      ,true_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_13_sales_budget_new a
  left join bidata.dt_12_customer b
    on a.true_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_21_outdepot' as tb_name
      ,null
      ,'ccuscode' as err_col
      ,null as err_value
      ,ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_21_outdepot a
  left join bidata.dt_12_customer b
    on a.ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_21_outdepot' as tb_name
      ,null
      ,'finnal_ccuscode' as err_col
      ,null as err_value
      ,finnal_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_21_outdepot a
  left join bidata.dt_12_customer b
    on a.finnal_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_31_checklist' as tb_name
      ,null
      ,'ccuscode' as err_col
      ,null as err_value
      ,ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_31_checklist a
  left join bidata.dt_12_customer b
    on a.ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_52_ar_plan' as tb_name
      ,null
      ,'true_ccuscode' as err_col
      ,null as err_value
      ,true_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_52_ar_plan a
  left join bidata.dt_12_customer b
    on a.true_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_61_dispatch' as tb_name
      ,null
      ,'ccuscode' as err_col
      ,null as err_value
      ,ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_61_dispatch a
  left join bidata.dt_12_customer b
    on a.ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

-- 暂时不监控，脚本还在修改
-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'erp'
--       ,'bidata' as source
--       ,'ft_51_ar_detail' as tb_name
--       ,null
--       ,'true_ccuscode' as err_col
--       ,null as err_value
--       ,true_ccuscode as err_col_name
--       ,'客户监控' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from bidata.ft_51_ar_detail a
--   left join bidata.dt_12_customer b
--     on a.true_ccuscode  = b.bi_cuscode
--  where b.bi_cuscode is null
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_52_ar_plan' as tb_name
      ,null
      ,'true_ccuscode' as err_col
      ,null as err_value
      ,true_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_52_ar_plan a
  left join bidata.dt_12_customer b
    on a.true_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

insert into tracking.jc_abnormal_day
select distinct 
       'erp'
      ,'bidata' as source
      ,'ft_61_dispatch' as tb_name
      ,null
      ,'finnal_ccuscode' as err_col
      ,null as err_value
      ,finnal_ccuscode as err_col_name
      ,'客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from bidata.ft_61_dispatch a
  left join bidata.dt_12_customer b
    on a.finnal_ccuscode  = b.bi_cuscode
 where b.bi_cuscode is null
;

-- 萧山医院的外送如果在U8有录账了，要监测出来，即停止一览表的收入统计
--  `ccusname` LIKE '%浙江萧山医院%' 
--  AND `db` LIKE 'UFDATA%' 
--  AND `ccustype` = 'LDT' 
--  AND `ddate` >= '2020-01-01' 

insert into tracking.jc_abnormal_day
select distinct 
       db
      ,'pdm' as source
      ,'invoice_order' as tb_name
      ,ddate
      ,'ccuscode' as err_col
      ,ccuscode as err_value
      ,ccusname as err_col_name
      ,'客户监控' as type
      ,2 as leve
      ,CURDATE( ) as date
  from pdm.invoice_order a
 where  ccusname LIKE '%浙江萧山医院%' 
  AND db LIKE 'UFDATA%' 
  AND ccustype = 'LDT' 
  AND ddate >= '2020-01-01'  
;


























