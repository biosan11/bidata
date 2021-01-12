-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 程序头部-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- 功能：项目对应的成效分析
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- 程序名称：cusitem_person_newstate.sql
-- 目标模型：cusitem_person_newstate
-- 源    表：pdm.mid0_cusitem_person_newstate,edw.x_sales_budget_20_ori,edw.x_cinv_relation
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -
-- 加载周期：日增
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
 -- 作者：jiangsh
 -- 开发日期：2020-03-09
 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
 -- 版本控制：版本号  提交人   提交日期   提交内容
 --          V1.0     jiangsh  2020-03-09   开发上线
 -- 调用方法　sh /home/bidata/report/python/jsh_test.sh
 -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 开始处理逻辑-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

-- 取 pdm.mid0_cusitem_person_newstate 中销售中心的数据 
drop table if exists pdm.mid0_cusitem_person_newstate;
create table if not exists pdm.mid0_cusitem_person_newstate
select * from pdm.invoice_order where year(ddate) >= 2019 and if_xs is null and db not in ('jsc','HNAB');
alter table pdm.mid0_cusitem_person_newstate add index(cohr);
alter table pdm.mid0_cusitem_person_newstate add index(finnal_ccuscode);
alter table pdm.mid0_cusitem_person_newstate add index(item_code);
alter table pdm.mid0_cusitem_person_newstate add index(cinvcode);

--  计算规则如下：①新增新客户（即2019年没有销售额，2020年有销售额的（产诊机构、产筛机构、B超通路打通、新筛中心、出防中心），即一家客户算一个；
--  ②老客户新增项目（新项目指特定的项目，包括杰毅NIPT、CMA、早孕、VD、耳聋、串联新筛，包括设备、外送项目），即一个项目算一个；
--  ③非设备销售以开票为完成节点，销售类设备以开票为完成节点，非销售类设备以装机验收合格为完成节点。

--  新客户按所属人员最早时间为准，例如：一个新客户存在两个项目，项目1计划1月完成，属于销售A，项目2计划4月完成，属于销售B，
--  两个项目同时属于主管C，则A计划1月完成， B计划4月完成，C计划1月完成。同理老客户新项目按最早的产品完成为标准，如果设备计划发货有数量，金额无，即投放，则也要统计进来。

--  字段：省份、地市、客户(终端客户ZD)、是否杭州贝生、20年最早日期、20年计划最早日期、医院负责人、主管、产品、产品类型、完成节点(正常开票、异常开票(无正常开票无装机)、正常装机)(这里都是20年装机)，
--  创建一张收入19年的老客户临时表
drop table if exists pdm.mid1_cusitem_person_newstate;
create temporary table pdm.mid1_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,finnal_ccuscode as cuscode
      ,finnal_ccusname as cusname
  from pdm.mid0_cusitem_person_newstate
 where year(ddate) = '2019'
   and left(finnal_ccuscode,2) = 'ZD'
   and (ifnull(isum,0) >= 0 or ifnull(iquantity,0) >= 0)
 group by cohr1,finnal_ccuscode
;

--  这里处理20年所有的客户项目，客户是终端客户
drop table if exists pdm.mid2_cusitem_person_newstate;
create temporary table pdm.mid2_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,min(ddate) as ddate
      ,province
      ,city
      ,finnal_ccuscode as cuscode
      ,finnal_ccusname as cusname
      ,cbustype
      ,cinvcode
      ,cinvname
      ,cverifier
      ,areadirector
      ,item_code
      ,sum(isum) as isum_
  from pdm.mid0_cusitem_person_newstate
 where year(ddate) = '2020'
   and left(finnal_ccuscode,2) = 'ZD'
 group by cohr1,finnal_ccuscode,cinvcode
 having isum_ <> 0
;

--  跟新杰毅NIPT、东方海洋VD
update pdm.mid2_cusitem_person_newstate set item_code = 'TEMP2020_1' where cinvcode = 'TEMP2020_1';
update pdm.mid2_cusitem_person_newstate set item_code = 'SJ02030' where cinvcode = 'SJ02030';


