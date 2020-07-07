------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：oa_kaipiaolc_bk.sql
--目标模型：oa_kaipiaolc_bk
--源    表：ufdata.oa_formtable_main_15,ufdata.oa_formtable_main_15_dt1,ufdata.oa_hrmresource
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2020-06-01
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　sh /home/edw/sh/oa_kplc.py 2020-06-01
------------------------------------开始处理逻辑------------------------------------------

-- oa的开票流程数据，目前只提取贝康的数据
truncate table edw.oa_kaipiaolc_bk;
insert into edw.oa_kaipiaolc_bk
select a.id
      ,case when m.currentnodetype = '0' then '发起'
            when m.currentnodetype = '1' then '审核'
            when m.currentnodetype = '2' then '审核'
            when m.currentnodetype = '3' then '归档'
            else '未知' end as lc_state
      ,m.status
      ,a.liuchengbh
      ,c.lastname as name
      ,a.shenqingrq
      ,d.departmentname as dept_name
      ,e.subcompanyname as cohr
      ,g.selectname as kaipiaolb
      ,a.kaipiaozje
      ,a.wendangzt
      ,a.liuchengwd
      ,null
      ,b.kehumcgr
      ,f.bi_cuscode
      ,f.bi_cusname
      ,b.zidingycp
      ,b.danjiahs
      ,b.xiaoji
      ,b.beizhu
  from ufdata.oa_formtable_main_15 a
  left join ufdata.oa_formtable_main_15_dt1 b
    on a.id = b.mainid
  left join ufdata.oa_hrmresource c
    on a.shenqingr = c.id
  left join ufdata.oa_hrmdepartment d
    on a.shenqingrbm = d.id
  left join ufdata.oa_hrmsubcompany e
    on a.kaipiaogs = e.id
  left join (select * from edw.dic_customer group by ccusname) f
    on b.kehumcgr = f.ccusname
  left join (select * from ufdata.oa_workflow_selectitem where fieldid = 7468) g
    on a.kaipiaolb = g.selectvalue	
  left join (select * from ufdata.oa_workflow_requestbase group by requestid) m
	  on a.requestid = m.requestid
 where e.subcompanyname = '北京贝康医学检验所有限公司'
;

-- -- 更新文档对应服务器位置
-- update edw.oa_kaipiaolc_bk a
--  inner join ufdata.oa_docimagefile b
--    on a.liuchengwd = b.docid
--    set a.file_path = REPLACE(b.imagefileid,',',';')
-- -- where status = '6.3归档'
-- ;
-- 
-- update edw.oa_kaipiaolc_bk a
--  inner join ufdata.oa_imagefile b
--    on a.file_path = b.imagefileid
--    set a.file_path = REPLACE(b.filerealpath,',',';')
-- -- where a.baoxiaorq >= '2019-01-01'
-- ;







