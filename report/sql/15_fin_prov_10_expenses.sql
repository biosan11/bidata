-- 这里是是省区绩效模板需要的费用分摊
-- 先加工一张中间过程表

-- drop table if exists report.fin_prov_08_expense_ccus;
-- CREATE TABLE if not exists report.fin_prov_08_expense_ccus (
--   `cohr` varchar(20) DEFAULT NULL,
--   `y_mon` varchar(20) DEFAULT NULL,
--   `ccuscode` varchar(20) DEFAULT NULL,
--   `md` double DEFAULT NULL,
--   `state` varchar(20) DEFAULT NULL,
--   `dept_name` varchar(20) DEFAULT NULL,
-- KEY `report_fin_prov_08_expense_base_year_` (`y_mon`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;


drop temporary table if exists report.fin_prov_ex001;
create temporary table if not exists report.fin_prov_ex001
select 
	   db
    ,cohr
    ,dbill_date
    ,ccuscode
    ,name_ehr_id
    ,md
    ,substring_index(fy_share_m1,'-', 1) as name_ehr_jsh
    ,concat(ifnull(fy_share_m1,""),name_ehr_id) as name_ehr_id2
    ,fy_share_ifccus
from bidata.ft_81_expenses;
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_dbill_date (dbill_date);
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_cohr (cohr);
alter table report.fin_prov_ex001 add index index_report_fin_prov_ex001_name_ehr_id2(name_ehr_id2);

-- 2. 根据年月 部门id（新） 科目code 分组 加入预算费用数据 
drop table if exists report.fin_prov_08_expense_ccus_pre;
create temporary table report.fin_prov_08_expense_ccus_pre as
select a.cohr 
      ,left(a.dbill_date,7) as y_mon
      ,a.ccuscode
      ,d.second_dept as second_dept_old
      ,d.third_dept as third_dept_old
      ,d.fourth_dept as fourth_dept_old
      ,d.fifth_dept as fifth_dept_old
      ,d.province as province_old
      ,round(sum(a.md),2) as md
      ,a.name_ehr_jsh as name_ehr_id2
      ,null as state
      ,null as dept_name
      ,fy_share_ifccus
from report.fin_prov_ex001 as a 
left join bidata.dt_21_deptment as d 
on a.name_ehr_id = d.cdept_id_ehr
where year(a.dbill_date) >= 2018
group by 
    left(a.dbill_date,7)
    ,a.name_ehr_id2
    ,a.ccuscode
    ,a.cohr
;

-- update report.fin_prov_08_expense_ccus_pre a
--  inner join map.map_customer b
--    set a.state = 'cc_md'
--       ,a.dept_name = b.province
--     on a.ccuscode = b.bi_cuscode
--  where b.bi_cuscode is not null;

-- 修改字段类型
alter table report.fin_prov_08_expense_ccus_pre modify state varchar(20);
alter table report.fin_prov_08_expense_ccus_pre modify dept_name varchar(20);

-- 各种补全,营销中心省区补全
update report.fin_prov_08_expense_ccus_pre
   set state = 'sq_md'
      ,dept_name = province_old
 where second_dept_old = '营销中心'
   and province_old in('江苏省','上海市','山西省','山东省','安徽省','浙江省','福建省','云南省','湖北省','湖南省','陕西省','海南省','四川省','河南省','黑龙江省')
   and dept_name is null
   and cohr != '杭州贝生'
;
update report.fin_prov_08_expense_ccus_pre
   set state = 'sq_md'
      ,dept_name = name_ehr_id2
 where second_dept_old = '营销中心'
   and name_ehr_id2 in('江苏省','上海市','山西省','山东省','安徽省','浙江省','福建省','云南省','湖北省','湖南省','陕西省','海南省','四川省','河南省','黑龙江省')
   and dept_name is null
   and cohr != '杭州贝生'
;

-- 大区补全
update report.fin_prov_08_expense_ccus_pre
   set state = 'dq_md'
      ,dept_name = fourth_dept_old
 where second_dept_old = '营销中心'
   and fourth_dept_old in ('销售二区','销售八区','销售一区','销售四区','销售五区','销售零区','销售三区','销售六区','销售七区','销售九区')
   and dept_name is null
   and cohr != '杭州贝生'
;
update report.fin_prov_08_expense_ccus_pre
   set state = 'dq_md'
      ,dept_name = left(name_ehr_id2,4)
 where second_dept_old = '营销中心'
   and left(name_ehr_id2,4) in ('销售二区','销售八区','销售一区','销售四区','销售五区','销售零区','销售三区','销售六区','销售七区','销售九区')
   and dept_name is null
   and cohr != '杭州贝生'
;
-- 营销中心所有的数据
update report.fin_prov_08_expense_ccus_pre
   set state = 'zz_md'
      ,dept_name = '营销中心'
 where second_dept_old = '营销中心'
   and dept_name is null
   and cohr != '杭州贝生'
;

-- 博圣其他数据处理
update report.fin_prov_08_expense_ccus_pre
   set state = 'bs_md'
      ,dept_name = third_dept_old
 where third_dept_old in ('400客服部','技术保障中心','供应链中心','信息中心')
   and cohr <> '杭州贝生'
   and dept_name is null
;
update report.fin_prov_08_expense_ccus_pre
   set state = 'bs_qt'
      ,dept_name = '博圣其他'
 where cohr <> '杭州贝生'
   and dept_name is null
;

-- 杭州贝生数据处理
update report.fin_prov_08_expense_ccus_pre
   set state = 'hzbs_md'
      ,dept_name = '营销中心'
 where second_dept_old = '营销中心'
   and cohr = '杭州贝生'
   and dept_name is null
;
update report.fin_prov_08_expense_ccus_pre
   set state = 'hzbs_qt'
      ,dept_name = '贝生其他'
 where cohr = '杭州贝生'
   and dept_name is null
;

-- 临时表结合到一起
truncate table report.fin_prov_08_expense_ccus;
insert into report.fin_prov_08_expense_ccus
select a.cohr
      ,a.y_mon
      ,case when a.fy_share_ifccus = "n" then null else ccuscode end as ccuscode
      -- ,case when left(a.ccuscode,2) in ('GL','QT') then null else ccuscode end as ccuscode
      ,round(sum(a.md),2) as md
      ,a.state
      ,a.dept_name
  from report.fin_prov_08_expense_ccus_pre a
 group by a.y_mon,state,dept_name,(case when a.fy_share_ifccus = "n" then null else ccuscode end)
;

-- 这里是吧所有到客户的费用先计算出来，杭州贝生不作数,只计算营销中心下面的直接费用
drop table if exists report.expenses_mid1;
create temporary table report.expenses_mid1 as
select a.ccuscode
      ,a.y_mon
      ,a.cohr
      ,sum(a.md) as md
      ,a.dept_name
  from report.fin_prov_08_expense_ccus a
 where a.ccuscode is not null
   and a.state in ('sq_md','dq_md','zz_md')
 group by ccuscode,y_mon
;

-- 没有到客户的费用，按照部门来拆分
drop table if exists report.expenses_mid2;
create temporary table report.expenses_mid2 as
select a.ccuscode
      ,a.y_mon
      ,a.cohr
      ,a.md
      ,a.dept_name
  from report.fin_prov_08_expense_ccus a
 where a.ccuscode is null
   and a.state = 'sq_md'
;

-- 先计算到省区的拆分,到客户的总金额
drop table if exists report.expenses_mid3;
create temporary table report.expenses_mid3 as
select left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
      ,b.province
  from bidata.ft_11_sales a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
 where b.province in('江苏省','上海市','山西省','山东省','安徽省','浙江省','福建省','云南省','湖北省','湖南省','陕西省','海南省','四川省','河南省','黑龙江省')
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
 group by b.province,left(a.ddate,7)
;
-- 到客户的总金额，每家客户情况
drop table if exists report.expenses_mid31;
create temporary table report.expenses_mid31 as
select a.finnal_ccuscode as ccuscode
      ,left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
      ,b.province
  from bidata.ft_11_sales a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
 where b.province in('江苏省','上海市','山西省','山东省','安徽省','浙江省','福建省','云南省','湖北省','湖南省','陕西省','海南省','四川省','河南省','黑龙江省')
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
 group by b.province,left(a.ddate,7),a.finnal_ccuscode
;

-- 先计算到省区的拆分,不到客户的总金额
-- drop table if exists report.expenses_mid4;
-- create temporary table report.expenses_mid4 as
-- select a.y_mon
--       ,a.cohr
--       ,sum(a.md) as md
--       ,fifth_dept
--   from report.expenses_mid2 a
--  where fifth_dept in('江苏省区','上海区','山西省区','山东省区','安徽省区','浙江省区','福建省区','云南省区','湖北省区','湖南省区','陕西省区','海南省区','四川省区','河南省区','黑龙江省区')
--    and (ccuscode is null or left(a.ccuscode,2) in ('GL','QT'))
--  group by fifth_dept,y_mon
-- ;

-- 这里的省份控制会对分组最后的值产生影响
-- 不到客户的总金额 减去实验员金额
drop table if exists report.x_account_sy_pre;
create table report.x_account_sy_pre as
select left(a.province,2) as province
      ,sum(mon_1)  as mon_1
      ,sum(mon_2) as mon_2 
      ,sum(mon_3) as mon_3 
      ,sum(mon_4) as mon_4 
      ,sum(mon_5) as mon_5 
      ,sum(mon_6) as mon_6 
      ,sum(mon_7) as mon_7 
      ,sum(mon_8) as mon_8 
      ,sum(mon_9) as mon_9 
      ,sum(mon_10) as mon_10
      ,sum(mon_11) as mon_11
      ,sum(mon_12) as mon_12
  from edw.x_account_sy a
 group by left(a.province,2)
;

-- 不到客户的总金额 减去实验员金额
drop table if exists report.x_insure_cover_pre;
create temporary table report.x_insure_cover_pre as
select left(a.province,2) as province
      ,sum(act_num*iunitcost)  as md
      ,left(ddate,7) as y_mon
  from edw.x_insure_cover a
 group by left(a.province,2),left(ddate,7)
;

-- 分配的客户整理合集
drop table if exists report.expenses_mid22;
create temporary table report.expenses_mid22 as
select distinct y_mon,left(dept_name,2) as dept_name from report.expenses_mid2 union 
select distinct '2019-01',province from report.x_account_sy_pre where ifnull(round(mon_1 ,0),0)<> 0 union
select distinct '2019-02',province from report.x_account_sy_pre where ifnull(round(mon_2 ,0),0)<> 0 union
select distinct '2019-03',province from report.x_account_sy_pre where ifnull(round(mon_3 ,0),0)<> 0 union
select distinct '2019-04',province from report.x_account_sy_pre where ifnull(round(mon_4 ,0),0)<> 0 union
select distinct '2019-05',province from report.x_account_sy_pre where ifnull(round(mon_5 ,0),0)<> 0 union
select distinct '2019-06',province from report.x_account_sy_pre where ifnull(round(mon_6 ,0),0)<> 0 union
select distinct '2019-07',province from report.x_account_sy_pre where ifnull(round(mon_7 ,0),0)<> 0 union
select distinct '2019-08',province from report.x_account_sy_pre where ifnull(round(mon_8 ,0),0)<> 0 union
select distinct '2019-09',province from report.x_account_sy_pre where ifnull(round(mon_9 ,0),0)<> 0 union
select distinct '2019-10',province from report.x_account_sy_pre where ifnull(round(mon_10,0),0) <> 0 union
select distinct '2019-11',province from report.x_account_sy_pre where ifnull(round(mon_11,0),0) <> 0 union
select distinct '2019-12',province from report.x_account_sy_pre where ifnull(round(mon_12,0),0) <> 0 union
select distinct y_mon,province from report.x_insure_cover_pre 
;

-- 得到未分配的金额
drop table if exists report.expenses_mid5;
create temporary table report.expenses_mid5 as
select a.y_mon
     ,(case when a.y_mon = '2019-01' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_1 ,0)
            when a.y_mon = '2019-02' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_2 ,0)
            when a.y_mon = '2019-03' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_3 ,0)
            when a.y_mon = '2019-04' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_4 ,0)
            when a.y_mon = '2019-05' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_5 ,0)
            when a.y_mon = '2019-06' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_6 ,0)
            when a.y_mon = '2019-07' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_7 ,0)
            when a.y_mon = '2019-08' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_8 ,0)
            when a.y_mon = '2019-09' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_9 ,0)
            when a.y_mon = '2019-10' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_10,0)
            when a.y_mon = '2019-11' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_11,0)
            when a.y_mon = '2019-12' and b.province is not null then ifnull(d.md,0) - ifnull(b.mon_12,0)
            else d.md end) - ifnull(c.md,0) as md
      ,a.dept_name as fifth_dept
  from report.expenses_mid22 a
  left join report.x_account_sy_pre b
    on left(a.dept_name,2) = b.province
  left join report.x_insure_cover_pre c
    on left(a.dept_name,2) = c.province
   and a.y_mon = c.y_mon
  left join report.expenses_mid2 d
    on left(a.dept_name,2) = left(d.dept_name,2)
   and a.y_mon = d.y_mon
