-- 24_ft_84_expenses_settlement

/*
-- 建表 bidata.ft_84_expenses_settlement
use bidata;
drop table if exists bidata.ft_84_expenses_settlement;
create table if not exists bidata.ft_84_expenses_settlement(
    ccuscode varchar(20) comment '客户编码',
    year_ smallint comment '年份',
    month_ smallint comment '月份',
    sy_md float(13,4) comment '实验员金额',
    bx_md float(13,4) comment '保险金额',
    xxzx_md float(13,4) comment '内部结算-信息中心',
    jsbz_md float(13,4) comment '内部结算-技术保障',
    wb_md float(13,4) comment '内部结算-维保',
    wl_md float(13,4) comment '内部结算-物流',
    key bidata_ft_84_expenses_settlement_ccuscode (ccuscode),
    key bidata_ft_84_expenses_settlement_year_ (year_),
    key bidata_ft_84_expenses_settlement_month_ (month_)
) engine=innodb default charset=utf8 comment='费用-内部结算（含实验员、保险）';
*/

truncate table bidata.ft_84_expenses_settlement;
-- 将实验员费用导入（实验员人员成本）
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,1,mon_1,0,0,0,0,0 
from edw.x_account_sy where mon_1 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,2,mon_2,0,0,0,0,0 
from edw.x_account_sy where mon_2 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,3,mon_3,0,0,0,0,0 
from edw.x_account_sy where mon_3 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,4,mon_4,0,0,0,0,0 
from edw.x_account_sy where mon_4 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,5,mon_5,0,0,0,0,0 
from edw.x_account_sy where mon_5 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,6,mon_6,0,0,0,0,0 
from edw.x_account_sy where mon_6 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,7,mon_7,0,0,0,0,0 
from edw.x_account_sy where mon_7 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,8,mon_8,0,0,0,0,0 
from edw.x_account_sy where mon_8 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,9,mon_9,0,0,0,0,0 
from edw.x_account_sy where mon_9 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,10,mon_10,0,0,0,0,0 
from edw.x_account_sy where mon_10 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,11,mon_11,0,0,0,0,0 
from edw.x_account_sy where mon_11 is not null;
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,12,mon_12,0,0,0,0,0 
from edw.x_account_sy where mon_12 is not null;

-- 保险成本
drop temporary table if exists bidata.x_insure_cover_pre;
create temporary table bidata.x_insure_cover_pre as
select 
    bi_cuscode as ccuscode
    ,year(ddate) as year_
    ,month(ddate) as month_
    ,sum(act_num*iunitcost) as bx_md
  from edw.x_insure_cover 
 group by bi_cuscode,year_,month_
;
insert into bidata.ft_84_expenses_settlement
select ccuscode,year_,month_,0,bx_md,0,0,0,0 
from bidata.x_insure_cover_pre;

-- infor_center信息中心、technical技术保障中心、maintenance维保、logistics物流费用



-- drop temporary table if exists bidata.x_account_insettle_pre;
-- create temporary table bidata.x_account_insettle_pre 
insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,1,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,2,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,3,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,4,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,5,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,6,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,7,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center" union all
select bi_cuscode,2019,8,0,0,isum/8,0,0,0 from edw.x_account_insettle where type = "infor_center";

insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,1,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,2,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,3,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,4,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,5,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,6,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,7,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical" union all
select bi_cuscode,2019,8,0,0,0,isum/8,0,0 from edw.x_account_insettle where type = "technical";

insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,1,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,2,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,3,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,4,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,5,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,6,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,7,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance" union all
select bi_cuscode,2019,8,0,0,0,0,isum/8,0 from edw.x_account_insettle where type = "maintenance";

insert into bidata.ft_84_expenses_settlement
select bi_cuscode,2019,1,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,2,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,3,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,4,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,5,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,6,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,7,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics" union all
select bi_cuscode,2019,8,0,0,0,0,0,isum/8 from edw.x_account_insettle where type = "logistics";

