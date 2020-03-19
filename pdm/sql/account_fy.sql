-- u8科目情况表
create temporary table edw.code as
select distinct ccode,ccode_name
  from ufdata.code
 where (db = 'UFDATA_111_2018' or db = 'UFDATA_222_2019')
   and iyear = "2019" union
select distinct ccode,ccode_name
  from ufdata.code
 where db = 'UFDATA_170_2020'
   and iyear = "2019"
;

insert into edw.code values('640110','人员成本');

-- 取19年以后的科目
create temporary table pdm.accvouch_u8_pre as
select
db
,left(dbill_date,10) as dbill_date
,liuchengbh
,ccode_lv2
,ccode_name_lv2
,cdept_id
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
  and cdept_id is not null
  and md <> 0
;

-- 创建一张中间oa凭证表
-- create temporary table pdm.accvouch_oa_pre
-- select * 
--       ,sum(jine) as jine1
--   from edw.accvouch_oa
--  group by u8dykm,kehumc,liuchengbh;

-- 创建oa共有的情况表
create temporary table pdm.accvouch_oa_pre as
select a.*
  from edw.accvouch_oa a
  left join (select * from pdm.accvouch_u8_pre group by liuchengbh) b
    on a.liuchengbh = b.liuchengbh
 where b.liuchengbh is not null
   and left(a.oa_ccode,2) in ('51','53','64','66')
;

create temporary table pdm.account_fy_pre2 as
select i_id
      ,a.db
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
            when a.db = 'UFDATA_170_2020' then '甄元'
            end as cohr
      ,dbill_date
      ,a.cdept_id
      ,a.cdepname
      ,cpersonname
      ,a.bi_cusname as kehumc
      ,ccode
      ,ccode_name
      ,concat(left(ccode,4),ccode_name) as sub_name
      ,ccode_lv2
      ,ccode_name_lv2
      ,cdepname_lv1
      ,cdepname_lv2
      ,cdepname_lv3
      ,cdepname_lv4
      ,md
      ,voucher_id
      ,a.liuchengbh as u8_liuchengbh
      ,a.sales_region as province
      from pdm.accvouch_u8_pre a
	left join (select * from pdm.accvouch_oa_pre group by liuchengbh) b
	  on a.liuchengbh = b.liuchengbh
 where b.liuchengbh is null ;

-- 这里重新匹配一下的意义在哪里
create temporary table pdm.account_fy_pre3 as
select a.i_id
      ,a.db
      ,a.cohr
      ,a.dbill_date
      ,a.cpersonname
      ,a.kehumc
      ,a.cdept_id
      ,a.cdepname
      ,a.cdepname_lv1
      ,a.cdepname_lv2
      ,a.cdepname_lv3
      ,a.cdepname_lv4
      ,a.voucher_id
      ,a.sub_name as u8dykm
      ,a.ccode as ccode
      ,b.ccode_name as ccode_name
      ,a.ccode_lv2
      ,a.ccode_name_lv2
      ,a.md
      ,a.u8_liuchengbh
      ,a.province
      ,'u8独有' as state
  from pdm.account_fy_pre2 a
  left join (select * from edw.code group by ccode) b
    on a.ccode = b.ccode
;


--      ,case when a.oa_liuchengbh is null then a.ccode else a.oa_ccode end as ccode
--      ,case when a.oa_liuchengbh is null then a.ccode_name else a.oa_ccode_name end as ccode_name

-- update pdm.account_fy_pre3 a
--  inner join edw.accvouch_oa b
--     on a.u8_liuchengbh = b.liuchengbh
--    set a.kehumc = b.kehumc
--       ,a.state = '共有'
--  where a.state = 'u8独有';




-- 先插入u8独有的部分
truncate table pdm.account_fy;
insert into pdm.account_fy
select a.i_id    
      ,a.db             
      ,a.cohr
      ,a.dbill_date
      ,null
      ,a.cpersonname
      ,case when a.kehumc is not null and e.ccusname is null then '请核查'
            when a.kehumc is not null and e.ccusname is not null then e.bi_cuscode
            else null end
      ,case when a.kehumc is not null and e.ccusname is null then '请核查'
            when a.kehumc is not null and e.ccusname is not null then e.bi_cusname
            else null end
      ,a.kehumc
      ,a.province
      ,a.cdepname
      ,c.cdept_id_ehr
      ,c.name_ehr
      ,c.second_dept
      ,c.third_dept
      ,c.fourth_dept
      ,c.fifth_dept
      ,c.sixth_dept
      ,null
      ,null
      ,null
      ,a.voucher_id
      ,null
      ,null
      ,a.u8dykm
      ,a.ccode
      ,a.ccode_name
      ,a.ccode_lv2
      ,a.ccode_name_lv2
