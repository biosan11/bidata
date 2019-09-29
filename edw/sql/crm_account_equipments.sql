-- 先删除edw层有的类主键


create temporary table edw.crm_account_equipments_pre as
select * 
  from ufdata.crm_account_equipments a
 where a.statecode = '0';

-- delete from edw.crm_account_equipments where new_account_equipmentid in (select new_account_equipmentid from edw.crm_account_equipments_pre);

-- 关联获取到数据
truncate table edw.crm_account_equipments;
insert into edw.crm_account_equipments
select a.new_account_equipmentid
      ,null
      ,a.new_name
      ,j.new_code as new_product_code
      ,a.new_product_name
      ,case when h.cinvname is null then '请核查' else h.bi_cinvcode end as bi_cinvcode
      ,case when h.cinvname is null then '请核查' else h.bi_cinvname end as bi_cinvname
      ,f.new_num as custcode
      ,f.name as custname
      ,case when f.name is not null and i.ccusname is null then '请核查' else i.bi_cuscode end as bi_cuscode
      ,case when f.name is not null and i.ccusname is null then '请核查' else i.bi_cusname end as bi_cusname
      ,g.new_area
      ,a.new_model
      ,case when a.new_use_mode = 1 then '正常'
            when a.new_use_mode = 2 then '停用'
            when a.new_use_mode = 3 then '计划采购'
            when a.new_use_mode = 4 then '培训机'
            when a.new_use_mode = 5 then '备用'
            when a.new_use_mode = 6 then '回收'
            when a.new_use_mode = 7 then '报废'
       else '未知状态' end as use_mode
      ,a.new_equipment_type
      ,b.lastname as owner
      ,a.new_trademark
      ,a.new_prod_brand
      ,a.new_prod_id
      ,a.new_installation_date
      ,a._new_account_equipment_value
      ,a.new_host_guarantee
      ,a.new_instrument_nature
      ,a.new_administrative_office
      ,a.new_supplier
      ,a.new_service_cycle
      ,a.modifiedon
      ,d.lastname as modifiedby
      ,a.new_reception_time
      ,a.new_manufacturedate
      ,a.createdon
      ,d.lastname as createdby
      ,a.new_original_date
      ,a.new_expiration_date
      ,a.new_brand
      ,a.new_remark
      ,d.lastname as setupby
      ,a._new_work_order_value
      ,a.new_upkeep
      ,a.new_lastyear_check
      ,a.new_avg_breakdown
      ,a._new_open_project_value
      ,a.new_main
      ,a.new_competitor
      ,a.statecode
      ,a.new_service_time
      ,null
      ,localtimestamp()
  from edw.crm_account_equipments_pre a
	left join ufdata.crm_systemusers b
	  on a._ownerid_value = b.ownerid
	left join ufdata.crm_systemusers c
	  on a._modifiedby_value = c.ownerid
	left join ufdata.crm_systemusers d
	  on a._createdby_value = d.ownerid
	left join ufdata.crm_systemusers e
	  on a._new_setupby_value = e.ownerid
  left join ufdata.crm_accounts f
    on a._new_account_value = f.accountid
  left join edw.crm_accounts g
    on f.new_num = g.new_num
  left join ufdata.crm_new_products j
    on a._new_product_value = j.new_productid
  left join (select * from edw.dic_inventory group by cinvcode) h
    on j.new_code = h.cinvcode
  left join (select * from edw.dic_customer group by ccusname) i
    on f.name = i.ccusname
  ;


-- 跟新几个产品名称为空，但是存在简称的产品
-- 更新简称为MB8/MB4
update edw.crm_account_equipments
   set bi_cinvcode = 'TEMP161'
      ,bi_cinvname = 'MB8/MB4'
  where bi_cinvcode = '请核查'
    and new_equipment_type = '15';

-- 更新简称为Victor
update edw.crm_account_equipments
   set bi_cinvcode = 'YQ01007'
      ,bi_cinvname = '1420（新筛）'
  where bi_cinvcode = '请核查'
    and new_equipment_type = '10';


-- 根据合同来处理出用章单位
update edw.crm_account_equipments a
 inner join (select * from edw.cm_contract group by bi_cuscode,bi_cinvcode) b
	  on a.bi_cuscode = b.bi_cuscode
	 and a.bi_cinvcode = b.bi_cinvcode
   set a.yzdw = b.cdefine11
  where b.bi_cinvcode is not null
;

-- 添加项目的数据
update edw.crm_account_equipments a
 inner join (select * from edw.map_inventory group by bi_cinvcode) b
	  on a.bi_cinvcode = b.bi_cinvcode
   set a.item_code = b.item_code
  where b.bi_cinvcode is not null
;
