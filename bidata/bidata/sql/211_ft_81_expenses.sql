
update pdm.account_fy set fashengrq = null where fashengrq = '';
update pdm.account_fy set ccuscode = null where ccuscode = '';
-- 整合线上、下费用的数据，按照客户、账套、时间、凭证、部门等分组排序
truncate table bidata.ft_81_expenses;
insert into bidata.ft_81_expenses
select 
    a.i_id
    ,a.db
    ,a.cohr
    ,a.dbill_date
    ,replace(a.fashengrq,'',null)
    ,a.cpersonname
    ,a.ccuscode
    ,a.name_ehr_id
    ,a.name_ehr
    ,a.bx_name
    ,a.voucher_id
    ,a.code
    ,sum(a.md) as md
    ,case
        when a.cdept_id = "ZJBS080909" then "销售六区市场部" -- 原销售六区市场部费用
        when a.cdept_id = "ZJBS080304" then "销售三区市场部" -- 原销售三区市场部费用
        when a.cdept_id = "ZJBS080410" then "销售四区市场部" -- 原销售四区市场部费用
        when a.cdept_id = "ZJBS080807" then "销售五区市场部" -- 原销售五区市场部费用
        when a.cdept_id = "ZJBS080908" then "销售六区公卫部" -- 原销售六区公卫部费用
        when a.cdept_id = "ZJBS080303" then "销售三区公卫部" -- 原销售三区公卫部费用
        when a.cdept_id = "ZJBS080411" then "销售四区公卫部" -- 原销售四区公卫部费用
        when a.cdept_id = "ZJBS080806" then "销售五区公卫部" -- 原销售五区公卫部费用
        else null 
    end as fy_share_m1
    ,case 
        when a.ccuscode is null then "n"
        when a.ccuscode = "请核查" then "n"
        -- when b.type in ("个人客户","代理商","终端客户") then "y"
        else null 
    end as fy_share_ifccus
  from pdm.account_fy a
 where status = '取'
 group by cohr,dbill_date,cpersonname,ccuscode,name_ehr_id,bx_name,voucher_id,code
;

-- 插入线下18年的数据
insert into bidata.ft_81_expenses
select 
     null
    ,null
    ,a.cohr
    ,a.dbill_date
    ,null
    ,a.cpersonname_adjust
    ,a.bi_cuscode
    ,a.cdept_id_ehr
    ,null
    ,null
    ,a.voucher_id
    ,a.code
    ,a.md
    ,case 
        when a.fourth_dept = "产品推广部" and a.province is not null then concat(a.province,"-市场部")
        when a.fourth_dept = "公卫资源部" and a.province is not null then concat(a.province,"-公卫部")
        when a.fourth_dept = "销售中心" and a.province is not null then concat(a.province,"-销售中心")
        when a.fourth_dept = "学科服务部" and a.province is not null then concat(a.province,"-学科服务部")
        when a.fourth_dept = "营销管理部" and a.province is not null then concat(a.province,"-营销管理部")
        when a.fourth_dept = "营销中心" and a.province is not null then concat(a.province,"-营销中心")
        else null 
    end as fy_share_m1
    ,case 
        when a.bi_cuscode is null then "n"
        when a.bi_cuscode = "请核查" then "n"
        -- when b.type in ("个人客户","代理商","终端客户") then "y"
        else null 
    end as fy_share_ifccus
  from edw.x_account_fy a
 where a.dbill_date < '2019-01-01'
;

update bidata.ft_81_expenses as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
set a.fy_share_ifccus = "y"
where a.fy_share_ifccus is null 
and b.type in ("个人客户","代理商","终端客户");

update bidata.ft_81_expenses as a 
set fy_share_ifccus = "n"
where a.fy_share_ifccus is null;



