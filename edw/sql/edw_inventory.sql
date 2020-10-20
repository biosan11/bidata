 ------------------------------------程序头部----------------------------------------------
--功能：整合层客户档案
------------------------------------------------------------------------------------------
--程序名称：inventory.sql
--目标模型：inventory
--源    表：ufdata.inventory
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/inventory.python 2018-11-12
------------------------------------开始处理逻辑------------------------------------------
--订单edw层加工逻辑
--inventory建表语句
--create table `inventory` (
--  `db` varchar(20) NOT NULL DEFAULT '' COMMENT '来源数据库',
--  `cinvcode` varchar(60) DEFAULT NULL comment '存货编码',
--  `cinvname` varchar(255) DEFAULT NULL comment '存货名称',
--  `bi_cinvcode` varchar(60) DEFAULT NULL comment 'bi存货编码',
--  `bi_cinvname` varchar(255) DEFAULT NULL comment 'bi正确存货名称',
--  `cinvstd` varchar(255) DEFAULT NULL comment '规格型号',
--  `cinvdefine8` varchar(120) DEFAULT NULL comment '项目简称',
--  `cinvdefine9` varchar(120) DEFAULT NULL comment '项目详细名称',
--  `cinvdefine13` double DEFAULT NULL comment '人份数',
--  `cinvdefine5` varchar(60) DEFAULT NULL comment '存货自定义项5 ',
--  `cinvccode` varchar(12) DEFAULT NULL comment '存货大类编码 ',
--  `cvencode` varchar(20) DEFAULT NULL comment '供应商编码',
--  `bsale` char(1) DEFAULT NULL comment '是否销售',
--  `dsdate` datetime DEFAULT NULL comment '启用日期',
--  `dedate` datetime DEFAULT NULL comment '停用日期',
--  `cmodifyperson` varchar(20) DEFAULT NULL comment '变更人',
--  `dmodifydate` datetime DEFAULT NULL comment '变日期',
--  `cinvdefine7` varchar(120) DEFAULT NULL comment '项目简称',
--  `end_date` date default null comment '数据时间',
--  `sys_time` datetime default null comment '数据时间戳'
--) engine=innodb default charset=utf8;

--alter table inventory comment '存货档案表';
--新建索引，删除增量数据的时候更快
--create index index_bi_inventory_cinvcode on edw.inventory(cinvcode);
--create index index_bi_inventory_db on edw.inventory(db);


use edw;

drop table if exists edw.inventory_pre;
create temporary table edw.inventory_pre as
select a.*
  from ufdata.inventory a
;
-- where left(a.dmodifydate,10) >= '${start_dt}';

-- 防重跑机制
-- delete from edw.inventory where end_date >= '${start_dt}' and end_date < '3000-12-31';

-- 删除今天更新的数据
-- UPDATE edw.inventory set end_date = '${start_dt}' where cinvcode in (select cinvcode from edw.inventory_pre);


truncate table edw.inventory;
insert into edw.inventory
select a.db
      ,a.cinvcode
      ,a.cinvname
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvcode end
      ,case when b.cinvcode is null then '请核查' else b.bi_cinvname end
      ,a.cinvstd
      ,a.cinvdefine8
      ,a.cinvdefine9
      ,a.cinvdefine13
      ,case 
		when a.cinvdefine5 is not null then a.cinvdefine5 
		when a.cinvdefine5 is null and a.centerprise = '贝安云' then '贝安云'
		when a.cinvdefine5 is null and a.centerprise = '博圣' then '博圣'
		when a.cinvdefine5 is null and a.centerprise = '杭州宝荣科技有限公司' then '宝荣'
		when a.cinvdefine5 is null and a.centerprise = '杭州贝安云科技有限公司' then '贝安云'
		when a.cinvdefine5 is null and a.centerprise = '杭州杰毅麦特医疗器械有限公司' then '杰毅麦特'
		when a.cinvdefine5 is null and a.centerprise = '甄元' then '甄元'
		else null 
	end as cinvdefine5
      ,a.centerprise
      ,a.cinvccode
      ,a.cvencode
      ,a.bsale
      ,a.dsdate
      ,a.dedate
      ,a.cmodifyperson
      ,a.dmodifydate
      ,a.cinvdefine7
      ,c.cidefine5
      ,c.cidefine4
      ,c.cidefine3
      ,c.cidefine2
      ,c.cidefine1
      ,'3000-12-31'
      ,localtimestamp()
  from edw.inventory_pre a
  left join (select cinvcode,db,bi_cinvcode,bi_cinvname from dic_inventory group by cinvcode) b
    on a.cinvcode = b.cinvcode
  left join ufdata.inventory_extradefine c
    on a.cinvcode = c.cinvcode
 where a.db not in ('UFDATA_222_2018','UFDATA_222_2019', 'UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018')
