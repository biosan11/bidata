truncate table edw.x_account_fy_mon;
insert into edw.x_account_fy_mon
select a.y_mon
      ,a.i_id
      ,a.db
      ,a.cohr
      ,a.dbill_date
      ,a.fashengrq
      ,a.cpersonname
      ,case when a.kehumc <> '' and a.kehumc is not null and b.ccusname is null then '请核查'  else b.bi_cuscode end as cuscode
      ,case when a.kehumc <> '' and a.kehumc is not null and b.ccusname is null then '请核查'  else b.bi_cusname end as cusname
      ,a.kehumc
      ,c.province
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
      ,a.kemu_u8
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
      ,a.state2
  from ufdata.x_account_fy_mon a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.kehumc = b.ccusname
  left join (select * from edw.map_customer group by bi_cuscode) c
    on b.bi_cuscode = c.bi_cuscode
;

