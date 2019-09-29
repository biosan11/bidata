drop table if exists pdm.yj_outdepot_pre;
create temporary table pdm.yj_outdepot_pre as
select uguid1
      ,uguid2
      ,case when cohr = '浙江博圣生物技术股份有限公司' then '博圣'
            when cohr = '杭州贝生医疗器械有限公司' then '贝生'
            when cohr = '宁波贝生医疗器械有限公司' then '宁波贝生'
            when cohr = '南京卓恩生物技术有限公司' then '卓恩'
            else '未知' end as cohr
      ,tbilldate
      ,tcrtdate
      ,torderdate
      ,bi_cinvcode as cinvcode
      ,bi_cinvname as cinvname
      ,sproductmodel
      ,sproductstyle
      ,slicnumber
      ,sdefineno
      ,spoductlotno
      ,dqty
      ,dprice
      ,dmoney
      ,bi_cuscode as ccuscode
      ,bi_cusname as ccusname
      ,finnal_cuscode as finnal_ccuscode
      ,finnal_ccusname
      ,tproductdate
      ,teffectdate
      ,'0' as state
  from edw.yj_outdepot
;

-- alter table pdm.yj_outdepot_pre comment '药监发货记录表';


-- 插入历史数据
insert into pdm.yj_outdepot_pre
select null
      ,null
      ,case when cohr = '上海恩允' then '恩允'
            when cohr = '杭州贝生' then '贝生'
            else cohr end as cohr
      ,a.ddate
      ,null
      ,null
      ,a.bi_cinvcode
      ,a.bi_cinvname
      ,null
      ,a.sproductstyle
      ,a.slicnumber
      ,null
      ,a.spoductlotno
      ,a.dqty
      ,a.dprice
      ,a.dmoney
      ,bi_cuscode as ccuscode
      ,bi_cusname as ccusname
      ,finnal_cuscode as finnal_ccuscode
      ,finnal_ccusname
      ,null
      ,a.teffectdate
      ,'0' as state
  from edw.x_yj_outdepot a
 where bi_cuscode <> '请核查'
   and bi_cinvcode <> '请核查'
;

-- 删除关联公司
delete from pdm.yj_outdepot_pre where left(ccuscode,2) = 'GL';



-- 插入数据
truncate table pdm.yj_outdepot;
insert into pdm.yj_outdepot
select a.uguid1
      ,a.uguid2
      ,a.cohr
      ,b.province
      ,a.tbilldate
      ,a.tcrtdate
      ,a.torderdate
      ,a.cinvcode
      ,a.cinvname
      ,c.item_code
      ,c.level_three
      ,c.equipment
      ,c.business_class
      ,c.inum_unit_person
      ,a.sproductmodel
      ,a.sproductstyle
      ,a.slicnumber
      ,a.sdefineno
      ,a.spoductlotno
      ,a.dqty
      ,a.dprice
      ,a.dmoney
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,a.tproductdate
      ,a.teffectdate
      ,a.state
  from pdm.yj_outdepot_pre a
  left join edw.map_customer b
    on a.ccuscode = b.bi_cuscode
  left join edw.map_inventory c
    on a.cinvcode = c.bi_cinvcode
;

drop table if exists pdm.yj_outdepot_fx;
create table pdm.yj_outdepot_fx as 
select 'yj' as source
      ,a.cohr
      ,a.province
      ,left(a.tbilldate,10) as tbilldate
      ,a.cinvcode
      ,a.cinvname
      ,a.item_code
      ,a.item_name
      ,a.equipment
      ,a.business_class
      ,a.inum_unit_person
      ,a.dqty
      ,round(a.inum_unit_person * a.dqty,0) as inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
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

drop table if exists pdm.outdepot_order_fx;
create temporary table pdm.outdepot_order_fx as select * from pdm.outdepot_order a where a.citemname in ('PKU'
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


CREATE INDEX index_yj_outdepot_fx_ccuscode ON pdm.yj_outdepot_fx(ccuscode);
CREATE INDEX index_yj_outdepot_fx_item_code ON pdm.yj_outdepot_fx(item_code);
CREATE INDEX index_yj_outdepot_fx_tbilldate ON pdm.yj_outdepot_fx(tbilldate);
CREATE INDEX index_yj_outdepot_fx_dqty ON pdm.yj_outdepot_fx(dqty);


CREATE INDEX index_outdepot_order_fx_ccuscode ON pdm.outdepot_order_fx(ccuscode);
CREATE INDEX index_outdepot_order_fx_item_code ON pdm.outdepot_order_fx(item_code);
CREATE INDEX index_outdepot_order_fx_ddate ON pdm.outdepot_order_fx(ddate);
CREATE INDEX index_outdepot_order_fx_iquantity ON pdm.outdepot_order_fx(iquantity);

-- 代码调整数据
update pdm.yj_outdepot_fx a
 inner join pdm.outdepot_order_fx b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   and left(a.tbilldate,7) = left(b.ddate,7)
   and round(a.dqty,0) = round(b.iquantity,0)
   set a.finnal_ccuscode = b.finnal_ccuscode
      ,a.finnal_ccusname = b.finnal_ccusname
 where a.finnal_ccuscode = 'multi' or left(a.finnal_ccuscode,2) = 'DL'
;

-- 直接按照项目操作
update pdm.yj_outdepot_fx a
 inner join pdm.outdepot_order_fx b
    on a.ccuscode = b.ccuscode
   and a.item_code = b.item_code
   set a.finnal_ccuscode = b.finnal_ccuscode
      ,a.finnal_ccusname = b.finnal_ccusname
 where a.finnal_ccuscode = 'multi' or left(a.finnal_ccuscode,2) = 'DL'
;

-- 修改个别记录
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-03' and round(dqty,0) = '5';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2014-10' and round(dqty,0) = '6';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2016-05' and round(dqty,0) = '10';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-03' and round(dqty,0) = '5';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2014-10' and round(dqty,0) = '6';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-01' and round(dqty,0) = '4';
update pdm.yj_outdepot_fx set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院' where ccuscode = 'DL3710001' and left(tbilldate,7) = '2015-01' and round(dqty,0) = '1';

-- 上东威高的最终客户区分不出来
update pdm.yj_outdepot_fx 
   set finnal_ccuscode = 'ZD3710001',finnal_ccusname = '荣成市妇幼保健院'
 where ccuscode = 'DL3710001'
   and item_name in ('UE3','AFP/Free hCGβ')
;

-- 插入u8数据CMA和美博特奥博特
insert into pdm.yj_outdepot_fx
select 'u8'
      ,a.cohr
      ,a.province
      ,left(a.ddate,10)
      ,a.cinvcode
      ,a.cinvname
      ,a.item_code
      ,b.level_three
      ,b.equipment
      ,a.cbustype
      ,b.inum_unit_person
      ,a.iquantity
      ,a.inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
  from pdm.outdepot_order_fx a
  left join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
 where a.cohr = '美博特' or a.cohr = '奥博特' or a.item_code = 'CQ0704'
   and a.cbustype = '产品类'
;

-- 修改表字段名称
alter table pdm.yj_outdepot_fx change tbilldate ddate date;

