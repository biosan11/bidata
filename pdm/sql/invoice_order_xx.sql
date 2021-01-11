drop table if exists pdm.invoice_order_item;
create temporary table pdm.invoice_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,f.plan_class
      ,f.key_project
   from (select * from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;

-- 插入18年历史数据
delete from pdm.invoice_order where year(ddate) = '2018';
insert into pdm.invoice_order
select a.sbvid
      ,a.autoid
      ,a.ddate
      ,a.db
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
            end
      ,a.csbvcode
      ,a.csocode
      ,a.cwhcode
      ,c.cwhname
      ,a.cdepcode
      ,d.cdepname
      ,a.cpersoncode
      ,e.sales_dept
      ,e.sales_region_new
      ,a.sales_region
      ,a.province
      ,a.city
      ,a.ccustype
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname
      ,a.cbustype
      ,case when a.cdefine22 = '1' then '其他' else ifnull(a.cdefine22,'其他') end
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,b.plan_class
      ,b.key_project
      ,a.itaxunitprice
      ,a.iquantity
      ,a.itax
      ,a.isum
      ,a.item_name
      ,b.cinvbrand
      ,a.cvenabbname
      ,case when a.cstcode = '01' then '其他销售'
            when a.cstcode = '02' then '终端销售'
            when a.cstcode = '03' then '关联销售'
            when a.cstcode = '04' then '暂估销售'
            when a.cstcode = '05' then '代理销售'
            when a.cstcode = '06' then '服务销售'
            when a.cstcode = '07' then '配件销售'
            when a.cstcode = '08' then '检测项目销售'
            else '未知销售' end  as cstcode
      ,a.specification_type
      ,case when a.itb = '1' then '退补'
          else '正常' end
      ,case when a.breturnflag = 'Y' then '是'
          else '否' end
      ,a.tbquantity
      ,a.isosid
      ,a.idlsid
      ,a.isaleoutid
      ,null
      ,null
      ,localtimestamp()
  from edw.x_invoice_order_18 a
  left join (select * from pdm.invoice_order_item group by bi_cinvcode) b
    on a.bi_cinvcode = b.bi_cinvcode
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select * from edw.map_customer group by bi_cuscode) e
    on a.true_finnal_ccuscode = e.bi_cuscode
;


delete from pdm.invoice_order where db = 'bkgr';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,'bkgr'
      ,'贝康个人'
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,d.sales_dept
      ,d.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.type
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,'LDT'
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,ifnull(a.isum,0) as itaxunitprice
      ,1 as iquantity
      ,case when year(a.ddate) = '2019' then round(ifnull(a.isum,0) /(1+0.06)*0.06,2)
            when year(a.ddate) = '2018' then round(ifnull(a.isum,0) /(1+0.06)*0.06,2)
          else null end
      ,round(ifnull(a.isum,0),2)
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,'正常'
      ,'否'
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
	  ,null as if_xs
      ,localtimestamp()
  from edw.x_sales_bkgr a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
  left join (select * from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
  left join (select * from edw.map_customer group by bi_cuscode) d
    on a.finnal_ccuscode = d.bi_cuscode
 where year(a.ddate) >= 2018
   and a.method_settlement = '个人'
   and a.accounts like '%贝康%';

delete from pdm.invoice_order where db = 'bk';
delete from pdm.invoice_order where db = 'zyjk';
delete from pdm.invoice_order where db = 'zysy';
delete from pdm.invoice_order where db = 'jymt';
delete from pdm.invoice_order where db = 'xj';
delete from pdm.invoice_order where db = 'HNAB';
delete from pdm.invoice_order where db = 'jsc';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,case when a.db = 'bk' then 'bk'
            when a.db = 'ZYJK' then 'zyjk'
            when a.db = 'JYMT' then 'jymt'
            when a.db = 'XJ' then 'xj'
			when a.db = 'HNAB' then 'HNAB'
			when a.db = 'jsc' then 'jsc'
            else 'zysy' end
      ,case when a.db = 'bk' then '贝康'
            when a.db = 'ZYJK' then '甄元健康'
            when a.db = 'JYMT' then '杰毅麦特'
            when a.db = 'XJ' then '现金'
			when a.db = 'HNAB' then '河南爱博'
			when a.db = 'jsc' then '金筛查'
            else '甄元实验室' end
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,d.sales_dept
      ,d.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.type
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,b.finnal_cuscode
      ,b.finnal_ccusname
--      ,'LDT'
      ,a.business_class
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,a.price
      ,a.iquantity
      ,case when year(a.ddate) = '2019' then round(a.itax,2)
            when year(a.ddate) = '2018' then round(ifnull(a.isum,0) /(1+0.06)*0.06,2)
          else null end
      ,round(ifnull(a.isum,0),2)
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,'正常'
      ,'否'
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
	  ,null as if_xs 
      ,localtimestamp()
  from edw.x_sales_bk a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
  left join (select * from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
  left join (select * from edw.map_customer group by bi_cuscode) d
    on b.finnal_cuscode = d.bi_cuscode
 where year(a.ddate)>=2018
;


delete from pdm.invoice_order where db = 'old';
insert into pdm.invoice_order
select '17'
      ,a.auto_id
      ,a.ddate
      ,'old'
      ,case when a.db = '博圣' then '博圣' 
            when a.db = '四川美博特' then '美博特'
            when a.db = '湖北奥博特' then '奥博特'
            when a.db = '贝康' then '贝康'
            when a.db = 'UFDATA_111_2018' then '博圣'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_666_2018' then '启代'
            end
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
      ,b.sales_dept
      ,b.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.type
      ,a.true_ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode
      ,a.true_finnal_ccusname
      ,d.business_class
      ,'销售'
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,a.item_code
      ,e.plan_class
      ,e.key_project
      ,null
      ,null
      ,a.isum - a.itax_excluded
      ,a.isum
      ,c.level_three
      ,e.cinvbrand
      ,null
      ,null
      ,null
      ,'正常'
      ,'否'
      ,null
      ,null
      ,null
      ,null
      ,null
      ,cverifier
      ,null as if_xs
      ,localtimestamp()
  from edw.x_sales_history a
  left join (select * from edw.map_customer group by bi_cusname) b
    on a.true_finnal_ccusname = b.bi_cusname
  left join (select bi_cinvcode,plan_class,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code
  left join (select bi_cinvcode,business_class from edw.map_inventory group by bi_cinvcode) d
    on a.bi_cinvcode = d.bi_cinvcode
 where year(a.ddate) < 2018 or (a.auto_id >= '448548')
;


-- 增加对无效客户的删除
delete from pdm.invoice_order where ccuscode = 'DL1101002' and cinvcode = 'QT00004';
delete from pdm.invoice_order where left(ccuscode,2) = 'GL';


-- 更新最终客户是multi改为客户
update pdm.invoice_order
   set finnal_ccuscode = ccuscode
      ,finnal_ccusname = ccusname
 where finnal_ccusname = 'multi'
;

-- 按照王涛提供的客户项目负责人跟新18年以后的数据
update pdm.invoice_order a
 inner join pdm.cusitem_person b
    on a.finnal_ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and a.cbustype = b.cbustype
   set a.areadirector = b.areadirector
      ,a.cverifier = b.cverifier
 where a.ddate >= '2018-01-01'
   and a.ddate >= b.start_dt
   and a.ddate <= b.end_dt
;

