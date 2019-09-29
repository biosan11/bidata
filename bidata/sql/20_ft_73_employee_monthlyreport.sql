-- 27_ft_73_employee_monthlyreport

-- 

truncate table bidata.ft_73_employee_monthlyreport;
insert into bidata.ft_73_employee_monthlyreport
select 
    staffid
    ,date
    ,cast(targetdays +0 as  signed) as targetdays
    ,holidaydays
    ,actualdays
    ,lateduration
    ,latetimes
    ,leaveearlyduration
    ,leaveearlytimes
    ,absenteeismduration
    ,business
    ,annualleave
    ,casualleave
    ,sickleave
    ,marriageleave
    ,adjustleave
    ,maternityleave
    ,bereavementleave
    ,nursingleave
    ,birthseizeleave
    ,paternityleave
    ,collateralleave
    ,workdayovertime
    ,festivalovertime
    ,holidayovertime
from ufdata.ehr_monthly_report
where left(date,4) =2019;