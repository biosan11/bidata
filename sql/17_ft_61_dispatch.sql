-- 6_ft_61_dispatch
/*
-- 建表 bidata.ft_61_dispatch
use bidata;
drop table if exists bidata.ft_61_dispatch;
create table if not exists bidata.ft_61_dispatch(
    dlid int comment '发货退货单主表标识',
    cohr varchar(20) comment '公司简称',
    ddate datetime comment '单据日期',
    ccuscode varchar(20) comment '客户编码',
    finnal_ccuscode varchar(20) comment '最终客户正确编码',
    cbustype varchar(8) comment '业务类型',
    cinvcode varchar(60) comment '存货编码',
    iquantity float(13,3) comment '数量',
    itaxunitprice float(13,3) comment '原币含税单价',
    itax float(13,3) comment '原币税额',
    isum float(13,3) comment '原币价税合计',
    item_code varchar(60) comment '正确项目编码',
    cstcode varchar(2) comment '销售类型编码',
    isale int comment '是否先发货',
    breturnflag varchar(20) comment '退货标志 ',
    bsaleoutcreatebill varchar(20) comment '是否出库开票 ',
    autoid int comment '发货退货子表标识',
    isosid int comment '销售订单子表标识',
    foutquantity varchar(64) comment '累计出库数量',
    itb varchar(64) comment '退补标志 ',
    key bidata_ft_61_dispatch_dlid (dlid),
    key bidata_ft_61_dispatch_ccuscode (ccuscode),
    key bidata_ft_61_dispatch_finnal_ccuscode (finnal_ccuscode),
    key bidata_ft_61_dispatch_cinvcode (cinvcode),
    key bidata_ft_61_dispatch_item_code (item_code),
    key bidata_ft_61_dispatch_autoid (autoid),
    key bidata_ft_61_dispatch_isosid (isosid)
) engine=innodb default charset=utf8 comment='bi发货单列表';
 */
 
 -- ft_61_dispatch 取数据 来源第三层
truncate table bidata.ft_61_dispatch;
insert into bidata.ft_61_dispatch
select
    dlid
    ,cohr
    ,ddate
    ,ccuscode
    ,finnal_ccuscode
    ,cbustype
    ,cinvcode
    ,round(iquantity,3) as iquantity
    ,round(itaxunitprice,3) as itaxunitprice
    ,round(itax/1000,3) as itax
    ,round(isum/1000,3) as isum 
    ,item_code
    ,cstcode
    ,isale
    ,breturnflag
    ,bsaleoutcreatebill
    ,autoid
    ,isosid
    ,foutquantity
    ,itb
from pdm.dispatch_order
where item_code != "jk0101"
and (isum != 0 or itax != 0);

update bidata.ft_61_dispatch
set finnal_ccuscode = ccuscode 
where finnal_ccuscode = "multi";