-- 2_ft_11_sales
/* test
-- 建表 bidata.ft_11_sales
CREATE TABLE `ft_11_sales` (
  `sbvid` int(11) DEFAULT NULL COMMENT '销售发票主表标识',
  `ddate` datetime DEFAULT NULL COMMENT '单据日期',
  `cohr` varchar(20) DEFAULT NULL COMMENT '公司简称',
  `cwhcode` varchar(10) DEFAULT NULL COMMENT '仓库编码',
  `cdepcode` varchar(12) DEFAULT NULL COMMENT '部门编码',
  `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编码',
  `ccusname` varchar(100) DEFAULT NULL COMMENT '客户名称',
  `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
  `finnal_ccusname` varchar(100) DEFAULT NULL COMMENT '最终客户名称',
  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
  `cinvcode` varchar(60) DEFAULT NULL COMMENT '存货编码',
  `item_code` varchar(60) DEFAULT NULL COMMENT '项目编码',
  `plan_type` varchar(255) DEFAULT NULL COMMENT '计划类型:占点、保点、上量、增项',
  `key_points` varchar(20) DEFAULT NULL COMMENT '是否重点',
  `itaxunitprice` float(13,3) DEFAULT NULL COMMENT '原币含税单价',
  `itax` float(13,3) DEFAULT NULL COMMENT '原币税额',
  `isum` float(13,3) DEFAULT NULL COMMENT '原币价税合计',
  `areadirector` varchar(60) DEFAULT NULL,
  `cverifier` varchar(60) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL,
  `sys_time` datetime DEFAULT NULL COMMENT '数据时间戳',
  KEY `index_bidata_bisales_sbvid` (`sbvid`),
  KEY `index_bidata_bisales_ccuscode` (`ccuscode`),
  KEY `index_bidata_bisales_finnal_ccuscode` (`finnal_ccuscode`),
  KEY `index_bidata_bisales_cinvcode` (`cinvcode`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='bi销售收入表';
 */
 
-- bidata.ft_11_sales取部分字段
truncate table bidata.ft_11_sales;
insert into bidata.ft_11_sales 
select
	 a.sbvid
	,a.ddate
	,a.cohr
	,a.cwhcode
	,a.cdepcode
	,ifnull(ccuscode,"unknowncus")
	,ifnull(ccusname,"unknowncus")
	,finnal_ccuscode
	,finnal_ccusname
	,ifnull(b.business_class,"产品类")
	,a.cinvcode
	,ifnull(a.item_code,"其他")
	,a.plan_type
	,a.key_points
	,round((ifnull(itaxunitprice,0)/1000),3) as itaxunitprice
	,round((ifnull(a.itax,0)/1000),3) as itax
	,round((ifnull(a.isum,0)/1000),3) as isum
	,a.areadirector
	,a.cverifier
	,a.sys_time
from pdm.invoice_order a
left join edw.map_inventory b
  on a.cinvcode = b.bi_cinvcode
where a.item_code != "jk0101"
and (isum != 0 or a.itax != 0);

update bidata.ft_11_sales 
set finnal_ccuscode = ccuscode 
where finnal_ccuscode = "multi";
