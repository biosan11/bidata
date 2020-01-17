/*
CREATE TABLE `ft_111_sales_order` (
	`csocode` varchar(30) DEFAULT NULL COMMENT '销售订单号',
  `cohr` varchar(20) DEFAULT NULL COMMENT '公司简称',
  `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编码',
  `finnal_ccuscode` varchar(20) DEFAULT NULL COMMENT '最终客户正确编码',
  `cbustype` varchar(60) DEFAULT NULL COMMENT '业务类型',
  `cinvcode` varchar(60) DEFAULT NULL COMMENT '存货编码',
  `item_code` varchar(60) DEFAULT NULL COMMENT '项目编码',
  `itaxunitprice` decimal(30,10) DEFAULT NULL COMMENT '原币含税单价',
  `iquantity` decimal(30,10) DEFAULT NULL COMMENT '数量',
  `itax` decimal(19,4) DEFAULT NULL COMMENT '原币税额',
  `isum` decimal(19,4) DEFAULT NULL COMMENT '原币价税合计',
  KEY `index_ft_111_sales_order_csocode` (`csocode`) USING BTREE
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='BI销售订单表';
*/
truncate table bidata.ft_111_sales_order;
insert into bidata.ft_111_sales_order 
select
  `csocode` ,
  `cohr`,
  `ccuscode`,
  `finnal_ccuscode` ,
  `cbustype`,
  `cinvcode`,
  `item_code`,
  `itaxunitprice`,
  `iquantity`,
  `itax`,
  `isum`
from pdm.sales_order;