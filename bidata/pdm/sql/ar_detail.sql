
use pdm;

drop temporary table if exists pdm.ft_51_ar_tem;
create temporary table if not exists pdm.ft_51_ar_tem
select a.true_ccuscode,a.class,ifnull(aperiod,90) as aperiod
from 
(select true_ccuscode,class,ddate,aperiod from edw.x_ar_plan 
order by true_ccuscode,class,ddate desc,aperiod
) as a
group by a.true_ccuscode,a.class;

-- 新增临时表 concat（db,cvouchid)
drop temporary table if exists pdm.ar_tem01;
create temporary table if not exists pdm.ar_tem01
select 
    *
    ,concat(db,cvouchid,cdwcode) as matchid
    ,concat(db,ccancelno) as matchid2
from edw.ar_detail
where (idamount != 0 or icamount != 0)
and left(true_ccuscode,2) != "gl";
alter table pdm.ar_tem01 add index index_ar_tem01_matchid (matchid);
alter table pdm.ar_tem01 add index index_ar_tem01_matchid2 (matchid2);

drop temporary table if exists pdm.ar_tem03;
create temporary table if not exists pdm.ar_tem03 
select 
    concat(db,ccancelno) as matchid2
    ,max(dvouchdate) as dvouchdate2
from edw.ar_detail 
group by db,ccancelno;
alter table pdm.ar_tem03 add index index_ar_tem03_matchid2 (matchid2);


-- 导入数据 来源pdm层
drop temporary table if exists pdm.ft_51_ar;
create temporary table if not exists pdm.ft_51_ar as
select
case 
    when a.cvouchtype in ("26","27","r0") then "ar"
    when a.cvouchtype in ("48","49") then "ap"
    else "other"
    end as ar_ap
,case 
    when a.db = 'UFDATA_111_2018' then '博圣' 
    when a.db = 'UFDATA_118_2018' then '卓恩'
    when a.db = 'UFDATA_123_2018' then '恩允'
    when a.db = 'UFDATA_168_2018' then '杭州贝生'
    when a.db = 'UFDATA_168_2019' then '杭州贝生'
    when a.db = 'UFDATA_169_2018' then '云鼎'
    when a.db = 'UFDATA_222_2018' then '宝荣'
    when a.db = 'UFDATA_222_2019' then '宝荣'
    when a.db = 'UFDATA_333_2018' then '宁波贝生'
    when a.db = 'UFDATA_588_2018' then '奥博特'
    when a.db = 'UFDATA_588_2019' then '奥博特'
    when a.db = 'UFDATA_666_2018' then '启代'
    when a.db = 'UFDATA_889_2018' then '美博特'
    when a.db = 'UFDATA_889_2019' then '美博特'
    when a.db = 'UFDATA_555_2018' then '贝安云'
    else '其他'
    end as cohr
,a.db
,a.cvouchtype
,a.cvouchid
,a.dvouchdate
,d.dvouchdate2 as dvouchdate2
,a.dregdate
,a.cdwcode
,a.true_ccuscode
,a.cinvcode
,a.true_cinvcode
,a.ar_class
,a.cdigest
,a.ibvid
,round(a.idamount/1000,4) as idamount
,round(a.icamount/1000,4) as icamount
,a.cprocstyle
,a.ccancelno
,a.ccovouchtype
,a.ccovouchid
,ifnull(b.aperiod,90) as aperiod
,if(b.true_ccuscode is null,0,1) as mark
,a.iVouchAmount_s
,round(a.invoice_amount/1000,4) as invoice_amount
,specification_type
from pdm.ar_tem01 as a 
left join pdm.ft_51_ar_tem as b
on a.true_ccuscode = b.true_ccuscode and a.ar_class = b.class 
left join pdm.ar_tem03 as d
on a.matchid2 = d.matchid2
order by a.db,a.cdwcode,a.dvouchdate,a.ccovouchid;


drop temporary table if exists pdm.ft_51_ar_test_tem;
create temporary table if not exists pdm.ft_51_ar_test_tem
select 
    concat(db,cdwcode,ccovouchid) as matchid
    ,null as c_id 
    ,null as state
    ,case
        when cprocstyle in ("26","27","r0") then "ar"
        when cprocstyle in ("48","49") then "ap"
        else cprocstyle
     end as cprocstyle2
    ,case 
        when ccovouchtype in ("26","27","r0") then "ar"
        when ccovouchtype in ("48","49") then "ap"
        else "other"
     end as ccovouchtype2
    ,a.*
from pdm.ft_51_ar as a;

alter table pdm.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_matchid (matchid);
alter table pdm.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ar_ap (ar_ap);
alter table pdm.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_cprocstyle2 (cprocstyle2);
alter table pdm.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ccovouchtype2 (ccovouchtype2);

--
drop temporary table if exists pdm.ft_51_ar_test_tem01;
create temporary table if not exists pdm.ft_51_ar_test_tem01
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from pdm.ft_51_ar
where ar_ap = "ap"
and ccovouchtype in ("48","49")
group by db,cdwcode,ccovouchid;

alter table pdm.ft_51_ar_test_tem01 add index index_ft_51_ar_test_tem01_matchid (matchid);

--
drop temporary table if exists pdm.ft_51_ar_test_tem02;
create temporary table if not exists pdm.ft_51_ar_test_tem02
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from pdm.ft_51_ar
where ccovouchtype in ("26","27","r0")
group by db,cdwcode,ccovouchid;

alter table pdm.ft_51_ar_test_tem02 add index index_ft_51_ar_test_tem02_matchid (matchid);