--      ,case when a.db <> 'UFDATA_170_2020' and (LENGTH(a.ccode) = 8 or LENGTH(a.ccode) = 10) then b.ccode else a.ccode end as ccode_lv2
--      ,case when a.db <> 'UFDATA_170_2020' and (LENGTH(a.ccode) = 8 or LENGTH(a.ccode) = 10) then b.ccode_name else a.ccode_name end as ccode_name_lv2
      ,a.md
      ,a.u8_liuchengbh
      ,null
      ,'u8独有'
      ,a.cdept_id
      ,'取'
      ,null
  from pdm.account_fy_pre3 a
--  left join (select * from edw.code group by ccode,ccode_name) b
--    on left(a.ccode,6) = b.ccode
  left join (select * from edw.dic_deptment group by cdept_id,db) c
    on a.cdept_id = c.cdept_id
   and left(a.db,10) = left(c.db,10)
	left join (select * from edw.dic_customer group by ccusname) e
	  on a.kehumc = e.ccusname
;

-- 插入oa-u8共有的部分
-- 部门层级话分使用u8的架构来执行
create temporary table pdm.accvouch_u8_pre1 as select * from pdm.accvouch_u8_pre;
CREATE INDEX index_accvouch_u8_pre1_liuchengbh ON pdm.accvouch_u8_pre1(liuchengbh);
CREATE INDEX index_accvouch_u8_pre_liuchengbh ON pdm.accvouch_u8_pre(liuchengbh);
CREATE INDEX index_accvouch_u8_pre_md ON pdm.accvouch_u8_pre(md);

insert into pdm.account_fy
select f.i_id
      ,f.db
      ,case when f.db = 'UFDATA_111_2018' then '博圣' 
            when f.db = 'UFDATA_118_2018' then '卓恩'
            when f.db = 'UFDATA_123_2018' then '恩允'
            when f.db = 'UFDATA_168_2018' then '杭州贝生'
            when f.db = 'UFDATA_168_2019' then '杭州贝生'
            when f.db = 'UFDATA_169_2018' then '云鼎'
            when f.db = 'UFDATA_222_2018' then '宝荣'
            when f.db = 'UFDATA_222_2019' then '宝荣'
            when f.db = 'UFDATA_333_2018' then '宁波贝生'
            when f.db = 'UFDATA_588_2018' then '奥博特'
            when f.db = 'UFDATA_588_2019' then '奥博特'
            when f.db = 'UFDATA_666_2018' then '启代'
            when f.db = 'UFDATA_889_2018' then '美博特'
            when f.db = 'UFDATA_889_2019' then '美博特'
            when f.db = 'UFDATA_555_2018' then '贝安云'
            when f.db = 'UFDATA_170_2020' then '甄元'
            end as cohr
      ,f.dbill_date
      ,a.fashengrq
      ,a.bx_name
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.kehumc
      ,a.province
      ,case when b.liuchengbh is not null then b.cdepname     else f.cdepname      end
      ,case when b.liuchengbh is not null then c.cdept_id_ehr else d.cdept_id_ehr  end
      ,case when b.liuchengbh is not null then c.name_ehr     else d.name_ehr      end
      ,case when b.liuchengbh is not null then c.second_dept  else d.second_dept   end
      ,case when b.liuchengbh is not null then c.third_dept   else d.third_dept    end
      ,case when b.liuchengbh is not null then c.fourth_dept  else d.fourth_dept   end
      ,case when b.liuchengbh is not null then c.fifth_dept   else d.fifth_dept    end
      ,case when b.liuchengbh is not null then c.sixth_dept   else d.sixth_dept    end
      ,a.bx_name
      ,a.bxr_dept_name
      ,a.cd_name
      ,f.voucher_id
      ,a.neibuhylxmc as fylx
      ,a.u8dykm
      ,a.oadykm
      ,a.oa_ccode
      ,a.oa_ccode_name
      ,a.oa_ccode_lv2
      ,a.oa_ccode_name_lv2
      ,a.jine
      ,a.liuchengbh
      ,a.beizhu
      ,case when f.liuchengbh is null then '未知情况' else '共有' end
      ,case when b.liuchengbh is not null then b.cdept_id     else f.cdept_id      end
      ,'取'
      ,a.u8dykm
  from pdm.accvouch_oa_pre a
  left join (select * from pdm.accvouch_u8_pre group by liuchengbh,md) b
    on a.liuchengbh = b.liuchengbh
   and a.jine = b.md
  left join (select * from edw.dic_deptment group by cdept_id,db) c
    on b.cdept_id = c.cdept_id
   and left(b.db,10) = left(c.db,10)
  left join (select * from pdm.accvouch_u8_pre1 group by liuchengbh) f
    on a.liuchengbh = f.liuchengbh
  left join (select * from edw.dic_deptment group by cdept_id,db) d
    on f.cdept_id = d.cdept_id
   and left(f.db,10) = left(d.db,10)
