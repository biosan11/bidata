-- 7_ft_25_outdepot_hzbs.sql
/*
-- 建表 bidata.ft_25_outdepot_hzbs
use bidata;
drop table if exists ft_25_outdepot_hzbs;
create table `ft_25_outdepot_hzbs`(
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
	key bidata_ft_25_outdepot_hzbs_id (id),
	key bidata_ft_25_outdepot_hzbs_ccuscode (ccuscode),
	key bidata_ft_25_outdepot_hzbs_finnal_ccuscode (finnal_ccuscode),
	key bidata_ft_25_outdepot_hzbs_iunitcost (iunitcost),
	key bidata_ft_25_outdepot_hzbs_item_code (item_code)
) engine=innodb default charset=utf8 comment='bi销售发货表_杭州贝生';
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
    ,ifnull(a.ccuscode,"unknowncus")
    ,ifnull(a.finnal_ccuscode,"unknowncus")
    ,ifnull(a.cbustype,"产品类")
    ,null as sales_type
    ,a.cinvcode
    ,null
    ,a.iquantity
    ,a.isum
    ,a.iquantity * b.inum_unit_person as inum_person
    ,a.item_code 
    ,null as plan_type 
    ,null as key_points
    ,null as fsettleqty
    ,null as sys_time
from ufdata.x_sales_hzbs as a
left join edw.map_inventory as b
on a.cinvcode = b.bi_cinvcode;