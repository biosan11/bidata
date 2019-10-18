-- not confirm
/*
-- 建表 report.financial_sales_cost_backup
use report;
drop table if exists report.financial_sales_cost_backup;
create table if not exists report.financial_sales_cost_backup(
    matchid varchar(50) comment 'id_1',
    matchid3 varchar(50) comment 'id_3',
    sbvid int comment '销售发票主表标识',
    autoid int comment '销售订单子表标识',
    ddate_invoice date comment '单据日期_开票',
    cohr varchar(20) comment '公司简称',
    ccuscode_invoice varchar(20) comment '客户编码',
    finnal_ccuscode_invoice varchar(20) comment '最终客户正确编码',
    cbustype varchar(60) comment '业务类型',
    cinvcode_invoice varchar(60) comment '存货编码',
    item_code_invoice varchar(60) comment '项目编码',
    itaxunitprice float(13,3) comment '原币含税单价',
    iquantity_invoice float(13,3) comment '销量(盒)',
    itax float(13,3) comment '原币税额',
    isum_invoice float(13,3) comment '原币价税合计',
    matchid2 varchar(50) comment 'id_2',
    ddate_outdepot date comment '单据日期_发货',
    ccuscode_outdepot varchar(20) comment '客户编码',
    finnal_ccuscode_outdepot varchar(20) comment '最终客户正确编码',
    cinvcode_outdepot varchar(20) comment '存货编码',
    item_code_outdepot varchar(20) comment '项目编码',
    iunitcost float(13,3) comment '成本价',
    iquantity_outdepot float(13,3) comment '发货数量',
    mark_iunitcost varchar(50) comment '读取单价标记',
    key report_financial_sales_cost_matchid (matchid),
    key report_financial_sales_cost_matchid2 (matchid2),
    key report_financial_sales_cost_matchid3 (matchid3),
    key report_financial_sales_cost_sbvid (sbvid),
    key report_financial_sales_cost_autoid (autoid)
) engine=innodb default charset=utf8 comment='省区财务绩效模板数据_收入成本毛利';
 */
 
-- 临时表1    取pdm.invoice_order 数据 2018&2019数据
drop temporary table if exists report.tem00;
create temporary table if not exists report.tem00
select 
    concat(db,autoid) as matchid 
    ,concat(db,ccuscode,cinvcode) as matchid3
    ,sbvid
    ,autoid
    ,ddate as ddate_invoice
    ,cohr
    ,ccuscode as ccuscode_invoice
    ,finnal_ccuscode as finnal_ccuscode_invoice
    ,cbustype
    ,cinvcode as cinvcode_invoice
    ,item_code as item_code_invoice
    ,round(itaxunitprice,3) as itaxunitprice
    ,round(iquantity,3) as iquantity_invoice
    ,round(itax,3) as itax
    ,round(isum,3) as isum_invoice
from pdm.invoice_order 
where year(ddate) >= 2018;
alter table report.tem00 add index index_tem00_matchid (matchid);

-- 临时表2    取edw.invoice_order数据 2018&2019数据（取 isaleoutid 字段）
drop temporary table if exists report.tem01;
create temporary table if not exists report.tem01
select
    concat(db,autoid) as matchid
    ,concat(db,isaleoutid) as matchid2
from edw.invoice_order 
where year(ddate) >= 2018;
alter table report.tem01 add index index_tem01_matchid (matchid);
alter table report.tem01 add index index_tem01_matchid2 (matchid2);

-- 临时表3    取edw.outdepot_order 数据 
drop temporary table if exists report.tem02;
create temporary table if not exists report.tem02
select 
    concat(db,autoid) as matchid2
    ,ddate as ddate_outdepot
    ,true_ccuscode as ccuscode_outdepot
    ,true_finnal_ccuscode as finnal_ccuscode_outdepot
    ,bi_cinvcode as cinvcode_outdepot
    ,true_itemcode as item_code_outdepot
    ,round(iunitcost,3) as iunitcost 
    ,round(iquantity,3) as iquantity_outdepot
from edw.outdepot_order;
alter table report.tem02 add index index_tem02_matchid2 (matchid2);

-- 临时表4  取edw.outdepot_order 客户产品第一次出现的价格
drop temporary table if exists report.tem03;
create temporary table if not exists report.tem03
select 
    a.matchid3
    ,a.ddate
    ,a.iunitcost
from 
(
    select 
        concat(db,true_ccuscode,bi_cinvcode) as matchid3
        ,ddate
        ,iunitcost
    from edw.outdepot_order 
    where iunitcost != 0 
    order by matchid3,ddate asc ,iunitcost
) as a
group by matchid3;
alter table report.tem03 add index index_tem03_matchid3 (matchid3);

-- 临时表5  取edw.outdepot_order 客户产品第一次出现的价格(不取db)
drop temporary table if exists report.tem04;
create temporary table if not exists report.tem04
select 
    a.matchid4
    ,a.ddate
    ,a.iunitcost
from 
(
    select 
        concat(true_ccuscode,bi_cinvcode) as matchid4
        ,ddate
        ,iunitcost
    from edw.outdepot_order 
    where iunitcost != 0 
    and year(ddate) = 2018
    order by matchid4,ddate asc ,iunitcost
) as a
group by matchid4;
alter table report.tem04 add index index_tem04_matchid4 (matchid4);

-- 临时表6  取edw.outdepot_order 客户产品第一次出现的价格(不取db,ccuscode)
drop temporary table if exists report.tem05;
create temporary table if not exists report.tem05
select 
    a.cinvcode
    ,a.ddate
    ,a.iunitcost
from 
(
    select 
        bi_cinvcode as cinvcode
        ,ddate
        ,iunitcost
    from edw.outdepot_order 
    where iunitcost != 0 
    order by cinvcode,ddate asc ,iunitcost
) as a
group by cinvcode;
alter table report.tem05 add index index_tem05_cinvcode (cinvcode);


-- 组合上述3张临时表 
truncate table report.financial_sales_cost_backup;
insert into report.financial_sales_cost_backup
select 
    a.*
    ,c.*
    ,if (b.matchid2 is null,null,"outdepot")
from report.tem00 as a
left join report.tem01 as b
on a.matchid = b.matchid
left join report.tem02 as c
on b.matchid2 = c.matchid2
where item_code_invoice != "jk0101";

-- 更新没有价格的部分    cohr 不等于 贝康 贝康个人 甄元等
update report.financial_sales_cost_backup as a 
left join report.tem03 as b 
on a.matchid3 = b.matchid3
set a.iunitcost = b.iunitcost ,a.mark_iunitcost = "db_ccuscode_cinvcode"
where a.iunitcost is null 
and a.cohr not in ("贝康","贝康个人","甄元健康","甄元实验室");

update report.financial_sales_cost_backup as a 
left join report.tem04 as b 
on concat(a.ccuscode_invoice,a.cinvcode_invoice) = b.matchid4
set a.iunitcost = b.iunitcost ,a.mark_iunitcost = "ccuscode_cinvcode"
where a.iunitcost is null 
and a.cohr not in ("贝康","贝康个人","甄元健康","甄元实验室");

update report.financial_sales_cost_backup as a 
left join report.tem05 as b 
on a.cinvcode_invoice = b.cinvcode
set a.iunitcost = b.iunitcost ,a.mark_iunitcost = "cinvcode"
where a.iunitcost is null 
and a.cohr not in ("贝康","贝康个人","甄元健康","甄元实验室");

-- not confirm
-- 加入没有出库数据的单价内容
