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
      ,null as if_xs 
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

-- 更新销售中心口径标签, 健康检测  启代 
update pdm.invoice_order set if_xs = '非销售_健康检测' where item_code is null;
update pdm.invoice_order set if_xs = '非销售_启代' where if_xs is null and db ='UFDATA_666_2018';

-- 更新线下确认数据  20年
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（1）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（2）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（3）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（4）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（6）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316696（5）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（1）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（2）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（3）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（4）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（5）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（6）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（8）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（9）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316693（7）';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158591';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940211';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201019013';
update pdm.invoice_order set if_xs='非销售_北京贝康检测' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940484';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200731020';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '05130614';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '12891812';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889333';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889328';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889329';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889330';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889331';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '07889332';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '19585494';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '05170912';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804005';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200922015';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940081';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940080';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940162';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940171';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200317010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075375';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097347';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200330001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316585（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316505';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331036';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331037';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331041';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331058';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331061';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331082';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331083';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331084';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331091';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331092';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331093';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331102';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331103';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331106';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331113';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331114';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331119';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331121';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200331122';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819918';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421036';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200421039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097381';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819929';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819930';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819936';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423047';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423053';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423064';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423065';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423066';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423078';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423085';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423086';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423087';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423094';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423095';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200424029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819964';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819963';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316604（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25819971';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200428011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200428016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200428017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200428018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200428019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200429002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25820008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '65813619';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513057';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513064';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513066';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200513067';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '65813644';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200514011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200514012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200514015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200514017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200514018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316676';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200519003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200519004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200519005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388787';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388786';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388789';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525046';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525047';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200525048';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388785（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388785（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200527001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200528011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200528012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200529001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200529002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200529006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200529007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316687';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388926';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200611023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200616002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158313';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622041';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622042';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622043';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622044';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622045';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622051';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622052';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622053';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622054';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622067';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622068';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622069';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622073';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200622074';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200623027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749891';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749892';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749924';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749925';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749927';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158331（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158331（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749926（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749926（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749928（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749928（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723051';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200630015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200630016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200630017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200630033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708048';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200708049';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200709005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723128';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200710003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723129（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723129（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200713024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200714015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200720021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200720027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200720028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '05161611';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200723004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200723007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200723008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254176';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727044';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727046';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200729003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200729009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200729010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200731021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200731022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200804012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200805011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200805012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200805025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200806001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200806002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200806003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200806004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254014-4015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17254020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158550（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158550（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200807018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200812036';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200813008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200813009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200817034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200819016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200819018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868581';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868585';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '72628460（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '72628460（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '72628461（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '72628461（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158452（1)';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826037';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826044';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826045';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826049';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826050';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200826054';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200830001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200830002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200831032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868635';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868636';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158464';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200831038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200903002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868684（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868684（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158471（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158471（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200909004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200909005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910042';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868769';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910049';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158599（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200911011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200911012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200914007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868802';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '98977247';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200921018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200922010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200922013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200922014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158599（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200922017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940206';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200923006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '98977479';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200924003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200924004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200925003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200925005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200927010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940038-0039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '98977336';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '98977337';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200928006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200928007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940040（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940040（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200929006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200929008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940219';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200915008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201012002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201014023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201015027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201016012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201020001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201020028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '44111010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940073';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201026002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201026012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201027016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201029005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201029010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '52438786';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '52438788';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '52438789';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '52438790';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201031041';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '52438787（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201110007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201110008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201110019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201110020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111054';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111056';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111058';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111070';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111071';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111072';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111073';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111077';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111078';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111079';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201113008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201113009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201113010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201117011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201117013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201117014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201117015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201117021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201118001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201118002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201123004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201123005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201125008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201127017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940257（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940257（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882866';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882881';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201202001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201202002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882880';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882871';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882872';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882873';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882874';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882875';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882877';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882878';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882879';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80882876';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130044';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130045';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130046';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130047';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130049';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130052';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130053';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748228';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748229';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748230';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748227';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748231';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201207002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940478';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940190';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940477（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940191（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940191（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201210006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201210007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201214005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201214006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201214007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201214009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201216006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748332';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201216011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201222022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201222023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201222024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223031';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748640';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223059';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223060';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223061';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223062';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223063';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748406（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223064';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748406（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223071';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223072';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223073';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223074';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223093';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223094';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201223099';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748705';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '88748485';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201228027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201229018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201230018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201231020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201231021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201231022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201231023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201231024';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097357';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097369';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097358';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '64097359';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954564';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200423048';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '65813682';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '68388859';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723048';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690525';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '74749920';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200910045';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '44110837';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '75868962/44110910';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = 'HZZYPF20200131030';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '64280935（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '67508549';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '67508649';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '05170889';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_170_2020'and csbvcode = '05170886';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322557';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322568';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322572';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322582';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322643';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322644';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '02004712';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113644';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113649-3650';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113667';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113670';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113671';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113672';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113673-76';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113678-81';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113677';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '04113685';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643771';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643774';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643784';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643797';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643802';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316432';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02047440';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316438';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316448';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316462';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316473';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200316011';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200317009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316508';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316510';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316521';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057928';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057941';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057964';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057969';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057975';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057982-7985';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02057998';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02058014';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316657';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158334';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158337';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158347';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158373';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158376';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158388';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158393';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727019';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158408';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200731019';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158424';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158429';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158432';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158453';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158468';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158478';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158480';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158482';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158488';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158493';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940020';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940058';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940085';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940111';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940127';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940130';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940135';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940156';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940166';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940267';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940268';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940270';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940278';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940283';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940296';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_169_2018'and csbvcode = '39853985';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_555_2018'and csbvcode = '44995559';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = 'ZJBSPF200430008';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '30977207';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316544';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316543';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316548';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316440';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316457（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316457（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075228（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075228（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316474';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316496';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316584';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316498';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316588（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316588（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422017';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200426002';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316665';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316678';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316677';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01316679';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200629009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158511';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158538(2)';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158538(1)';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158524';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200727023';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158549';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158452（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200828008';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200828009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01158589';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '72628532';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200911009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200930083';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200930084';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940236';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201110018';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201111029';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00940477';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '05130611';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422014';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422016';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422018';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422020';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422021';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200422023';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '25820190';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '65736603';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200624012';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF200624013';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '80723257';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028008';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028009';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028010';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201028011';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201106005';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130077';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF201130078';

