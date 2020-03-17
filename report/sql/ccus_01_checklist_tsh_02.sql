
-- 第二段生成预测和修复数据
-- 修复送检医院的数据,数据不包括浙江数据
-- 先插入一个负的到收养客户,收养客户全部存在
insert into report.checklist_tsh_yc
select a.ddate
      ,0 - a.inum_person
      ,finnal_cusname
  from edw.x_ccus_delivery a
 where a.item_name = 'TSH'
   and a.province_get <> '浙江省'
   and a.inum_person <> 0
;

-- 送样地区直接到客户的，直接插入
insert into report.checklist_tsh_yc
select a.ddate
      ,a.inum_person
      ,bi_cusname
  from edw.x_ccus_delivery a
 where a.item_name = 'TSH'
   and a.bi_cuscode <> '请核查'
   and a.province_get <> '浙江省'
   and a.inum_person <> 0
;


-- 送样地区没有到客户的，随机找一下客户插入
drop table if exists report.x_ccus_delivery;
create temporary table report.x_ccus_delivery
select *
  from edw.x_ccus_delivery a
 where a.item_name = 'TSH'
   and a.bi_cuscode = '请核查'
   and a.province_get <> '浙江省'
   and a.inum_person <> 0
;

update report.x_ccus_delivery a
 inner join (select * from edw.map_customer where type <> '代理商' group by city) b
   on a.city_give = b.city
  set a.bi_cuscode = b.bi_cuscode
     ,a.bi_cusname = b.bi_cusname
;

insert into report.checklist_tsh_yc
select a.ddate
      ,a.inum_person
      ,a.bi_cusname
  from report.x_ccus_delivery a
;

