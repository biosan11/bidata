/*
drop table if exists bidata.ft_51_ar_detail;
create table bidata.ft_51_ar_detail (
  `auto_id` int(6) not null comment '排序编号',
  `ar_ap` varchar(20) DEFAULT NULL COMMENT 'arap标记',
  `cohr` varchar(20) DEFAULT NULL COMMENT '公司',
  `mark_` varchar(5) character set utf8mb4 default null,
  `cdwcode` varchar(20) default null comment '单位编码 ',
  `true_ccuscode` varchar(20) default null comment '正确客户编码',
  `true_cinvcode` varchar(20) default null comment '正确产品编码',
  `cinvcode` varchar(20) DEFAULT NULL COMMENT '产品编码',
  `item_code` varchar(60) DEFAULT NULL COMMENT '项目编码',
  `ar_class` varchar(10) character set utf8 collate utf8_bin default null comment '业务类型',
  `dvouchdate_ar` date default null comment '应收日期',
  `dvouchdate_ap` date default null comment '回款日期',
  `ap_amount` float(12,4) DEFAULT NULL COMMENT '应收金额',
  `refund_amount` float(12,4) default null comment '回款金额',
`cdigest` varchar(300) DEFAULT NULL COMMENT '摘要 '
) engine=innodb default charset=utf8 comment='应收回款明细';
*/


truncate table bidata.ft_51_ar_detail;
insert into bidata.ft_51_ar_detail
select 
    concat(true_ccuscode,ar_class) as ccuscode_class
    ,auto_id
    ,ar_ap
    ,cohr
    ,mark_
    ,cdwcode
    ,true_ccuscode
    ,true_cinvcode
    ,cinvcode
    ,item_code
    ,ar_class
    ,dvouchdate_ar
    ,dvouchdate_ap
    ,ap_amount
    ,refund_amount
    ,cdigest
 from pdm.ar_detail
 where mark_ is not null;