;
-- 分批插入
insert into edw.inventory
select a.db
      ,a.cinvcode
      ,a.cinvname
      ,case when b.db is null then '请核查' else b.bi_cinvcode end
      ,case when b.db is null then '请核查' else b.bi_cinvname end
      ,a.cinvstd
      ,a.cinvdefine8
      ,a.cinvdefine9
      ,a.cinvdefine13
      ,case 
		when a.cinvdefine5 is not null then a.cinvdefine5 
		when a.cinvdefine5 is null and a.centerprise = '贝安云' then '贝安云'
		when a.cinvdefine5 is null and a.centerprise = '博圣' then '博圣'
		when a.cinvdefine5 is null and a.centerprise = '杭州宝荣科技有限公司' then '宝荣'
		when a.cinvdefine5 is null and a.centerprise = '杭州贝安云科技有限公司' then '贝安云'
		when a.cinvdefine5 is null and a.centerprise = '杭州杰毅麦特医疗器械有限公司' then '杰毅麦特'
		when a.cinvdefine5 is null and a.centerprise = '甄元' then '甄元'
		else null 
	end as cinvdefine5
      ,a.centerprise
      ,a.cinvccode
      ,a.cvencode
      ,a.bsale
      ,a.dsdate
      ,a.dedate
      ,a.cmodifyperson
      ,a.dmodifydate
      ,a.cinvdefine7
      ,c.cidefine5
      ,c.cidefine4
      ,c.cidefine3
      ,c.cidefine2
      ,c.cidefine1
      ,'3000-12-31'
      ,localtimestamp()
  from edw.inventory_pre a
  left join dic_inventory b
    on left(a.db,10) = left(b.db,10)
   and a.cinvcode = b.cinvcode
  left join ufdata.inventory_extradefine c
    on a.cinvcode = c.cinvcode
 where a.db in ('UFDATA_222_2018','UFDATA_222_2019','UFDATA_588_2019','UFDATA_889_2019','UFDATA_588_2018','UFDATA_889_2018')
;

-- 根据erp的客户档案来修改我们，map_inventory部分字段
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where cinvstd is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.specification_type = c.cinvstd
;

-- 根据erp的客户档案来修改我们，map_inventory部分字段
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where dsdate is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.start_date = c.dsdate
--   ,a.latest_cost = c.iinvncost
;
-- 开始结束时间同步
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where dedate is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.end_date = c.dedate
--   ,a.product = c.cinvccode
--   ,a.cinvbrand = c.cinvdefine5
--   ,a.itax = c.itaxrate
--   ,a.latest_cost = c.iinvncost
;

update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where cinvccode is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.product = c.cinvccode
--   ,a.cinvbrand = c.cinvdefine5
--   ,a.itax = c.itaxrate
--   ,a.latest_cost = c.iinvncost
;
-- 单价同步
-- update edw.map_inventory a
-- inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
--   on a.bi_cinvcode = b.bi_cinvcode
-- inner join (select * from edw.edw.inventory where itaxrate is not null group by cinvcode) c
--   on b.cinvcode = c.cinvcode
-- set a.itax = c.itaxrate
-- --   ,a.latest_cost = c.iinvncost
;
-- U8名称同步
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where cinvname is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.u8_name = c.cinvname
--   ,a.latest_cost = c.iinvncost
;

-- 只更新品牌有问题的
update edw.map_inventory a
inner join (select * from edw.dic_inventory group by bi_cinvcode,cinvcode) b
  on a.bi_cinvcode = b.bi_cinvcode
inner join (select * from edw.inventory where cinvdefine5 is not null group by cinvcode) c
  on b.cinvcode = c.cinvcode
set a.cinvbrand = c.cinvdefine5
where a.cinvbrand is null
;

