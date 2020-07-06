-- CREATE TABLE `ar_detail_aging` (
--   `matchid` varchar(60) CHARACTER SET utf8 DEFAULT NULL,
--   `db` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT '来源库',
--   `cdwcode` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT 'u8客户编码',
--   `ddate` longtext CHARACTER SET utf8mb4,
--   `cohr` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT '公司',
--   `ccuscode` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT 'BI客户编码',
--   `ccusname` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT 'BI客户名称',
--   `ar_class` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT '应收类型',
--   `dvouchdate` date DEFAULT NULL COMMENT '单据日期',
--   `balance_closing` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_0_3` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_3_6` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_6_12` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_12_24` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_24_36` decimal(41,4) NOT NULL DEFAULT '0.0000',
--   `date_36` decimal(41,4) NOT NULL DEFAULT '0.0000'
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


set @dt = last_day('${start_dt}');
-- truncate table pdm.ar_detail_aging;
delete from pdm.ar_detail_aging where ddate = last_day('${start_dt}');
insert into pdm.ar_detail_aging
select concat(db,cdwcode,ar_class) as matchid
      ,db
      ,cdwcode
      ,@dt as ddate
      ,cohr 
      ,ccuscode
      ,ccusname
      ,ar_class
			,dvouchdate
      -- 期初余额逻辑, ar_ap = ar , dvouchdate 和 dvouchdate2 都<= 上期月末  减 ar_ap = ap , dvouchdate 和 dvouchdate2 都<= 上期月末
      ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as balance_closing
			 -- 0-30
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 3 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 3 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_0_3
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 3 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 6 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 3 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 6 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_3_6
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 6 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 12 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 6 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 12 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_6_12
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 12 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 24 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 12 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 24 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_12_24
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 24 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 36 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 24 month) < @dt and DATE_ADD(dvouchdate,INTERVAL 36 month) >= @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_24_36
			 ,ifnull(sum(case 
              when ar_ap = 'ar' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 36 month) < @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(idamount,0)
           end),0) 
      - ifnull(sum(case 
              when ar_ap = 'ap' and ifnull(dvouchdate,'1900-01-01') <= @dt and DATE_ADD(dvouchdate,INTERVAL 36 month) < @dt
              and ifnull(dvouchdate2,'1900-01-01') <= @dt
              then ifnull(icamount,0)
           end),0) as date_36
    from pdm.ar_detail
    where db != "UFDATA_666_2018" 
    and ar_class != "健康检测"
    group by db,cdwcode,ar_class
;