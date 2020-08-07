-- ----------------------------------程序头部----------------------------------------------
-- 功能：pdm层应收明细表
-- 说明：取edw层ar_detail 并加工生成筛选字段(核销明细通过筛选展示)
-- ----------------------------------------------------------------------------------------
-- 程序名称：ar_detail.py
-- 目标模型：pdm.ar_detail
-- 源    表：edw.ar_detail;pdm.ar_detail_aperiod
-- ---------------------------------------------------------------------------------------
-- 加载周期：日
-- ----------------------------------------------------------------------------------------
-- 作者:jinj
-- 开发日期：2020-03-18
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 调用方法：python /home/pdm/py/ar_detail.py
-- 建表脚本
-- use pdm;
-- drop table if exists pdm.ar_detail;
-- create table if not exists pdm.ar_detail(
--     autoid int comment '自增编码',
--     mark_ varchar(20) comment '筛选标签',
--     if_0 decimal(18,4) comment '是否平账',
--     balance_ar_2 decimal(18,4) comment '单据应收金额',
--     balance_ap_2 decimal(18,4) comment '单据回款金额',
--     matchid varchar(60) comment '组合匹配id',
--     cprocstyle2 varchar(20) comment 'cprocstyle分类',
--     ccovouchtype2 varchar(20) comment 'ccovouchtype分类',
--     ar_ap varchar(20) comment '应收or回款',
--     cohr varchar(20) comment '公司',
--     db varchar(20) comment '来源库',
--     cvouchtype varchar(20) comment '单据类型',
--     cvouchid varchar(20) comment '单据号',
--     dvouchdate date comment '单据日期',
--     dvouchdate2 date comment '单据日期2',
--     dregdate date comment '核销日期',
--     cdwcode varchar(20) comment 'u8客户编码',
--     ccuscode varchar(20) comment 'BI客户编码',
--     ccusname varchar(255) comment 'BI客户名称',
--     sales_dept varchar(20) comment '销售部门',
--     sales_region_new varchar(20) comment '销售区域',
--     province varchar(20) comment '省份',
--     city varchar(20) comment '地级市',
--     cinvcode varchar(20) comment '产品编码',
--     ar_class varchar(20) comment '应收类型',
--     cdigest varchar(255) comment '备注',
--     idamount decimal(18,4) comment '应收金额',
--     icamount decimal(18,4) comment '回款金额',
--     date_ar date comment '应收单据日期',
--     date_ap date comment '回款单据日期',
--     cprocstyle varchar(20) comment '处理方式',
--     ccancelno varchar(90) comment '处理标识符',
--     ccovouchtype varchar(20) comment '对应单据类型',
--     ccovouchid varchar(20) comment '对应单据号',
--     aperiod smallint comment '账期',
--     mark_aperiod varchar(20) comment '是否常规账期',
--     invoice_amount decimal(18,4) comment '单据金额',
--     iVouchAmount_s decimal(18,4) comment '单据数量',
--     key pdm_ar_detail_autoid (autoid),
--     key pdm_ar_detail_ar_ap (ar_ap),
--     key pdm_ar_detail_db (db),
--     key pdm_ar_detail_cvouchid (cvouchid),
--     key pdm_ar_detail_ccuscode (ccuscode),
--     key pdm_ar_detail_cinvcode (cinvcode)
-- ) engine=innodb default charset=utf8 comment='应收回款明细';

use pdm;

-- 新增临时表 concat（db,cvouchid,cdwcode) 组合出两个用于匹配的matchid
-- 不取关联公司 
drop temporary table if exists pdm.ar_tem01;
create temporary table if not exists pdm.ar_tem01
select 
    *
    ,concat(db,cvouchid,cdwcode) as matchid
    ,concat(db,ccancelno) as matchid2
from edw.ar_detail
where (idamount != 0 or icamount != 0)
and left(true_ccuscode,2) != "gl";
alter table pdm.ar_tem01 add index index_ar_tem01_matchid (matchid);
alter table pdm.ar_tem01 add index index_ar_tem01_matchid2 (matchid2);
alter table pdm.ar_tem01 add index index_ar_tem01_ccuscode(true_ccuscode);
alter table pdm.ar_tem01 add index index_ar_tem01_ar_class(ar_class);

-- 处理提取 对应单据日期
drop temporary table if exists pdm.ar_tem02;
create temporary table if not exists pdm.ar_tem02 
select 
    concat(db,ccancelno) as matchid2
    ,max(dvouchdate) as dvouchdate2
from edw.ar_detail 
group by db,ccancelno;
alter table pdm.ar_tem02 add index index_ar_tem02_matchid2 (matchid2);

