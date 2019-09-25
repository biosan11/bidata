
/*
-- 建表 bidata.ft_26_outdepot_yj
use bidata;
drop table if exists ft_26_outdepot_yj;
create table `ft_26_outdepot_yj`(
    uguid1 varchar(36) comment 'uGuid1',
    uguid2 varchar(36) comment 'uGuid2',
    cohr varchar(60) comment '公司',
    tbilldate date comment '送货日期',
    tcrtdate date comment '制单日期',
    torderdate date comment '结算日期',
    cinvcode varchar(60) comment 'bi_产品编号',
    item_code  varchar(30) comment '项目编码',
    cbustype varchar(30) comment '业务类型',
    sproductmodel varchar(60) comment '产品型号',
    sproductstyle varchar(60) comment '产品规格',
    sdefineno varchar(60) comment '批次',
    spoductlotno varchar(60) comment '批号',
    dqty float(13,3) comment '销售数量',
    inum_person float(13,3) comment '人份数',
    dprice float(13,3) comment '价格',
    dmoney float(13,3) comment '金额',
    ccuscode varchar(30) comment 'bi_客户编号',
    tproductdate date comment '生产日期',
    teffectdate date comment '有效期至',
    key bidata_ft_26_outdepot_yj_cinvcode (cinvcode),
    key bidata_ft_26_outdepot_yj_item_code  (item_code ),
    key bidata_ft_26_outdepot_yj_ccuscode (ccuscode)
) engine=innodb default charset=utf8 comment='bi药监体统发货表';
 */


-- bi_outdepot取部分字段
truncate table bidata.ft_26_outdepot_yj;
insert into bidata.ft_26_outdepot_yj 
select
    a.uguid1
    ,a.uguid2
    ,a.cohr
    ,date(a.tbilldate)
    ,date(a.tcrtdate)
    ,date(a.torderdate)
    ,a.cinvcode
    ,b.item_code 
    ,b.business_class
    ,a.sproductmodel
    ,a.sproductstyle
    ,a.sdefineno
    ,a.spoductlotno
    ,a.dqty
    ,a.dqty * b.inum_unit_person as inum_person
    ,a.dprice
    ,a.dmoney
    ,a.ccuscode
    ,date(a.tproductdate)
    ,date(a.teffectdate)
from pdm.yj_outdepot as a 
left join edw.map_inventory as b 
on a.cinvcode = b.bi_cinvcode;
