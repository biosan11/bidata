------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：invoice_order.sql
--目标模型：invoice_order
--源    表：ufdata.salebillvouch,ufdata.salebillvouchs,edw.customer
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/jsh_test.sh invoice_order
------------------------------------开始处理逻辑------------------------------------------
--订单pdm层加工逻辑
--invoice_order建表语句
-- create table `invoice_order` (
--  `sbvid` int(11) default null comment '销售发票主表标识',
--  `autoid` int(11) DEFAULT NULL COMMENT '销售订单子表标识',
--  `ddate` datetime default null comment '单据日期',
--  `db` varchar(20) default null comment '来源数据库',
--  `cohr` varchar(20) default null comment '公司简称',
--  `cwhcode` varchar(10) DEFAULT NULL comment '仓库编码',
--  `cwhname` varchar(20) DEFAULT NULL comment '仓库名称',
--  `cdepcode` varchar(12) default null comment '部门编码',
--  `cdepname` varchar(255) DEFAULT NULL comment '部门名称',
--  `cpersoncode` varchar(20) DEFAULT NULL COMMENT '业务员编码',
--  `sales_region` varchar(20) DEFAULT NULL COMMENT '销售区域',
--  `province` varchar(60) DEFAULT NULL COMMENT '销售省份',
--  `city` varchar(60) DEFAULT NULL COMMENT '销售城市',
--  `ccustype` varchar(10) DEFAULT NULL COMMENT '客户类型',
--  `ccuscode` varchar(20) default null comment '客户编码',
--  `ccusname` varchar(120) default null comment '客户名称',
--  `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
--  `finnal_ccusname` varchar(60) DEFAULT NULL COMMENT '最终客户名称',
--  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
--  `sales_type` varchar(60) DEFAULT NULL COMMENT '产品销售类型-销售、赠送、配套、其他',
--  `cinvcode` varchar(60) default null comment '存货编码',
--  `cinvname` varchar(255) default null comment '存货名称',
--  `item_code` varchar(60) default null comment '项目编码',
--  `plan_type` varchar(255) default null comment '计划类型:占点、保点、上量、增项',
--  `key_points` varchar(20) default null comment '是否重点',
--  `itaxunitprice` decimal(30,10) default null comment '原币含税单价',
--  `iquantity` decimal(30,10) DEFAULT NULL COMMENT '数量',
--  `itax` decimal(19,4) DEFAULT NULL COMMENT '原币税额',
--  `isum` decimal(19,4) DEFAULT NULL COMMENT '原币价税合计',
--  `citemname` varchar(255) default null comment '项目名称',
--  `cvenabbname` varchar(60) DEFAULT NULL comment '供应商名称',
--  `cinvbrand` varchar(60) DEFAULT NULL COMMENT '品牌',
--  `cstcode` varchar(2) default null comment '销售类型编码',
--  `sys_time` datetime default null comment '数据时间戳',
--   PRIMARY KEY (`autoid`,`db`),
--   key index_invoice_order_sbvid  (`sbvid`),
--   key index_invoice_order_autoid  (`autoid`),
--   key index_invoice_order_db  (`db`)
-- ) engine=innodb default charset=utf8 comment '销售发票表';

-- 抽取增量，修改只取2019年以后的数据
create temporary table pdm.invoice_order_pre as 
select a.*
      ,b.type as ccustype
  from edw.invoice_order a
  left join edw.map_customer b
    on a.true_ccuscode = b.bi_cuscode
 -- where left(a.sys_time,10) >= '${start_dt}'
  where year(ddate)>=2019
  and state = '有效';
  
-- 删除贝康、检测收入
delete from pdm.invoice_order_pre where left(true_ccuscode,2) = 'GL';
delete from pdm.invoice_order_pre where true_ccuscode = 'DL1101002' and cinvcode = 'QT00004';

-- 删除客户是关联公司的订单 type = '关联公司'
-- delete from pdm.invoice_order_pre where ccustype = '关联公司';


-- 删除今天更新的数据
-- delete from pdm.invoice_order where sbvid in (select sbvid from  pdm.invoice_order_pre);
delete from pdm.invoice_order where year(ddate)>=2019;


-- 创建中间临时表加工item_code
-- drop table if exists pdm.invoice_order_item;
create temporary table pdm.invoice_order_item as
select e.bi_cinvcode
      ,e.business_class
      ,e.cinvbrand
      ,e.item_code
      ,e.specification_type
      ,f.plan_class
      ,f.key_project
   from (select specification_type,bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
   left join (select ccuscode,true_item_code,plan_class,key_project from edw.x_sales_budget_18 group by ccuscode,true_item_code) f
    on e.item_code = f.true_item_code
;


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
            when a.db = 'UFDATA_170_2020' then '甄元实验室'
            end
      ,a.csbvcode
      ,a.csocode
      ,a.cwhcode
      ,c.cwhname
      ,a.cdepcode
      ,d.cdepname
      ,a.cpersoncode
      ,b.sales_dept
      ,b.sales_region_new
      ,b.sales_region
      ,b.province
      ,b.city
      ,a.ccustype
      ,a.true_ccuscode as ccuscode
      ,a.true_ccusname as ccusname
      ,a.true_finnal_ccuscode as finnal_ccuscode
      ,a.true_finnal_ccusname2 as finnal_ccusname
      ,e.business_class
      ,a.cdefine22
      ,a.bi_cinvcode as cinvcode
      ,a.bi_cinvname as cinvname
      ,f.item_code
      ,e.plan_class
      ,e.key_project
      ,round(a.itaxunitprice,2)
      ,round(a.iquantity,2)
      ,round(a.itax,2)
      ,round(a.isum,2)
      ,f.level_three
      ,e.cinvbrand
      ,a.cvenabbname
      ,a.cstcode
      ,e.specification_type
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
  from pdm.invoice_order_pre a
  left join edw.map_customer b
    on a.true_finnal_ccuscode = b.bi_cuscode 
  left join (select cwhcode,db,cwhname from ufdata.warehouse group by cwhcode,db) c
    on a.cwhcode = c.cwhcode
   and a.db = c.db
  left join (select cdepcode,db,cdepname from ufdata.department group by cdepcode,db) d
    on a.cdepcode = d.cdepcode
   and a.db = d.db
  left join (select bi_cinvcode,plan_class,specification_type,key_project,business_class,cinvbrand from pdm.invoice_order_item group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
  left join (select * from edw.map_inventory group by bi_cinvcode) f
    on a.bi_cinvcode = f.bi_cinvcode
;

-- 删除上游已经删除的数据
-- drop table if exists pdm.invoice_order_wx;
-- create temporary table pdm.invoice_order_wx as select concat(db,sbvid) as db from edw.invoice_order where state = '无效';
-- CREATE INDEX index_invoice_order_wx_db ON pdm.invoice_order_wx(db);
-- delete from pdm.invoice_order where concat(db,sbvid) in (select db from pdm.invoice_order_wx) ;

-- 这里新增更新部门
update pdm.invoice_order s
  join (select * from ufdata.department where db = 'UFDATA_111_2018'  group by cdepcode) c
    on s.cdepcode = c.cdepcode
   set s.cdepname = c.cdepname
 where s.cdepname is null
   and s.cdepcode is not null
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




-- 客户名称 = 杭州云医购供应链科技有限公司  最终客户 = 上海文脉生物科技有限公司  的数据(通过订单号, 发票号等定位),最终客户改成 安庆市妇幼保健计划生育服务中心
update pdm.invoice_order set itaxunitprice = '49.54',itax = '5.7',isum='49.54', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='HC01028' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '504.39',itax = '116.05',isum='1008.78', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='HC01624' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '2.25',itax = '25.9',isum='225.17', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='HC01673' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '17684.21',itax = '20344.65',isum='176842.11', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='SJ01021' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '2357.89',itax = '2712.61',isum='23578.95', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='SJ01026' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '75157.89',itax = '86464.83',isum='751578.95', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='SJ01028' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '585.45',itax = '134.71',isum='1170.9', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='WX01423' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '180.14',itax = '20.73',isum='180.14', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='WX02028' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '270.21',itax = '31.08',isum='270.21', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='WX02038' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '1333029.67',itax = '153357.39',isum='1333029.67', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ01004' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '217518.02',itax = '25024.2',isum='217518.02', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ01008' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '1390043.71',itax = '159916.53',isum='1390043.71', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ01010' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '40.53',itax = '4.67',isum='40.53', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02067' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '5404.17',itax = '621.72',isum='5404.17', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02100' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '5224.04',itax = '601',isum='5224.04', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02112' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '1531.18',itax = '176.16',isum='1531.18', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02127' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '1891.46',itax = '217.6',isum='1891.46', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02146' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '92231.24',itax = '10610.67',isum='92231.24', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02147' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '990.77',itax = '113.98',isum='990.77', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02181' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '5043.9',itax = '580.27',isum='5043.9', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02254' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '24.77',itax = '5.7',isum='49.54', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02275' and sbvid = '1000024466' and db = 'UFDATA_111_2018';
update pdm.invoice_order set itaxunitprice = '9097.03',itax = '1046.56',isum='9097.03', finnal_ccuscode= 'ZD3408002',finnal_ccusname = '安庆市妇幼保健计划生育服务中心' where cinvcode ='YQ02291' and sbvid = '1000024466' and db = 'UFDATA_111_2018';

-- 甄元账套 开票数据中, 客户是吉林三基医学检验实验室有限公司 的数据, 收入应该归在杭州贝生  
update pdm.invoice_order set db = 'UFDATA_168_2018',cohr = '杭州贝生' where cohr = '甄元实验室' and ccusname = '吉林三基医学检验实验室有限公司';


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

