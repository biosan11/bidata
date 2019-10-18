-- 退货第二层加工

drop table if exists ufdata.oa_formtable_main_6_pre;
create temporary table ufdata.oa_formtable_main_6_pre as
select a.id
      ,a.kehumc
      ,b.selectname
  from ufdata.oa_formtable_main_6 a
  left join (select selectname,selectvalue from ufdata.oa_workflow_selectitem where fieldid = 8985) b
    on a.suozaisf = b.selectvalue;

truncate table edw.oa_outdepot_back;
insert into edw.oa_outdepot_back
select a.id
      ,a.liuchengbh
      ,case when m.currentnodetype = '0' then '发起'
            when m.currentnodetype = '1' then '审核'
            when m.currentnodetype = '2' then '审核'
            when m.currentnodetype = '3' then '归档'
            else '未知' end as lc_state
      ,a.shenqingrq
      ,d.subcompanyname as cohr
      ,e.departmentname as dept_name
      ,f.kehumc as ccusname
      ,case when h.ccusname is null and f.kehumc is not null then '请核查' else h.bi_cuscode end as bi_cuscode
      ,case when h.ccusname is null and f.kehumc is not null then '请核查' else h.bi_cusname end as bi_cusname
      ,c.lastname as person
      ,case when a.tuihuolx = '0' then '破损'
            when a.tuihuolx = '1' then '质量'
            when a.tuihuolx = '2' then '其他'
            else '未知' end as tuihuolx
      ,b.huohao
      ,b.shul
      ,b.tuihuoyy
      ,g.chanpinbh
      ,g.chanpinmc
      ,case when i.cinvname is null and g.chanpinmc is not null then '请核查' else i.bi_cinvcode end as bi_cinvcode
      ,case when i.cinvname is null and g.chanpinmc is not null then '请核查' else i.bi_cinvname end as bi_cinvname
  from ufdata.oa_formtable_main_170 a
  left join ufdata.oa_formtable_main_170_dt1 b
    on a.id = b.mainid
  left join ufdata.oa_hrmresource c
    on a.shenqingr = c.id
  left join ufdata.oa_hrmsubcompany d
    on a.shenqingrgs = d.id
  left join ufdata.oa_hrmdepartment e
    on a.shenqingrbm = e.id
  left join ufdata.oa_formtable_main_6_pre f
    on a.kehumc2 = f.id
  left join ufdata.oa_uf_chanpinku g
    on b.id = g.id
  left join (select * from edw.dic_customer group by ccusname) h
    on f.kehumc = h.ccusname
  left join (select * from edw.dic_inventory group by cinvname) i
    on g.chanpinmc = i.cinvname
	left join (select * from ufdata.oa_workflow_requestbase group by requestid) m
	  on a.requestid = m.requestid
;

