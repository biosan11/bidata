------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：invoice_order_cw.sql
--目标模型：invoice_order_cw
--源    表：ufdata.salebillvouch,ufdata.salebillvouchs,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--         V1.0     jiangsh  2020-03-30   修改销售出库类型，转为中文
--调用方法　python /home/bidata/edw/invoice_order_cost.py 1900-01-01 1900-01-01
------------------------------------开始处理逻辑------------------------------------------


truncate table pdm.invoice_order_cw;
insert into pdm.invoice_order_cw
select a.db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '杭州贝生'
            when a.db = 'UFDATA_168_2019' then '杭州贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝荣'
            when a.db = 'UFDATA_222_2019' then '宝荣'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '奥博特'
            when a.db = 'UFDATA_588_2019' then '奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '美博特'
            when a.db = 'UFDATA_889_2019' then '美博特'
            when a.db = 'UFDATA_555_2018' then '贝安云'
            when a.db = 'UFDATA_170_2020' then '甄元实验室'
            end
      ,a.ddate
      ,a.cstcode
      ,a.csbvcode
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname1 as finnal_ccusname
      ,e.sales_region_new
      ,e.sales_region
      ,e.province
      ,e.city
      ,a.cdepcode
      ,a.cmaker
      ,a.cwhcode
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,c.item_code
      ,c.level_three as item_name
      ,c.level_two
      ,c.level_one
      ,c.business_class as cbustype
      ,ifnull(a.isum,0)
      ,ifnull(a.itax,0)
      ,round(ifnull(a.iquantity,0),2)
      ,round(ifnull(a.itaxunitprice,0),2)
      ,round(ifnull(a.itaxrate,0),2)
      ,round(ifnull(b.iunitcost,0),2)
--      ,case when a.itb = '1' and ifnull(a.tbquantity,0) < 0 then round(ifnull(b.iprice,0),2) * - 1 else round(ifnull(b.iprice,0),2) end as price
--      ,case when a.itb = '1' and ifnull(a.tbquantity,0) < 0 then round(ifnull(d.iaoutprice,0),2) * - 1 else round(ifnull(d.iaoutprice,0),2) end as price1
      ,round(ifnull(b.iprice,0),2) as price
      ,round(ifnull(d.iaoutprice,0),2) price1
      ,a.cdefine22
      ,a.cdefine23
      ,case when a.itb = '1' then '退补' else '正常' end
      ,a.cbsaleout
      ,a.tbquantity
      ,a.cmemo
      ,a.cbdlcode
  from edw.invoice_order a
  left join edw.outdepot_order b
    on a.isaleoutid=b.autoid
   and a.db = b.db
  left join edw.map_inventory c
    on a.bi_cinvcode = c.bi_cinvcode
  left join ufdata.ia_ensubsidiary d
    on d.outid = a.autoid
   and a.db = d.db
  left join edw.map_customer e
    on a.true_finnal_ccuscode = e.bi_cuscode
;