--  创建20年计划客户项目最早计划时间,计划最早时间用有计划销售额,这里到项目
drop table if exists pdm.mid3_cusitem_person_newstate;
create temporary table pdm.mid3_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,min(ddate) as ddate
      ,province
      ,city
      ,bi_cuscode as cuscode
      ,bi_cusname as cusname
      ,cbustype
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,item_code
      ,cverifier
      ,areadirector
  from edw.x_sales_budget_20_ori
 where year(ddate) = '2020'
   and left(bi_cuscode,2) = 'ZD'
   and isum_budget <> 0
 group by cohr1,bi_cuscode,item_code
;

--  创建20年计划客户项目最早计划时间,计划最早时间用有计划销售额,这里到产品
drop table if exists pdm.mid31_cusitem_person_newstate;
create temporary table pdm.mid31_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,min(ddate) as ddate
      ,province
      ,city
      ,bi_cuscode as cuscode
      ,bi_cusname as cusname
      ,cbustype
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,item_code
      ,cverifier
      ,areadirector
  from edw.x_sales_budget_20_ori
 where year(ddate) = '2020'
   and left(bi_cuscode,2) = 'ZD'
   and isum_budget <> 0
 group by cohr1,bi_cuscode,cinvcode
;

--  跟新杰毅NIPT、东方海洋VD
update pdm.mid31_cusitem_person_newstate set item_code = 'TEMP2020_1' where cinvcode = 'TEMP2020_1';
update pdm.mid31_cusitem_person_newstate set item_code = 'SJ02030' where cinvcode = 'SJ02030';


--  插入最终数据
truncate table pdm.cusitem_person_newstate;
insert into pdm.cusitem_person_newstate
select a.cohr1 as cohr
      ,a.ddate
      ,a.province
      ,a.city
      ,a.cuscode
      ,a.cusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,d.item_code
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,a.cverifier
      ,a.areadirector
      ,c.ddate as ddate_plan
--       ,c.cverifier as cverifier_plan
--       ,c.areadirector as areadirector_plan
      ,'异常开票' as type
      ,'新客户' as status
      ,null
      ,null
      ,null
      ,null
      ,null
      ,1
  from pdm.mid2_cusitem_person_newstate a
  left join pdm.mid1_cusitem_person_newstate b
    on a.cohr1 = b.cohr1
   and a.cuscode = b.cuscode
  left join pdm.mid3_cusitem_person_newstate c
    on a.cohr1 = c.cohr1
   and a.cuscode = c.cuscode
   and a.item_code = c.item_code
  left join edw.map_inventory d
    on a.cinvcode = d.bi_cinvcode
 where b.cuscode is null
;

--  取20年存在收入的开票记录
drop table if exists pdm.mid4_cusitem_person_newstate;
create temporary table pdm.mid4_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,min(ddate) as ddate
      ,province
      ,city
      ,finnal_ccuscode as cuscode
      ,finnal_ccusname as cusname
      ,cbustype
      ,cinvcode
      ,cinvname
      ,cverifier
      ,areadirector
  from pdm.mid0_cusitem_person_newstate
 where year(ddate) = '2020'
   and left(finnal_ccuscode,2) = 'ZD'
   and ifnull(isum,0) <> 0
 group by cohr1,finnal_ccuscode,cinvcode
;

update pdm.cusitem_person_newstate a
 inner join pdm.mid4_cusitem_person_newstate b
    on a.cohr = b.cohr1
   and a.cuscode = b.cuscode
   and a.cinvcode = b.cinvcode
   set a.type = '正常开票'
;

--  取20年装机档案存在的客户
update pdm.cusitem_person_newstate a
 inner join (select * from edw.crm_account_equipments where year(new_installation_date) = '2020' group by bi_cuscode) b
    on a.cuscode = b.bi_cuscode
   set a.type = '正常装机'
 where a.type = '异常开票'
   and a.cohr = '博圣'
;

--  20年杭州贝生装机档案
update pdm.cusitem_person_newstate a set type = '正常装机' where cuscode = 'ZD4103004' and cohr = '杭州贝生';

--  插入计划数据
insert into pdm.cusitem_person_newstate
select a.cohr1 as cohr         
      ,a.ddate
      ,a.province
      ,a.city
      ,a.cuscode
      ,a.cusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,d.item_code
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,null
      ,null
      ,a.ddate as ddate_plan
      ,'只有计划' as type
      ,'新客户' as status
      ,null
      ,null
      ,null
      ,null
      ,null
      ,1
  from pdm.mid31_cusitem_person_newstate a
  left join pdm.mid1_cusitem_person_newstate b
    on a.cohr1 = b.cohr1
   and a.cuscode = b.cuscode
  left join (select * from pdm.cusitem_person_newstate group by cohr,cuscode,item_code) c
    on a.cohr1 = c.cohr
   and a.cuscode = c.cuscode
   and a.item_code = c.item_code
  left join edw.map_inventory d
    on a.cinvcode = d.bi_cinvcode
 where b.cuscode is null
   and c.cuscode is null
