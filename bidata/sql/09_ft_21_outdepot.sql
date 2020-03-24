-- 5_ft_21_outdepot
/*
CREATE TABLE `ft_21_outdepot` (
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
  `areadirector` varchar(20) DEFAULT NULL COMMENT '主管',
  `cverifier` varchar(20) DEFAULT NULL COMMENT '销售',
  `sys_time` datetime DEFAULT NULL COMMENT '数据时间戳',
  KEY `bidata_bi_outdepot_id` (`id`),
  KEY `bidata_bi_outdepot_ccuscode` (`ccuscode`),
  KEY `bidata_bi_outdepot_finnal_ccuscode` (`finnal_ccuscode`),
  KEY `bidata_bi_outdepot_iunitcost` (`iunitcost`),
  KEY `bidata_bi_outdepot_item_code` (`item_code`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='bi销售发货表';
 */
 
 -- bi_outdepot取部分字段
truncate table bidata.ft_21_outdepot;
insert into bidata.ft_21_outdepot 
select
	 id
	,cohr
	,ddate
	,cwhcode
	,cdepcode
	,cpersoncode
	,ccuscode
	,finnal_ccuscode
	,ifnull(cbustype,"产品类")
	,sales_type
	,cinvcode
	,null
	,round(iquantity,3)
	,null
	,round(inum_person,3)
	,ifnull(item_code,"其他")
	,plan_type
	,key_points
	,round(fsettleqty,3)
	,areadirector
	,cverifier
	,sys_time
from pdm.outdepot_order
where iquantity != 0;

update bidata.ft_21_outdepot 
set finnal_ccuscode = ccuscode 
where finnal_ccuscode = "multi";