drop temporary table if exists pdm.ar_detail_tem00;
create temporary table if not exists pdm.ar_detail_tem00
select
    concat(a.db,a.cdwcode,a.ccovouchid) as matchid
    ,case -- 处理cprocstyle2 
        when cprocstyle in ("26","27","r0") then "ar"
        when cprocstyle in ("48","49") then "ap"
        else cprocstyle
     end as cprocstyle2
    ,case -- 处理ccovouchtype2 需要注释意义
        when ccovouchtype in ("26","27","r0") then "ar"
        when ccovouchtype in ("48","49") then "ap"
        else "other"
     end as ccovouchtype2
    ,case -- 处理ar_ap
        when a.cvouchtype in ("26","27","r0") then "ar"
        when a.cvouchtype in ("48","49") then "ap"
        else "other"
        end as ar_ap
    ,case -- 处理cohr
        when a.db = 'UFDATA_111_2018' then '博圣' 
        when a.db = 'UFDATA_118_2018' then '卓恩'
        when a.db = 'UFDATA_123_2018' then '恩允'
        when a.db = 'UFDATA_168_2018' then '杭州贝生'
        when a.db = 'UFDATA_168_2019' then '杭州贝生'
        when a.db = 'UFDATA_169_2018' then '云鼎'
        when a.db = 'UFDATA_222_2018' then '宝荣'
        when a.db = 'UFDATA_222_2019' then '宝荣'
        when a.db = 'UFDATA_333_2018' then '宁波贝生'
        when a.db = 'UFDATA_588_2018' then '奥博特'
        when a.db = 'UFDATA_588_2019' then '奥博特'
        when a.db = 'UFDATA_666_2018' then '启代'
        when a.db = 'UFDATA_889_2018' then '美博特'
        when a.db = 'UFDATA_889_2019' then '美博特'
        when a.db = 'UFDATA_555_2018' then '贝安云'
        when a.db = 'UFDATA_170_2020' then '甄元'
        else '其他'
        end as cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,d.dvouchdate2 as dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.ar_class
    ,a.cdigest
    ,round(a.idamount,4) as idamount
    ,round(a.icamount,4) as icamount
    ,a.idamount_s
    ,a.icamount_s
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,b.aperiod 
    ,b.mark_aperiod
    ,a.mark as mark_cinvcode
    ,case -- 处理item_code
        when a.item_code is null
            then "其他"
        when left(a.item_code,2)="JK"
            then "其他"
        else a.item_code
        end as item_code
    ,a.iVouchAmount_s
    ,a.invoice_amount
from pdm.ar_tem01 as a 
left join pdm.ar_detail_aperiod as b
on a.true_ccuscode = b.ccuscode and a.ar_class = b.ar_class 
left join pdm.ar_tem02 as d
on a.matchid2 = d.matchid2
-- 临时条件 
-- where b.province = "浙江省"
order by a.db,a.cdwcode,a.dvouchdate,a.ccovouchid;


alter table pdm.ar_detail_tem00 add index index_ar_detail_tem00_matchid (matchid);
alter table pdm.ar_detail_tem00 add index index_ar_detail_tem00_ar_ap (ar_ap);
alter table pdm.ar_detail_tem00 add index index_ar_detail_tem00_cprocstyle2 (cprocstyle2);
alter table pdm.ar_detail_tem00 add index index_ar_detail_tem00_ccovouchtype2 (ccovouchtype2);

-- 提取数据  当ar_ap = ap时 按db,cdwcode,ccovouchid 分组的求和 idamount icamount 数据 
drop temporary table if exists pdm.ft_51_ar_test_tem01;
create temporary table if not exists pdm.ft_51_ar_test_tem01
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_ap
    ,sum(icamount) as icamount_ap
from pdm.ar_detail_tem00
where ar_ap = "ap"
and ccovouchtype in ("48","49")
group by db,cdwcode,ccovouchid;
alter table pdm.ft_51_ar_test_tem01 add index index_ft_51_ar_test_tem01_matchid (matchid);

-- 提取数据  按db,cdwcode,ccovouchid 分组的求和 idamount icamount 数据 
drop temporary table if exists pdm.ft_51_ar_test_tem02;
create temporary table if not exists pdm.ft_51_ar_test_tem02
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_all
    ,sum(icamount) as icamount_all
from pdm.ar_detail_tem00
where ccovouchtype in ("26","27","r0")
group by db,cdwcode,ccovouchid;
alter table pdm.ft_51_ar_test_tem02 add index index_ft_51_ar_test_tem02_matchid (matchid);

-- 提取生成红冲等数据
drop temporary table if exists pdm.ft_51_ar_test_tem03;
create temporary table if not exists pdm.ft_51_ar_test_tem03
select 
    concat(db,cdwcode,ccovouchid) as matchid
    ,"hc" as hc
