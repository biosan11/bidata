

-- 去增量数据，主表合并字表
-- 直接使用税后的金额
create temporary table edw.accvouch_oa_pre as
SELECT
  a.id,
  a.requestid,
	a.baoxiaorq,
	a.liuchengbh,
	a.baoxiaor,
	a.baoxiaorbm,
	c.cdr as chengdanr,
	a.chengdanrbm,
	a.kaipiaogs,
	a.feiyonglx,
	d.selectname,
	c.fashengrq,
  c.u8km,
  c.kmwb,
	a.neibuhy,
	a.neibuhylx,
	a.pingzhengscrq,
	c.xiangguankh,
	a.baoxiaorgs,
	b.subcompanyname,
	(ifnull(c.jine,0) - ifnull(c.sh,0)) as jine,
	c.shuoming,
	c.beizhu,
	c.sjqy,
	CONCAT(c.shuoming,'-',ifnull(c.beizhu,'')) as new_beizhu
FROM
	ufdata.oa_formtable_main_183 a
	LEFT JOIN ufdata.oa_hrmsubcompany b 
	  ON a.baoxiaorgs = b.id
	left join ufdata.oa_formtable_main_183_dt1 c 
	  on a.id = c.mainid
	left join (select Selectvalue,selectname from ufdata.oa_workflow_SelectItem where fieldid = 6530 group by Selectvalue) d 
	  on a.feiyonglx = d.Selectvalue 
	 and a.feiyonglx !=1 
;


create temporary table ufdata.oa_formtable_main_6_pre as
select a.id
      ,a.kehumc
      ,b.selectname
  from ufdata.oa_formtable_main_6 a
  left join (select selectname,selectvalue from ufdata.oa_workflow_SelectItem where fieldid = 8985) b
    on a.suozaisf = b.selectvalue;

-- 更新关联的oa编码为空的数据
-- update ufdata.oa_formtable_main_6_pre
--    set kmwb = u8dykm
--  where u8dykm is null
--    and baoxiaorq >= '2019-01-01'
-- ;

-- drop table if exists edw.code;
-- create  table edw.code as
-- select ccode,ccode_name
--   from ufdata.code
--  where db = 'UFDATA_111_2018'
--    and iyear = "2019"
-- ;
-- 
-- insert into edw.code values('640110','人员成本');
-- 

CREATE INDEX index_accvouch_oa_pre_chengdanrbm ON edw.accvouch_oa_pre(chengdanrbm);
CREATE INDEX index_accvouch_oa_pre_baoxiaorbm ON edw.accvouch_oa_pre(baoxiaorbm);
CREATE INDEX index_accvouch_oa_pre_baoxiaor ON edw.accvouch_oa_pre(baoxiaor);
CREATE INDEX index_accvouch_oa_pre_chengdanr ON edw.accvouch_oa_pre(chengdanr);
CREATE INDEX index_accvouch_oa_pre_kaipiaogs ON edw.accvouch_oa_pre(kaipiaogs);
CREATE INDEX index_accvouch_oa_pre_feiyonglx ON edw.accvouch_oa_pre(feiyonglx);
CREATE INDEX index_accvouch_oa_pre_requestid ON edw.accvouch_oa_pre(requestid);



