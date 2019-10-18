-- 全量更新
use edw;

truncate table edw.x_ar_plan;



-- 1. 客户清洗条件 ccusname
insert into edw.x_ar_plan
select
	 a.auto_id
	,a.company
	,a.ccusname
	,a.ccuscode
	,case when b.ccusname is null then "请核查"
	 else b.bi_cuscode end as true_ccuscode 
	,case when b.ccusname is null then "请核查"
	 else b.bi_cusname end as true_ccusname
	,a.cpersonname
	,a.areadirector
	,a.aperiod
	,a.ddate
	,a.class
	,a.amount_plan
	,a.amount_act
from ufdata.x_ar_plan as a
left join 
(select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by  ccusname) as b
on a.ccusname = b.ccusname;





