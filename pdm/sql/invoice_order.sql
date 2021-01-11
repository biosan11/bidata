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

技术保障维保' where if_xs is null and db = 'UFDATA_111_2018'and csbvcode = 'ZJBSPF190620026';
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


