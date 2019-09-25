
-- 差旅连续出差的天数，公司和个人
-- CREATE TABLE `nums` (
--   `id` int(11) DEFAULT NULL,
--   `num` int(11) DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8;
-- 
-- SELECT A.id,A.num,
-- IF(@num=A.num,@rank:=@rank+1,@rank:=1) AS rank,
-- @num:=A.num
-- FROM
-- (
-- SELECT id,num FROM nums ORDER BY id ASC
-- ) A ,(SELECT @num:= NULL ,@rank:=0) B
-- ;


-- 先按时间和人员分组排序
set @n = 0;
drop table if exists jsh.account_fy_fx;
create table jsh.account_fy_fx as
select (@n := @n + 1) as id
      ,a.*
  from (select cpersonname
             ,fashengrq
         from pdm.account_fy
        where cpersonname is not null
          and fashengrq is not null
          and code_name_lv2 = '差旅费'
        group by cpersonname,fashengrq
        order by cpersonname,fashengrq
       ) a
;

CREATE INDEX index_account_fy_fx_id ON jsh.account_fy_fx(id);
CREATE INDEX index_account_fy_fx_cpersonname ON jsh.account_fy_fx(cpersonname);


set @n = 0;
-- 计算连续时间先相减获取到时间间隔
drop table if exists jsh.account_fy_mid1;
create table jsh.account_fy_mid1 as
select (@n := @n + 1) as id
      ,a.cpersonname
      ,b.fashengrq as s_dt
      ,a.fashengrq as e_dt
      ,datediff(a.fashengrq,b.fashengrq) as d_num
  from jsh.account_fy_fx a
  left join jsh.account_fy_fx b
    on a.id = b.id + 1
   and a.cpersonname = b.cpersonname
 where b.id is not null
;

drop table if exists jsh.account_fy_date;
create table jsh.account_fy_date as
select d.cpersonname
      ,d.rank + 1 as diff_dt
      ,d.s_dt
      ,d.e_dt 
  from (
select c.cpersonname
      ,c.d_num
      ,c.rank
      ,c.randt as s_dt
      ,c.e_dt 
  from (SELECT A.id,A.d_num,cpersonname,
         IF(@num=A.d_num,@rank:=@rank+1,@rank:=1) AS rank,
         IF(@num=A.d_num,@randt:=date_add(e_dt, interval -@rank day),@randt:=s_dt) AS randt,
         @s_dt:=A.s_dt as s_dt,
         @e_dt:=A.e_dt as e_dt
         FROM
         (
         SELECT id,d_num,cpersonname,s_dt,e_dt FROM jsh.account_fy_mid1 ORDER BY id ASC
         ) A ,(SELECT @num:= 1 ,@rank:=0,@randt:='1900-01-01') B
         ) c
 order by cpersonname,s_dt,rank desc ) d
 group by cpersonname,s_dt
;

drop table if exists jsh.account_fy_mid1;
drop table if exists jsh.account_fy_fx;












