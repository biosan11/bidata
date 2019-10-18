------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：dispatch_order.sql
--目标模型：dispatch_order
--源    表：ufdata.dispatchlist,ufdata.dispatchlists,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/dispatch_order.python 2018-11-12 2018-11-12
------------------------------------开始处理逻辑------------------------------------------

truncate table edw.crm_appointments;

insert into edw.crm_appointments
select a.subject
      ,b.yomifullname
      ,case when a.statuscode = '1' then '已开启'
            when a.statuscode = '2' then ''
            when a.statuscode = '3' then '已完成'
            when a.statuscode = '4' then '已取消'
            when a.statuscode = '5' then '已计划'
            else '未知' end as statuscode
      ,b.title
      ,c.name as ccusname
      ,d.name as dept_name
      ,a.actualstart
      ,a.actualdurationminutes
      ,a.actualend
      ,a.new_purpose
      ,a.description
      ,a.new_num
      ,a.scheduleddurationminutes
      ,'拜访'
      ,localtimestamp() as sys_time
  from ufdata.crm_appointments a
  left join ufdata.crm_systemusers b
    on a.ownerid = b.ownerid
  left join ufdata.crm_accounts c
    on a.regardingobjectid = c.accountid
  left join ufdata.crm_deptment d
    on b.businessunitid = d.businessunitid
;