;

-- 得到省区下面客户拆分情况,没有到客户的是当月没有客户出现，需要在公司营销中心下面拆分
drop table if exists report.expenses_sq;
create temporary table report.expenses_sq as
select c.ccuscode
      ,a.fifth_dept
      ,a.y_mon
      ,case when c.ccuscode is not null then c.md/b.md*a.md else a.md end as md
  from report.expenses_mid5 a
  left join report.expenses_mid3 b
    on left(a.fifth_dept,2) = left(b.province,2)
   and a.y_mon = b.y_mon
  left join report.expenses_mid31 c
    on left(a.fifth_dept,2) = left(c.province,2)
   and a.y_mon = c.y_mon
 where a.y_mon >= '2018-01'
;

-- 拆分到省区的建一个虚拟客户
update report.expenses_sq
   set ccuscode = concat('xn-',fifth_dept)
 where ccuscode is null
;

-- 到大区的拆分
drop table if exists report.expenses_dq1;
create temporary table report.expenses_dq1 as
select left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
      ,b.sales_region
  from bidata.ft_11_sales a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
 where b.sales_region in('销售二区','销售八区','销售一区','销售四区','销售五区','销售零区','销售三区','销售六区','销售七区','销售九区')
   and left(a.ddate,7) >= '2018-01'
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
 group by b.sales_region,left(a.ddate,7)