-- 19年 
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063006';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063007';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063008';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063010';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063011';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063013';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_666_2018'and csbvcode = '59063012';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_169_2018'and csbvcode = '14582611';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_169_2018'and csbvcode = '14582625';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639268';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639526';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190327003';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190521011';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115045';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115071';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950929';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643620';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658399';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '02078505';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '02078528';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '02078543';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '02078544';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658327';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658350';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658370';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658371';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658372';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658373';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658400';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658401';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658424';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658426';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658444';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658446';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '00658477';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649265';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075594';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075707';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649106';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649133';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649234';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649298';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639336';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643469';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643493';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643494';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643511';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643688';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643723';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950635';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075798';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075799-5800';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075824';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075846';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639262';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639288（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075802';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639267';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639410';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639429';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639521';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639556';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639558';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639436';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639528';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639561';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075741';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639437';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639464';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639452';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639453';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643587（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643609（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954407（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075680';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649181';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01916098（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649167';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075578';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075722';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075775';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643533';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643626';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643649';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643733';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075654';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '13006119';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '03777042';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '12889592';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075583';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075645';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075652';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322478';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322474--2477';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639346';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639358';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643655';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '13006120';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649188';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643571';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06800994';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871888';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06823938';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871903';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904405';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075646';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075651';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904694';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075717';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927070';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649193';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649204';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649217';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649230';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649291';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649301';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639301';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639351';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643476';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643525';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643563';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075623';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639293（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639293（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469268';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075607';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129018';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190830006';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06801005';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075593';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871839';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871899';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190327008';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927086';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950765';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469391';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469415';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639363';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690501';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771498';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643752';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950634';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649235';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643753';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322473';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690527';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639290（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639290（2）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190919002';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322471';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322472';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_222_2019'and csbvcode = '01322479--2482';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639288（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950841';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954407（1）';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190729012';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119009';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643683';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190813010';
update pdm.invoice_order set if_xs='非销售_销管代理商确认' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075745';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954550';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690789';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954648';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954676';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02008804';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639451';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '03777041';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927327';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950581';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075797';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469681';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469733';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492539';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492868';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492865';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492895（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492915（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492913';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492973（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492974（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690596（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690875（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639472';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639493（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639489';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690874';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771372';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771408';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639509';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771628（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954307';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954618（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954601';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954602';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954604';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954469（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954671';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190520015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = 'ZJBSPF190831001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690645';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950935';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '69495335';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950715';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950885';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191113005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231037';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231138';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190627010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190911012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191010002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = '44385990';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492495';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492507';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190124027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190124034';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190826013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190930003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690644';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639493（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190513001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190124033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075776';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649226';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954618（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690927';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190627001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190627004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190628001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191031003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06018807';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06018757';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190711001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190711002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190711003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129042';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904549';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190429006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927225';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190430001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190528002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190718024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954333';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231191';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191231003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190830001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191217002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191028006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06030174';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190509017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191226002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954470';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771268';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190221003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904757';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950934';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492911';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690639';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014033';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191017018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639525';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191224010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231051';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190812013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190911005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190929008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190917010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190917011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190918007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '69495329';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '84733169';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '84733172';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690646';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029874';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06030222';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771467';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954519';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231120';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190430008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190826020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191029002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029988';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469303';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129045';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190627002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643632';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231114';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190520013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190929009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771267';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771183';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639495';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '69495309';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '40493841';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190109004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029986';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06030244';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190731003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07280834';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871816';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871906';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871924';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871928';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871946';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190226030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190312008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927069';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950694';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469442';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190723007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492987';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643561';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771337';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771327';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771520';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954546';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954411';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690944';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231036';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231183';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469330';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191011006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '40493893';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '40493952';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '26895046';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '44766283';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190726001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871850';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190124026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06823928-3933';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06823895';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130036';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130037';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190221010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075763';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904829';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904910';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190419003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190419004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190429009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190509016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00649241';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469389';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492496';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190729011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492895（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492666';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190827006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492969';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190910012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190918008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190918009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13493010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014029';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771094';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191022006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771182';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191113003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954373';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954394';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954652';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954469（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954528（2）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954395';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231094';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231130';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231139';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190314013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190725004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190930005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130039';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771628（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129038';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639431';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190125003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '01092942';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07341035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115040';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871925';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871926';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190218001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904693';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927044';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927233';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190430006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190520012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469443';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469493';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190712014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190731026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690570';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690732';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771461';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954617';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191210005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190826014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469216';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954603';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190520014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492973（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190930004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130041';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190331004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190813012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639524';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231065';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190918010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191125011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190430007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190214003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927270';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492842';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690941';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190509002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190822013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF191029002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771301';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191209003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643724';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029987';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '26750872';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '26895103';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07315573';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF191111001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07358003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904478';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469452';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190712008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190731024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190813011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = 'ZJBSPF190430002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = 'ZJBSPF190624002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = '23664404';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '40493938';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '26895020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '29602575';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190129005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029846';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029854';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029991';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06030122';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06018660';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190819004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07258190';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07340916';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07340970';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07340967';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07340984';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF191220007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07358208';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06800993';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871914';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190220009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904366';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904375';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190307026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190312005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904554';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904597';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904598';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904626';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904675';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075712';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927153';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927190';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927250';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190430014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950661';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950668';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190517005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190520003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950769';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950854';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469332';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469397';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469396';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469412';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469627';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492357';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492445';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190730001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492658';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492768';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190917001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690562';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191008006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191008008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690714';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771169';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771203';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771470';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771557';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954622';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954382';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231095';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231153';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690731';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469187';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191209002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF191118004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '26894981';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871933';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492601';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771338';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029980';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190718021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643589';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231122';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190929007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190912001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191108003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07315553';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190718022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191216003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231116';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190929003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909026';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06800986';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190531006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191113004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190221004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231192';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190221008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190221009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190429007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639407';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190929006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190628001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190708005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115076';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115077';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129021';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190314017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190314019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927277';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411049';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190509006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190509011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771206';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231173';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231174';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = '10753635-36';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '40493988';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190125001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029950';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190505001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06800954';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871891';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190430013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190731025';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771109';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771171';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771339';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191030005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190128001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190131005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075772';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190225001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190429008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190731007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771373';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618016';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130027';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190117001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639285';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190822006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190115032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904908';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492962';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690596（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690827';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690828';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771480';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191014010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191211006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190726006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190418023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191010003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190617002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190621001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = 'SHEYPF190521002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231185';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = 'SHEYPF190917001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = 'SHEYPF191112002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07244853';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492402';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492558';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190816018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190820004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190820005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492779';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909023';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190910005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190910015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190916004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190916005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190917002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690779';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690823';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191008018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690694';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690864';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191012002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191015012';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643566';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191017014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191022002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191029011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191031004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191108001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771318';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119022';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191130018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771542';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771584';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191224003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191224007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231020';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231030';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231083';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231152';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469218';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771199-1201';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690641-0643';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690695-0697';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690698-0700';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771161';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690638';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190729005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190916017';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191029003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190822005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190910011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492974（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190930007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690875（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771185';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771217';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643618';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191125019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954466';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771493';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639557';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954642';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231121';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '29602395';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '01092893';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190221002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190221003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190509001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07315550';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190429003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190924005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191023011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771184';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954528（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231189';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190812014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190823001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690843';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191011002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191011003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690872';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191028008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00643609（1）';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107008';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191218005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231115';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190129003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190930006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469226/13469748';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190419003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190419004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06030183';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190321011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411074';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927176';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927234';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950880';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492667';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492725';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190911006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871858';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '26895145-5175，29602376-2384';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927272';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927211';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469702';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190712004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190228018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06904724，4779-4780';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190411024';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190531004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111018';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954554-4555';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '01954552-4553';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191210003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_123_2018'and csbvcode = '29602489';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029852';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029937';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06029959';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '06018774';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07315502';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06823900';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06871832';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02075715';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927172';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950846';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469350';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492572';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492686';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690713';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190820006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690514';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190325003';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190531004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = 'NBBSPF190630004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07244789';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07258145';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_333_2018'and csbvcode = '07258147';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190130035';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428006';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190428011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190617001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190618015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190627009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190708004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190812015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190821013';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190910014';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190924011';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690559';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690598';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191028007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771207';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191107007';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191108009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231093';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231117';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF190325002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492894';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469188';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190916028';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190823009';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231113';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231086';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191017019';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130002';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190826015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191031001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_588_2019'and csbvcode = 'ZJBSPF191130004';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119005';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191231155';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190909032';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191119010';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191216001';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_118_2018'and csbvcode = '84733170';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF191111015';
update pdm.invoice_order set if_xs='非销售_技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190827007';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190315005';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06927314';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950592';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '06950580';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469186';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469236-9237';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190611025';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469684';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '00639269';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469707';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13469758';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492497';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492498';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492505';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492844';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190815003';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190815005';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492935';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13492936';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13493025';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '13493028';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690934';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690935';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690894';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17690921';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771382';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '17771409';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = '02008742';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190815007';
update pdm.invoice_order set if_xs='非销售_BD' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190815008';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '13006119';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '03777042';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '12889592';
update pdm.invoice_order set if_xs='非销售_关联' where if_xs is null and db = 'UFDATA_889_2019'and csbvcode = '13006120';