-- 修改一波有问题的品牌
update edw.map_inventory set cinvbrand = '英派康' where bi_cinvcode = 'HC01099';
update edw.map_inventory set cinvbrand = '雪莲牌' where bi_cinvcode = 'HC01422';
update edw.map_inventory set cinvbrand = '雅培' where bi_cinvcode = 'SJ03001';
update edw.map_inventory set cinvbrand = '松下' where bi_cinvcode = 'YQ02464';

-- 增加一条其他选项，方便bi调用时处理报错
insert into edw.map_item (item_code,level_three,level_two,level_one,equipment) 
values("其他","其他","其他","其他","否");

-- 20年新品药品
update edw.map_inventory set cinv_key_2020 = '服务_软件' where level_two='信息化B端' and (cinvbrand='博圣' or cinvbrand='贝安云');
update edw.map_inventory set cinv_key_2020 = '服务_物流' where level_two='标本配送';
update edw.map_inventory set cinv_key_2020 = '自有产品_宝荣' where cinvbrand='宝荣';
update edw.map_inventory set cinv_key_2020 = '甄元LDT' where business_class='LDT' and  cinvbrand='甄元';
update edw.map_inventory set cinv_key_2020 = '贝康LDT' where business_class='LDT' and  cinvbrand='贝康';
update edw.map_inventory set cinv_key_2020 = '串联试剂' where level_three='串联试剂';
update edw.map_inventory set cinv_key_2020 = '早孕' where level_three='Free hCGβ（早）' or level_three='PAPP-A';
update edw.map_inventory set cinv_key_2020 = '致善耳聋' where level_three='耳聋基因' and  cinvbrand='厦门致善';
update edw.map_inventory set cinv_key_2020 = '杰毅麦特NIPT' where level_three='NIPT' and  cinvbrand='杰毅麦特';
update edw.map_inventory set cinv_key_2020 = '芯片_自建' where level_three='CMA' and business_class='产品类';
update edw.map_inventory set cinv_key_2020 = '东方海洋VD' where level_three='维生素D' and  cinvbrand='东方海洋';

