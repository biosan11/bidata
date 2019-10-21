-- drop procedure if exists  pdm.yj_outdepot_forecast_lv2;
-- delimiter $$
-- create procedure pdm.yj_outdepot_forecast_lv2()
-- begin
-- 新逻辑，直接对除最后一个月的前4个月进行操作
-- 这里是最后一个数据进行删除
drop table if exists pdm.outdepot_forecast_pre1;
create temporary table pdm.outdepot_forecast_pre1 as
select a.ccuscode
      ,a.item_code
      ,a.ddate
      ,a.inum_person
  from (select finnal_ccuscode as ccuscode
              ,item_code
              ,concat(left(tbilldate,7),'-01') as ddate
      ,round(inum_person,2) as inum_person
          from pdm.yj_outdepot_fx
--         where (tbilldate < '2019-04-01' and state = 0) or state > 0
         group by finnal_ccuscode,item_code,left(tbilldate,7)
         order by finnal_ccuscode,item_code,left(tbilldate,7) desc
        ) a
 group by a.ccuscode,a.item_code
;

drop table if exists pdm.outdepot_forecast_pre2;
create temporary table pdm.outdepot_forecast_pre2 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,concat(left(tbilldate,7),'-01') as ddate
      ,round(sum(inum_person),2) as inum_person
  from pdm.yj_outdepot_fx
-- where (tbilldate < '2019-04-01' and state = 0) or state > 0
 group by finnal_ccuscode,item_code,left(tbilldate,7)
 order by finnal_ccuscode,item_code,left(tbilldate,7) desc
;

-- 进行排序，选择日期最大的在第一位
drop table if exists pdm.outdepot_forecast;
create temporary table pdm.outdepot_forecast as
select @r:= case when @ccuscode=a.ccuscode and @item_code = a.item_code then @r+1 else 1 end as rownum
      ,@ccuscode:=a.ccuscode as ccuscode
      ,@item_code:=a.item_code as item_code
      ,ddate
      ,inum_person
  from pdm.outdepot_forecast_pre2 a,(select @r:=0,@ccuscode:='',@item_code:='') b
;

-- 得到第一位的数据
drop table if exists pdm.outdepot_forecast_1;
create temporary table pdm.outdepot_forecast_1 as
select rownum
      ,ccuscode
      ,item_code
      ,ddate
      ,inum_person
  from pdm.outdepot_forecast
 where rownum = 1
;

-- 建立索引
alter table pdm.outdepot_forecast_1 add index index_outdepot_forecast_1_ccuscode(ccuscode);
alter table pdm.outdepot_forecast_1 add index index_outdepot_forecast_1_item_code(item_code);

-- 和排序第一次的数据做出差值
drop table if exists pdm.outdepot_forecast_12;
create temporary table pdm.outdepot_forecast_12 as
select b.rownum
      ,a.ccuscode
      ,a.item_code
      ,b.ddate
      ,TIMESTAMPDIFF(MONTH,b.ddate,a.ddate) as mon_diff
      ,b.inum_person
  from pdm.outdepot_forecast_1 a
  left join pdm.outdepot_forecast  b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
;

-- 删除间隔时间在12个月以上的数据，没有分析价值
delete from pdm.outdepot_forecast_12 where mon_diff >= 12;

-- 这里得到一年内的最大有效次数，计算最后的发货行为
drop table if exists pdm.outdepot_forecast_12_first;
create temporary table pdm.outdepot_forecast_12_first as
select a.ccuscode
      ,a.item_code
      ,max(a.mon_diff) as mon_diff
  from pdm.outdepot_forecast_12 a
 group by ccuscode,item_code
;

-- 对剩余的数据进行统计，每月发货次数count统计次数
drop table if exists pdm.outdepot_forecast_count;
create temporary table pdm.outdepot_forecast_count as
select a.ccuscode
      ,a.item_code
      ,count(*) as ct
  from pdm.outdepot_forecast_12 a
 group by ccuscode,item_code
;

