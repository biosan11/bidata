-- 客户项目停用加工逻辑


drop table if exists edw.yj_outdepot_fx;
create temporary table edw.yj_outdepot_fx as 
select 'yj' as source
      ,a.province
      ,left(a.tbilldate,10) as tbilldate
      ,a.item_code
      ,a.item_name
      ,round(a.inum_unit_person * a.dqty,0) as inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,0 as state
      ,null as avg_inum_person
      ,null as zq_mon
      ,dqty
  from pdm.yj_outdepot a where a.item_name in ('PKU'
                    ,'G6PD'
                    ,'AFP/Free hCGβ'
                    ,'UE3'
                    ,'17α-OH-P'
                    ,'串联试剂'
                    ,'TSH'
                    ,'Free hCGβ（早）'
                    ,'PAPP-A'
                    ,'NIPT'
                    ,'地贫试剂'
                    ,'地贫基因'
                    ,'常规核型'
                    ,'CMA'
                    ,'耳聋基因'
                    ,'FISH'
                    ,'BoBs'
                    ,'高分辨核型'
                    ,'G6PD基因'
                    ,'叶酸') 
   and a.province in ('山东省'
                   ,'浙江省'
                   ,'江苏省'
                   ,'安徽省'
                   ,'福建省'
                   ,'湖南省'
                   ,'湖北省')
;

drop table if exists edw.outdepot_order_fx;
create temporary table edw.outdepot_order_fx as select * from pdm.outdepot_order a where a.citemname in ('PKU'
                    ,'G6PD'
                    ,'AFP/Free hCGβ'
                    ,'UE3'
                    ,'17α-OH-P'
                    ,'串联试剂'
                    ,'TSH'
                    ,'Free hCGβ（早）'
                    ,'PAPP-A'
                    ,'NIPT'
                    ,'地贫试剂'
                    ,'地贫基因'
                    ,'常规核型'
                    ,'CMA'
                    ,'耳聋基因'
                    ,'FISH'
                    ,'BoBs'
                    ,'高分辨核型'
                    ,'G6PD基因'
                    ,'叶酸') 
   and a.province in ('山东省'
                   ,'浙江省'
                   ,'江苏省'
                   ,'安徽省'
                   ,'福建省'
                   ,'湖南省'
                   ,'湖北省')
;


CREATE INDEX index_yj_outdepot_fx_ccuscode ON edw.yj_outdepot_fx(ccuscode);
CREATE INDEX index_yj_outdepot_fx_item_code ON edw.yj_outdepot_fx(item_code);
CREATE INDEX index_yj_outdepot_fx_tbilldate ON edw.yj_outdepot_fx(tbilldate);
CREATE INDEX index_yj_outdepot_fx_dqty ON edw.yj_outdepot_fx(dqty);


CREATE INDEX index_outdepot_order_fx_ccuscode ON edw.outdepot_order_fx(ccuscode);
CREATE INDEX index_outdepot_order_fx_item_code ON edw.outdepot_order_fx(item_code);
CREATE INDEX index_outdepot_order_fx_ddate ON edw.outdepot_order_fx(ddate);
CREATE INDEX index_outdepot_order_fx_iquantity ON edw.outdepot_order_fx(iquantity);

-- 代码调整数据
update edw.yj_outdepot_fx a
 inner join edw.outdepot_order_fx b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and left(a.tbilldate,7) = left(b.ddate,7)
   and round(a.dqty,0) = round(b.iquantity,0)
   set a.finnal_ccuscode = b.finnal_ccuscode
      ,a.finnal_ccusname = b.finnal_ccusname
 where a.finnal_ccuscode = 'multi' or left(a.finnal_ccuscode,2) = 'DL'
;

-- 直接按照项目操作
update edw.yj_outdepot_fx a
 inner join edw.outdepot_order_fx b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   set a.finnal_ccuscode = b.finnal_ccuscode
      ,a.finnal_ccusname = b.finnal_ccusname
 where a.finnal_ccuscode = 'multi' or left(a.finnal_ccuscode,2) = 'DL'
;

-- 修改个别记录
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-03' and round(dqty,0) = '5';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2014-10' and round(dqty,0) = '6';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2016-05' and round(dqty,0) = '10';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-03' and round(dqty,0) = '5';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2014-10' and round(dqty,0) = '6';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-01' and round(dqty,0) = '4';
update edw.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-01' and round(dqty,0) = '1';

-- 上东威高的最终客户区分不出来
update edw.yj_outdepot_fx 
   set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院'
 where ccuscode = 'DL3710001'
   and item_name in ('UE3','AFP/Free hCGβ')
;

-- 插入u8数据CMA和美博特奥博特
insert into edw.yj_outdepot_fx
select 'u8'
      ,a.province
      ,left(a.ddate,10)
      ,a.item_code
      ,b.level_three
      ,a.inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,0
      ,null
      ,null
      ,iquantity
  from edw.outdepot_order_fx a
  left join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
 where a.cohr = '美博特' or a.cohr = '奥博特' or a.item_code = 'CQ0704'
   and a.cbustype = '产品类'
;

-- 加工初次末次发货情况
drop table if exists edw.yj_outdepot_fx_pre;
create temporary table edw.yj_outdepot_fx_pre as
select finnal_ccuscode as ccuscode
      ,item_code
      ,min(tbilldate) as first_consign_dt
      ,max(tbilldate) as last_consign_dt
  from edw.yj_outdepot_fx
 group by finnal_ccuscode,item_code
;

-- 新增客户清洗
truncate table edw.x_cusitem_enddate;
insert into edw.x_cusitem_enddate
select d.sales_dept
      ,d.sales_region_new
      ,d.sales_region
      ,a.province
      ,a.city
      ,a.ccuscode
      ,a.ccusname
      ,case when e.ccuscode is null then '请核查' else e.bi_cuscode end as bi_cuscode
      ,case when e.ccuscode is null then '请核查' else e.bi_cusname end as bi_cusname
      ,c.level_one
      ,c.level_two
      ,a.item_code
      ,a.item_name
      ,a.cbustype
      ,b.first_consign_dt
      ,b.last_consign_dt
      ,a.status_class
      ,a.comment
      ,a.end_date
  from ufdata.x_cusitem_enddate a
  left join edw.yj_outdepot_fx_pre b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
  left join (select * from edw.map_inventory group by item_code) c
    on a.item_code = c.item_code
  left join (select * from edw.dic_customer group by ccusname) e
    on a.ccusname = e.ccusname
  left join (select * from edw.map_customer group by bi_cuscode) d
    on e.bi_cuscode = d.bi_cuscode
;