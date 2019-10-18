-- 2_ft_11_sales
/*
-- 建表 bidata.ft_11_sales
use bidata;
drop table if exists ft_11_sales;
create table `ft_11_sales`(
    `sbvid` int(11) default null comment '销售发票主表标识',
    `ddate` datetime default null comment '单据日期',
    `cohr` varchar(20) default null comment '公司简称',
    `cwhcode` varchar(10) default null comment '仓库编码',
    `cdepcode` varchar(12) default null comment '部门编码',
    `ccuscode` varchar(20) default null comment '客户编码',
    `finnal_ccuscode` varchar(20) default null comment '最终客户正确编码',
    `cbustype` varchar(60) default null comment '业务类型',
    `cinvcode` varchar(60) default null comment '存货编码',
    `item_code` varchar(60) default null comment '项目编码',
    `plan_type` varchar(255) default null comment '计划类型:占点、保点、上量、增项',
    `key_points` varchar(20) default null comment '是否重点',
    `itaxunitprice` float(13,3) default null comment '原币含税单价',
    `itax`  float(13,3)  default  null  comment  '原币税额',  
    `isum`  float(13,3)  default  null  comment  '原币价税合计',   
    `sys_time` datetime default null comment '数据时间戳',
    key `index_bidata_bisales_sbvid` (`sbvid`),
    key `index_bidata_bisales_ccuscode` (`ccuscode`),
    key `index_bidata_bisales_finnal_ccuscode` (finnal_ccuscode),
    key `index_bidata_bisales_cinvcode` (cinvcode)
) engine=innodb default charset=utf8 comment='bi销售收入表';
 */
 
-- bidata.ft_11_sales取部分字段
truncate table bidata.ft_11_sales;
insert into bidata.ft_11_sales 
select
	sbvid
	,ddate
	,cohr
	,cwhcode
	,cdepcode
	,ifnull(ccuscode,"unknowncus")
	,finnal_ccuscode
	,ifnull(cbustype,"产品类")
	,cinvcode
	,ifnull(item_code,"其他")
	,plan_type
	,key_points
	,round((ifnull(itaxunitprice,0)/1000),3) as itaxunitprice
	,round((ifnull(itax,0)/1000),3) as itax
	,round((ifnull(isum,0)/1000),3) as isum
	,sys_time
from pdm.invoice_order
where item_code != "jk0101"
and (isum != 0 or itax != 0);

update bidata.ft_11_sales 
set finnal_ccuscode = ccuscode 
where finnal_ccuscode = "multi";