-- 这里对模型进行修改，发货次数是1，2，3，4保持原有的逻辑
-- 5，6，7，8.9.10.11取前3次的记录
-- 这样对上量的情况就比较明显了
-- 删除多余的数据
update pdm.outdepot_forecast_12 a
 inner join (select * from pdm.outdepot_forecast_count where ct >= 5) b
    on a.ccuscode = b.ccuscode 
   and a.item_code = b.item_code
   set inum_person = 0
 where rownum >= 5
;
delete from pdm.outdepot_forecast_12 where inum_person = 0;

-- 这里重新计算月间隔
-- drop table if exists pdm.outdepot_forecast_122;
-- create temporary table pdm.outdepot_forecast_122 as
-- select a.ccuscode
--       ,a.item_code
--       ,TIMESTAMPDIFF(MONTH,max(a.ddate),min(a.ddate)) as mon_diff
--   from pdm.outdepot_forecast_12 a
--  group by item_code,ccuscode;
-- 
-- update pdm.outdepot_forecast_12 a
--  inner join pdm.outdepot_forecast_122 b
--     on a.ccuscode = b.ccuscode 
--    and a.item_code = b.item_code
--    set a.mon_diff = b.mon_diff
-- ;

-- 这里获取一个最后的时间的标签
drop table if exists pdm.outdepot_forecast_last;
create temporary table pdm.outdepot_forecast_last as
select a.ccuscode
      ,a.item_code
      ,max(a.mon_diff) as mon_diff
      ,inum_person
      ,ddate
  from (select * from pdm.outdepot_forecast_12 order by inum_person) a
 group by ccuscode,item_code
;


-- 得到分析前最终模型表
drop table if exists pdm.outdepot_forecast_fx1;
create table pdm.outdepot_forecast_fx1 as
select a.rownum 
      ,a.ccuscode
      ,a.item_code
      ,c.ddate
      ,a.mon_diff
      ,a.inum_person
      ,b.ct
      ,c.mon_diff as max_mon
  from pdm.outdepot_forecast_12 a
  left join pdm.outdepot_forecast_count b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
  left join pdm.outdepot_forecast_last c
    on a.ccuscode  = c.ccuscode
   and a.item_code = c.item_code
   
;
-- 建立索引
alter table pdm.outdepot_forecast_fx1 add index index_outdepot_forecast_fx1_ccuscode(ccuscode);
alter table pdm.outdepot_forecast_fx1 add index index_outdepot_forecast_fx1_item_code(item_code);

-- 拉伸到一张记录12个月的宽表
drop table if exists pdm.outdepot_forecast_fx;
create table pdm.outdepot_forecast_fx as
select a.ccuscode
      ,a.item_code
      ,b.ddate
      ,b.ct
      ,b.max_mon
      ,ifnull(b.inum_person,0) as mon_1
      ,ifnull(c.inum_person,0) as mon_2
      ,ifnull(d.inum_person,0) as mon_3
      ,ifnull(e.inum_person,0) as mon_4
      ,ifnull(f.inum_person,0) as mon_5
      ,ifnull(g.inum_person,0) as mon_6
      ,ifnull(h.inum_person,0) as mon_7
      ,ifnull(i.inum_person,0) as mon_8
      ,ifnull(j.inum_person,0) as mon_9
      ,ifnull(k.inum_person,0) as mon_10
      ,ifnull(l.inum_person,0) as mon_11
      ,ifnull(m.inum_person,0) as mon_12
  from pdm.outdepot_forecast_1 a
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 0) b
    on a.ccuscode  = b.ccuscode
   and a.item_code = b.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 1) c
    on a.ccuscode  = c.ccuscode
   and a.item_code = c.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 2) d
    on a.ccuscode  = d.ccuscode
   and a.item_code = d.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 3) e
    on a.ccuscode  = e.ccuscode
   and a.item_code = e.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 4) f
    on a.ccuscode  = f.ccuscode
   and a.item_code = f.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 5) g
    on a.ccuscode  = g.ccuscode
   and a.item_code = g.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 6) h
    on a.ccuscode  = h.ccuscode
   and a.item_code = h.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 7) i
    on a.ccuscode  = i.ccuscode
   and a.item_code = i.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 8) j
    on a.ccuscode  = j.ccuscode
   and a.item_code = j.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 9) k
    on a.ccuscode  = k.ccuscode
   and a.item_code = k.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 10) l
    on a.ccuscode  = l.ccuscode
   and a.item_code = l.item_code
  left join (select * from pdm.outdepot_forecast_fx1 where mon_diff = 11) m
    on a.ccuscode  = m.ccuscode
   and a.item_code = m.item_code