from pdm.ar_detail_tem00 
where ar_ap = "ar" and cprocstyle2 = "9n" -- 这些是红冲的单据, 找到ccovouchid 打上红冲标签
group by db,cdwcode,ccovouchid;
alter table pdm.ft_51_ar_test_tem03 add index index_ft_51_ar_test_tem03_matchid (matchid);


-- 加工出来几个金额, 用于筛选 并且增加自增序号
set @rownum = 0;
drop temporary table if exists pdm.ar_detail_tem01;
create temporary table if not exists pdm.ar_detail_tem01
select 
    @rownum := @rownum +1 as autoid
    ,case 
        when a.ar_ap = "ar" then "qu_ar" -- 应收ar部分
        when a.ar_ap = "ap" and a.ccovouchtype2 = "ar" then "qu_ap" -- 应收回款已经勾稽
        when (ifnull(c.idamount_all,0)-ifnull(c.icamount_all,0)-ifnull(b.icamount_ap,0)) != 0 then "qu_buping"  -- 回款未核销完
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ap != 0 and a.idamount != 0 then "qu" -- ??
        else null 
    end as mark_
    -- ,case 
    --     when a.ar_ap = "ar" and a.cprocstyle2 in("ar","BZ") and a.ccovouchtype2 = "ar" then c.idamount_all-c.icamount_all 
    --     else 0 
    -- end as balance_ar_1
    -- ,case 
    --     when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and a.idamount != 0 then b.icamount_ap 
    --     else 0 
    -- end as balance_ap_1
    ,case 
        when ccovouchtype = "ro" then null
        when d.hc is not null and (ifnull(c.idamount_all,0)-ifnull(c.icamount_all,0)-ifnull(b.icamount_ap,0)) != 0 then "hc_buping"
        else d.hc 
        end as hc
    ,ifnull(c.idamount_all,0)-ifnull(c.icamount_all,0)-ifnull(b.icamount_ap,0) as if_0
    ,ifnull(c.idamount_all,0)-ifnull(c.icamount_all,0) as balance_ar_2
    ,ifnull(b.icamount_ap,0) as balance_ap_2
    ,a.matchid
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.ar_class
    ,a.cdigest
    ,a.idamount
    ,a.icamount
    ,a.idamount_s
    ,a.icamount_s
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark_aperiod
    ,a.mark_cinvcode
    ,a.invoice_amount
    ,a.iVouchAmount_s
from pdm.ar_detail_tem00 as a 
left join pdm.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
left join pdm.ft_51_ar_test_tem02 as c
on a.matchid = c.matchid
left join pdm.ft_51_ar_test_tem03 as d 
on a.matchid = d.matchid;

alter table pdm.ar_detail_tem01 add index index_ar_detail_tem01_db (db);
alter table pdm.ar_detail_tem01 add index index_ar_detail_tem01_cvouchid (cvouchid);
alter table pdm.ar_detail_tem01 add index index_ar_detail_tem01_matchid (matchid);


-- 提取回款单据日期数据
drop temporary table if exists pdm.ft_51_ar_test_pre1 ;
create temporary table if not exists pdm.ft_51_ar_test_pre1 
select * from pdm.ar_detail_tem01 as a
where cprocstyle2 = 'ap'
and ccovouchtype2 = 'ap'
and ar_ap = 'ap'
group by cvouchid,db;

alter table pdm.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_cvouchid (cvouchid);
alter table pdm.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_db (db);


-- 导入pdm层ar_detail表
truncate table pdm.ar_detail;
insert into pdm.ar_detail
select 
    a.autoid
    ,a.mark_
    ,a.hc
    ,round(a.if_0,4)
    ,round(a.balance_ar_2,4)
    ,round(a.balance_ap_2,4)
    ,a.matchid
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode as ccuscode
    ,d.bi_cusname as ccusname
    ,d.sales_dept
    ,d.sales_region_new
    ,d.province
    ,d.city
    ,a.true_cinvcode as cinvcode
    ,a.ar_class
    ,a.cdigest
    ,round(a.idamount,4)
    ,round(a.icamount,4)
    ,round(a.idamount_s,4)
    ,round(a.icamount_s,4)
    ,case when a.ar_ap = 'ar' then a.dvouchdate else null end as date_ar
    ,case when a.ar_ap = 'ap' then b.dvouchdate else null end as date_ap
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark_aperiod
    ,round(a.invoice_amount,4)
    ,round(a.iVouchAmount_s,4) 
  from pdm.ar_detail_tem01 a
  left join pdm.ft_51_ar_test_pre1 b
    on a.cvouchid = b.cvouchid
   and a.db = b.db
  left join edw.map_customer d
    on a.true_ccuscode = d.bi_cuscode
;