;
-- 到客户的总金额，每家客户情况
drop table if exists report.expenses_dq2;
create temporary table report.expenses_dq2 as
select a.finnal_ccuscode as ccuscode
      ,left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
      ,b.sales_region
  from bidata.ft_11_sales a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
 where b.sales_region in('销售二区','销售八区','销售一区','销售四区','销售五区','销售零区','销售三区','销售六区','销售七区','销售九区')
   and left(a.ddate,7) >= '2018-01'
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
 group by b.sales_region,left(a.ddate,7),a.finnal_ccuscode
;

drop table if exists report.expenses_dq3;
create temporary table report.expenses_dq3 as
select a.ccuscode
      ,a.y_mon
      ,a.cohr
      ,a.md
      ,a.dept_name as fourth_dept
  from report.fin_prov_08_expense_ccus a
 where a.ccuscode is null
   and a.state = 'dq_md'
;

drop table if exists report.expenses_dq4;
create temporary table report.expenses_dq4 as
select b.fourth_dept
      ,b.y_mon
      ,b.md
  from report.expenses_dq3 b
  left join report.expenses_dq2 a
    on left(a.sales_region,4) = left(b.fourth_dept,4)
   and a.y_mon = b.y_mon
 where a.y_mon is null
;

-- 这里取18，19年开票的前3家
drop table if exists report.expenses_dq5;
create table report.expenses_dq5 as
select distinct a.finnal_ccuscode as ccuscode
      ,left(a.ddate,4) as year_
      ,a.isum as md
      ,b.sales_region
  from bidata.ft_11_sales a
  left join edw.map_customer b
    on a.finnal_ccuscode = b.bi_cuscode
 where b.sales_region in('销售二区','销售八区','销售一区','销售四区','销售五区','销售零区','销售三区','销售六区','销售七区','销售九区')
   and left(a.ddate,7) >= '2018-01'
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
-- group by b.sales_region,left(a.ddate,4),a.finnal_ccuscode
;
alter table report.expenses_dq5 add index index_expenses_dq5_ccuscode(ccuscode) ;
alter table report.expenses_dq5 add index index_expenses_dq5_year_(year_) ;
alter table report.expenses_dq5 add index index_expenses_dq5_sales_region(sales_region) ;