;
-- 最后一次发货在18年以前的数据进行删除
-- delete from pdm.outdepot_forecast_fx where ddate < '2018-01-01';

drop table if exists pdm.outdepot_forecast_fx1;

-- 分析一次的不做预测
drop table if exists pdm.yj_outdepot_forecast_lv2_pre;
create temporary table pdm.yj_outdepot_forecast_lv2_pre as
select a.ccuscode
      ,a.item_code
      ,a.ddate
      ,a.mon_1
      ,a.ct
      ,a.max_mon
      ,case when a.ct = 1 then 0
            else round((mon_2 + mon_3 + mon_4 + mon_5 + mon_6 + mon_7 + mon_8 + mon_9 + mon_10 + mon_11 + mon_12) / a.max_mon , 0 ) 
            end as avg_inum_person
--      ,ifnull(round(b.inum_person_ad,0),0) as inum_person_ad -- 检测量暂时不需要
  from pdm.outdepot_forecast_fx a
  left join (select * from (select * from pdm.checklist_fx_pd order by ccuscode,item_code,ym desc) c group by ccuscode,item_code) b
    on a.ccuscode  = b.ccuscode
   and a.item_code = b.item_code
;

-- 计算最大的时间
drop table if exists pdm.yj_outdepot_fx_maxd;
create temporary table pdm.yj_outdepot_fx_maxd as
select finnal_ccuscode as ccuscode
      ,item_code
      ,max(tbilldate) as ddate
  from pdm.yj_outdepot_fx a
-- where (tbilldate < '2019-04-01' and state = 0) or state > 0
 group by finnal_ccuscode,item_code
;

-- 这里是为了得到最后一次项目对应的产品
drop temporary table if exists pdm.outfor_tem15;
create temporary table if not exists pdm.outfor_tem15
select 
  a.ccuscode
  ,a.item_code
  ,a.cinvcode
  ,ifnull(b.inum_unit_person,1) as inum_unit_person
from 
  (
    select 
    finnal_ccuscode as ccuscode
    ,item_code
    ,cinvcode
    ,ddate
    from bidata.ft_21_outdepot 
    where 
    finnal_ccuscode in (select ccuscode from bidata.ft_41_cusitem_occupy group by ccuscode)
    and item_code in (select item_code from bidata.ft_41_cusitem_occupy where equipment = "否" group by item_code)
    -- 预测数据 不取采血卡XS0109
    and item_code != "XS0109"
    and cbustype = "产品类"
    and inum_person > 0 
    order by finnal_ccuscode,item_code,ddate desc
  ) as a 
  left join (select * from edw.map_inventory group by bi_cinvcode) b
    on a.cinvcode = b.bi_cinvcode
  group by a.ccuscode,a.item_code;
alter table pdm.outfor_tem15 add index index_outfor_tem15_ccuscode (ccuscode);
alter table pdm.outfor_tem15 add index index_outfor_tem15_item_code (item_code);

-- 预测下次发货时间和发货量
drop table if exists pdm.yj_outdepot_forecast;
create table pdm.yj_outdepot_forecast as
select  a.ccuscode
      ,a.item_code
      ,a.ddate
      ,a.mon_1
      ,a.ct
      ,a.max_mon
      ,a.avg_inum_person
--      ,a.inum_person_ad
      ,date_add(b.ddate, interval round(a.mon_1/a.avg_inum_person*30) day) as next_ddate
      ,case when round(c.mon_diff / a.ct * a.avg_inum_person / d.inum_unit_person) = 0 then d.inum_unit_person
            when d.inum_unit_person is null then round(c.mon_diff / a.ct * a.avg_inum_person)
            else round(c.mon_diff / a.ct * a.avg_inum_person / d.inum_unit_person) * d.inum_unit_person end as next_inum_person
      ,a.mon_1/a.avg_inum_person as zq_mon
  from pdm.yj_outdepot_forecast_lv2_pre a
  left join pdm.yj_outdepot_fx_maxd b
    on a.ccuscode  = b.ccuscode
   and a.item_code = b.item_code
  left join pdm.outdepot_forecast_12_first c
    on a.ccuscode  = c.ccuscode
   and a.item_code = c.item_code
  left join pdm.outfor_tem15 d
    on a.ccuscode  = d.ccuscode
   and a.item_code = d.item_code
