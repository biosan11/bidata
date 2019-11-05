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

-- pdm层单位人分数为0的数据进行监控
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'map_inventory'
      ,CURDATE( )
      ,'cinvcode'
      ,cinvcode
      ,cinvname
      ,'单位人份数监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.outdepot_order
 where cinvcode <> '请核查'
   and iquantity = '0'
;
-- 费用部门清洗监控
insert into tracking.jc_abnormal_day
select distinct 
       left(db,10)
      ,'pdm' as source
      ,'account_fy'
      ,dbill_date
      ,'cdept_id'
      ,cdept_id
      ,name_u8
      ,'部门监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.account_fy
 where name_ehr_id is null
;

-- 18年收入金额
insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'invoice_order'
      ,null
      ,null
      ,null
      ,null
      ,'18年金额监控' as type
      ,3 as leve
      ,CURDATE( ) as date
  from(select sum(isum) as isum 
         from pdm.invoice_order 
        where left(ddate,4) = '2018') a
 where round(a.isum,0) <> '909718116';

-- 杭州贝生出现的客户需要单独的客户档案
insert into tracking.jc_abnormal_day
select distinct 
       'hzbs'
      ,'edw' as source
      ,'map_customer_hzbs'
      ,null
      ,'ccuscode'
      ,ccuscode
      ,ccusname
      ,'杭州贝生客户监控' as type
      ,1 as leve
      ,CURDATE( ) as date
  from(select distinct ccuscode,ccusname from pdm.invoice_order where left(db,10) = 'UFDATA_168'
       union
       select distinct ccuscode,ccusname from pdm.outdepot_order where left(db,10) = 'UFDATA_168'
       union
       select distinct ccuscode,ccusname from pdm.dispatch_order where left(db,10) = 'UFDATA_168'
       union
       select distinct ccuscode,ccusname from pdm.sales_order where left(db,10) = 'UFDATA_168'
      ) a
  left join edw.map_customer_hzbs b
    on a.ccuscode = b.bi_cuscode
 where b.bi_cuscode is null
   and a.ccuscode <> '请核查'
;


-- 增加对19年以前的发票、出库、订单、发货的客户由于bi调整编号的产生的不同
-- 这部分需要手动调整
insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'invoice_order'
      ,null
      ,'ccuscode'
      ,a.ccuscode
      ,a.ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.invoice_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.ccuscode = b.bi_cuscode
	and a.ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'outdepot_order'
      ,null
      ,'ccuscode'
      ,a.ccuscode
      ,a.ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.outdepot_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.ccuscode = b.bi_cuscode
	and a.ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'dispatch_order'
      ,null
      ,'ccuscode'
      ,a.ccuscode
      ,a.ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.dispatch_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.ccuscode = b.bi_cuscode
	and a.ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'sales_order'
      ,null
      ,'ccuscode'
      ,a.ccuscode
      ,a.ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.sales_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.ccuscode = b.bi_cuscode
	and a.ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

-- 监控19年线下预算
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'x_sales_budget_19'
      ,null
      ,'bi_cuscode'
      ,a.bi_cuscode
      ,a.bi_cusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_budget_19 a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.bi_cuscode = b.bi_cuscode
	and a.bi_cusname = b.bi_cusname
where b.bi_cuscode is null
  and a.bi_cuscode <> '请核查'
  and a.bi_cusname is not null
;

insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'x_sales_budget_19_new'
      ,null
      ,'ccuscode'
      ,a.ccuscode
      ,a.ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from edw.x_sales_budget_19_new a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.ccuscode = b.bi_cuscode
	and a.ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
  and a.ccusname is not null
;



-- 增加对19年以前的发票、出库、订单、发货的客户由于bi调整编号的产生的不同
-- 这部分需要手动调整
insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'invoice_order'
      ,null
      ,'finnal_ccuscode'
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.invoice_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.finnal_ccuscode = b.bi_cuscode
	and a.finnal_ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'outdepot_order'
      ,null
      ,'finnal_ccuscode'
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.outdepot_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.finnal_ccuscode = b.bi_cuscode
	and a.finnal_ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'dispatch_order'
      ,null
      ,'finnal_ccuscode'
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.dispatch_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.finnal_ccuscode = b.bi_cuscode
	and a.finnal_ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

insert into tracking.jc_abnormal_day
select distinct 
       'pdm'
      ,'pdm' as source
      ,'sales_order'
      ,null
      ,'finnal_ccuscode'
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,'客户编号变动' as type
      ,1 as leve
      ,CURDATE( ) as date
  from pdm.sales_order a
	left join (select * from edw.dic_customer group by bi_cuscode,bi_cusname) b
	  on a.finnal_ccuscode = b.bi_cuscode
	and a.finnal_ccusname = b.bi_cusname
where b.bi_cuscode is null
  and a.ccuscode <> '请核查'
;

-- crm用户资质表更监控
insert into tracking.jc_abnormal_day
select distinct 
       'edw'
      ,'edw' as source
      ,'crm_accounts'
      ,null
      ,'bi_cusname'
      ,d.bi_cusname
      ,c.new_zz
      ,'客户资质变更' as type
      ,1 as leve
      ,CURDATE( ) as date
  from (select a.name,
               case when ifnull(a.new_xs ,'') <> ifnull(b.new_xs ,'') then '新筛变更' 
                    when ifnull(a.new_cs ,'') <> ifnull(b.new_cs ,'') then '产筛变更'  
                    when ifnull(a.new_cz ,'') <> ifnull(b.new_cz ,'') then '产诊变更' 
                    when ifnull(a.new_pcr,'') <> ifnull(b.new_pcr,'')  then 'PCR变更' else '' end as new_zz
          from (select * from edw.crm_accounts where left(sys_time,10) = CURDATE() and new_erp_num is not null) a
         left join edw.crm_accounts_jc b
           on ifnull(a.new_erp_num,'') = ifnull(b.new_erp_num,'')) c
  left join (select * from edw.dic_customer group by ccusname) d
    on c.name = d.ccusname
 where c.new_zz <> ''
   and d.ccusname is not null
;

-- 客户项目人重复监控
insert into tracking.jc_abnormal_day
select distinct
       'edw'
      ,'edw'
      ,'map_cusitem_person'
      ,null
      ,'autoid'
      ,autoid
      ,uniqueid
      ,'客户项目人重复'
      ,2
      ,CURDATE( ) as date
  from edw.map_cusitem_person 
 group by ddate_effect,uniqueid 
 having count(*) >=2
;

-- 新增对费用科目的监控,费用非甄元的数据，二级科目都是6位
insert into tracking.jc_abnormal_day
select distinct
       'pdm'
      ,'pdm'
      ,'account_fy'
      ,null
      ,'code_lv2'
      ,code_lv2
      ,code_name_lv2
      ,'费用科目'
      ,2
      ,CURDATE( ) as date
  from pdm.account_fy
 where db <> 'UFDATA_007_2019'
   and LENGTH(code_lv2) <> '6'
;

-- 甄元的科目存在几条修正的当时是按照6位提供的，还有3天关联上了oa的流程导致也是6位
insert into tracking.jc_abnormal_day
select distinct
       'pdm'
      ,'pdm'
      ,'account_fy'
      ,null
      ,'code_lv2'
      ,code_lv2
      ,code_name_lv2
      ,'费用科目'
      ,2
      ,CURDATE( ) as date
  from pdm.account_fy
 where db = 'UFDATA_007_2019'
   and LENGTH(code_lv2) <> '6'
   and LENGTH(code_lv2) <> '8'
;


