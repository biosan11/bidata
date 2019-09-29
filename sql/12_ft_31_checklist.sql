-- 7_ft_31_checklist
/*
-- 建表 bidata.ft_31_checklist
use bidata;
drop table if exists bidata.ft_31_checklist;
create table bidata.ft_31_checklist(
autoid varchar(20) comment '序号,主键',
db varchar(20) comment '来源',
ddate date comment '日期',
ccuscode varchar(20) comment '客户编号',
cinvcode varchar(120) comment '产品编号',
item_code varchar(40) comment '项目编号',
cbustype varchar(60) comment '业务类型',
inum_person int(6) comment '检测量',
recall_num decimal(30,10) comment '召回量',
competitor varchar(10) comment '是否竞争对手',
competitor_name varchar(100) comment '竞争对手名称',
sys_time datetime comment '数据时间戳',
mark_zjxs varchar(20) comment '浙江新筛串联标记',
key bidata_bi_checklist_db (db),
key bidata_bi_checklist_ccuscode (ccuscode),
key bidata_bi_checklist_cinvcode (cinvcode),
key bidata_bi_checklist_item_code (item_code)
) engine=innodb default charset=utf8 comment='bi检测量表';
*/

truncate table bidata.ft_31_checklist;
insert into bidata.ft_31_checklist
select 
	 a.autoid
	,a.db
	,a.ddate
	,a.ccuscode
	,a.cinvcode
	,case 
	when a.item_code is null
		then "其他"
	when left(a.item_code,2)="JK"
		then "其他"
	else a.item_code
	end
	,ifnull(a.cbustype,"产品类")
	,a.inum_person
	,a.recall_num
	,a.competitor
	,a.competitor_name
	,a.sys_time
    ,case 
        when b.province = "浙江省" and a.ccuscode != "ZD3302012" and c.level_two in ("传统新筛","串联新筛")
            then "浙江新筛and串联"
        else "正常"
    end as mark_zjxs
from pdm.checklist as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
left join edw.map_item as c 
on a.item_code = c.item_code 
where inum_person != 0;