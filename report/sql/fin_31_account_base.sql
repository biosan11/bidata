-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2019年以后期末期初应收余额
-- 说明：取自pdm层ar_detail,通过日期参数筛选计算余额, 不取健康检测, 不取启代
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者:
-- 开发日期：
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 
-- 调用方法　
/* 建表脚本
use report;
drop table if exists report.fin_31_account_base;
create table if not exists report.fin_31_account_base(
    db varchar(30) comment '来源数据库',
    cdwcode varchar(30) comment'原始客户编码',
    ddate date comment '日期',
    cohr varchar(30) comment '公司',
    ccuscode varchar(30) comment '客户编码',
    ccusname varchar(255) comment '客户名称',
    sales_dept varchar(30) comment '销售部门',
    sales_region_new varchar(30) comment '销售区域',
    province varchar(60) comment '省份',
    ar_class varchar(30) comment '应收类型',
    balance_opening decimal(18,4) comment '期初余额',
    idamount_month decimal(18,4) comment '本月新增应收' ,
    icamount_month decimal(18,4) comment '本月回款',
    balance_closing decimal(18,4) comment '期末余额',
    fr_history decimal(18,4) comment '历史应回款未回',
    fr_add_month decimal(18,4) comment '本月新增应回款',
    fr_month decimal(18,4) comment '本月应回款',
key repot_fin_31_account_base_db (db),
key repot_fin_31_account_base_cohr (cohr),
key repot_fin_31_account_base_cdwcode (cdwcode),
key repot_fin_31_account_base_ccuscode (ccuscode),
key repot_fin_31_account_base_ar_class (ar_class)
)engine=innodb default charset=utf8 comment='2019年以后客户应收类型期初期末余额基础表';
*/

