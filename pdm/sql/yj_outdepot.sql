/*
CREATE TABLE `yj_outdepot_fx` (
  `source` varchar(2) CHARACTER SET utf8mb4 NOT NULL DEFAULT '',
  `cohr` varchar(4) CHARACTER SET utf8mb4 DEFAULT NULL,
  `province` varchar(60) COLLATE utf8_bin DEFAULT NULL COMMENT '销售省份',
  `tbilldate` date DEFAULT NULL,
  `cinvcode` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT 'bi_产品编号',
  `cinvname` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT 'bi_产品名称',
  `item_code` varchar(60) COLLATE utf8_bin DEFAULT NULL COMMENT '项目编码',
  `item_name` varchar(60) COLLATE utf8_bin DEFAULT NULL COMMENT '项目名称',
  `equipment` varchar(60) COLLATE utf8_bin DEFAULT NULL COMMENT '是否设备',
  `business_class` varchar(10) COLLATE utf8_bin DEFAULT NULL COMMENT '业务类型',
  `inum_unit_person` decimal(30,10) DEFAULT NULL COMMENT '人份',
  `dqty` decimal(24,6) DEFAULT NULL COMMENT '销售数量',
  `inum_person` decimal(39,0) DEFAULT NULL,
  `ccuscode` varchar(30) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户编号',
  `ccusname` varchar(120) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户名称',
  `finnal_ccuscode` varchar(30) CHARACTER SET utf8 DEFAULT NULL COMMENT '最终客户编号',
  `finnal_ccusname` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '最终客户名称',
  `state` int(1) NOT NULL DEFAULT '0',
  KEY `index_yj_outdepot_fx_ccuscode` (`ccuscode`),
  KEY `index_yj_outdepot_fx_item_code` (`item_code`),
  KEY `index_yj_outdepot_fx_tbilldate` (`tbilldate`),
  KEY `index_yj_outdepot_fx_dqty` (`dqty`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;
*/

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
      ,null as status
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
                   ,'湖北省'
                   ,'上海市')
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
                   ,'湖北省'
                   ,'上海市')
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
      ,null
      ,iquantity
  from pdm.outdepot_order_fx a
  left join (select * from edw.map_inventory group by item_code) b
    on a.item_code = b.item_code
 where a.cohr = '美博特' or a.cohr = '奥博特' or a.item_code = 'CQ0704'
   and a.cbustype = '产品类'
;

-- 修改表字段名称
alter table pdm.yj_outdepot_fx change tbilldate tbilldate date;
alter table pdm.yj_outdepot_fx change status status varchar(20);
alter table pdm.yj_outdepot_fx change avg_inum_person avg_inum_person decimal(10,2);
alter table pdm.yj_outdepot_fx change zq_mon zq_mon decimal(10,2);

-- 删除字段
alter table pdm.yj_outdepot_fx DROP COLUMN dqty;


-- 对历史数据分组聚合一下
drop table if exists pdm.yj_outdepot_fx_jh;
create temporary table pdm.yj_outdepot_fx_jh as select * from pdm.yj_outdepot_fx;

truncate table pdm.yj_outdepot_fx;
insert into pdm.yj_outdepot_fx 
select source
      ,province
      ,tbilldate
      ,item_code
      ,item_name
      ,sum(inum_person) as inum_person
      ,ccuscode
      ,ccusname
      ,finnal_ccuscode
      ,finnal_ccusname
      ,state
      ,avg_inum_person
      ,zq_mon
      ,status
  from pdm.yj_outdepot_fx_jh
 group by item_code,finnal_ccuscode,left(tbilldate,7)
 order by finnal_ccuscode,item_code,left(tbilldate,7)
;

-- 这里新增分组排序来计算月均和发货周期
drop table if exists pdm.yj_outdepot_fx_px;
create table pdm.yj_outdepot_fx_px
SELECT
    @r:= case when @finnal_ccuscode=a.finnal_ccuscode and @item_code = a.item_code then @r+1 else 1 end as rownum,
    @finnal_ccuscode:=a.finnal_ccuscode as finnal_ccuscode,
    @item_code:= a.item_code as item_code,
    @tbilldate:= a.tbilldate as tbilldate,
       a.source
      ,a.province
      ,a.item_name
      ,a.inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccusname
from
    (select * from pdm.yj_outdepot_fx
      group by finnal_ccuscode,item_code,tbilldate
      order by finnal_ccuscode,item_code,tbilldate) a
   ,(select @r:=0 ,@finnal_ccuscode:='',@item_code:='') b
;

CREATE INDEX index_yj_outdepot_fx_px_finnal_ccuscode ON pdm.yj_outdepot_fx_px(finnal_ccuscode);
CREATE INDEX index_yj_outdepot_fx_px_finnal_item_code ON pdm.yj_outdepot_fx_px(item_code);

truncate table pdm.yj_outdepot_fx;
insert into pdm.yj_outdepot_fx 
select a.source
      ,a.province
      ,a.tbilldate
      ,a.item_code
      ,a.item_name
      ,a.inum_person
      ,a.ccuscode
      ,a.ccusname
      ,a.finnal_ccuscode
      ,a.finnal_ccusname
      ,0 as state
      ,case when a.rownum < 3 then 0 else (b.inum_person + c.inum_person ) / (cast(DATEDIFF(a.tbilldate,c.tbilldate)/30 as SIGNED)) end as avg_inum_person
      ,case when a.rownum < 3 then 0 else a.inum_person / ((b.inum_person + c.inum_person ) / (cast(DATEDIFF(a.tbilldate,c.tbilldate)/30 as SIGNED))) end as zq_mon
      ,null
  from pdm.yj_outdepot_fx_px a
  left join pdm.yj_outdepot_fx_px b
    on a.finnal_ccuscode = b.finnal_ccuscode
   and a.item_code = b.item_code
   and a.rownum = b.rownum + 1
  left join pdm.yj_outdepot_fx_px c
    on a.finnal_ccuscode = c.finnal_ccuscode
   and a.item_code = c.item_code
   and a.rownum = c.rownum + 2
;

-- 更新第1，2次没有做月均的数据的补充，用第三次的来处理
update pdm.yj_outdepot_fx a
 inner join (select * from pdm.yj_outdepot_fx where avg_inum_person <> 0 group by finnal_ccuscode,item_code) b
    on a.finnal_ccuscode = b.finnal_ccuscode
   and a.item_code = b.item_code
   set a.avg_inum_person = b.avg_inum_person
      ,a.zq_mon = a.inum_person / b.b.avg_inum_person
 where a.avg_inum_person = 0
;

drop table if exists pdm.yj_outdepot_fx_px;


