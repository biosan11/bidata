set @n = 0;
drop table if exists jsh.account_fy_fx;
create table jsh.account_fy_fx as
select (@n := @n + 1) as id
      ,a.*
  from (select fashengrq
             ,ccusname
             ,ccuscode
         from pdm.account_fy
        where fashengrq is not null
          and ccuscode is not null
          and code_name_lv2 = '差旅费'
        group by ccuscode,fashengrq
        order by ccuscode,fashengrq
       ) a
;

CREATE INDEX index_account_fy_fx_id ON jsh.account_fy_fx(id);
CREATE INDEX index_account_fy_fx_ccusname ON jsh.account_fy_fx(ccusname);


set @n = 0;
-- 计算连续时间先相减获取到时间间隔
drop table if exists jsh.account_fy_mid1;
create table jsh.account_fy_mid1 as
select (@n := @n + 1) as id
      ,a.ccusname
      ,a.ccuscode
      ,a.fashengrq as s_dt
      ,ifnull(b.fashengrq,a.fashengrq) as e_dt
      ,datediff(ifnull(b.fashengrq,a.fashengrq),a.fashengrq) as d_num
  from jsh.account_fy_fx a
  left join jsh.account_fy_fx b
    on a.id = b.id - 1
   and a.ccusname = b.ccusname
--   and a.name_ehr = b.name_ehr
;

update jsh.account_fy_mid1 set e_dt = s_dt where d_num <> 1;
drop table if exists jsh.account_fy_mid11;
create temporary table jsh.account_fy_mid11 as select * from jsh.account_fy_mid1;
truncate table jsh.account_fy_mid1;
insert into jsh.account_fy_mid1 select * from jsh.account_fy_mid11 group by ccusname,e_dt order by ccusname,s_dt;


drop table if exists jsh.account_fy_ccus;
create table jsh.account_fy_ccus as
select d.rank + 1 as diff_dt
      ,d.d_num
      ,d.ccuscode
      ,d.ccusname
      ,d.s_dt
      ,d.e_dt 
  from (
select c.d_num
      ,c.rank
      ,c.ccusname
      ,c.ccuscode
      ,c.randt as s_dt
      ,c.e_dt 
  from (SELECT A.id,s_dt,ccuscode,
         IF(@d_num=A.d_num  and @ccusname=a.ccusname and @s_dt = s_dt,@rank:=@rank+1,@rank:=1) AS rank,
         IF(@d_num=A.d_num  and @ccusname=a.ccusname and @s_dt = s_dt,@randt:=date_add(e_dt, interval -(@rank) day),@randt:=s_dt) AS randt,
         @s_dt:=date_add(s_dt, interval 1 day) ,
         @e_dt:=A.e_dt as e_dt,
         @d_num:=a.d_num as d_num,
         @ccusname:=a.ccusname as ccusname
         FROM
         (
         SELECT id,d_num,s_dt,e_dt,ccusname,ccuscode FROM jsh.account_fy_mid1 ORDER BY id ASC
         ) A ,(SELECT @d_num := 1 ,@num:= 1 ,@rank:=1,@randt:='1900-01-01',@ccusname:=null,@s_dt:=null) B
         ) c
 order by s_dt,rank desc ) d
 group by s_dt,ccusname
;

update jsh.account_fy_ccus set d_num = 0 where d_num > 1;
update jsh.account_fy_ccus set diff_dt = 1 where d_num = 0;
-- select d.rank as diff_dt
--       ,d.d_num
--       ,d.ccusname
--       ,d.s_dt
--       ,d.e_dt 
--   from (
-- select c.d_num
--       ,c.rank
--       ,c.ccusname
--       ,c.randt as s_dt
--       ,c.e_dt 
--   from (SELECT A.id,A.d_num,ccusname,
--          IF(@num=A.d_num,@rank:=@rank+1,@rank:=1) AS rank,
--          IF(@num=A.d_num,@randt:=date_add(e_dt, interval -(@rank-1) day),@randt:=s_dt) AS randt,
--          @s_dt:=A.s_dt as s_dt,
--          @e_dt:=A.e_dt as e_dt
--          FROM
--          (
--          SELECT id,d_num,s_dt,e_dt,ccusname FROM jsh.account_fy_mid1 ORDER BY id ASC
--          ) A ,(SELECT @num:= 1 ,@rank:=0,@randt:='1900-01-01') B
--          ) c
--  order by s_dt,rank desc ) d
--  group by d.s_dt,d.ccusname
-- ;

-- update jsh.account_fy_ccus set e_dt = null where d_num <> 1;

drop table if exists jsh.account_fy_mid1;
drop table if exists jsh.account_fy_fx;
