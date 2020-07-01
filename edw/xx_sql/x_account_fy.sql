

truncate table edw.x_account_fy;
insert into edw.x_account_fy
select a.cohr
      ,a.y_mon
      ,a.voucher_id
      ,a.dbill_date
      ,a.code
      ,null
      ,null
      ,null
      ,null
      ,a.cd_name
      ,replace(trim(a.kehumc),' ','') as kehumc
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cusname end as bi_cusname
      ,a.province
      ,a.city
      ,substring_index(substring_index(a.bx_name,"（",1),"(",1) as bx_name
      ,a.bxr_dept_name
      ,a.u8_liuchengbh
      ,a.md
      ,a.cdr_dept_name
      ,c.cdept_id_ehr
      ,c.name_ehr
      ,c.second_dept
      ,c.third_dept
      ,c.fourth_dept
      ,c.fifth_dept
      ,c.sixth_dept
      ,a.kemu
      ,a.code_class
  from ufdata.x_account_fy a
  left join (select * from edw.dic_customer group by ccusname) b
    on replace(trim(a.kehumc),' ','') = b.ccusname
  left join (select * from edw.dic_deptment where source = 'xlsx' group by cdept_name) c
    on a.cdr_dept_name = c.cdept_name
;

update edw.x_account_fy
   set bi_cuscode = null,bi_cusname = null
 where kehumc = '-';

update edw.x_account_fy
   set bi_cuscode = null,bi_cusname = null
where replace(kehumc,' ','') = '';

-- 处理甄元对应的科目层级混乱的现象
update edw.x_account_fy
   set code_old = concat(left(code_old,4),SUBSTRING(code_old,7))
 where cohr = '甄元'
   and SUBSTRING(code_old,5,2) = '00'
;

-- 先处理能处理的科目
update  edw.x_account_fy a
 inner join (select * from ufdata.code group by ccode) b
    on a.code_old = b.ccode
   set a.code = b.ccode
      ,a.code_name = b.ccode_name
 where b.ccode is not null
;

update  edw.x_account_fy a
 inner join (select * from ufdata.code group by ccode) b
    on left(a.code_old,6) = b.ccode
   set a.code_lv2 = b.ccode
      ,a.code_name_lv2 = b.ccode_name
 where b.ccode is not null
;

update edw.x_account_fy a
   set a.code = a.code_lv2
      ,a.code_name = a.code_name_lv2
 where a.code is null
;

update edw.x_account_fy a
   set a.code_class = '人员成本'
 where a.code_class = '人力成本'
;


