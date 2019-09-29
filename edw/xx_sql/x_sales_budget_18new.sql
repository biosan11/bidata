
use edw;
truncate table edw.x_sales_budget_18new;

insert into edw.x_sales_budget_18new
select a.auto_id
      ,a.db
      ,a.ccuscode
      ,a.ccusname
	  ,case when b.bi_cuscode is null then '请核查'
       else b.bi_cuscode end as true_ccus
	  ,case when b.bi_cusname is null then '请核查'
       else b.bi_cusname end as true_ccusname
      ,a.item_code
      ,a.item_name
	  ,case when c.bi_item_code is null then '请核查'
       else c.bi_item_code end as true_item_code
	  ,case when c.bi_item_name is null then '请核查'
       else c.bi_item_name end as true_item_name
      ,a.business_class
      ,a.plan_class
      ,a.key_project
      ,a.ddate
      ,a.inum_budget
      ,a.price
      ,a.isum_budget	  
  from ufdata.x_sales_budget_18new as a
  left join (select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by ccusname) as b
    on a.ccusname = b.ccusname
  left join (select item_name,bi_item_code,bi_item_name from edw.dic_item group by item_name) as c 
    on a.item_name = c.item_name;  
