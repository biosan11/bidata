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

-- u8相关模型

-- 项目清洗不区分数据库
-- 产品没有清洗出来的项目不处理
-- truncate table tracking.jc_abnormal_day;
insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'dispatch_order' as tb_name
      ,ddate
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvname as err_value
      ,bi_cinvcode as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.dispatch_order 
                where true_itemcode = '请核查'
                  and bi_cinvcode <> '请核查' order by ddate asc) a
 group by bi_cinvcode
;

insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'invoice_order' as tb_name
      ,ddate
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvname as err_value
      ,bi_cinvcode as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.invoice_order 
                where true_itemcode = '请核查'
                  and bi_cinvcode <> '请核查' order by ddate asc) a
 group by bi_cinvcode
;

insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'outdepot_order' as tb_name
      ,ddate
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvname as err_value
      ,bi_cinvcode as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.outdepot_order 
                where true_itemcode = '请核查'
                  and bi_cinvcode <> '请核查' order by ddate asc) a
 group by bi_cinvcode
;

insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'sales_order' as tb_name
      ,ddate
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvname as err_value
      ,bi_cinvcode as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.sales_order 
                where true_itemcode = '请核查'
                  and bi_cinvcode <> '请核查' order by ddate asc) a
 group by bi_cinvcode
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_eq_depreciation_18' as tb_name
      ,null
      ,'cinvcode' as err_col_id
      ,cinvcode as err_value
      ,cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_18 
 where item_code = '请核查'
   and cinvcode <> '请核查' 
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_eq_depreciation_19' as tb_name
      ,null
      ,'cinvcode' as err_col_id
      ,cinvcode as err_value
      ,cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_19 
 where item_code = '请核查'
   and cinvcode <> '请核查' 
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_sales_bk' as tb_name
      ,null
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvcode as err_value
      ,bi_cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bk 
 where item_code = '请核查'
   and bi_cinvcode <> '请核查' 
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_sales_bkgr' as tb_name
      ,null
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvcode as err_value
      ,bi_cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bkgr 
 where item_code = '请核查'
   and bi_cinvcode <> '请核查' 
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_ldt_list_before' as tb_name
      ,null
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvcode as err_value
      ,bi_cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_list_before 
 where item_code = '请核查'
   and bi_cinvcode <> '请核查' 
;


insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_sales_hospital' as tb_name
      ,null
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvcode as err_value
      ,bi_cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_hospital 
 where item_code = '请核查'
   and bi_cinvcode <> '请核查' 
;

insert into tracking.jc_abnormal_day
select distinct 'excel'
      ,'edw' as source
      ,'x_ldt_bk' as tb_name
      ,null
      ,'bi_cinvcode' as err_col_id
      ,bi_cinvcode as err_value
      ,bi_cinvname as err_value2
      ,'项目清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_bk 
 where item_code = '请核查'
   and bi_cinvcode <> '请核查' 
;












