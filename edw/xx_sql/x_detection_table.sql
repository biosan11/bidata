
-- 清洗客户产品
use edw;
truncate table edw.x_detection_table;
insert into edw.x_detection_table
select a.autoid
      ,a.db
      ,a.state
      ,a.ddate
      ,a.ccuscode
      ,a.ccusname
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cuscode end
      ,case when b.bi_cuscode is null then '请核查' else b.bi_cusname end
      ,a.cverifier
      ,a.reportperson
      ,a.item_code
      ,a.item_name
      ,case when c.item_code is null then '请核查' else c.item_code end
      ,case when c.item_code is null then '请核查' else c.level_three end
      ,a.business_class
      ,a.feeler_mechanism
      ,a.detection_num
      ,a.competitor_num
      ,a.competitor
      ,a.recall_num
  from ufdata.x_detection_table a
  left join (select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cuscode) b
    on a.ccuscode = b.bi_cuscode
  left join (select item_code,level_three from edw.map_item group by item_code) c
    on a.item_code = c.item_code;
