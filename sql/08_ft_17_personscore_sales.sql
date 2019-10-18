-- 27_ft_ft_18_personscore_sales
/*建表
use ufdata;
drop table if exists ufdata.cx_person_position;
create table if not exists ufdata.x_person_position(
    year_ smallint comment '年份',
    quarter_ smallint comment '季度',
    person_name varchar(20) comment '姓名',
    position_name_ad varchar(40) comment '职位_手动维护',
    key x_person_position_person_name (person_name)
)engine=innodb default charset=utf8 comment='季度销售职位手动维护';
*/

-- 声明变量
set @year_ = 2019;

-- 通过 bidata.ft_16_sales_person_post 处理生成 临时表（取这张临时表继续处理）
drop temporary table if exists bidata.bonus_tem00;
create temporary table if not exists bidata.bonus_tem00
select 
    a.p_sales_sup
    ,a.p_sales_spe 
    ,a.ddate
    ,a.ccuscode
    ,a.item_code 
    ,a.equipment
    ,case 
        when b.item_key in("血清学筛查","NIPT","CMA","CNV-seq","MSMS","代谢病诊断") then "是"
        else "否"
     end as if_item_key
     ,isum 
     ,isum_budget 
from bidata.ft_16_sales_person_post as a
left join edw.map_item as b 
on a.item_code = b.item_code
where year(ddate) >= @year_;
alter table bidata.bonus_tem00 add index index_bonus_tem00_p_sales_sup (p_sales_sup);
alter table bidata.bonus_tem00 add index index_bonus_tem00_p_sales_spe (p_sales_spe);
alter table bidata.bonus_tem00 add index index_bonus_tem00_p_equipment (equipment);
alter table bidata.bonus_tem00 add index index_bonus_tem00_p_if_item_key (if_item_key);


-- 用于人员考核得分计算
drop temporary table if exists bidata.bonus_tem01;
create temporary table if not exists bidata.bonus_tem01
select 
    @year_ as year_
    ,"sup" as jobpost
    ,p_sales_sup as person_name
    ,month(ddate) as month_
    ,quarter(ddate) as quarter_
    ,equipment
    ,if_item_key
    ,sum(isum) as isum
    ,sum(isum_budget) as isum_budget 
from bidata.bonus_tem00
group by p_sales_sup,month(ddate),quarter(ddate),equipment,if_item_key;
    
insert into bidata.bonus_tem01
select 
    @year_ as year_
    ,"spe" as jobpost
    ,p_sales_spe as person_name
    ,month(ddate) as month_
    ,quarter(ddate) as quarter_
    ,equipment
    ,if_item_key
    ,sum(isum) as isum
    ,sum(isum_budget) as isum_budget 
from bidata.bonus_tem00
group by p_sales_spe,month(ddate),quarter(ddate),equipment,if_item_key;
    
    
-- 导入正式表 用于计算试剂业务考核分
truncate table bidata.ft_17_personscore_sales;
insert into bidata.ft_17_personscore_sales
select 
    a.year_
    ,a.person_name
    ,a.month_
    ,a.quarter_
    ,a.equipment
    ,a.if_item_key
    ,sum(a.isum) as isum
    ,sum(a.isum_budget) as isum_budget
    ,b.position_name
    ,b.position_main
    ,c.position_name_ad
    ,b.jobpost_name
    ,b.employeestatus
    ,b.lastworkdate
from bidata.bonus_tem01 as a 
left join 
(select 
    name
    ,position_name
    ,substring_index(position_name,"兼",1) as position_main
    ,jobpost_name
    ,employeestatus
    ,lastworkdate 
from pdm.ehr_employee group by name) as b
on a.person_name = b.name
left join ufdata.x_person_position as c 
on a.year_ = c.year_ and a.quarter_ = c.quarter_ and a.person_name = c.person_name
group by a.person_name,a.month_,a.equipment,a.if_item_key;
alter table `bidata`.`ft_17_personscore_sales` comment = 'bi销售人员考核数据（试剂业务考核分）';
