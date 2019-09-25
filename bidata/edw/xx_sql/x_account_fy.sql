
create temporary table edw.dic_deptment_pre as
select a.*
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
   from edw.dic_deptment a
   group by third_dept,fourth_dept,fifth_dept
;

truncate table edw.x_account_fy;
insert into edw.x_account_fy
select 
    a.cohr
    ,a.y_mon
    ,a.dbill_date
    ,a.voucher_id
    ,a.code
    ,a.code_name
    ,a.cdepname
    ,a.cpersonname
    ,substring_index(substring_index(a.cpersonname,"（",1),"(",1) as cpersonname_adjust
    ,a.province
    ,replace(trim(a.kehumc),' ','') as kehumc
    ,a.u8_liuchengbh
    ,a.md
    ,a.code_type
    ,a.code_class
    ,a.codename_lv1
    ,a.fifth_dept
    ,a.fourth_dept
    ,a.third_dept
    ,a.dept_type
    ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cuscode end as bi_cuscode
    ,case when b.ccusname is null and a.kehumc is not null then '请核查' else b.bi_cusname end as bi_cusname
    ,c.cdept_id_ehr
  from ufdata.x_account_fy a
  left join (select * from edw.dic_customer group by ccusname) b
    on replace(trim(a.kehumc),' ','') = b.ccusname
  left join (select * from edw.dic_deptment where source = 'xlsx_2' group by cdept_name) c
    on concat(ifnull(a.dept_type,''),ifnull(a.third_dept,''),ifnull(a.fourth_dept,''),ifnull(a.fifth_dept,'')) = c.cdept_name
;

update edw.x_account_fy
   set bi_cuscode = null,bi_cusname = null
 where kehumc = '-';

update edw.x_account_fy
   set bi_cuscode = null,bi_cusname = null
where replace(kehumc,' ','') = '';
