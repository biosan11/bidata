-- 5_ft_21_outdepot
/*
-- 建表 bidata.ft_21_outdepot
use bidata;
drop table if exists ft_21_outdepot;
create table `ft_21_outdepot`(
	id int(11) comment '出库单主表标识',
	cohr varchar(20) comment '公司简称',
	ddate datetime comment '单据日期',
	cwhcode varchar(10) comment '仓库编码',
	cdepcode varchar(12) comment '部门编码',
	cpersoncode varchar(20) comment '业务员编码',
	ccuscode varchar(20) comment '客户编码',
	finnal_ccuscode varchar(20) comment '最终客户正确编码',
	cbustype varchar(60) comment '业务类型',
	sales_type varchar(60) comment '产品销售类型-销售、赠送、配套、其他',
	cinvcode varchar(60) comment '存货编码',
	iunitcost float(13,3) comment '原币含税单价',
	iquantity float(13,3) comment '数量',
	isum float(13,3) comment '原币价税合计',
	inum_person float(13,3) comment '销量(人份)',
	item_code varchar(60) comment '项目编码',
	plan_type varchar(255) comment '计划类型:占点、保点、上量、增项',
	key_points varchar(20) comment '是否重点',
	fsettleqty float(13,3) comment '已经开票数量',
	sys_time datetime comment '数据时间戳',
	key bidata_bi_outdepot_id (id),
	key bidata_bi_outdepot_ccuscode (ccuscode),
	key bidata_bi_outdepot_finnal_ccuscode (finnal_ccuscode),
	key bidata_bi_outdepot_iunitcost (iunitcost),
	key bidata_bi_outdepot_item_code (item_code)
) engine=innodb default charset=utf8 comment='bi销售发货表';
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
	,sys_time
from pdm.outdepot_order
where iquantity != 0;

update bidata.ft_21_outdepot 
set finnal_ccuscode = ccuscode 
where finnal_ccuscode = "multi";