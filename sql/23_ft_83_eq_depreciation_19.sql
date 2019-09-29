-- 33_ft_83_eq_depreciation_19

/*
-- 建表 bidata.ft_83_eq_depreciation_19
use bidata;
drop table if exists bidata.ft_83_eq_depreciation_19;
create table if not exists bidata.ft_83_eq_depreciation_19(
    cohr varchar(20) comment '公司',
    vouchid varchar(60) comment '卡片编码',
    bi_cuscode varchar(20) comment '客户编码',
    eq_name varchar(255) comment '折旧设备',
    item_code varchar(60) comment '项目编码',
    ddate date comment '折旧日期',
    amount_depre float(13,3) comment '折旧金额',
    key bidata_ft_83_eq_depreciation_19_cohr (cohr),
    key bidata_ft_83_eq_depreciation_19_bi_cuscode (bi_cuscode)
) engine=innodb default charset=utf8 comment='bi设备折旧表';
 */

-- 导入数据 来源第二层 edw.x_eq_depreciation_19
truncate table bidata.ft_83_eq_depreciation_19;
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-01-01'
    ,amount_depre_1
from edw.x_eq_depreciation_19;

-- 2月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-02-01'
    ,amount_depre_2
from edw.x_eq_depreciation_19;

-- 3月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-03-01'
    ,amount_depre_3
from edw.x_eq_depreciation_19;

-- 4月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-04-01'
    ,amount_depre_4
from edw.x_eq_depreciation_19;

-- 5月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-05-01'
    ,amount_depre_5
from edw.x_eq_depreciation_19;

-- 6月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-06-01'
    ,amount_depre_6
from edw.x_eq_depreciation_19;

-- 7月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-07-01'
    ,amount_depre_7
from edw.x_eq_depreciation_19;

-- 8月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-08-01'
    ,amount_depre_8
from edw.x_eq_depreciation_19;

-- 9月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-09-01'
    ,amount_depre_9
from edw.x_eq_depreciation_19;

-- 10月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-10-01'
    ,amount_depre_10
from edw.x_eq_depreciation_19;

-- 11月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-11-01'
    ,amount_depre_11
from edw.x_eq_depreciation_19;

-- 12月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2019-12-01'
    ,amount_depre_12
from edw.x_eq_depreciation_19;

-- 导入18年数据
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-01-01'
    ,amount_depre_1
from edw.x_eq_depreciation_18;

-- 2月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-02-01'
    ,amount_depre_2
from edw.x_eq_depreciation_18;

-- 3月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-03-01'
    ,amount_depre_3
from edw.x_eq_depreciation_18;

-- 4月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-04-01'
    ,amount_depre_4
from edw.x_eq_depreciation_18;

-- 5月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-05-01'
    ,amount_depre_5
from edw.x_eq_depreciation_18;

-- 6月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-06-01'
    ,amount_depre_6
from edw.x_eq_depreciation_18;

-- 7月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-07-01'
    ,amount_depre_7
from edw.x_eq_depreciation_18;

-- 8月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-08-01'
    ,amount_depre_8
from edw.x_eq_depreciation_18;

-- 9月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-09-01'
    ,amount_depre_9
from edw.x_eq_depreciation_18;

-- 10月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-10-01'
    ,amount_depre_10
from edw.x_eq_depreciation_18;

-- 11月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-11-01'
    ,amount_depre_11
from edw.x_eq_depreciation_18;

-- 12月
insert into bidata.ft_83_eq_depreciation_19
select 
    cohr
    ,vouchid
    ,bi_cuscode
    ,eq_name
    ,item_code
    ,'2018-12-01'
    ,amount_depre_12
from edw.x_eq_depreciation_18;
-- 将amount_depre中所有空值 替换成0  
update bidata.ft_83_eq_depreciation_19 set amount_depre = 0 where amount_depre is null ;