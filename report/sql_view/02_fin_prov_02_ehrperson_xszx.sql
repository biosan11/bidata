
create or replace view report.fin_prov_02_ehrperson_xszx as
select 
    month
    ,second_dept
    ,third_dept
    ,substring_index(fourth_dept,"（原）",1) as fourth_dept
    ,case 
        when fifth_dept is null then substring_index(fourth_dept,"（原）",1)
    else fifth_dept
    end as fifth_dept_adjust
    ,case 
        when fifth_dept = "上海区" then "上海市"
        when right(fifth_dept,1) = "区" then substring_index(fifth_dept,"区",1)
        else fifth_dept
    end as province
    ,position_main
    ,case 
        when locate("省区经理",position_main)>0 then "省区经理"
        when locate("实验员",position_main)>0 then "实验员"
        when locate("技术销售主管",position_main)>0 then "技术销售主管"
        when locate("大区总监助理",position_main)>0 then "大区总监助理"
        when locate("区域主管",position_main)>0 then "区域主管"
        else position_main
    end as position_adjust
    ,num_person as num_person_1
from report.fin_21_ehrperson_all 
where second_dept = "营销中心";