;

--  2.0
--  这里把老客户新项目放在一张表
--  项目维度增加两个新项目的自由情况的产品编号，最后还原
drop table if exists pdm.mid5_cusitem_person_newstate;
create table pdm.mid5_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,finnal_ccuscode as cuscode
      ,finnal_ccusname as cusname
      ,case when cinvcode in ('SJ02030','TEMP2020_1') then cinvcode else item_code end as item_code
  from pdm.mid0_cusitem_person_newstate
 where year(ddate) = '2019'
   and left(finnal_ccuscode,2) = 'ZD'
   and (ifnull(isum,0) >= 0 or ifnull(iquantity,0) >= 0)
 group by cohr1,finnal_ccuscode,(case when cinvcode in ('SJ02030','TEMP2020_1') then cinvcode else item_code end)
;

insert into pdm.mid5_cusitem_person_newstate
select cohr1
      ,cuscode
      ,cusname
      ,case when item_code = 'CQ0704' then 'CQ0705'
            when item_code = 'CQ0705' then 'CQ0704'
            when item_code = 'XS0501' then 'XS0909'
            when item_code = 'XS0909' then 'XS0501'
            when item_code = 'XS0301' then 'XS0201'
            when item_code = 'XS0201' then 'XS0301'
       end as item_code
  from pdm.mid5_cusitem_person_newstate
 where item_code in ("CQ0704", "CQ0705","XS0501", "XS0909","XS0301", "XS0201")
;

drop table if exists pdm.mid51_cusitem_person_newstate;
create table pdm.mid51_cusitem_person_newstate as
select distinct *
  from pdm.mid5_cusitem_person_newstate
;

drop table if exists pdm.mid5_cusitem_person_newstate;

drop table if exists pdm.mid6_cusitem_person_newstate;
create table pdm.mid6_cusitem_person_newstate as
select a.cohr1 as cohr
      ,a.ddate
      ,a.province
      ,a.city
      ,a.cuscode
      ,a.cusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,d.item_code
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,a.cverifier
      ,a.areadirector
      ,c.ddate as ddate_plan
--       ,c.cverifier as cverifier_plan
--       ,c.areadirector as areadirector_plan
      ,'异常开票' as type
  from pdm.mid2_cusitem_person_newstate a
  left join pdm.mid51_cusitem_person_newstate b
    on a.cohr1 = b.cohr1
   and a.cuscode = b.cuscode
   and a.item_code = b.item_code
  left join pdm.mid3_cusitem_person_newstate c
    on a.cohr1 = c.cohr1
   and a.cuscode = c.cuscode
   and a.cinvcode = c.cinvcode
  left join edw.map_inventory d
    on a.cinvcode = d.bi_cinvcode
 where b.cuscode is null
;

update pdm.mid6_cusitem_person_newstate a
 inner join pdm.mid4_cusitem_person_newstate b
    on a.cohr = b.cohr1
   and a.cuscode = b.cuscode
   and a.cinvcode = b.cinvcode
   set a.type = '正常开票'
;


--  插入计划数据
insert into pdm.mid6_cusitem_person_newstate
select a.cohr1 as cohr
      ,a.ddate
      ,a.province
      ,a.city
      ,a.cuscode
      ,a.cusname
      ,a.cbustype
      ,a.cinvcode
      ,a.cinvname
      ,d.item_code
      ,d.level_three
      ,d.level_two
      ,d.level_one
      ,null
      ,null
      ,a.ddate as ddate_plan
--       ,a.cverifier as cverifier_plan
--       ,a.areadirector as areadirector_plan
      ,'只有计划' as type
  from pdm.mid31_cusitem_person_newstate a
  left join pdm.mid51_cusitem_person_newstate b
    on a.cohr1 = b.cohr1
   and a.cuscode = b.cuscode
   and a.item_code = b.item_code
  left join (select * from pdm.mid6_cusitem_person_newstate group by cohr,cuscode,item_code) c
    on a.cohr1 = c.cohr
   and a.cuscode = c.cuscode
   and a.cinvcode = c.cinvcode
  left join edw.map_inventory d
    on a.cinvcode = d.bi_cinvcode
 where b.cuscode is null
   and c.cuscode is null