;

-- end 
-- $$
-- delimiter ;

# 删除字段
-- alter table pdm.yj_outdepot_fx DROP COLUMN status;
-- 第一次迭代
-- call pdm.yj_outdepot_forecast_lv2();
insert into pdm.yj_outdepot_fx
select 'yc'
      ,null
      ,a.next_ddate
      ,a.item_code
      ,null
      ,a.next_inum_person
      ,a.ccuscode
      ,null
      ,a.ccuscode
      ,null
      ,'${state}'
      ,avg_inum_person
      ,zq_mon
      ,null
  from pdm.yj_outdepot_forecast a
 where next_ddate is not null
;

-- 第二次迭代
-- call pdm.yj_outdepot_forecast_lv2();
-- insert into pdm.yj_outdepot_fx
-- select 'yc'
--       ,null
--       ,a.next_ddate
--       ,a.item_code
--       ,null
--       ,a.next_inum_person
--       ,a.ccuscode
--       ,null
--       ,a.ccuscode
--       ,null
--       ,2
--       ,avg_inum_person
--       ,zq_mon
--       ,null
--   from pdm.yj_outdepot_forecast_lv2 a
--  where next_ddate is not null
-- ;
-- 
-- -- 第三次迭代
-- call pdm.yj_outdepot_forecast_lv2();
-- insert into pdm.yj_outdepot_fx
-- select 'yc'
--       ,null
--       ,a.next_ddate
--       ,a.item_code
--       ,null
--       ,a.next_inum_person
--       ,a.ccuscode
--       ,null
--       ,a.ccuscode
--       ,null
--       ,3
--       ,avg_inum_person
--       ,zq_mon
--       ,null
--   from pdm.yj_outdepot_forecast_lv2 a
--  where next_ddate is not null
-- ;
-- 
-- -- 第四次迭代
-- call pdm.yj_outdepot_forecast_lv2();
-- insert into pdm.yj_outdepot_fx
-- select 'yc'
--       ,null
--       ,a.next_ddate
--       ,a.item_code
--       ,null
--       ,a.next_inum_person
--       ,a.ccuscode
--       ,null
--       ,a.ccuscode
--       ,null
--       ,4
--       ,avg_inum_person
--       ,zq_mon
--       ,null
--   from pdm.yj_outdepot_forecast_lv2 a
--  where next_ddate is not null
-- ;
-- 
-- -- 第五次迭代
-- call pdm.yj_outdepot_forecast_lv2();
-- insert into pdm.yj_outdepot_fx
-- select 'yc'
--       ,null
--       ,a.next_ddate
--       ,a.item_code
--       ,null
--       ,a.next_inum_person
--       ,a.ccuscode
--       ,null
--       ,a.ccuscode
--       ,null
--       ,5
--       ,avg_inum_person
--       ,zq_mon
--       ,null
--   from pdm.yj_outdepot_forecast_lv2 a
--  where next_ddate is not null
-- ;

-- 更新一下各种名称
update pdm.yj_outdepot_fx a
 inner join edw.map_customer b
    on a.ccuscode = b.bi_cuscode
   set a.ccusname = b.bi_cusname
      ,a.finnal_ccusname = b.bi_cusname
      ,a.province = b.province
 where a.ccusname is null
;

update pdm.yj_outdepot_fx a
 inner join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
   set a.item_name = b.level_three
 where a.item_name is null
;

-- 增加一个字段，打上停用的标签
-- ALTER TABLE pdm.yj_outdepot_fx ADD COLUMN status varchar(50);
update pdm.yj_outdepot_fx a
 inner join (select * from edw.x_cusitem_enddate where cbustype = '产品类' group by item_code,ccuscode) b
    on a.item_code = b.item_code
   and a.ccuscode  = b.ccuscode
   set a.status = '停用'
;