use report;
drop procedure if exists report.fin_31_account_base_pro;
delimiter $$
create procedure report.fin_31_account_base_pro(in dt date)
begin
    drop temporary table if exists report.ar_tem01;
    create temporary table if not exists report.ar_tem01 
    select 
        concat(db,cdwcode,ar_class) as matchid
        ,db
        ,cdwcode
        ,@dt as ddate
        ,cohr 
        ,ccuscode
        ,ar_class
        -- 期初余额逻辑, ar_ap = ar , dvouchdate 和 dvouchdate2 都<= 上期月末  减 ar_ap = ap , dvouchdate 和 dvouchdate2 都<= 上期月末
        ,ifnull(sum(case 
                when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                and ifnull(dvouchdate2,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                then ifnull(idamount,0)
             end),0) 
        - ifnull(sum(case 
                when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                and ifnull(dvouchdate2,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                then ifnull(icamount,0)
             end),0) as balance_opening
        -- 期末余额逻辑, ar_ap = ap , dvouchdate 和 dvouchdate2 都<= 本期月末  减 ar_ap = ap , dvouchdate 和 dvouchdate2 都<= 本期月末
        ,ifnull(sum(case 
                when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt
                and ifnull(dvouchdate2,'1900-01-01') <= @dt
                then ifnull(idamount,0)
             end),0) 
        - ifnull(sum(case 
                when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt
                and ifnull(dvouchdate2,'1900-01-01') <= @dt
                then ifnull(icamount,0)
             end),0) as balance_closing
        -- 本月新增应收逻辑, ar_ap = ar , cprocstyle != "9n" ,本期月末 >= dvouchdate > 上期月末 
        ,ifnull(sum(case 
                when ar_ap = 'ar' and cprocstyle != "9n"
                and ifnull(dvouchdate,'1900-01-01') > date_add(@dt,interval -day(@dt) day)
                and dvouchdate <= @dt
                then ifnull(idamount,0)
             end),0) as idamount_month
        -- 历史应回款未回 逻辑, ar_ap = ar dvouchdate+账期 <= 上期月末 减 ar_ap = ap dvouchdate 和 dvouchdate2 都<= 上期月末 
        -- fund-restreaming plan 回款计划
        ,ifnull(sum(case 
                when ar_ap = 'ar' 
                and date_add(ifnull(dvouchdate,'1900-01-01'), interval aperiod month) <= date_add(@dt,interval -day(@dt) day)
                -- and ifnull(dvouchdate2,'1900-01-01') <= date_add(@dt,interval -day(@dt) day) -- 这个条件不需要 有红冲需要选进去 
                then ifnull(idamount,0)
             end),0) 
        - ifnull(sum(case 
                when ar_ap = 'ap' 
                and ifnull(dvouchdate,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                and ifnull(dvouchdate2,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                then ifnull(icamount,0)
             end),0) as fr_history
        -- 本月新增应回款 逻辑, ar_ap = ar dvouchdate+账期 <= 本期月末 减 ar_ap = ar dvouchdate+账期 <= 上期月末
        ,ifnull(sum(case 
                when ar_ap = 'ar' 
                and date_add(ifnull(dvouchdate,'1900-01-01'), interval aperiod month) <= @dt
                then ifnull(idamount,0)
             end),0) 
        - ifnull(sum(case 
                when ar_ap = 'ar' 
                and date_add(ifnull(dvouchdate,'1900-01-01'), interval aperiod month) <= date_add(@dt,interval -day(@dt) day)
                then ifnull(idamount,0)
             end),0) as fr_add_month
         -- 本月应回款 逻辑, ar_ap = ar dvouchdate+账期 <= 本期月末 dvouchdate2 <= 本期月末 减 ar_ap = ap dvouchdate 和 dvouchdate2 都<= 上期月末 
        ,ifnull(sum(case 
                when ar_ap = 'ar' 
                and date_add(ifnull(dvouchdate,'1900-01-01'), interval aperiod month) <= @dt
                -- and ifnull(dvouchdate2,'1900-01-01') <= @dt -- 这个条件不需要 有红冲需要选进去 
                then ifnull(idamount,0)
             end),0) 
        - ifnull(sum(case 
                when ar_ap = 'ap' 
                and ifnull(dvouchdate,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                and ifnull(dvouchdate2,'1900-01-01') <= date_add(@dt,interval -day(@dt) day)
                then ifnull(icamount,0)
             end),0) as fr_month
    from pdm.ar_detail
    where db != "UFDATA_666_2018" 
    and ar_class != "健康检测"
    group by db,cdwcode,ar_class;
    alter table report.ar_tem01 add index (matchid),add index(ccuscode);

    insert into report.fin_31_account_base
    select 
        a.db
        ,a.cdwcode
        ,a.ddate
        ,a.cohr
        ,a.ccuscode
        ,b.bi_cusname as ccusname 
        ,b.sales_dept
        ,b.sales_region_new
        ,b.province
        ,a.ar_class
        ,a.balance_opening
        ,a.idamount_month
        ,a.balance_opening + a.idamount_month - a.balance_closing as icamount_amount
        ,a.balance_closing
        ,a.fr_history 
        ,a.fr_add_month
        ,a.fr_month
    from report.ar_tem01 as a 
    left join edw.map_customer as b 
    on a.ccuscode = b.bi_cuscode;
end
$$
delimiter ;


-- 先清空
truncate table report.fin_31_account_base;

-- 导入加日期参数导入
set @dt = '2018-01-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-02-28';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-03-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-04-30';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-05-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-06-30';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-07-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-08-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-09-30';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-10-31';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-11-30';
call report.fin_31_account_base_pro(@dt);
set @dt = '2018-12-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-01-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-02-28';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-03-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-04-30';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-05-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-06-30';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-07-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-08-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-09-30';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-10-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-11-30';
call report.fin_31_account_base_pro(@dt);

set @dt = '2019-12-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2020-01-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2020-02-29';
call report.fin_31_account_base_pro(@dt);

set @dt = '2020-03-31';
call report.fin_31_account_base_pro(@dt);

set @dt = '2020-04-30';
call report.fin_31_account_base_pro(@dt);

set @dt = '2020-05-31';
call report.fin_31_account_base_pro(@dt);
