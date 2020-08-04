
-- truncate table edw.x_account_sy;
-- insert into edw.x_account_sy
drop table if exists edw.x_account_sy_pre;
create temporary table edw.x_account_sy_pre as
select a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,c.sales_region
      ,c.province
      ,a.year_
      ,a.bonus
      ,a.peoplenumber
      ,sum(a.mon_1) as mon_1
      ,sum(a.mon_2) as mon_2
      ,sum(a.mon_3) as mon_3
      ,sum(a.mon_4) as mon_4
      ,sum(a.mon_5) as mon_5
      ,sum(a.mon_6) as mon_6
      ,sum(a.mon_7) as mon_7
      ,sum(a.mon_8) as mon_8
      ,sum(a.mon_9) as mon_9
      ,sum(a.mon_10) as mon_10
      ,sum(a.mon_11) as mon_11
      ,sum(a.mon_12) as mon_12
  from ufdata.x_account_sy a
  left join (select * from edw.dic_customer group by trim(ccusname)) b
    on trim(a.ccusname) = trim(b.ccusname)
  left join (select * from edw.map_customer group by bi_cuscode) c
    on b.bi_cuscode = c.bi_cuscode
 group by b.bi_cuscode,a.year_
;

truncate table edw.x_account_sy;
insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-01') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_1,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-02') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_2,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-03') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_3,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-04') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_4,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-05') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_5,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-06') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_6,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-07') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_7,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-08') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_8,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-09') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_9,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-10') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_10,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-11') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_11,0)
  from edw.x_account_sy_pre
;

insert into edw.x_account_sy
select ccusname
      ,bi_cuscode
      ,bi_cusname
      ,sales_region
      ,province
      ,concat(year_,'-12') as y_mon
      ,bonus
      ,peoplenumber
      ,ifnull(mon_12,0)
  from edw.x_account_sy_pre
;

-- 删除费用是0的客户月份
delete from edw.x_account_sy where isum = 0;