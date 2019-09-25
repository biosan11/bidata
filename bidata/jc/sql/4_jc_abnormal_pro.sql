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
-- truncate table tracking.jc_abnormal_day;
-- insert into tracking.jc_abnormal_day
select distinct 'UFDATA_111'
      ,'edw' as source
      ,'ar_detail' as tb_name
      ,null
      ,'cinvcode' as err_col_id
      ,cinvcode as err_value
      ,null as err_value2
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.ar_detail where true_cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_222' then 'UFDATA_222' 
            when left(db,10) = 'UFDATA_588' then 'UFDATA_588' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'dispatch_order' as tb_name
      ,ddate
      ,'cinvcode' as err_col
      ,cinvcode as err_value
      ,cinvname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.dispatch_order where bi_cinvcode = '请核查' order by ddate asc) a
 group by cinvcode 
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_222' then 'UFDATA_222' 
            when left(db,10) = 'UFDATA_588' then 'UFDATA_588' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'invoice_order' as tb_name
      ,ddate
      ,'cinvcode' as err_col
      ,cinvcode as err_value
      ,cinvname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.invoice_order where bi_cinvcode = '请核查' order by ddate asc) a
 group by cinvcode 
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_222' then 'UFDATA_222' 
            when left(db,10) = 'UFDATA_588' then 'UFDATA_588' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'outdepot_order' as tb_name
      ,ddate
      ,'cinvcode' as err_col
      ,cinvcode as err_value
      ,null as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.outdepot_order where bi_cinvcode = '请核查' order by ddate asc) a
 group by cinvcode,db
;

insert into tracking.jc_abnormal_day
select distinct 
       case when left(db,10) = 'UFDATA_889' then 'UFDATA_889' 
            when left(db,10) = 'UFDATA_222' then 'UFDATA_222' 
            when left(db,10) = 'UFDATA_588' then 'UFDATA_588' 
            when left(db,10) = 'UFDATA_555' then 'UFDATA_555' 
            else 'UFDATA_111' end
      ,'edw' as source
      ,'sales_order' as tb_name
      ,ddate
      ,'cinvcode' as err_col
      ,cinvcode as err_value
      ,null as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select * from edw.sales_order where bi_cinvcode = '请核查' order by ddate asc) a
 group by cinvcode 
;

-- 线下表的产品清洗
-- crm线上导出的装机档案，停用
-- insert into tracking.jc_abnormal_day
-- select distinct 
--        'excel'
--       ,'edw' as source
--       ,'x_cuspro_archives' as tb_name
--       ,null
--       ,'cinvcode' as err_col
--       ,cinvcode as err_value
--       ,cinvname as err_col_name
--       ,'产品清洗' as type
--       ,1 as leve
--       ,CURDATE( ) as date
--   from edw.x_cuspro_archives where bi_cinvcode = '请核查'
-- ;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_depreciation_18' as tb_name
      ,null
      ,'eq_name' as err_col
      ,null as err_value
      ,eq_name as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_18 where cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_depreciation_19' as tb_name
      ,null
      ,'eq_name' as err_col
      ,null as err_value
      ,eq_name as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_depreciation_19 where cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_eq_launch' as tb_name
      ,null
      ,'cinvcode_oir' as err_col
      ,cinvcode_oir as err_value
      ,cinvname_ori as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_eq_launch where cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_bkgr' as tb_name
      ,null
      ,'true_product_code' as err_col
      ,true_product_code as err_value
      ,true_product_ori as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bkgr where bi_cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_ldt_list_before' as tb_name
      ,null
      ,'true_product_code' as err_col
      ,true_product_code as err_value
      ,true_product_ori as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_list_before where bi_cinvcode = '请核查'
;


insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_bk' as tb_name
      ,null
      ,'product_ori' as err_col
      ,null as err_value
      ,product_ori as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_bk where bi_cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_sales_hospital' as tb_name
      ,null
      ,'cinvname' as err_col
      ,null as err_value
      ,cinvname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_hospital where bi_cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'excel'
      ,'edw' as source
      ,'x_ldt_bk' as tb_name
      ,null
      ,'cinvname' as err_col
      ,null as err_value
      ,cinvname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_ldt_bk where bi_cinvcode = '请核查'
;

-- 药监数据库相关的产品
insert into tracking.jc_abnormal_day
select distinct 
       'yj'
      ,'edw' as source
      ,'yj_outdepot' as tb_name
      ,null
      ,'sproductcode' as err_col
      ,left(sproductcode,7) as err_value
      ,sproductname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.yj_outdepot where bi_cinvcode = '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'yj'
      ,'edw' as source
      ,'yj_invoince_stock' as tb_name
      ,null
      ,'sproductcode' as err_col
      ,left(sproductcode,7) as err_value
      ,sproductname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.yj_invoince_stock where bi_cinvcode = '请核查'
;

-- crm相关流程数据产品清洗
insert into tracking.jc_abnormal_day
select distinct 
       'crm'
      ,'edw' as source
      ,'crm_account_equipments' as tb_name
      ,null
      ,'new_product_code' as err_col
      ,new_product_code as err_value
      ,new_product_name as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.crm_account_equipments where bi_cinvcode = '请核查'
;
-- 合同的产品清洗是按照类型+编码，需要剥除出来
insert into tracking.jc_abnormal_day
select distinct 
       'crm'
      ,'edw' as source
      ,'cm_contract' as tb_name
      ,null
      ,'cinvcode' as err_col
      ,e.cinvcode as err_value
      ,e.cinvname as err_col_name
      ,'产品清洗' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.cm_contract a 
  left join (select * from edw.inventory group by cinvcode,cinvccode) e
    on left(a.strCode,11) = concat(e.cinvccode,e.cinvcode)
 where a.bi_cinvcode = '请核查'
;




-- 更新只有编号没有名称的产品
update tracking.jc_abnormal_day a
 inner join (select * from ufdata.inventory where db = 'UFDATA_889_2019') b
    on a.err_value = b.cinvcode
   set a.err_value2 = b.cinvname
 where a.err_value2 is null
   and a.db = 'UFDATA_889'
;

update tracking.jc_abnormal_day a
 inner join (select * from ufdata.inventory where db = 'UFDATA_222_2019') b
    on a.err_value = b.cinvcode
   set a.err_value2 = b.cinvname
 where a.err_value2 is null
   and a.db = 'UFDATA_222'
;

update tracking.jc_abnormal_day a
 inner join (select * from ufdata.inventory where db = 'UFDATA_588_2019') b
    on a.err_value = b.cinvcode
   set a.err_value2 = b.cinvname
 where a.err_value2 is null
   and a.db = 'UFDATA_588'
;

update tracking.jc_abnormal_day a
 inner join (select * from ufdata.inventory where db = 'UFDATA_111_2018') b
    on a.err_value = b.cinvcode
   set a.err_value2 = b.cinvname
 where a.err_value2 is null
   and a.db = 'UFDATA_111'
;

update tracking.jc_abnormal_day a
 inner join (select * from ufdata.inventory where db = 'UFDATA_555_2018') b
    on a.err_value = b.cinvcode
   set a.err_value2 = b.cinvname
 where a.err_value2 is null
   and a.db = 'UFDATA_555'
;












