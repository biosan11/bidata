------------------------------------程序头部----------------------------------------------
--功能：crm客户档案
------------------------------------------------------------------------------------------
--程序名称：crm_accounts.sql
--目标模型：crm_accounts
--源    表：ufdata.crm_accounts ufdata.crm_sales_areas ufdata.crm_systemusers
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/crm_accounts.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------
--crm客户档案
-- 获取每天新增或者修改的客户
-- 镇江区第一人民医院，加一下
update ufdata.crm_accounts set statecode = '0' where accountid = '8ef218e9-9e75-e811-80c6-0050569a5e34';
create temporary table edw.crm_accounts_pre as
select * 
  from ufdata.crm_accounts a
 where (left(a.createdon,10) = '${start_dt}' or left(a.modifiedon,10) = '${start_dt}')
   and a.statecode = '0';

-- 修改数据关联处理,这里主表没有索引，但是每天数据量很小
create temporary table edw.mid1_crm_accounts as
select a.accountid as crm_num
      ,a.new_num
      ,a.new_erp_num
      ,a.new_oa_id
      ,a.NAME
      ,a.new_ccusabbname
      ,case when a.new_type = 1 then '医院/终端'
            when a.new_type = 2 then '公卫'
            when a.new_type = 3 then '政府'
            when a.new_type = 4 then '渠道/代理'
            when a.new_type = 5 then '关联公司' else '未知' end as new_type
      ,case when a.new_account = 1 then '未占有'
            when a.new_account = 2 then '已占有'
            when a.new_account = 3 then '已发货' else '未知' end as new_account
      ,a.new_other_name
      ,a.parentaccountid
      ,a.websiteurl
      ,a.new_autonomic
      ,c.name as new_area
      ,b.new_name as new_province
      ,d.new_name as new_city
      ,e.new_name as new_county
      ,a.new_ccusoaddress
      ,f.lastname as ownerid
      ,a.new_develop_date
      ,a.new_hint
      ,case when a.new_grade = 1 then 'V VIP'
            when a.new_grade = 2 then 'V+ VIP'
            when a.new_grade = 3 then 'VIP'
            when a.new_grade = 4 then '一般客户'
            when a.new_grade = 5 then '其他' else '未知' end as new_grade
      ,case when a.new_hierarchy = 1 then '省级'
            when a.new_hierarchy = 2 then '市级'
            when a.new_hierarchy = 3 then '区县级'
            when a.new_hierarchy = 4 then '区县级以下' else '未知' end as new_hierarchy
      ,case when a.new_nature = 1 then '综合医院'
            when a.new_nature = 2 then '妇幼体系'
            when a.new_nature = 3 then '中医院'
            when a.new_nature = 4 then '其他' else '未知' end as new_nature
      ,case when a.new_enterprise_type = 1 then '公立'
            when a.new_enterprise_type = 2 then '私立' else '未知' end as new_enterprise_type
      ,case when a.new_hospital_level = 11 then '一甲'
            when a.new_hospital_level = 12 then '一乙'
            when a.new_hospital_level = 13 then '一丙'
            when a.new_hospital_level = 14 then '未定级'
            when a.new_hospital_level = 21 then '二甲'
            when a.new_hospital_level = 22 then '二乙'
            when a.new_hospital_level = 23 then '二丙'
            when a.new_hospital_level = 31 then '三甲'
            when a.new_hospital_level = 32 then '三乙'
            when a.new_hospital_level = 33 then '三丙'  else '未知' end as new_hospital_level
      ,a.new_credit_status
      ,a.new_xs
      ,a.new_xsc
      ,a.new_cs
      ,a.new_csc
      ,a.new_cz
      ,a.new_czc
      ,case when a.new_pcr = 1 then '有'
            when a.new_pcr = 2 then '无'
            when a.new_pcr = 3 then '正在申请' else '未知' end as new_pcr
      ,a.new_gspp9
      ,g.lastname as createdby
      ,a.createdon
      ,h.lastname as modifiedby
      ,a.modifiedon
      ,a.customertypecode
      ,case when a.statecode = 0 then '可用'
            when a.statecode = 1 then '不可用' else '未知' end as statecode
      ,case when a.statuscode = 1 then '可用'
            when a.statuscode = 2 then '不可用' else '未知' end as statuscode
      ,a.sys_time
  from edw.crm_accounts_pre a
	left join ufdata.crm_sales_areas b
	  on a.new_province = b.new_siteid
	left join edw.dic_crm c
	  on a.new_area = c.id
	left join ufdata.crm_sales_areas d
	  on a.new_city = d.new_siteid
	left join ufdata.crm_sales_areas e
	  on a.new_county = e.new_siteid
	left join ufdata.crm_systemusers f
	  on a.ownerid = f.ownerid
	left join ufdata.crm_systemusers g
	  on a.createdby = g.ownerid
	left join ufdata.crm_systemusers h
	  on a.modifiedby = h.ownerid
;

-- 防止重跑
delete from edw.crm_accounts where end_dt = '3000-12-31' and new_num in (select new_num from edw.mid1_crm_accounts);
update edw.crm_accounts set end_dt = '3000-12-31' where end_dt = '${start_dt}';

-- 历史数据变更
update edw.crm_accounts set end_dt = '${start_dt}' where new_num in (select new_num from edw.mid1_crm_accounts);

insert into edw.crm_accounts
select crm_num 
      ,new_num
      ,'3000-12-31'
      ,new_erp_num
      ,new_oa_id
      ,NAME
      ,new_ccusabbname
      ,new_type
      ,new_account
      ,new_other_name
      ,parentaccountid
      ,websiteurl
      ,new_autonomic
      ,new_area
      ,new_province
      ,new_city
      ,new_county
      ,new_ccusoaddress
      ,ownerid
      ,new_develop_date
      ,new_hint
      ,new_grade
      ,new_hierarchy
      ,new_nature
      ,new_enterprise_type
      ,new_hospital_level
      ,new_credit_status
      ,new_xs
      ,new_xsc
      ,new_cs
      ,new_csc
      ,new_cz
      ,new_czc
      ,new_pcr
      ,new_gspp9
      ,createdby
      ,createdon
      ,modifiedby
      ,modifiedon
      ,customertypecode
      ,statecode
      ,statuscode
      ,localtimestamp() as sys_time
  from edw.mid1_crm_accounts;

-- 更新 edw.map_customer 相关字段
update edw.map_customer a
inner join (select * from edw.dic_customer group by bi_cuscode) b
  on a.bi_cuscode = b.bi_cuscode
inner join (select * from edw.mid1_crm_accounts group by new_num) c
  on b.ccuscode = c.new_num
set a.ccusgrade          = c.new_grade
   ,a.cus_type           = c.new_enterprise_type
   ,a.ccus_Hierarchy     = c.new_hierarchy
   ,a.Hospital_grade     = c.new_hospital_level
   ,a.cus_nature         = c.new_nature
   ,a.Credit_rating      = c.new_credit_status
   ,a.ccus_sname         = c.new_ccusabbname
   ,a.ccus_uname         = c.new_other_name
   ,a.nsieve_mechanism   = c.new_xs
   ,a.medical_mechanism  = c.new_cz
   ,a.screen_mechanism   = c.new_cs
   ,a.license_plate      = c.new_pcr
   ,a.ccsu_strdate       = c.new_develop_date 
   ,a.ccus_situation     = c.new_account
;