truncate table edw.accvouch_oa;
insert into edw.accvouch_oa
select a.id
      ,case when m.currentnodetype = '0' then '发起'
            when m.currentnodetype = '1' then '审核'
            when m.currentnodetype = '2' then '审核'
            when m.currentnodetype = '3' then '归档'
            else '未知' end as lc_state
      ,a.baoxiaorq
      ,a.liuchengbh
      ,a.baoxiaor
      ,c.lastname as bx_name
      ,a.baoxiaorbm
      ,b.departmentname as bxr_dept_name
      ,a.chengdanr
      ,d.lastname as cd_name
      ,a.chengdanrbm
      ,e.departmentname as cdr_dept_name
      ,f.subcompanyname as kaipiaogs
      ,a.subcompanyname
      ,case when f.subcompanyname = '浙江博圣生物技术股份有限公司' then 'UFDATA_111_2018'
            when f.subcompanyname = '杭州贝生医疗器械有限公司' then 'UFDATA_168_2018'
            when f.subcompanyname = '湖北奥博特生物技术有限公司' then 'UFDATA_588_2018'
            when f.subcompanyname = '杭州贝安云科技有限公司' then 'UFDATA_555_2018'
            when f.subcompanyname = '杭州宝荣科技有限公司' then 'UFDATA_222_2018'
            when f.subcompanyname = '杭州启代医疗门诊部有限公司' then 'UFDATA_666_2018'
            when f.subcompanyname = '杭州博圣云鼎冷链物流有限公司' then 'UFDATA_169_2018'
            when f.subcompanyname = '南京卓恩生物技术有限公司' then 'UFDATA_118_2018'
            when f.subcompanyname = '宁波贝生医疗器械有限公司' then 'UFDATA_333_2018'
            when f.subcompanyname = '上海恩允实业有限公司' then 'UFDATA_123_2018'
            else '未知' end as db
      ,a.feiyonglx
      ,a.selectname
      ,a.u8km
      ,g.kemumc
      ,g.u8kemubm
      ,a.kmwb
      ,case when k.oa_code is null then '请核查' else k.u8_code end
      ,case when k.oa_code is null then '请核查' else k.code end
      ,k.code_name
      ,k.code_lv2
      ,k.code_lv2_name
      ,a.fashengrq
      ,a.pingzhengscrq
      ,a.xiangguankh
      ,h.kehumc
      ,case when l.ccusname is not null and h.kehumc is not null then l.bi_cuscode 
            when h.kehumc is null	then null 
            else '请核查' end as bi_cuscode
      ,case when l.ccusname is not null and h.kehumc is not null then l.bi_cusname
            when h.kehumc is null	then null 
            else '请核查' end as bi_cusname
      ,h.selectname
      ,a.neibuhy
      ,i.huiyimc
      ,a.neibuhylx
      ,j.selectname
      ,a.jine
      ,a.shuoming
      ,a.beizhu
      ,a.new_beizhu
      ,localtimestamp()
  from edw.accvouch_oa_pre a
	left join ufdata.oa_hrmdepartment e on a.chengdanrbm = e.id
	left join ufdata.oa_hrmdepartment b on a.baoxiaorbm = b.id
	left join ufdata.oa_hrmresource c on a.baoxiaor = c.id
	left join ufdata.oa_hrmresource d on a.chengdanr = d.id
	left join ufdata.oa_hrmsubcompany f on a.kaipiaogs = f.id
	left join ufdata.oa_uf_u8dykm g on a.u8km = g.id
	left join ufdata.oa_formtable_main_6_pre h on a.xiangguankh = h.id
	left join ufdata.oa_formtable_main_112 i on a.neibuhy = i.id
	left join (select Selectvalue,selectname from ufdata.oa_workflow_SelectItem where fieldid = 6530 group by Selectvalue) j
	  on a.feiyonglx = j.Selectvalue 
	left join edw.dic_code k
	  on a.kmwb = k.oa_code
	left join (select * from edw.dic_customer group by ccusname) l
	  on h.kehumc = l.ccusname
	left join (select * from ufdata.oa_workflow_requestbase group by requestid) m
	  on a.requestid = m.requestid
;
update edw.accvouch_oa a
 inner join edw.dic_code b
   on a.u8dykm = b.oa_code
   set a.oadykm = b.u8_code
      ,a.oa_ccode = b.code
      ,a.oa_ccode_name = b.code_name
      ,a.oa_ccode_lv2 = b.code_lv2
      ,a.oa_ccode_name_lv2 = b.code_lv2_name
 where a.kmwb is null
   and a.baoxiaorq >= '2019-01-01'
;

update edw.accvouch_oa set oadykm = '6601试剂招标经费',oa_ccode = '660131',oa_ccode_name='试剂招标经费',oa_ccode_lv2='660131',oa_ccode_name_lv2='试剂招标经费' where kmwb = '66010032试剂招标经费';

-- drop table if exists edw.code;

-- 删除几条无效数据
delete from edw.accvouch_oa where baoxiaorq = '2019-01-15' and oadykm = '6605人员成本其他';
delete from edw.accvouch_oa where baoxiaorq = '2018-11-27' and oadykm = '6605押金';

-- 更新2个发生日期错误的数据
update edw.accvouch_oa set fashengrq = '2019-07-08' where fashengrq = '1019-07-08';
update edw.accvouch_oa set fashengrq = '2019-07-30' where fashengrq = '1019-07-30';
