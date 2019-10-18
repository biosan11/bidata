-- 
drop temporary table if exists test.ft_51_ar_test_tem;
create temporary table if not exists test.ft_51_ar_test_tem
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
from bidata.ft_51_ar as a;

alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_matchid (matchid);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ar_ap (ar_ap);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_cprocstyle2 (cprocstyle2);
alter table test.ft_51_ar_test_tem add index index_ft_51_ar_test_tem_ccovouchtype2 (ccovouchtype2);

--
drop temporary table if exists test.ft_51_ar_test_tem01;
create temporary table if not exists test.ft_51_ar_test_tem01
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from bidata.ft_51_ar
where ar_ap = "ap"
and ccovouchtype in ("48","49")
group by db,cdwcode,ccovouchid;

alter table test.ft_51_ar_test_tem01 add index index_ft_51_ar_test_tem01_matchid (matchid);

--
drop temporary table if exists test.ft_51_ar_test_tem02;
create temporary table if not exists test.ft_51_ar_test_tem02
select 
     concat(db,cdwcode,ccovouchid) as matchid
    ,sum(idamount) as idamount_
    ,sum(icamount) as icamount_
from bidata.ft_51_ar
where ccovouchtype in ("26","27","r0")
group by db,cdwcode,ccovouchid;

alter table test.ft_51_ar_test_tem02 add index index_ft_51_ar_test_tem02_matchid (matchid);

-- 
drop table if exists test.ft_51_ar_test;
create table if not exists test.ft_51_ar_test
select 
    case 
        when a.ar_ap = "ar" then "qu_ar"
        when a.ar_ap = "ap" and a.ccovouchtype2 = "ar" then "qu_ap"
        when a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0 then "qu"
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
    ,a.*
from test.ft_51_ar_test_tem as a
left join test.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
left join test.ft_51_ar_test_tem02 as c
on a.matchid = c.matchid;

insert into test.ft_51_ar_test
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
    ,null
    ,null
    ,null
from test.ft_51_ar_test as a 
left join test.ft_51_ar_test_tem01 as b 
on a.matchid = b.matchid
where mark_ is null 
and a.ar_ap = "ap" and a.cprocstyle2 = "ap" and a.ccovouchtype2 = "ap" and b.icamount_ != 0;


delete from test.ft_51_ar_test 
where mark_ is null;

delete from test.ft_51_ar_test  
where mark_ = "qu" and balance_ap = 0;