-- 产品档案的425_item和cinv_own，这两个字段麻烦设成自动更新
update  edw.map_inventory set 425_item='早孕' where level_three='PAPP-A';
update  edw.map_inventory set 425_item='早孕' where level_three='Free hCGβ（早）';
update  edw.map_inventory set 425_item='早孕' where level_three='早孕质控';
update  edw.map_inventory set 425_item='中孕' where level_three='中孕质控';
update  edw.map_inventory set 425_item='中孕' where level_three='UE3';
update  edw.map_inventory set 425_item='中孕' where level_three='AFP/Free hCGβ';
update  edw.map_inventory set 425_item='NIPT' where level_three='NIPT';
update  edw.map_inventory set 425_item='NIPT' where level_three='NIPT-plus';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='CMA';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='BoBs';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='CNV-seq';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='MCC';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='羊水培养基';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='细胞原位培养盒';
update  edw.map_inventory set 425_item='产前遗传病诊断' where level_three='绒毛膜细胞处理试剂';
update  edw.map_inventory set 425_item='产前地贫' where level_three='地贫试剂';
update  edw.map_inventory set 425_item='产前地贫' where level_three='地贫基因';
update  edw.map_inventory set 425_item='产筛辅助试剂耗材' where level_three='产筛辅助试剂耗材';
update  edw.map_inventory set 425_item='产诊辅助试剂耗材' where level_three='产诊辅助试剂耗材';
update  edw.map_inventory set 425_item='传统新筛' where level_three='17α-OH-P';
update  edw.map_inventory set 425_item='传统新筛' where level_three='TSH';
update  edw.map_inventory set 425_item='传统新筛' where level_three='G6PD';
update  edw.map_inventory set 425_item='传统新筛' where level_three='新筛质控';
update  edw.map_inventory set 425_item='传统新筛' where level_three='PKU';
update  edw.map_inventory set 425_item='传统新筛' where level_three='采血卡';
update  edw.map_inventory set 425_item='传统新筛' where level_three='条形码';
update  edw.map_inventory set 425_item='传统新筛' where level_three='采血针';
update  edw.map_inventory set 425_item='串联新筛' where level_three='串联试剂';
update  edw.map_inventory set 425_item='串联新筛' where level_three='串联试剂配套';
update  edw.map_inventory set 425_item='串联新筛' where level_three='串联质控';
update  edw.map_inventory set 425_item='耳聋检测' where level_three='耳聋基因';
update  edw.map_inventory set 425_item='传统新筛' where level_three='新筛辅助试剂耗材';
update  edw.map_inventory set 425_item='新生儿地贫' where level_three='新生儿地贫基因';
update  edw.map_inventory set 425_item='传统新筛' where level_three='G6PD基因';
update  edw.map_inventory set 425_item='IEM' where level_three='GCMS';
update  edw.map_inventory set 425_item='IEM' where level_three='遗传代谢病panel';
update  edw.map_inventory set 425_item='传统新筛' where level_three='CAH基因';
update  edw.map_inventory set 425_item='传统新筛' where level_three='PAH基因';
update  edw.map_inventory set 425_item='物流' where level_three='标本配送';
update  edw.map_inventory set 425_item='维保服务' where level_three='维保服务（筛查）';
update  edw.map_inventory set 425_item='维保服务' where level_three='产筛维修配件耗材';
update  edw.map_inventory set 425_item='维保服务' where level_three='维保服务（人工服务）';
update  edw.map_inventory set 425_item='维保服务' where level_three='产诊维修配件耗材';
update  edw.map_inventory set 425_item='维保服务' where level_three='新筛维修配件耗材';
update  edw.map_inventory set 425_item='维保服务' where level_three='维保服务（诊断）';
update  edw.map_inventory set 425_item='软件' where level_three='产筛信息管理系统服务';
update  edw.map_inventory set 425_item='软件' where level_three='新筛信息管理系统服务';
update  edw.map_inventory set 425_item='设备销售' where level_three='GSP' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='Puncher9' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='1420（新筛）' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='串联质谱仪' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='新筛配套设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='GCMS设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='PCR仪-致善' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='二代测序仪' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='产筛毛细管电泳仪' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='产诊配套设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='产筛配套设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='1235（产前）' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='DX6000' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='LifeCycle' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='CMA设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='GSL-120' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='细胞收获仪' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='一代测序仪' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='BoBs设备' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='KM2' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='CDS-5' and business_class='产品类';
update  edw.map_inventory set 425_item='设备销售' where level_three='KM1' and business_class='产品类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='GSP' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='Puncher9' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='1420（新筛）' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='串联质谱仪' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='新筛配套设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='GCMS设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='PCR仪-致善' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='二代测序仪' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='产筛毛细管电泳仪' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='产诊配套设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='产筛配套设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='1235（产前）' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='DX6000' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='LifeCycle' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='CMA设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='GSL-120' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='细胞收获仪' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='一代测序仪' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='BoBs设备' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='KM2' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='CDS-5' and business_class='租赁类';
update  edw.map_inventory set 425_item='设备租赁' where level_three='KM1' and business_class='租赁类';

update edw.map_inventory set cinv_own ='自有产品_博圣' where cinvbrand='博圣';
update edw.map_inventory set cinv_own ='自有产品_宝荣' where cinvbrand='宝荣';
update edw.map_inventory set cinv_own ='自有产品_贝康' where cinvbrand='贝康';
update edw.map_inventory set cinv_own ='自有产品_甄元' where cinvbrand='甄元';
update edw.map_inventory set cinv_own ='自有产品_杰毅麦特' where cinvbrand='杰毅麦特';
update edw.map_inventory set cinv_own ='自有产品_贝安云' where cinvbrand='贝安云';

-- 20200618更新: 产品档案中 425_item, item_key_2019等, 空替换成null
update edw.map_inventory set 425_item = null where 425_item = '';
update edw.map_inventory set item_key_2019 = null where item_key_2019 = '';
update edw.map_inventory set cinv_key_2020 = null where cinv_key_2020 = '';
update edw.map_inventory set cinv_own = null where cinv_own = '';

-- 20200724更新(金晶) : 产品档案中,  screen_class 空替换成 null
update edw.map_inventory set screen_class = null where screen_class = '';

-- 这里每天全量覆盖现有的项目档案的情况,每日一运行保持一致
truncate table edw.map_item;
insert into edw.map_item
select DISTINCT
item_code, level_three, level_two, level_one, equipment,screen_class, null, item_key_2019
  from edw.map_inventory
;

