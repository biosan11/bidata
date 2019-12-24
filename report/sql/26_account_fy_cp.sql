
-- CREATE TABLE `account_fy_finl` (
--   `cpersonname` varchar(40) DEFAULT NULL COMMENT '职员名称',
--   `fashengrq` varchar(10) DEFAULT NULL COMMENT '发生日期',
--   `ccuscode` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '客户编码',
--   `ccusname` varchar(255) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT '客户名称',
--   `md` decimal(41,4) DEFAULT NULL COMMENT '金额',
--   `name_ehr_id` varchar(20) CHARACTER SET utf8 COLLATE utf8_bin DEFAULT NULL COMMENT 'ehr自定义id',
--   `name_ehr` varchar(255) DEFAULT NULL COMMENT 'erh部门名称',
--   `num` bigint(21) DEFAULT '0' COMMENT '当天出差同意客户人数',
--   `s_dt` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '区间开始时间',
--   `e_dt` varchar(10) DEFAULT NULL COMMENT '区间结束时间',
--   `rownum` double DEFAULT NULL COMMENT '当次是当年第几次',
--   `diff_dt` double DEFAULT NULL COMMENT '出差连续天数',
--   `d_num` bigint(44) DEFAULT NULL COMMENT '间隔天数，只有等于1是计算连续的',
--   `ccus_s_dt` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '客户维度区间开始时间',
--   `ccus_e_dt` varchar(10) DEFAULT NULL COMMENT '客户维度区间结束时间',
--   `ccus_rownum` double DEFAULT NULL COMMENT '客户维度当次是当年第几次',
--   `ccus_diff_dt` bigint(67) DEFAULT NULL COMMENT '客户维度出差连续天数',
--   `ccus_d_num` bigint(44) DEFAULT NULL COMMENT '客户维度间隔天数，只有等于1是计算连续的'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

-- 差旅连续出差的天数，公司和个人
set @n = 0;
drop table if exists report.account_fy_fx;
create table report.account_fy_fx as
select (@n := @n + 1) as id
      ,a.*
  from (select cpersonname
             ,fashengrq
             ,ccuscode
             ,ccusname
             ,name_ehr
         from pdm.account_fy
        where cpersonname is not null
          and fashengrq is not null
          and ccuscode is not null
          and code_name_lv2 = '差旅费'
        group by cpersonname,ccuscode,fashengrq,name_ehr
        order by cpersonname,ccuscode,fashengrq,name_ehr
       ) a
;

CREATE INDEX index_account_fy_fx_id ON report.account_fy_fx(id);
CREATE INDEX index_account_fy_fx_cpersonname ON report.account_fy_fx(cpersonname);
CREATE INDEX index_account_fy_fx_ccusname ON report.account_fy_fx(ccusname);


set @n = 0;
-- 计算连续时间先相减获取到时间间隔
drop table if exists report.account_fy_mid1;
create table report.account_fy_mid1 as
select (@n := @n + 1) as id
      ,a.cpersonname
      ,a.ccuscode
      ,a.ccusname
      ,a.name_ehr
      ,a.fashengrq as s_dt
      ,ifnull(b.fashengrq,a.fashengrq) as e_dt
      ,datediff(ifnull(b.fashengrq,a.fashengrq),a.fashengrq) as d_num
  from report.account_fy_fx a
  left join report.account_fy_fx b
    on a.id = b.id - 1
   and a.cpersonname = b.cpersonname
   and a.ccusname = b.ccusname
--   and a.name_ehr = b.name_ehr
-- where b.id is not null
;
update report.account_fy_mid1 set e_dt = s_dt where d_num <> 1;
drop table if exists report.account_fy_mid11;
create temporary table report.account_fy_mid11 as select * from report.account_fy_mid1;
truncate table report.account_fy_mid1;
insert into report.account_fy_mid1 select * from report.account_fy_mid11 group by cpersonname,ccusname,e_dt;

-- delete from report.account_fy_mid1 where id in (select a.id from (select id+1 as id from report.account_fy_mid1 where d_num = 1) a ) and d_num <> 0;

drop table if exists report.account_fy_cp;
create table report.account_fy_cp as
select d.cpersonname
      ,d.rank + 1 as diff_dt
      ,d.d_num
      ,d.ccuscode
      ,d.ccusname
      ,d.name_ehr
      ,d.s_dt
      ,d.e_dt 
      ,year(d.s_dt) as year_
  from (
select c.cpersonname
      ,c.d_num
      ,c.rank
      ,c.ccuscode
      ,c.ccusname
      ,c.name_ehr
      ,c.randt as s_dt
      ,c.e_dt 
  from (SELECT A.id,name_ehr,s_dt,ccuscode,
  -- a.d_num,a.cpersonname,a.ccusname,
         IF(@d_num=A.d_num and @cpersonname=a.cpersonname and @ccusname=a.ccusname and @s_dt = s_dt,@rank:=@rank+1,@rank:=1) AS rank,
         IF(@d_num=A.d_num and @cpersonname=a.cpersonname and @ccusname=a.ccusname and @s_dt = s_dt,@randt:=date_add(e_dt, interval -(@rank) day),@randt:=s_dt) AS randt,
         @s_dt:=date_add(s_dt, interval 1 day) ,
         @e_dt:=A.e_dt as e_dt,
         @d_num:=a.d_num as d_num,
         @cpersonname:=a.cpersonname as cpersonname,
         @ccusname:=a.ccusname as ccusname
         FROM
         (
         SELECT id,d_num,cpersonname,s_dt,e_dt,ccusname,name_ehr,ccuscode FROM report.account_fy_mid1 ORDER BY id ASC
         ) A ,(SELECT @d_num := 1 ,@num:= 1 ,@rank:=1,@randt:='1900-01-01',@cpersonname:=null,@ccusname:=null,@s_dt:=null) B
         ) c
 order by cpersonname,s_dt,rank desc ) d
 group by cpersonname,s_dt,ccusname
;
update report.account_fy_cp set d_num = 0 where d_num > 1;
update report.account_fy_cp set diff_dt = 1 where d_num = 0;

-- 这里新增一个计算当次是当年的第几次
drop table if exists report.account_fy_cp_pre;
create temporary table report.account_fy_cp_pre as
select @r:= case when @cpersonname=a.cpersonname and @ccusname = a.ccusname and @year_ = a.year_ then @r+1 else 1 end as rownum
      ,@cpersonname:=a.cpersonname as cpersonname
      ,a.diff_dt
      ,a.d_num
      ,a.ccuscode
      ,@ccusname:=a.ccusname as ccusname
      ,a.name_ehr
      ,a.s_dt
      ,a.e_dt
			,@year_:=a.year_ as year_
  from (select * from report.account_fy_cp order by cpersonname,ccusname,s_dt) a,(select @r:=0,@cpersonname:='',@ccusname:='',@year_:='') b
;

-- 这里新增一个计算医院维度当次是当年的第几次
drop table if exists report.account_fy_ccus_pre;
create temporary table report.account_fy_ccus_pre as
select @r:= case when  @ccusname = a.ccusname and @year_ = a.year_ then @r+1 else 1 end as rownum
      ,a.diff_dt
      ,a.d_num
      ,a.ccuscode
      ,@ccusname:=a.ccusname as ccusname
      ,a.s_dt
      ,a.e_dt
			,@year_:=a.year_ as year_
  from (select * from report.account_fy_ccus order by ccusname,s_dt) a,(select @r:=0,@ccusname:='',@year_:='') b
;

drop table if exists report.account_fy_mid1;
drop table if exists report.account_fy_fx;

-- 这里是结合明细数据
-- 这里是当天去同一个医院的人数
drop table if exists report.account_fy_mid2;
create temporary table report.account_fy_mid2 as
select count(*) as num
      ,fashengrq
      ,ccuscode
      ,ccusname
  from (select * from pdm.account_fy where cpersonname is not null
                                       and fashengrq is not null
                                       and ccuscode is not null
                                       and code_name_lv2 = '差旅费' 
                                     group by fashengrq,ccuscode,cpersonname) a
 group by ccuscode,fashengrq
 order by ccuscode,fashengrq
;

-- 这里是明细数据结合
drop table if exists report.account_fy_mid3;
create temporary table report.account_fy_mid3 as
select cpersonname
      ,fashengrq
      ,ccuscode
      ,ccusname
      ,sum(md) as md
      ,name_ehr_id
      ,name_ehr
  from pdm.account_fy
 where cpersonname is not null
   and fashengrq is not null
   and ccuscode is not null
   and code_name_lv2 = '差旅费'
 group by fashengrq,ccusname,cpersonname
;

CREATE INDEX index_account_fy_mid3_fashengrq ON report.account_fy_mid3(fashengrq);
CREATE INDEX index_account_fy_mid3_ccusname ON report.account_fy_mid3(ccusname);
CREATE INDEX index_account_fy_mid2_fashengrq ON report.account_fy_mid2(fashengrq);
CREATE INDEX index_account_fy_mid2_ccusname ON report.account_fy_mid2(ccusname);

-- 生成最终情况模型1
drop table if exists report.account_fy_finl_pre;
create temporary table report.account_fy_finl_pre as
select a.cpersonname
      ,a.fashengrq
      ,a.ccuscode
      ,a.ccusname
      ,a.md
      ,a.name_ehr_id
      ,a.name_ehr
      ,b.num
  from report.account_fy_mid3 a
  left join report.account_fy_mid2 b
    on a.fashengrq = b.fashengrq
   and a.ccusname = b.ccusname
;


CREATE INDEX index_account_fy_finl_pre_cpersonname ON report.account_fy_finl_pre(cpersonname);
CREATE INDEX index_account_fy_finl_pre_ccusname ON report.account_fy_finl_pre(ccusname);
CREATE INDEX index_account_fy_finl_pre_fashengrq ON report.account_fy_finl_pre(fashengrq);
CREATE INDEX index_account_fy_cp_pre_ccusname ON report.account_fy_cp_pre(ccusname);
CREATE INDEX index_account_fy_cp_pre_cpersonname ON report.account_fy_cp_pre(cpersonname);
CREATE INDEX index_account_fy_cp_pre_s_dt ON report.account_fy_cp_pre(s_dt);
CREATE INDEX index_account_fy_cp_pre_e_dt ON report.account_fy_cp_pre(e_dt);

-- 生成最终情况模型
drop table if exists report.account_fy_finl_pre1;
create temporary table report.account_fy_finl_pre1 as
select a.cpersonname
      ,a.fashengrq
      ,a.ccuscode
      ,a.ccusname
      ,a.md
      ,a.name_ehr_id
      ,a.name_ehr
      ,a.num
      ,b.s_dt
      ,b.e_dt
      ,b.rownum
      ,b.diff_dt
      ,b.d_num
  from report.account_fy_finl_pre a,report.account_fy_cp_pre b
 where a.ccusname = b.ccusname
   and a.cpersonname = b.cpersonname
   and a.fashengrq >= b.s_dt
   and a.fashengrq <= b.e_dt
 group by a.cpersonname,a.fashengrq,a.ccusname
;

CREATE INDEX index_account_fy_finl_pre1_ccusname ON report.account_fy_finl_pre1(ccusname);
CREATE INDEX index_account_fy_finl_pre1_fashengrq ON report.account_fy_finl_pre1(fashengrq);
CREATE INDEX index_account_fy_ccus_pre_ccusname ON report.account_fy_ccus_pre(ccusname);
CREATE INDEX index_account_fy_ccus_pre_s_dt ON report.account_fy_ccus_pre(s_dt);
CREATE INDEX index_account_fy_ccus_pre_e_dt ON report.account_fy_ccus_pre(e_dt);

truncate table report.account_fy_finl;
insert into report.account_fy_finl
select a.cpersonname 
      ,a.fashengrq
      ,a.ccuscode
      ,a.ccusname
      ,a.md
      ,a.name_ehr_id
      ,a.name_ehr
      ,a.num
      ,a.s_dt
      ,a.e_dt
      ,a.rownum
      ,a.diff_dt
      ,a.d_num
      ,b.s_dt as ccus_s_dt
      ,b.e_dt as ccus_e_dt
      ,b.rownum as ccus_rownum
      ,b.diff_dt as ccus_diff_dt
      ,b.d_num as ccus_d_num
  from report.account_fy_finl_pre1 a,report.account_fy_ccus_pre b
 where a.ccusname = b.ccusname
   and a.fashengrq >= b.s_dt
   and a.fashengrq <= b.e_dt
 group by a.cpersonname,a.fashengrq,a.ccusname
;


