-- 7_ft_25_outdepot_hzbs.sql
/*
CREATE TABLE `ft_25_outdepot_hzbs` (
  `id` int(11) DEFAULT NULL COMMENT '出库单主表标识',
  `cohr` varchar(20) DEFAULT NULL COMMENT '公司简称',
  `ddate` datetime DEFAULT NULL COMMENT '单据日期',
  `cwhcode` varchar(10) DEFAULT NULL COMMENT '仓库编码',
  `cdepcode` varchar(12) DEFAULT NULL COMMENT '部门编码',
  `cpersoncode` varchar(20) DEFAULT NULL COMMENT '业务员编码',
  `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编码',
  `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
  `sales_type` varchar(60) DEFAULT NULL COMMENT '产品销售类型-销售、赠送、配套、其他',
  `cinvcode` varchar(60) DEFAULT NULL COMMENT '存货编码',
  `iunitcost` float(13,3) DEFAULT NULL COMMENT '原币含税单价',
  `iquantity` float(13,3) DEFAULT NULL COMMENT '数量',
  `isum` float(13,3) DEFAULT NULL COMMENT '原币价税合计',
  `inum_person` float(13,3) DEFAULT NULL COMMENT '销量(人份)',
  `item_code` varchar(60) DEFAULT NULL COMMENT '项目编码',
  `plan_type` varchar(255) DEFAULT NULL COMMENT '计划类型:占点、保点、上量、增项',
  `key_points` varchar(20) DEFAULT NULL COMMENT '是否重点',
  `fsettleqty` float(13,3) DEFAULT NULL COMMENT '已经开票数量',
  `areadirector` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `cverifier` varchar(60) DEFAULT NULL,
  `sys_time` datetime DEFAULT NULL COMMENT '数据时间戳',
  KEY `bidata_ft_25_outdepot_hzbs_id` (`id`),
  KEY `bidata_ft_25_outdepot_hzbs_ccuscode` (`ccuscode`),
  KEY `bidata_ft_25_outdepot_hzbs_finnal_ccuscode` (`finnal_ccuscode`),
  KEY `bidata_ft_25_outdepot_hzbs_iunitcost` (`iunitcost`),
  KEY `bidata_ft_25_outdepot_hzbs_item_code` (`item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='bi销售发货表_杭州贝生';
 */
 
truncate table bidata.ft_25_outdepot_hzbs;

-- 导入线上数据
insert into bidata.ft_25_outdepot_hzbs
select * from bidata.ft_21_outdepot
where cohr = "杭州贝生";

/*
-- 导入线上数据（关联公司）

*/

-- 导入线下数据
insert into bidata.ft_25_outdepot_hzbs
select 
    99999999 as id 
    ,"杭州贝生"
    ,a.ddate
    ,null as cwhcode
    ,null as cdepcode
    ,null as cpersoncode
    ,ifnull(bi_cuscode,"unknowncus")
    ,true_finnal_ccuscode
    ,ifnull(cbustype,"产品类")
    ,null as sales_type
    ,a.bi_cinvcode
    ,null
    ,a.iquantity
    ,a.isum
    ,a.iquantity * b.inum_unit_person as inum_person
    ,a.item_code 
    ,null as plan_type 
    ,null as key_points
    ,null as fsettleqty
	,NULL
	,NULL
    ,null as sys_time
from edw.x_sales_hzbs as a
left join edw.map_inventory as b
on a.bi_cinvcode = b.bi_cinvcode;
