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
,a.ddate
,a.aperiod as aperiod_ori 
-- 提供账期未空, 默认3个月
,case 
    when a.aperiod = "" then 3  
    when a.aperiod is null then 3
    when (a.aperiod REGEXP '[^0-9.]')=1 then 3
    else a.aperiod
    end as aperiod
,case 
    when a.aperiod = "" then "未知"
    when a.aperiod is null then "未知"
    when a.aperiod = "设备" then "设备"
    when (a.aperiod REGEXP '[^0-9.]')=1 then "特殊账期"
    else "常规账期"
 end as mark_aperiod
,a.ar_class
,a.amount_plan
,a.amount_act
from ufdata.x_ar_plan as a
left join 
(select ccusname,bi_cuscode,bi_cusname from edw.dic_customer group by  ccusname) as b
on a.ccusname = b.ccusname;

-- 200520 增加逻辑 对于 mark_aperiod 是 未知的 客户, 终端客户 账期3个月  代理商和个人客户 账期0
update edw.x_ar_plan 
set aperiod = 0 
where mark_aperiod = "未知" and left(true_ccuscode,2) != 'ZD';



