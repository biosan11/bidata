------------------------------------程序头部----------------------------------------------
--功能：19年设备折旧表
------------------------------------------------------------------------------------------
--程序名称：x_eq_depreciation_20.sql
--目标模型：x_eq_depreciation_20
--源    表：ufdata.x_eq_depreciation_20
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-02-26
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2019-10-26   开发上线
--         V1.0     jiangsh  2020-03-05   修改数值存放形式，行列转化
--调用方法　python /home/bidata/report/python/x_eq_depreciation_20.py
------------------------------------开始处理逻辑------------------------------------------


-- 设备折旧19

drop table if exists edw.x_eq_depreciation_20_pre;
create temporary table edw.x_eq_depreciation_20_pre as
select a.cohr
      ,a.year_belong
      ,a.vouchid
      ,a.ddate_belong
      ,a.vouchnum
      ,a.province
      ,a.sales_region
      ,a.ccusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.eq_name
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,case when d.bi_cinvcode is null then '请核查' else d.level_three end as level_three
      ,case when d.bi_cinvcode is null then '请核查' else d.level_two end as level_two
      ,case when d.bi_cinvcode is null then '请核查' else d.level_one end as level_one
      ,a.isum
      ,a.iquantity
      ,a.amount_depre_mon
      ,a.comment
      ,a.amount_depre_1
      ,a.amount_depre_2
      ,a.amount_depre_3
      ,a.amount_depre_4
      ,a.amount_depre_5
      ,a.amount_depre_6
      ,a.amount_depre_7
      ,a.amount_depre_8
      ,a.amount_depre_9
      ,a.amount_depre_10
      ,a.amount_depre_11
      ,a.amount_depre_12
  from ufdata.x_eq_depreciation_20 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.eq_name = c.cinvname
  left join edw.map_inventory d
    on c.bi_cinvcode = d.bi_cinvcode
;

update edw.x_eq_depreciation_20_pre a
 inner join (select * from edw.fa_cards group by sassetnum) b
    on a.vouchid = b.sassetnum
   set a.eq_name = b.sassetname
 where a.cinvcode = '请核查';



drop table if exists edw.x_eq_depreciation_20_pre2;
create temporary table edw.x_eq_depreciation_20_pre2 as
select a.cohr
      ,a.year_belong
      ,a.vouchid
      ,a.ddate_belong
      ,a.vouchnum
      ,a.province
      ,a.sales_region
      ,a.ccusname
      ,case when b.ccusname is not null then b.bi_cuscode else '请核查' end as bi_cuscode
      ,case when b.ccusname is not null then b.bi_cusname else '请核查' end as bi_cusname
      ,a.eq_name
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,case when d.bi_cinvcode is null then '请核查' else d.level_three end as level_three
      ,case when d.bi_cinvcode is null then '请核查' else d.level_two end as level_two
      ,case when d.bi_cinvcode is null then '请核查' else d.level_one end as level_one
      ,a.isum
      ,a.iquantity
      ,a.amount_depre_mon
      ,a.comment
      ,a.amount_depre_1
      ,a.amount_depre_2
      ,a.amount_depre_3
      ,a.amount_depre_4
      ,a.amount_depre_5
      ,a.amount_depre_6
      ,a.amount_depre_7
      ,a.amount_depre_8
      ,a.amount_depre_9
      ,a.amount_depre_10
      ,a.amount_depre_11
      ,a.amount_depre_12
  from edw.x_eq_depreciation_20_pre a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.eq_name = c.cinvname
  left join edw.map_inventory d
    on c.bi_cinvcode = d.bi_cinvcode
;

-- 根据bi需求，增加最终客户和月份转置
truncate table edw.x_eq_depreciation_20;
insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_1
      ,'2020-01-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_2
      ,'2020-02-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_3
      ,'2020-03-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_4
      ,'2020-04-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_5
      ,'2020-05-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_6
      ,'2020-06-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_7
      ,'2020-07-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_8
      ,'2020-08-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_9
      ,'2020-09-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_10
      ,'2020-10-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_11
      ,'2020-11-01'
  from edw.x_eq_depreciation_20_pre2
;

insert into edw.x_eq_depreciation_20
select cohr
      ,year_belong
      ,vouchid
      ,ddate_belong
      ,vouchnum
      ,province
      ,sales_region
      ,ccusname
      ,bi_cuscode
      ,bi_cusname
      ,bi_cuscode
      ,bi_cusname
      ,eq_name
      ,cinvcode
      ,cinvname
      ,item_code
      ,level_three
      ,level_two
      ,level_one
      ,isum
      ,iquantity
      ,amount_depre_mon
      ,comment
      ,amount_depre_12
      ,'2020-12-01'
  from edw.x_eq_depreciation_20_pre2
;


-- 将amount_depre中所有空值 替换成0  
update edw.x_eq_depreciation_20 set amount_depre = 0 where amount_depre is null ;

-- 191011更新 新增一列 将DL开头代理商 通过map档案一对一的处理成终端客户 
update edw.x_eq_depreciation_20 as a 
left join edw.map_customer as b 
on a.finnal_cuscode = b.bi_cuscode 
set a.finnal_cuscode = b.finnal_cuscode
   ,a.finnal_cusname = b.finnal_ccusname
where left(a.finnal_cuscode,2) = "DL";
-- 处理的结果 如果是multi 则返回原客户编码
update edw.x_eq_depreciation_20 set finnal_cuscode = bi_cuscode,finnal_cusname = bi_cusname where finnal_cuscode = "multi";

-- 删除amount_depre是0的数据
delete from edw.x_eq_depreciation_20 where amount_depre = '0';