;

--  插入到一张表里面
insert into pdm.cusitem_person_newstate
select a.*
      ,'老客户'
      ,null
      ,null
      ,null
      ,null
      ,null
      ,null
  from pdm.mid6_cusitem_person_newstate a
  left join pdm.cusitem_person_newstate b
    on a.cohr = b.cohr
   and a.cuscode = b.cuscode
 where b.cuscode is null
;

--  更新20年新项目
update pdm.cusitem_person_newstate set new_item = CASE
	WHEN
		cinvcode in ("SJ02030","SJ02027","SJ02029") THEN
			"杰毅NIPT" 
			WHEN item_code IN ( "CQ0704", "CQ0705" ) THEN
			"CMA(含设备)" 
			WHEN item_code = "CQ0608" THEN
			"早孕" --  只取CQ0608
			
			WHEN cinvcode in("TEMP2020_1","SJ01027") THEN
			"东方海洋VD" --  临时的编码, 后面有正式的需要修改
			
			WHEN item_code IN ( "XS0501", "XS0909" ) THEN
			"耳聋基因" --  加XS0909
			
			WHEN item_code IN ( "XS0301", "XS0201" ) THEN
			"串联试剂(含设备)"  end
;

drop table if exists pdm.mid6_cusitem_person_newstate;
drop table if exists pdm.mid51_cusitem_person_newstate;

update pdm.cusitem_person_newstate
   set item_code = 'CQ0101'
 where cinvcode = 'SJ02030'
;

update pdm.cusitem_person_newstate
   set item_code = 'CQ0615'
 where cinvcode = 'TEMP2020_1'
;

--  更新一下客户项目负责人
update pdm.cusitem_person_newstate a
 inner join pdm.cusitem_person b
    on a.cuscode = b.ccuscode
   and a.item_code = b.item_code
   and a.cbustype = b.cbustype
   set a.areadirector = b.areadirector
      ,a.cverifier = b.cverifier
 where a.ddate >= '2018-01-01'
   and a.ddate >= b.start_dt
   and a.ddate <= b.end_dt
;

--  新增几个客户资质字段
update pdm.cusitem_person_newstate a
 inner join edw.map_customer b
    on a.cuscode = b.bi_cuscode
   set a.nsieve_mechanism = b.nsieve_mechanism
      ,a.medical_mechanism = b.medical_mechanism
      ,a.screen_mechanism = b.screen_mechanism
;

update pdm.cusitem_person_newstate set if_mechanism_online = 'False';
update pdm.cusitem_person_newstate set if_mechanism_online = 'True' where nsieve_mechanism = 'True' or medical_mechanism = 'True' or screen_mechanism = 'True' or nsieve_mechanism = '筹' or medical_mechanism = '筹' or screen_mechanism = '筹';

--  200424确认删除健康项目
delete from pdm.cusitem_person_newstate where left(item_code,2) = 'jk';


--  增加客户项目成功率
update pdm.cusitem_person_newstate a
 inner join (select cohr,bi_cuscode,item_code,max(plan_success_rate) as plan_success_rate from edw.x_sales_budget_20_ori group by cohr,bi_cuscode,item_code) b
    on a.cuscode = b.bi_cuscode
   and left(a.cohr,2) = left(b.cohr,2)
   and a.item_code = b.item_code
   set a.plan_success_rate = b.plan_success_rate
--  where type = '只有计划'
;

--  判断一下20年收入是否为0，是则不计算
drop table if exists pdm.mid2_cusitem_person_newstate;
create temporary table pdm.mid2_cusitem_person_newstate as
select case when cohr  = '杭州贝生' then '杭州贝生' else '博圣' end as cohr1
      ,finnal_ccuscode
  from pdm.mid0_cusitem_person_newstate
 where year(ddate) = '2020'
   and left(finnal_ccuscode,2) = 'ZD'
 group by cohr1,finnal_ccuscode
 having sum(isum) = 0
;

delete from pdm.cusitem_person_newstate 
 where concat(cohr,cuscode) in (select concat(cohr1,finnal_ccuscode) from pdm.mid2_cusitem_person_newstate)
   and type <> '只有计划'
;

