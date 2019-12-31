-- 费用拆分整合到一起
-- report.fin_prov_10_expense_else
-- report.fin_prov_10_expense_yx
-- edw.x_account_insettle
-- edw.x_account_sy


-- CREATE TABLE `fin_prov_10_expense_all` (
--   `y_mon` varchar(7) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '年月',
--   `ccuscode` varchar(20) DEFAULT NULL COMMENT '客户编号',
--   `cohr` varchar(4) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '公司',
--   `dept_name` varchar(6) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '部门名称',
--   `cc_md` double(19,2) DEFAULT NULL COMMENT '直接到客户',
--   `sq_md` double(24,7) DEFAULT NULL COMMENT '拆分到省区',
--   `dq_md` double(19,2) DEFAULT NULL COMMENT '拆分到大区',
--   `zx_md` double(19,2) DEFAULT NULL COMMENT '拆分到中心',
--   `sy_md` double(19,2) DEFAULT NULL COMMENT '实验员',
--   `bx_md` double(19,2) DEFAULT NULL COMMENT '保险',
--   `xxzx_md` double(10,3) DEFAULT NULL COMMENT '内部结算-信息中心',
--   `jsbz_md` double(10,3) DEFAULT NULL COMMENT '内部结算金额-技术保障',
--   `wb_md` double(10,3) DEFAULT NULL COMMENT '内部结算金额-维保',
--   `wl_md` double(10,3) DEFAULT NULL COMMENT '内部结算金额-物流'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='费用分摊整合表';


-- 投保临时表
drop table if exists report.x_insure_cover_pre;
create temporary table report.x_insure_cover_pre as
select a.bi_cuscode as ccuscode
      ,sum(act_num*iunitcost)  as md
      ,left(ddate,7) as y_mon
  from edw.x_insure_cover a
 group by bi_cuscode,left(ddate,7)
;

-- 不到客户的总金额 减去实验员金额
drop table if exists report.x_account_sy_pre;
create temporary table report.x_account_sy_pre as
select bi_cuscode
      ,year_
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
 group by bi_cuscode,year_
;



drop table if exists report.expenses_pre;
create temporary table report.expenses_pre as
select distinct ccuscode,y_mon from report.fin_prov_10_expense_yx union
select distinct bi_cuscode,'2019-01' from edw.x_account_sy where round(mon_1 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-02' from edw.x_account_sy where round(mon_2 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-03' from edw.x_account_sy where round(mon_3 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-04' from edw.x_account_sy where round(mon_4 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-05' from edw.x_account_sy where round(mon_5 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-06' from edw.x_account_sy where round(mon_6 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-07' from edw.x_account_sy where round(mon_7 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-08' from edw.x_account_sy where round(mon_8 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-09' from edw.x_account_sy where round(mon_9 ,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-10' from edw.x_account_sy where round(mon_10,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-11' from edw.x_account_sy where round(mon_11,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2019-12' from edw.x_account_sy where round(mon_12,0) <> 0 and year_ = '2019' union
select distinct bi_cuscode,'2018-01' from edw.x_account_sy where round(mon_1 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-02' from edw.x_account_sy where round(mon_2 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-03' from edw.x_account_sy where round(mon_3 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-04' from edw.x_account_sy where round(mon_4 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-05' from edw.x_account_sy where round(mon_5 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-06' from edw.x_account_sy where round(mon_6 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-07' from edw.x_account_sy where round(mon_7 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-08' from edw.x_account_sy where round(mon_8 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-09' from edw.x_account_sy where round(mon_9 ,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-10' from edw.x_account_sy where round(mon_10,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-11' from edw.x_account_sy where round(mon_11,0) <> 0 and year_ = '2018' union
select distinct bi_cuscode,'2018-12' from edw.x_account_sy where round(mon_12,0) <> 0 and year_ = '2018' union
select distinct ccuscode,y_mon from report.x_insure_cover_pre where y_mon >= '2018-01'
;

truncate table report.fin_prov_10_expense_all;
insert into report.fin_prov_10_expense_all
select a.y_mon
      ,a.ccuscode
      ,'bs'
      ,'营销中心'
      ,ifnull(d.cc_md,0)
      ,ifnull(d.sq_md,0)
      ,ifnull(d.dq_md,0)
      ,ifnull(d.zx_md,0)
      ,case when a.y_mon = '2019-01' then ifnull(b.mon_1 ,0)
            when a.y_mon = '2019-02' then ifnull(b.mon_2 ,0)
            when a.y_mon = '2019-03' then ifnull(b.mon_3 ,0)
            when a.y_mon = '2019-04' then ifnull(b.mon_4 ,0)
            when a.y_mon = '2019-05' then ifnull(b.mon_5 ,0)
            when a.y_mon = '2019-06' then ifnull(b.mon_6 ,0)
            when a.y_mon = '2019-07' then ifnull(b.mon_7 ,0)
            when a.y_mon = '2019-08' then ifnull(b.mon_8 ,0)
            when a.y_mon = '2018-01' then ifnull(b.mon_1 ,0)
            when a.y_mon = '2018-02' then ifnull(b.mon_2 ,0)
            when a.y_mon = '2018-03' then ifnull(b.mon_3 ,0)
            when a.y_mon = '2018-04' then ifnull(b.mon_4 ,0)
            when a.y_mon = '2018-05' then ifnull(b.mon_5 ,0)
            when a.y_mon = '2018-06' then ifnull(b.mon_6 ,0)
            when a.y_mon = '2018-07' then ifnull(b.mon_7 ,0)
            when a.y_mon = '2018-08' then ifnull(b.mon_8 ,0)
            when a.y_mon = '2018-09' then ifnull(b.mon_9 ,0)
            when a.y_mon = '2018-10' then ifnull(b.mon_10 ,0)
            when a.y_mon = '2018-11' then ifnull(b.mon_11 ,0)
            when a.y_mon = '2018-12' then ifnull(b.mon_12 ,0)
--            when a.y_mon = '2019-09' then ifnull(b.mon_9 ,0)
--            when a.y_mon = '2019-10' then ifnull(b.mon_10,0)
--            when a.y_mon = '2019-11' then ifnull(b.mon_11,0)
--            when a.y_mon = '2019-12' then ifnull(b.mon_12,0)
            else 0 end as sy_md
      ,ifnull(c.md,0)
      ,0
      ,0
      ,0
      ,0
  from report.expenses_pre a
  left join report.x_account_sy_pre b
    on a.ccuscode = b.bi_cuscode
   and left(a.y_mon,4) = b.year_
  left join report.x_insure_cover_pre c
    on a.ccuscode = c.ccuscode
   and a.y_mon = c.y_mon
  left join report.fin_prov_10_expense_yx d
    on a.ccuscode = d.ccuscode
   and a.y_mon = d.y_mon
;

-- 这里由于19-09以后拆分调整
drop table if exists report.x_account_sy_pre1;
create temporary table report.x_account_sy_pre1 as
select concat(year_,'-01') as y_mon,bi_cuscode as ccuscode ,sum(mon_1)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-02') as y_mon,bi_cuscode as ccuscode ,sum(mon_2)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-03') as y_mon,bi_cuscode as ccuscode ,sum(mon_3)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-04') as y_mon,bi_cuscode as ccuscode ,sum(mon_4)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-05') as y_mon,bi_cuscode as ccuscode ,sum(mon_5)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-06') as y_mon,bi_cuscode as ccuscode ,sum(mon_6)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-07') as y_mon,bi_cuscode as ccuscode ,sum(mon_7)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-08') as y_mon,bi_cuscode as ccuscode ,sum(mon_8)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-09') as y_mon,bi_cuscode as ccuscode ,sum(mon_9)  as md from edw.x_account_sy a group by year_ ,bi_cuscode union
select concat(year_,'-10') as y_mon,bi_cuscode as ccuscode ,sum(mon_10)  as md from edw.x_account_sy a group by year_,bi_cuscode union
select concat(year_,'-11') as y_mon,bi_cuscode as ccuscode ,sum(mon_11)  as md from edw.x_account_sy a group by year_,bi_cuscode union
select concat(year_,'-12') as y_mon,bi_cuscode as ccuscode ,sum(mon_12)  as md from edw.x_account_sy a group by year_,bi_cuscode 
;


drop table if exists report.fin_prov_10_expense_else_pre;
create temporary table report.fin_prov_10_expense_else_pre
select a.y_mon
      ,a.ccuscode
      ,a.cohr
      ,a.dept_name
      ,sum(ifnull(a.cc_md,0)) as cc_md
      ,sum(ifnull(a.sq_md,0)) as sq_md
      ,sum(ifnull(a.xxzx_md,0)) as xxzx_md
      ,sum(ifnull(a.jsbz_md,0)) as jsbz_md
      ,sum(ifnull(a.wb_md  ,0)) as wb_md
      ,sum(ifnull(a.wl_md  ,0)) as wl_md
  from report.fin_prov_10_expense_else a
 group by a.y_mon,a.ccuscode,a.dept_name
union all
select a.y_mon
      ,a.ccuscode
      ,'bs'
      ,'技术保障中心'
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
  from (select * from report.x_account_sy_pre1 where y_mon >= '2019-09') a
  left join report.fin_prov_10_expense_else b
    on a.ccuscode = b.ccuscode
   and a.y_mon = b.y_mon
 where b.y_mon is null
;


-- 插入公司其他的部门的数据
insert into report.fin_prov_10_expense_all
select a.y_mon
      ,a.ccuscode
      ,a.cohr
      ,a.dept_name
      ,a.cc_md
      ,0
      ,0
      ,a.sq_md
      ,case when a.y_mon = '2019-09' and a.dept_name = '技术保障中心' then ifnull(b.mon_9 ,0)
            when a.y_mon = '2019-10' and a.dept_name = '技术保障中心' then ifnull(b.mon_10,0)
            when a.y_mon = '2019-11' and a.dept_name = '技术保障中心' then ifnull(b.mon_11,0)
            when a.y_mon = '2019-12' and a.dept_name = '技术保障中心' then ifnull(b.mon_12,0)
            else 0 end as sy_md
      ,0
      ,a.xxzx_md
      ,a.jsbz_md
      ,a.wb_md
      ,a.wl_md
  from report.fin_prov_10_expense_else_pre a
  left join report.x_account_sy_pre b
    on a.ccuscode = b.bi_cuscode
   and left(a.y_mon,4) = b.year_
;