drop table if exists report.expenses_dq6;
create temporary table report.expenses_dq6 as
select a.ccuscode
      ,a.year_
      ,sum(a.md) as md
      ,a.sales_region
  from report.expenses_dq5 a
 where (select count(*) from report.expenses_dq5 where ccuscode=a.ccuscode and sales_region=a.sales_region and year_=a.year_ and a.md<md)<3
 group by a.ccuscode,a.year_,a.sales_region
 order by a.ccuscode,a.year_,a.sales_region,a.md
;

drop table if exists report.expenses_dq7;
create temporary table report.expenses_dq7 as
select a.year_
      ,sum(a.md) as md
      ,a.sales_region
  from report.expenses_dq5 a
 where (select count(*) from report.expenses_dq5 where ccuscode=a.ccuscode and sales_region=a.sales_region and year_=a.year_ and a.md<md)<3
 group by a.year_,a.sales_region
 order by a.ccuscode,a.year_,a.sales_region,a.md
;

drop table if exists report.expenses_dq5;

-- 这里是正常到大区的拆分
drop table if exists report.expenses_dq;
create temporary table report.expenses_dq as
select a.ccuscode
      ,a.sales_region
      ,a.y_mon
      ,round(ifnull(a.md/c.md,1)*b.md,2) as md
  from report.expenses_dq2 a
  left join report.expenses_dq3 b
    on left(a.sales_region,4) = left(b.fourth_dept,4)
   and a.y_mon = b.y_mon
  left join report.expenses_dq1 c
    on left(a.sales_region,4) = left(c.sales_region,4)
   and a.y_mon = c.y_mon
 where a.y_mon >= '2018-01'
 order by a.ccuscode
