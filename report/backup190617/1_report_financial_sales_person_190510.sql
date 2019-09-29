
-- 获取主管数据
drop table if exists report.financial_sales_person;
create table if not exists report.financial_sales_person
select 
    "sup" as jobpost
    ,mark
    ,post
    ,p_sales_sup as person_name
    ,ddate
    ,ccuscode
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itaxunitprice
    ,isum
    ,inum_budget
    ,isum_budget
from bidata.ft_16_sales_person_post;
-- 获取员工级数据
insert into report.financial_sales_person
select 
    "spe" as jobpost
    ,mark
    ,post
    ,p_sales_spe as person_name
    ,ddate
    ,ccuscode
    ,item_code
    ,cinvcode
    ,equipment
    ,screen_class
    ,cbustype
    ,itaxunitprice
    ,isum
    ,inum_budget
    ,isum_budget
from bidata.ft_16_sales_person_post;