;

-- -- 删除每月的数据
create temporary table pdm.account_fy_mon_del as
select distinct liuchengbh
      ,dbill_date
  from edw.x_account_fy_mon
 where state2 = '2'
;

create temporary table pdm.account_fy_mon_del1 as select * from pdm.account_fy_mon_del;

delete a,b 
  from pdm.account_fy  as a 
  join pdm.account_fy_mon_del as b 
    on a.dbill_date = b.dbill_date
   and a.liuchengbh = b.liuchengbh 
;

-- 插入删除的数据
insert into pdm.account_fy
select a.i_id
      ,a.db
      ,a.cohr
      ,a.dbill_date
      ,a.fashengrq
      ,a.cpersonname
      ,a.ccuscode
      ,a.ccusname
      ,a.kehumc
      ,a.province
      ,a.name_u8
      ,a.name_ehr_id
      ,a.name_ehr
      ,a.second_dept
      ,a.third_dept
      ,a.fourth_dept
      ,a.fifth_dept
      ,a.sixth_dept
      ,a.bx_name
      ,a.bxr_dept_name
      ,a.cd_name
      ,a.voucher_id
      ,a.fylx
      ,kemu_u8
      ,a.kemu
      ,a.code
      ,a.code_name
      ,a.code_lv2
      ,a.code_name_lv2
      ,a.md
      ,a.liuchengbh
      ,a.beizhu
      ,a.state
      ,a.cdept_id
      ,a.status
      ,a.oadykm_xdm
  from edw.x_account_fy_mon a
  left join pdm.account_fy_mon_del1 b
    on a.dbill_date = b.dbill_date
   and a.liuchengbh = b.liuchengbh
 where b.dbill_date is not null
;


update pdm.account_fy
   set fashengrq = null
 where fashengrq = '';

update pdm.account_fy
   set ccuscode = null
 where ccuscode = '';

update pdm.account_fy a
 inner join (select * from ufdata.department where db = 'UFDATA_111_2018' group by cdepcode) b
    on a.cdept_id = b.cdepcode
   set a.name_u8 = cdepname
 where (a.db = 'UFDATA_118_2018'
    or a.db = 'UFDATA_123_2018'
    or a.db = 'UFDATA_588_2019')
   and a.name_u8 is null
;

update pdm.account_fy set kemu = '6602专业机构费',code='66020015',code_name='专业机构费',code_lv2='66020015',code_name_lv2 ='专业机构费' where cohr = '甄元' and kemu = '6601材料'; 
update pdm.account_fy set kemu = '6601会务费',code='660128',code_name='会务费',code_lv2='660128',code_name_lv2 ='会务费' where cohr = '奥博特' and kemu = '6601会务招待'; 
update pdm.account_fy set kemu = '6601会务费',code='660128',code_name='会务费',code_lv2='660128',code_name_lv2 ='会务费' where cohr = '美博特' and kemu = '6601会务招待'; 
update pdm.account_fy set kemu = '6601会务费',code='660128',code_name='会务费',code_lv2='660128',code_name_lv2 ='会务费' where cohr = '博圣' and kemu = '6601会务招待'; 
update pdm.account_fy set kemu = '6601会务费',code='660128',code_name='会务费',code_lv2='660128',code_name_lv2 ='会务费' where cohr = '博圣' and kemu = '6602会务招待'; 
update pdm.account_fy set kemu = '6601人员成本',code='6601010104',code_name='交通补贴',code_lv2='660101',code_name_lv2 ='人员成本' where cohr = '博圣' and kemu = '6601交通补贴'; 
update pdm.account_fy set kemu = '6601人员成本',code='6601010104',code_name='交通补贴',code_lv2='660101',code_name_lv2 ='人员成本' where cohr = '美博特' and kemu = '6601交通补贴'; 
update pdm.account_fy set kemu = '6602内部会议费',code='660204',code_name='内部会议费',code_lv2='660204',code_name_lv2 ='内部会议费' where cohr = '甄元' and kemu = '6602内部会议费'; 
update pdm.account_fy set kemu = '6602专业机构费',code='66020015',code_name='专业机构费',code_lv2='66020015',code_name_lv2 ='专业机构费' where cohr = '甄元' and kemu = '6602外部服务费'; 
update pdm.account_fy set kemu = '6403印花税',code='640305',code_name='印花税',code_lv2='640305',code_name_lv2 ='印花税' where cohr = '恩允' and kemu = '6602印花税'; 
update pdm.account_fy set kemu = '6403印花税',code='640305',code_name='印花税',code_lv2='640305',code_name_lv2 ='印花税' where cohr = '奥博特' and kemu = '6602印花税'; 
update pdm.account_fy set kemu = '6403印花税',code='640305',code_name='印花税',code_lv2='640305',code_name_lv2 ='印花税' where cohr = '贝安云' and kemu = '6602印花税'; 
update pdm.account_fy set kemu = '6601会务费',code='660128',code_name='会务费',code_lv2='660128',code_name_lv2 ='会务费' where cohr = '美博特' and kemu = '6601院内沙龙'; 
update pdm.account_fy set kemu = '6601耗材及配件',code='660118',code_name='耗材及配件',code_lv2='660118',code_name_lv2 ='耗材及配件' where cohr = '甄元' and kemu = '6601运营费用'; 

