
-- 第三段生成最终数据
-- 运行完成以后插入数据,生成最终数据
drop table if exists report.checklist_tsh_hb;
CREATE TABLE report.checklist_tsh_hb (
  `ccusname` text COLLATE utf8_bin,
  `ddate` date DEFAULT NULL,
  `inum_person_new` int(6) DEFAULT NULL,
  `inum_person_old` int(6) DEFAULT NULL COMMENT '检测量',
  `province` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '省份',
  `city` varchar(255) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

-- truncate table report.checklist_tsh_hb;
insert into report.checklist_tsh_hb
select a.ccusname
      ,a.ddate
			,a.inum_person as inum_person_new
			,b.inum_person as inum_person_old
			,c.province
			,c.city
  from (select ddate,ccusname,SUM(inum_person) as inum_person from report.checklist_tsh_yc group by ccusname,ddate) a
	left join (select ccuscode,ddate,ccusname,SUM(inum_person) as inum_person from report.checklist_tsh group by ccuscode,ddate) b
	  on a.ccusname = b.ccusname
	 and YEAR(a.ddate) = YEAR(b.ddate)
	 and MONTH(a.ddate) = MONTH(b.ddate)
  left join (select * from edw.map_customer group by bi_cusname) c
	  on a.ccusname = c.bi_cusname
;

-- 删除多余的表
drop table if exists report.checklist_tsh;
drop table if exists report.checklist_tsh_yc;