-- 
drop table if exists pdm.ft_51_ar_test_pre;
create table if not exists pdm.ft_51_ar_test_pre
select 
    case 
        when a.ar_ap = "ar" then "qu_ar"
        when a.ar_ap = "ap" and a.ccovouchtype2 = "ar" then "qu_ap"
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0 and a.idamount != 0 then "qu"
        else null 
    end as mark_
    ,case 
        when a.ar_ap = "ar" and a.cprocstyle2 = "ar" and a.ccovouchtype2 = "ar" then c.idamount_-c.icamount_ 
        else 0 
    end as balance_ar
    ,case 
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and a.idamount != 0 then b.icamount_ 
        else 0 
    end as balance_ap
    ,a.matchid
    ,a.c_id
    ,a.state
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.specification_type
    ,a.ar_class
    ,a.cdigest
    ,a.idamount
    ,a.icamount
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark
    ,a.invoice_amount
    ,a.iVouchAmount_s
    ,a.ibvid
from pdm.ft_51_ar_test_tem as a
left join pdm.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
left join pdm.ft_51_ar_test_tem02 as c
on a.matchid = c.matchid;

insert into pdm.ft_51_ar_test_pre
select 
    "qu_in" as mark_
    ,0 as balance_ar
    ,b.icamount_ as balance_ap 
    ,a.matchid
    ,a.c_id
    ,a.state
    ,a.cprocstyle2
    ,a.ccovouchtype2
    ,a.ar_ap
    ,a.cohr
    ,a.db
    ,a.cvouchtype
    ,a.cvouchid
    ,a.dvouchdate
    ,a.dvouchdate2
    ,a.dregdate
    ,a.cdwcode
    ,a.true_ccuscode
    ,a.cinvcode
    ,a.true_cinvcode
    ,a.specification_type
    ,a.ar_class
    ,a.cdigest
    ,0 as idamount
    ,0 as icamount
    ,a.cprocstyle
    ,a.ccancelno
    ,a.ccovouchtype
    ,a.ccovouchid
    ,a.aperiod
    ,a.mark
    ,a.invoice_amount
    ,a.iVouchAmount_s
    ,a.ibvid
from pdm.ft_51_ar_test_pre as a 
left join pdm.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
where mark_ is null 
and a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0 and b.idamount_ = 0;

create temporary table pdm.ft_51_ar_test_pre2 as
select a.*
      , @rownum := @rownum +1 AS rownum1
  from (select * from pdm.ft_51_ar_test_pre order by db,cdwcode,dvouchdate) a
 ,(SELECT @rownum := 0) r
;


-- delete from pdm.ft_51_ar_test_pre where mark_ is null;

-- delete from pdm.ft_51_ar_test_pre where mark_ = "qu" and balance_ap = 0;

-- 新增应收、回款单据日期以及回款金额
create temporary table pdm.ft_51_ar_test_pre1 as
select a.*
      , @rownum := @rownum +1 AS rownum1
  from
(select *
  from pdm.ft_51_ar_test_pre a
 where cprocstyle2 = 'ap'
   and ccovouchtype2 = 'ap'
   and ar_ap = 'ap'
 group by cvouchid,db
 order by db,cdwcode,dvouchdate
 ) a,(SELECT @rownum := 0) r
;

alter table pdm.ft_51_ar_test_pre2 add index index_ft_51_ar_test_pre2_cvouchid (cvouchid);
alter table pdm.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_cvouchid (cvouchid);
alter table pdm.ft_51_ar_test_pre2 add index index_ft_51_ar_test_pre2_db (db);
alter table pdm.ft_51_ar_test_pre1 add index index_ft_51_ar_test_pre_db (db);
alter table pdm.ft_51_ar_test_pre2 add index index_ft_51_ar_test_pre2_true_cinvcode (true_cinvcode);

truncate table pdm.ar_detail;
insert into pdm.ar_detail
select a.rownum1
      ,a.mark_
      ,a.balance_ar
      ,a.balance_ap
      ,a.matchid
      ,a.c_id
      ,a.state
      ,a.cprocstyle2
      ,a.ccovouchtype2
      ,a.ar_ap
      ,a.cohr
      ,a.db
      ,a.cvouchtype
      ,a.cvouchid
      ,a.dvouchdate
      ,a.dvouchdate2
      ,a.dregdate
      ,a.cdwcode
      ,a.true_ccuscode
      ,d.finnal_cuscode
      ,d.sales_region
      ,d.province
      ,d.city
      ,a.cinvcode
      ,a.true_cinvcode
      ,c.item_code
      ,a.specification_type
      ,a.ar_class
      ,a.cdigest
      ,a.idamount
      ,a.icamount
      ,case when a.ar_ap = 'ar' then a.dvouchdate else null end
      ,case when a.ar_ap = 'ap' then b.dvouchdate else null end
      ,case when a.ar_ap = 'ar' then a.idamount else 0 end
      ,ifnull(a.balance_ap,0) + ifnull(a.icamount,0)
      ,a.cprocstyle
      ,a.ccancelno
      ,a.ccovouchtype
      ,a.ccovouchid
      ,a.aperiod
      ,a.mark
      ,a.invoice_amount
      ,a.iVouchAmount_s 
      ,a.ibvid
  from pdm.ft_51_ar_test_pre2 a
  left join pdm.ft_51_ar_test_pre1 b
    on a.cvouchid = b.cvouchid
   and a.db = b.db
  left join edw.map_inventory c
    on a.true_cinvcode = c.bi_cinvcode
  left join edw.map_customer d
    on a.true_ccuscode = d.bi_cuscode
;

drop table if exists pdm.ft_51_ar_test_pre;

update pdm.ar_detail a
 inner join pdm.invoice_order b
    on a.ibvid = b.autoid
   set a.finnal_cuscode = b.finnal_ccuscode
      ,a.sales_region = b.sales_region
      ,a.province = b.province
      ,a.city = b.city
 where a.finnal_cuscode = 'multi';