;

-- 存在问题，销售九区在19-02有费用没有开票，存在拆分
-- 就按照当前大区19年的费用前3家客户进行按比例拆分进去
insert into  report.expenses_dq
select b.ccuscode
      ,a.fourth_dept
      ,a.y_mon
      ,round(b.md/c.md*a.md,2) as md
  from report.expenses_dq4 a
  left join report.expenses_dq6 b
    on left(a.fourth_dept,4) = left(b.sales_region,4)
   and left(a.y_mon,4) = b.year_
  left join report.expenses_dq7 c
    on left(b.sales_region,4) = left(c.sales_region,4)
   and b.year_ = c.year_
 order by a.fourth_dept,a.y_mon
;


-- 到营销中心的拆分
drop table if exists report.expenses_zx1;
create temporary table report.expenses_zx1 as
select left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
  from bidata.ft_11_sales a
 where ddate >= '2018-01-01'
   and left(a.finnal_ccuscode,2) not in ('GL','QT')
 group by left(a.ddate,7)
;
-- 到客户的总金额，每家客户情况
drop table if exists report.expenses_zx2;
create temporary table report.expenses_zx2 as
select a.finnal_ccuscode as ccuscode
      ,left(a.ddate,7) as y_mon
      ,a.cohr
      ,sum(a.isum) as md
  from bidata.ft_11_sales a
 where left(a.finnal_ccuscode,2) not in ('GL','QT')
   and a.ddate >= '2018-01-01'
 group by left(a.ddate,7),a.finnal_ccuscode
;

drop table if exists report.expenses_zx3;
create temporary table report.expenses_zx3 as
select a.ccuscode
      ,a.y_mon
      ,a.cohr
      ,a.md
  from report.fin_prov_08_expense_ccus a
 where a.ccuscode is null
   and a.state = 'zz_md'
;

drop table if exists report.expenses_zx;
create temporary table report.expenses_zx as
select b.ccuscode
      ,a.y_mon
      ,round(b.md/c.md*(a.md),2) as md
  from report.expenses_zx3 a
  left join report.expenses_zx2 b
    on a.y_mon = b.y_mon
  left join report.expenses_zx1 c
    on a.y_mon = c.y_mon
 where a.y_mon >= '2018-01'
;

alter table report.expenses_mid1 add index index_expenses_mid1_ccuscode(ccuscode) ;
alter table report.expenses_mid1 add index index_expenses_mid1_y_mon(y_mon) ;
alter table report.expenses_dq add index index_expenses_dq_ccuscode(ccuscode) ;
alter table report.expenses_dq add index index_expenses_dq_y_mon(y_mon) ;
alter table report.expenses_sq add index index_expenses_sq_ccuscode(ccuscode) ;
alter table report.expenses_sq add index index_expenses_sq_y_mon(y_mon) ;
alter table report.expenses_zx add index index_expenses_zx_ccuscode(ccuscode) ;
alter table report.expenses_zx add index index_expenses_zx_y_mon(y_mon) ;

drop table if exists report.expenses_pre;
create temporary table report.expenses_pre as
select ccuscode
      ,y_mon
  from report.expenses_mid1 union
select ccuscode
      ,y_mon
  from report.expenses_sq union
select ccuscode
      ,y_mon
  from report.expenses_dq union
select ccuscode
      ,y_mon
  from report.expenses_zx
;

-- 整合到一起
truncate table report.fin_prov_10_expense_yx;
insert into report.fin_prov_10_expense_yx
select e.ccuscode
      ,e.y_mon
      ,a.md as cc_md
      ,b.md as sq_md
      ,c.md as dq_md
      ,d.md as zx_md
  from report.expenses_pre e
  left join report.expenses_sq b
    on e.ccuscode = b.ccuscode
   and e.y_mon = b.y_mon
  left join report.expenses_dq c
    on e.ccuscode = c.ccuscode
   and e.y_mon = c.y_mon
  left join report.expenses_zx d
    on e.ccuscode = d.ccuscode
   and e.y_mon = d.y_mon
  left join report.expenses_mid1 a
    on e.ccuscode = a.ccuscode
   and e.y_mon = a.y_mon
;

drop table if exists report.x_account_sy_pre;
