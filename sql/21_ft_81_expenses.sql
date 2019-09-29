-- 29_ft_81_expenses


/*
-- 建表 bidata.ft_81_expenses
use bidata;
drop table if exists ft_81_expenses;
create table ft_81_expenses(
    i_id int comment '唯一编号',
    db varchar(20) comment 'db',
    cohr varchar(4) comment '公司',
    dbill_date date comment '凭证日期',
    fashengrq date comment '发生日期',
    cpersonname varchar(40) comment '职员名称',
    ccuscode varchar(20) comment '客户编码',
    name_ehr_id varchar(20) comment 'ehr自定义id',
    name_ehr varchar(255) comment 'erh部门名称',
    bx_name varchar(60) comment '报销人',
    voucher_id varchar(60) comment '凭证编码',
    code varchar(40) comment '末级科目编号',
    md float(13,4) comment '金额',
    key bidata_ft_81_expenses_i_id (i_id),
    key bidata_ft_81_expenses_db (db),
    key bidata_ft_81_expenses_name_ehr_id (name_ehr_id),
    key bidata_ft_81_expenses_code (code)
) engine=innodb default charset=utf8 comment='bi实际费用明细表';

drop table if exists bidata.ft_81_expenses_x;
create table bidata.ft_81_expenses_x(
    cohr varchar(20) comment '公司',
    dbill_date date comment '凭证日期',
    voucher_id varchar(60) comment '凭证编码',
    code varchar(40) comment '科目编号',
    cpersonname varchar(40) comment '职员名称',
    md float(13,4) comment '金额',
    bi_cuscode varchar(30) comment '标准编码',
    cdept_id_ehr varchar(20) comment 'ehr部门编号',
    key bidata_ft_81_expenses_x_voucher_id (voucher_id),
    key bidata_ft_81_expenses_x_code (code),
    key bidata_ft_81_expenses_x_cdept_id_ehr (cdept_id_ehr)
) engine=innodb default charset=utf8 comment='bi实际费用明细表_线下';
 */

-- truncate table bidata.ft_81_expenses;
-- insert into bidata.ft_81_expenses values (1,"1","1","2019-1-1","2019-1-1","1","1","1","1","1","1","1",1);

truncate table bidata.ft_81_expenses_x;
insert into bidata.ft_81_expenses_x
select 
    cohr
    ,dbill_date
    ,voucher_id
    ,code
    ,cpersonname_adjust
    ,round(md,4) 
    ,bi_cuscode
    ,cdept_id_ehr
from edw.x_account_fy
;