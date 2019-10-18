-- ----------------------------------程序头部------------------------------------
-- 功能：更新 bidata.cusitem_occupy中的最后三个字段 
-- next_consign_dt_forecast    预测下次发货日期
-- next_inum_person_forecast    预测下次发货人份数1
-- result_mark    风险or其他标记
-- 文件路径：/home/bidata/bidata/sql/14_update_cusitem_occupy.sql
-- 依赖表：
-- bidata.cusitem_occupy
-- bidata.bi_outdepot_forecast_pro
-- 无


-- 增加预测数据
update bidata.ft_41_cusitem_occupy as a
inner join bidata.ft_24_outdepot_forecast_pro as b
on a.ccuscode = b.ccuscode and a.item_code = b.item_code
set 
a.next_consign_dt_forecast = b.next_consign_dt_forecast
,a.next_inum_person_forecast = b.next_inum_person_forecast
,a.delivery_cycle = (case when b.year_consign_num is null then null else  (12/b.year_consign_num) * 30 end)
;

-- 增加result_mark数据

-- 1. 计划占有
update bidata.ft_41_cusitem_occupy
set result_mark = "plan",result_risk = "计划占有"
where result_mark is null
and occupy_status = "计划占有";

-- 1.1 确认停用
update bidata.ft_41_cusitem_occupy
set result_mark = "stop",result_risk = "确认停用"
where result_mark is null
and occupy_status = "停用";


-- 2. 设备
update bidata.ft_41_cusitem_occupy 
set result_mark = "equipment", result_risk = "设备"
where result_mark is null
and equipment = "是";

-- 3. ldt类
update bidata.ft_41_cusitem_occupy 
set result_mark = "ldt" , result_risk = "ldt"
where result_mark is null
and cbustype = "ldt";

-- 4. 无发货日期
update bidata.ft_41_cusitem_occupy
set result_mark = "无发货", result_risk = "核查数据"
where result_mark is null
and first_consign_dt is null;

-- 5. 采血卡
update bidata.ft_41_cusitem_occupy
set result_mark = "采血卡", result_risk = "采血卡待确定"
where result_mark is null
and item_code = "XS0109";

-- 6. 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_发货未开票_1次发货_近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "发货未开票" and next_consign_dt_forecast is null 
and last_consign_dt >= date_add(DATE_ADD(curdate(),interval -day(curdate())+1 day),interval -6 month);

-- 7 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_发货未开票_1次发货_非近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "发货未开票" and next_consign_dt_forecast is null;

update bidata.ft_41_cusitem_occupy 
set result_mark = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '非采血卡_发货未开票_一周内'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '非采血卡_发货未开票_两周内'
                       else '非采血卡_发货未开票_超过两周期' end, 
    result_risk = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '正常'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '需要关注'
                       else '确认是否丢单' end
where result_mark is null
and occupy_class = "发货未开票" and next_consign_dt_forecast is not null;



-- 10
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_赠送_1次发货_近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "赠送" and next_consign_dt_forecast is null
and last_consign_dt >= date_add(DATE_ADD(curdate(),interval -day(curdate())+1 day),interval -6 month)
and first_consign_dt = last_consign_dt;

-- 11 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_赠送_预测问题_近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "赠送" and next_consign_dt_forecast is null
and last_consign_dt >= date_add(DATE_ADD(curdate(),interval -day(curdate())+1 day),interval -6 month);

-- 12
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_赠送_1次发货_非近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "赠送" and next_consign_dt_forecast is null
and first_consign_dt = last_consign_dt;

-- 13 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_赠送_预测问题_非近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "赠送" and next_consign_dt_forecast is null;


update bidata.ft_41_cusitem_occupy 
set result_mark = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '非采血卡_赠送_一周期内'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '非采血卡_赠送_两周期内'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 2 then '非采血卡_赠送_三周期内'
                       else '非采血卡_赠送_超过三周期' end, 
    result_risk = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '正常'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '需要关注'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 2 then '重点关注'
                       else '确认是否丢单' end
where result_mark is null
and occupy_class = "赠送" 
;

-- 19 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_购买_1次发货_近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "购买" 
and next_consign_dt_forecast is null 
and last_consign_dt >= date_add(DATE_ADD(curdate(),interval -day(curdate())+1 day),interval -6 month)
and last_consign_dt = last_consign_dt;

-- 20 
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_购买_预测问题_0-10%", result_risk = "0-10%"
where result_mark is null
and occupy_class = "购买" 
and next_consign_dt_forecast is null 
and last_consign_dt >= date_add(DATE_ADD(curdate(),interval -day(curdate())+1 day),interval -6 month);

-- 21
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_购买_1次发货_非近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "购买" 
and next_consign_dt_forecast is null 
and last_consign_dt = last_consign_dt;

-- 22
update bidata.ft_41_cusitem_occupy set result_mark = "非采血卡_购买_预测问题_非近期", result_risk = "核查数据"
where result_mark is null
and occupy_class = "购买" 
and next_consign_dt_forecast is null ;

update bidata.ft_41_cusitem_occupy 
set result_mark = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '非采血卡_购买_一周期内'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '非采血卡_购买_两周期内'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 2 then '非采血卡_购买_三周期内'
                       else '非采血卡_购买_超过三周期' end, 
    result_risk = case when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) <= 0 then '正常'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 1 then '需要关注'
                       when cast((datediff(curdate(),next_consign_dt_forecast))/delivery_cycle as SIGNED) = 2 then '重点关注'
                       else '确认是否丢单' end
where result_mark is null
and occupy_class = "购买" 
;

