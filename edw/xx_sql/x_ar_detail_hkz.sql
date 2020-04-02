-- ----------------------------------程序头部----------------------------------------------
-- 功能：edw层应收明细表_回款组
-- 说明：取ufdata层x_ar_detail_hkz 清洗出库公司,客户,应收类型,并加上部分客户属性字段
-- ----------------------------------------------------------------------------------------
-- 程序名称：x_ar_detail_hkz.sql
-- 目标模型：edw.x_ar_detail_hkz
-- 源    表：ufdata.x_ar_detail_hkz
-- ---------------------------------------------------------------------------------------
-- 加载周期：线下源更新后全量更新
-- ----------------------------------------------------------------------------------------
-- 作者: Jin
-- 开发日期：20200402
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法：sh user.sh /home/bidata/edw/xx_sql/x_ar_detail_hkz.sql
/* 建表脚本
drop table if exists ufdata.x_ar_detail_hkz;
create table if not exists ufdata.x_ar_detail_hkz (
    province_ori varchar(20) comment '省份',
    aperiod_ori varchar(20) comment '账期',
    cohr_ori varchar(20) comment '出库公司',
    ccusname_ori varchar(90) comment '客户名称',
    date_ar_plan_ori date comment '计划回款日期',
    date_ar date comment '开票日期',
    cinvname varchar(255) comment '货物名称',
    iquantity decimal(18,4) comment '数量',
    idamount decimal(18,4) comment '含税金额',
    cvouchid varchar(90) comment '发票号码',
    date_ap date comment '到款日期',
    icamount decimal(18,4) comment '回款金额',
    cdigest varchar(255) comment '备注',
    key ufdata_x_ar_detail_hkz_ccusname_ori(ccusname_ori),
    key ufdata_x_ar_detail_hkz_ccusname_cvouchid(cvouchid)
)engine=innodb default charset=utf8 comment='回款组核销明细表';

drop table if exists edw.x_ar_detail_hkz;
create table if not exists edw.x_ar_detail_hkz (
    cohr varchar(20) comment '出库公司_清洗后',
    sales_dept varchar(20) comment '销售部门',
    sales_region_new varchar(20) comment '销售区域',
    province varchar(60) comment '省份',
    city varchar(60) comment '地级市',
    ccuscode varchar(20) comment '客户编码',
    ccusname varchar(90) comment '客户名称',
    aperiod decimal(18,4) comment '处理后账期',
    date_ar_plan date comment '计划回款日期',
    ar_class varchar(20) comment '应收类型',
    ar_class_mark varchar(20) comment '应收类型标记',
    province_ori varchar(20) comment '省份_原',
    aperiod_ori varchar(20) comment '账期_原',
    cohr_ori varchar(20) comment '出库公司_原',
    ccusname_ori varchar(90) comment '客户名称_原',
    date_ar_plan_ori date comment '计划回款日期_原',
    date_ar date comment '开票日期',
    cinvname varchar(255) comment '货物名称',
    iquantity decimal(18,4) comment '数量',
    idamount decimal(18,4) comment '含税金额',
    cvouchid varchar(90) comment '发票号码',
    date_ap date comment '到款日期',
    icamount decimal(18,4) comment '回款金额',
    cdigest varchar(255) comment '备注',
    key edw_x_ar_detail_hkz_cohr(cohr),
    key edw_x_ar_detail_hkz_ccuscode(ccuscode),
    key edw_x_ar_detail_hkz_ar_class(ar_class),
    key edw_x_ar_detail_hkz_cvouchid(cvouchid)
)engine=innodb default charset=utf8 comment='回款组核销明细表';
*/
-- 建临时表, 获取发票
drop temporary table if exists edw.cvouchid_arclas;
create temporary table if not exists edw.cvouchid_arclas
select 
    cvouchid 
    ,ar_class
    ,ar_class_else
from edw.ar_detail 
where cvouchtype in ("26","27","r0")
group by cvouchid;
alter table edw.cvouchid_arclas add index (cvouchid);

truncate table edw.x_ar_detail_hkz;
insert edw.x_ar_detail_hkz
select 
    if(a.cohr_ori = '贝生', '宁波贝生',a.cohr_ori) as cohr
    ,c.sales_dept
    ,c.sales_region_new
    ,c.province
    ,c.city
    ,case when b.ccusname is null then "请核查"
        else b.bi_cuscode end as ccuscode
    ,case when b.ccusname is null then "请核查"
        else b.bi_cusname end as ccusname
    ,if(a.aperiod_ori = '设备',0,a.aperiod_ori) as aperiod
    ,if(a.aperiod_ori = '设备',null,date_add(a.date_ar, interval ifnull(a.aperiod_ori,0) day)) as date_ar_plan
    ,case 
        when a.aperiod_ori = '设备' then '设备'
        else ifnull(d.ar_class,"试剂")
        end as ar_class
    ,ifnull(d.ar_class_else,"发票号无") as ar_class_mark
    ,a.province_ori 
    ,a.aperiod_ori
    ,a.cohr_ori 
    ,a.ccusname_ori
    ,a.date_ar_plan_ori 
    ,a.date_ar 
    ,a.cinvname 
    ,a.iquantity 
    ,a.idamount 
    ,a.cvouchid 
    ,a.date_ap 
    ,a.icamount
    ,a.cdigest 
from ufdata.x_ar_detail_hkz as a 
left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) as b 
on a.ccusname_ori = b.ccusname 
left join edw.map_customer as c 
on b.bi_cuscode = c.bi_cuscode 
left join edw.cvouchid_arclas as d 
on a.cvouchid = d.cvouchid;
