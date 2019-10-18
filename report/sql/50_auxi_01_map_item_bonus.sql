-- 
truncate table report.auxi_01_map_item_bonus;
insert into report.auxi_01_map_item_bonus
select 
    item_code 
    ,equipment
    ,case 
        when item_key in ("血清学筛查","NIPT","CMA","CNV-seq","MSMS","代谢病诊断") then "是"
        else "否"
        end as item_key_score
from edw.map_item;

-- alter table report.auxi_01_map_item_bonus comment '2019年奖金计算用项目辅助表';
-- alter table report.auxi_01_map_item_bonus add index index_report_auxi_01_map_item_bonus (item_code);