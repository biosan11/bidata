-- ----------------------------------程序头部----------------------------------------------
-- 功能：pdm层ar_detail加工到bi层
-- 说明：取code字段 
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：bidata.ft_51_ar_detail
-- 源    表：pdm.ar_detail;
-- ---------------------------------------------------------------------------------------
-- 加载周期：日
-- ----------------------------------------------------------------------------------------
-- 作者:jinj
-- 开发日期：2020-03-19
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法：bi层单独运行
-- 建表脚本
-- use bidata;
-- drop table if exists bidata.ft_51_ar_detail;
-- create table if not exists bidata.ft_51_ar_detail(
--     ccuscode_class varchar(60) comment '客户应收类型组合',
--     autoid int comment '自增编码',
--     mark_ varchar(20) comment '筛选标签',
--     if_0 varchar(20) comment '是否平账',
--     ar_ap varchar(20) comment '应收or回款',
--     cohr varchar(20) comment '公司',
--     db varchar(20) comment '来源库',
--     cvouchtype varchar(20) comment '单据类型',
--     cvouchid varchar(60) comment '单据号',
--     dvouchdate date comment '单据日期',
--     dvouchdate2 date comment '单据日期2',
--     dregdate date comment '核销日期',
--     ccuscode varchar(20) comment 'BI客户编码',
--     cinvcode varchar(20) comment '产品编码',
--     ar_class varchar(20) comment '应收类型',
--     cdigest varchar(255) comment '备注',
--     idamount decimal(18,4) comment '应收金额',
--     icamount decimal(18,4) comment '回款金额',
--     idamount_s decimal(18,4) comment '应收数量',
--     icamount_s decimal(18,4) comment '回款数量',
--     date_ar date comment '应收单据日期',
--     date_ap date comment '回款单据日期',
--     cprocstyle varchar(20) comment '处理方式',
--     aperiod smallint comment '账期',
--     mark_aperiod varchar(20) comment '是否常规账期',
--     key bidata_ft_51_ar_detail_autoid (autoid),
--     key bidata_ft_51_ar_detail_ar_ap (ar_ap),
--     key bidata_ft_51_ar_detail_db (db),
--     key bidata_ft_51_ar_detail_cvouchid (cvouchid),
--     key bidata_ft_51_ar_detail_ccuscode (ccuscode),
--     key bidata_ft_51_ar_detail_cinvcode (cinvcode)
-- ) engine=innodb default charset=utf8 comment='bi应收回款明细';

truncate table bidata.ft_51_ar_detail;
insert into bidata.ft_51_ar_detail
select 
    concat(ccuscode,ar_class) as ccuscode_class
    ,autoid 
    ,mark_ 
    ,if_0 
    ,ar_ap 
    ,cohr 
    ,db 
    ,cvouchtype 
    ,cvouchid 
    ,dvouchdate 
    ,dvouchdate2 
    ,dregdate 
    ,ccuscode 
    ,cinvcode 
    ,ar_class 
    ,cdigest 
    ,idamount 
    ,icamount 
    ,idamount_s 
    ,idamount_s 
    ,date_ar 
    ,date_ap  
    ,cprocstyle
    ,aperiod 
    ,mark_aperiod 
from pdm.ar_detail;