-- 修正发生日期明显错误的数据
update pdm.account_fy set fashengrq = '2019-04-23' where fashengrq = '0019-04-23' and dbill_date = '2019-10-21';
update pdm.account_fy set fashengrq = '2019-06-26' where fashengrq = '2017-06-26' and dbill_date = '2019-08-27';
update pdm.account_fy set fashengrq = '2019-09-04' where fashengrq = '6019-09-04' and dbill_date = '2019-09-24';
update pdm.account_fy set fashengrq = '2019-09-21' where fashengrq = '2020-09-21' and dbill_date = '2019-10-14';
update pdm.account_fy set fashengrq = '2019-09-17' where fashengrq = '0019-09-17' and dbill_date = '2019-10-10';

-- 更新cpersonname 报销人是有人的但是承担人是没有人的 u8独有的数据
update pdm.account_fy 
   set cd_name = cpersonname
 WHERE `cpersonname` IS NOT NULL AND `cd_name` IS NULL
;

-- 彭丽需求。去除名字带括号的括号内的字符
update pdm.account_fy 
   set cd_name = substr(cd_name,1,instr(cd_name,'(')-1)
 where cd_name like '%(%' 
;

update pdm.account_fy 
   set cd_name = substr(cd_name,1,instr(cd_name,'（')-1)
 where cd_name like '%（%' 
;
-- 名字是吴婕 改为 吴沂禧
update pdm.account_fy 
   set cd_name = '吴沂禧'
 where cd_name = '吴婕'
;

-- 插入18年线下费用
insert into pdm.account_fy
select null
      ,null
      ,a.cohr
      ,a.dbill_date
      ,null
      ,a.cpersonname_adjust
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.kehumc
      ,a.province
      ,a.cdepname
      ,a.cdept_id_ehr
      ,b.name_ehr
      ,b.second_dept
      ,b.third_dept
      ,b.fourth_dept
      ,b.fifth_dept
      ,b.sixth_dept
      ,a.cpersonname_adjust
      ,a.cdepname
      ,a.cpersonname_adjust
      ,a.voucher_id
      ,a.code_class
      ,null
      ,concat(left(a.code,4),a.code_name) as kemu
      ,a.code
      ,a.code_name
      ,c.ccode
      ,c.ccode_name
      ,a.md
      ,a.u8_liuchengbh
      ,null
      ,'u8独有'
      ,null
      ,'取'
      ,null
  from edw.x_account_fy a
  left join (select * from edw.dic_deptment group by cdept_id_ehr) b
    on a.cdept_id_ehr = b.cdept_id_ehr
  left join (select * from edw.code group by ccode) c
    on left(a.code,6) = c.ccode
 where a.dbill_date < '2019-01-01'
;



-- 删除费用为0的数据,分析需要先不删除
-- delete from pdm.account_fy where md = 0;



update pdm.account_fy
   set status = '不取'
 where code = '660279';

update pdm.account_fy
   set status = '不取'
 where left(code,4) = '6603';

update pdm.account_fy
   set status = '不取'
 where left(code,4) = '6604';

update pdm.account_fy
   set status = '不取'
 where left(code,6) = '640106';

update pdm.account_fy
   set status = '不取'
 where left(code,4) = '6403';
 
update pdm.account_fy
   set status = '不取'
 where left(code,6) = '510118';

-- 博圣健康的暂时不取
update pdm.account_fy
   set status = '不取'
 where cohr = '博圣健康'
;

-- 调整博圣6月一笔检测量不取
update pdm.account_fy
   set status = '不取'
 where left(code,6) = '530135'
   and md = '1415094.35';


