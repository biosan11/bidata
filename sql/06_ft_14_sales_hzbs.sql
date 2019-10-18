-- 5_ft_15_sales_hzbs.sql
/*
use ufdata;
drop table if exists x_sales_hzbs;
create table `x_sales_hzbs`(
    `ddate` datetime default null comment '单据日期',
    `cohr` varchar(20) default null comment '公司简称',
    `ccuscode` varchar(20) default null comment '客户编码',
    `ccusname` varchar(120) comment '客户名称',
    `finnal_ccuscode` varchar(20) default null comment '最终客户正确编码',
    `finnal_ccusname` varchar(60) comment '最终客户名称',
    `cbustype` varchar(60) default null comment '业务类型',
    `cinvcode` varchar(60) default null comment '存货编码',
    `cinvname` varchar(255) comment '存货名称',
    `item_code` varchar(60) default null comment '项目编码',
    `level_one` varchar(60) comment '一级目录-产品线',
    `level_two` varchar(60) comment '二级目录-产品组',
    `level_three` varchar(60) comment '三级目录-项目',
    `itaxunitprice` float(13,3) default null comment '原币含税单价',
    `itax`  float(13,3)  default  null  comment  '原币税额',
    `iquantity` float(13,3) comment'发货数量',
    `isum`  float(13,3)  default  null  comment  '原币价税合计',
    key `index_x_sales_hzbs_ccuscode` (`ccuscode`),
    key `index_bx_sales_hzbs_finnal_ccuscode` (finnal_ccuscode),
    key `index_x_sales_hzbs_cinvcode` (cinvcode),
    key `index_x_sales_hzbs_item_code` (item_code)
) engine=innodb default charset=utf8 comment='线下收入表_杭州贝生';

-- 建表 bidata.ft_14_sales_hzbs
use bidata;
drop table if exists ft_14_sales_hzbs;
create table `ft_14_sales_hzbs`(
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
) engine=innodb default charset=utf8 comment='bi销售收入表_杭州贝生';
 */


truncate table bidata.ft_14_sales_hzbs;
-- 导入线上数据
insert into bidata.ft_14_sales_hzbs
select * from bidata.ft_11_sales
where cohr = "杭州贝生";


-- 导入线上数据（关联公司）
insert into bidata.ft_14_sales_hzbs
select 
    a.sbvid
    ,a.ddate
    ,"杭州贝生" as cohr
    ,a.cwhcode
    ,a.cdepcode
    ,ifnull(a.true_ccuscode,"unknowncus")
    ,a.true_finnal_ccuscode
    ,ifnull(e.business_class,"产品类")
    ,a.bi_cinvcode
    ,ifnull(true_itemcode,"其他")
    ,null
    ,null
    ,round((a.itaxunitprice/1000),2) as itaxunitprice
    ,round((a.itax/1000),3) as itax
    ,round((a.isum/1000),3) as isum
    ,a.sys_time
from edw.invoice_order as a
left join (select specification_type,bi_cinvcode,item_code,business_class,cinvbrand from edw.map_inventory group by bi_cinvcode) e
    on a.bi_cinvcode = e.bi_cinvcode
where 
db in ("UFDATA_168_2018","UFDATA_168_2019")
and left(true_ccuscode,2) = "gl";



-- 导入线下数据
insert into bidata.ft_14_sales_hzbs
select 
    99999999 -- 杭州贝生线下
    ,ddate
    ,cohr
    ,null
    ,null
    ,ifnull(ccuscode,"unknowncus")
    ,finnal_ccuscode
    ,ifnull(cbustype,"产品类")
    ,cinvcode
    ,ifnull(item_code,"其他")
    ,null
    ,null
    ,round((itaxunitprice/1000),2) as itaxunitprice
    ,round((itax/1000),3) as itax
    ,round((isum/1000),3) as isum
    ,null
from ufdata.x_sales_hzbs;







