
-- 检测外送和实验数据，只需要收样日期、客户、项目
-- 项目和客户清洗

create temporary table edw.x_sales_hospital_pre as
select a.id_smaple
      ,replace(a.ddate_sampling,'0:00:00','') as ddate_sampling
      ,a.ccusname
      ,case when a.cinvname = '全外显子组测序（出数据）' and a.kinship is null then '全外显子组测序（单先证者）' 
            when a.cinvname = '全外显子组测序（出数据）' and a.kinship is not null then '全外显子组测序（家系全外）' 
            when a.cinvname = '全外显子组测序' and a.kinship is not null then '全外显子组测序（家系全外）' 
            when a.cinvname = '全外显子组测序' and a.kinship is null then '全外显子组测序（单先证者）' 
       else a.cinvname end as cinvname
      ,a.class_smaple
  from ufdata.x_sales_hospital a
union all
select b.id_smaple
      ,replace(b.ddate_sampling,'0:00:00','') as ddate_sampling
      ,b.ccusname
      ,case when b.cinvname = '全外显子组测序（出数据）' then '全外显子组测序' else b.cinvname end as cinvname
      ,b.class_smaple
  from ufdata.x_sales_shiyan b
;

drop table if exists edw.x_sales_hospital_mid1;
create temporary table edw.x_sales_hospital_mid1 as
select a.*
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,case when c.cinvname is null then '请核查' else c.bi_cinvcode end as bi_cinvcode
      ,case when c.cinvname is null then '请核查' else c.bi_cinvname end as bi_cinvname
      ,case when d.bi_cinvcode is null then '请核查' else d.item_code end as item_code
      ,d.level_three as item_name
      ,d.business_class
      ,e.province
  from edw.x_sales_hospital_pre a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.dic_inventory group by cinvname) c
    on a.cinvname = c.cinvname
  left join (select * from edw.map_inventory group by bi_cinvcode) d
    on c.bi_cinvcode = d.bi_cinvcode
  left join (select * from edw.map_customer group by bi_cuscode) e
    on b.bi_cuscode = e.bi_cuscode
;

-- 加入区域、主管、学术代表、技术主管
truncate table edw.x_sales_hospital;
insert into edw.x_sales_hospital
select a.*
      ,b.p_sales_sup_clinic
      ,b.p_sales_spe_clinic
      ,b.p_sales_sup_tec
  from edw.x_sales_hospital_mid1 a
left join (select * from edw.map_cusitem_person where end_dt = '2019-12-31') b
    on a.bi_cuscode = b.ccuscode
   and a.item_code = b.item_code
 where a.ccusname <> '测试样本'
   and a.ccusname <> '研发测试'
;

-- 删除没用的数据
delete from edw.x_sales_hospital where ccusname = '';
delete from edw.x_sales_hospital where ccusname = '地中海贫血基因检测（α+β）';
delete from edw.x_sales_hospital where ccusname = '测试';
delete from edw.x_sales_hospital where ccusname = '未知单位';
delete from edw.x_sales_hospital where ccusname = '名医工作室';
delete from edw.x_sales_hospital where ccusname = '筛查实验室';
delete from edw.x_sales_hospital where ccusname = '【关键词】心跳呼吸骤停|出生时发病';
delete from edw.x_sales_hospital where ccusname = '？？';

-- 删除垃圾数据
delete from edw.x_sales_hospital where id_smaple = '全血';

-- 删除没用的产品
delete from edw.x_sales_hospital where cinvname = '';
delete from edw.x_sales_hospital where cinvname = '测试项目';

-- 时间格式问题数据调整
update edw.x_sales_hospital set ddate_sampling = '2019-04-08' where ddate_sampling = '2019/4/80:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-01' where ddate_sampling = '2019/7/100:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-15' where ddate_sampling = '2019/7/150:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-17' where ddate_sampling = '2019/7/170:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-23' where ddate_sampling = '2019/7/230:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-25' where ddate_sampling = '2019/7/250:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-30' where ddate_sampling = '2019/7/300:00:00';
update edw.x_sales_hospital set ddate_sampling = '2019-07-31' where ddate_sampling = '2019/7/310:00:00';

-- 这里有停用的产品，需要删除项目请核查
update edw.x_sales_hospital set item_code = null where left(bi_cinvname,2) = '暂停';

