
-- truncate table edw.x_account_insettle;
-- insert into edw.x_account_insettle
-- select a.ccusname
--       ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
--       ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
--       ,c.sales_region
--       ,c.province
--       ,a.year_
--       ,a.type
--       ,a.isum
--   from ufdata.x_account_insettle a
--   left join (select * from edw.dic_customer group by ccusname) b
--     on a.ccusname = b.ccusname
--   left join (select * from edw.map_customer group by bi_cuscode) c
--     on b.bi_cuscode = c.bi_cuscode
-- ;

-- 这里是修改后的逻辑
drop table if exists edw.x_account_insettle_pre;
create temporary table edw.x_account_insettle_pre as
select ccusname
      ,type
      ,s_date
      ,isum
      ,cast(DATEDIFF(e_date,s_date)/30 as SIGNED) + 1 as mon_num
			,case when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 0  then '0'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 1  then '0,1'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 2  then '0,1,2'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 3  then '0,1,2,3'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 4  then '0,1,2,3,4'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 5  then '0,1,2,3,4,5'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 6  then '0,1,2,3,4,5,6'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 7  then '0,1,2,3,4,5,6,7'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 8  then '0,1,2,3,4,5,6,7,8'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 9  then '0,1,2,3,4,5,6,7,8,9'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 10 then '0,1,2,3,4,5,6,7,8,9,10'
			      when cast(DATEDIFF(e_date,s_date)/30 as SIGNED) = 11 then '0,1,2,3,4,5,6,7,8,9,10,11'
			      end as mon_diff
  from ufdata.x_account_insettle
;

-- 分裂
drop table if exists edw.x_account_insettle_pre1;
create temporary table edw.x_account_insettle_pre1 as
select a.ccusname
      ,a.type
      ,a.s_date
      ,a.isum / mon_num as isum
      ,left(DATE_ADD(s_date,INTERVAL substring_index(substring_index(a.mon_diff,',',b.help_topic_id+1),',',-1) MONTH),7) as y_mon
  from edw.x_account_insettle_pre a 
  join mysql.help_topic b
    on b.help_topic_id < (length(a.mon_diff) - length(replace(a.mon_diff,',',''))+1)
 order by ccusname,type,s_date,mon_diff
;

-- 插入数据
truncate table edw.x_account_insettle;
insert into edw.x_account_insettle
select a.ccusname
      ,case when b.ccusname is null then '请核查' else b.bi_cuscode end as bi_cuscode
      ,case when b.ccusname is null then '请核查' else b.bi_cusname end as bi_cusname
      ,c.sales_region
      ,c.province
      ,a.y_mon
      ,a.type
      ,sum(round(a.isum,0))
  from edw.x_account_insettle_pre1 a
  left join (select * from edw.dic_customer group by ccusname) b
    on a.ccusname = b.ccusname
  left join (select * from edw.map_customer group by bi_cuscode) c
    on b.bi_cuscode = c.bi_cuscode
 group by b.bi_cuscode,y_mon,type
;

-- 20年的物流成本: 部门 = 供应链中心 样本流管理部 预算科目(code_name_lv2)) = 汽车费 与 邮运费
-- logistics
insert into edw.x_account_insettle
select a.kehumc
      ,a.bi_cuscode
      ,a.bi_cusname
      ,c.sales_region
      ,c.province
      ,left(a.dbill_date,7) as y_mon
      ,'logistics'
      ,sum(md)
  from edw.x_account_fy a
  left join (select * from edw.map_customer group by bi_cuscode) c
    on a.bi_cuscode = c.bi_cuscode
 where a.dbill_date >= '2020-01-01'
   and ifnull(a.bi_cuscode,'GL') <> 'GL'
   and ifnull(a.bi_cuscode,'GL') <> '请核查'
 group by a.bi_cuscode,y_mon
;