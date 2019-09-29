create temporary table pdm.accvouch_u8_pre as
select
db
,left(dbill_date,10) as dbill_date
,substring(liuchengbh,1, 20) as liuchengbh
,ccode_lv2
,ccode_name_lv2
,cdepname
,cdepname_lv1
,cdepname_lv2
,cdepname_lv3
,cdepname_lv4
,cpersonname
,bi_cusname
,md
,ccode
,ccode_name
,i_id
,voucher_id
,sales_region
from edw.accvouch_u8
where dbill_date >= '2019-01-01'
  and left(ccode,2) in ('51','53','64','66')
  and cdepname_lv1 is not null
;

-- 创建一张中间oa凭证表
create temporary table pdm.accvouch_oa_pre
select * 
      ,sum(jine) as jine1
  from edw.accvouch_oa
 group by u8dykm,kehumc,liuchengbh;


create temporary table pdm.account_fy_pre2 as
select i_id
      ,db
      ,case when a.db = 'UFDATA_111_2018' then '博圣' 
            when a.db = 'UFDATA_118_2018' then '卓恩'
            when a.db = 'UFDATA_123_2018' then '恩允'
            when a.db = 'UFDATA_168_2018' then '杭州贝生'
            when a.db = 'UFDATA_168_2019' then '杭州贝生'
            when a.db = 'UFDATA_169_2018' then '云鼎'
            when a.db = 'UFDATA_222_2018' then '宝荣'
            when a.db = 'UFDATA_222_2019' then '宝荣'
            when a.db = 'UFDATA_333_2018' then '宁波贝生'
            when a.db = 'UFDATA_588_2018' then '奥博特'
            when a.db = 'UFDATA_588_2019' then '奥博特'
            when a.db = 'UFDATA_666_2018' then '启代'
            when a.db = 'UFDATA_889_2018' then '美博特'
            when a.db = 'UFDATA_889_2019' then '美博特'
            when a.db = 'UFDATA_555_2018' then '贝安云'
            end as cohr
      ,dbill_date
      ,b.fashengrq
      ,a.cdepname
      ,cpersonname
      ,case when b.liuchengbh is null then a.bi_cusname else b.kehumc end as kehumc
      ,ccode
      ,ccode_name
      ,concat(left(ccode,4),ccode_name) as sub_name
      ,ccode_lv2
      ,ccode_name_lv2
      ,cdepname_lv1
      ,cdepname_lv2
      ,cdepname_lv3
      ,cdepname_lv4
      ,b.bx_name
      ,b.bxr_dept_name
      ,b.cd_name
      ,b.chengdanrbm
      ,b.subcompanyname
      ,b.u8kemubm
      ,case when b.u8dykm = '6601汽车修理费' then '6601汽车租赁费' 
            when b.u8dykm = '6601会务招待费' then '6601会务招待'
            else b.u8dykm end as u8dykm
      ,md
      ,voucher_id
      ,a.liuchengbh as u8_liuchengbh
      ,b.liuchengbh as oa_liuchengbh
      ,case when b.liuchengbh is null then a.sales_region else b.province end as province
      ,b.beizhu
      from pdm.accvouch_u8_pre a
	left join (select * from pdm.accvouch_oa_pre group by liuchengbh,jine1) b
	  on a.liuchengbh = b.liuchengbh
	 and a.md = b.jine1
 where a.md <> 0;
--   and a.ccode_name_lv2 <> '应交增值税'
--   and a.ccode_name_lv2 <> '短期薪资';

create temporary table pdm.account_fy_pre3 as
select a.i_id
      ,a.db
      ,a.cohr
      ,a.dbill_date
      ,a.fashengrq
      ,a.cpersonname
      ,a.kehumc
      ,a.cdepname
      ,a.cdepname_lv1
      ,a.cdepname_lv2
      ,a.cdepname_lv3
      ,a.cdepname_lv4
      ,a.bx_name
      ,a.bxr_dept_name
      ,a.voucher_id
      ,case when a.oa_liuchengbh is null then a.sub_name else a.u8dykm end as u8dykm
      ,case when a.oa_liuchengbh is null then a.ccode else b.ccode end as ccode
      ,case when a.oa_liuchengbh is null then a.ccode_name else b.ccode_name end as ccode_name
      ,a.md
      ,a.u8_liuchengbh
      ,a.province
      ,a.beizhu
      ,case when a.oa_liuchengbh is null then 'u8独有' else '共有' end as state
  from pdm.account_fy_pre2 a
  left join (select * from ufdata.code group by db,ccode,ccode_name) b
    on a.u8kemubm = b.ccode
   and a.db = b.db
;

truncate table pdm.account_fy;
insert into pdm.account_fy
select a.i_id
      ,a.cohr
      ,a.dbill_date
      ,a.fashengrq
      ,a.cpersonname
      ,a.kehumc
      ,a.cdepname
      ,c.name_ehr
      ,c.name_lv2
      ,c.name_lv3
      ,c.name_lv4
      ,c.name_lv5
      ,a.bx_name
      ,a.bxr_dept_name
      ,a.voucher_id
      ,a.u8dykm
      ,a.ccode
      ,a.ccode_name
      ,case when LENGTH(a.ccode) = 8 or LENGTH(a.ccode) = 10 then b.ccode else a.ccode end as ccode_lv2
      ,case when LENGTH(a.ccode) = 8 or LENGTH(a.ccode) = 10 then b.ccode_name else a.ccode_name end as ccode_name_lv2
      ,a.md
      ,a.u8_liuchengbh
      ,a.province
      ,a.beizhu
      ,a.state
  from pdm.account_fy_pre3 a
  left join (select * from ufdata.code group by ccode) b
    on left(a.ccode,6) = b.ccode
  left join (select * from edw.ehr_deptment group by name_u8) c
    on a.cdepname = c.name_u8
;

-- create table edw.ehr_deptment as
-- select a.oid
--       ,a.name
--       ,a.shortname
--       ,b.name as name_lv1
--       ,c.name as name_lv2
--       ,d.name as name_lv3
--       ,e.name as name_lv4
--       ,f.name as name_lv5
--       ,g.name as name_lv6
--       ,a.status
--   from ufdata.ehr_organization a
--   left join ufdata.ehr_organization b
--     on a.firstlevelorganization = b.oid
--   left join ufdata.ehr_organization c
--     on a.secondlevelorganization = c.oid
--   left join ufdata.ehr_organization d
--     on a.thirdlevelorganization = d.oid
--   left join ufdata.ehr_organization e
--     on a.fourthlevelorganization = e.oid
--   left join ufdata.ehr_organization f
--     on a.fifthlevelorganization = f.oid
--   left join ufdata.ehr_organization g
--     on a.sixthlevelorganization = g.oid
--  where a.stdisdeleted = 'false'
--    and a.isdeleted = 'false'
-- ;