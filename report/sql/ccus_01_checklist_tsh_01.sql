-- 第一段生成出事表
drop table if exists report.checklist_tsh;
CREATE TABLE report.checklist_tsh (
  `ccuscode` varchar(120) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户编号',
  `ccusname` varchar(120) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户名称',
  `ddate` date DEFAULT NULL COMMENT '日期',
  `inum_person` int(6) DEFAULT NULL COMMENT '检测量',
  `item_name` varchar(255) CHARACTER SET utf8 DEFAULT NULL COMMENT '项目名称',
  `date_type` varchar(10) COLLATE utf8_bin DEFAULT NULL COMMENT '数据类型'
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='人口基础数据-tsh处理完的数据';


-- 插入tsh数据
-- truncate table report.checklist_tsh;
insert into report.checklist_tsh
select ccuscode
      ,ccusname
      ,ddate
      ,inum_person
      ,item_name
      ,'tsh原始'
  from pdm.checklist 
 WHERE item_name = 'tsh'
   and competitor = '否'
;

-- 插入17α-OH-P数据到tsh中补空
insert into report.checklist_tsh
SELECT a.ccuscode
      ,a.ccusname
      ,a.ddate
      ,a.inum_person
      ,a.item_name
      ,'17α补充'
FROM
	( SELECT * FROM pdm.checklist WHERE item_name = '17α-OH-P' and competitor = '否') a
	LEFT JOIN report.checklist_tsh b 
	ON a.ccuscode = b.ccuscode
	and a.ddate = b.ddate
where b.ccuscode is null
;

-- 先建立report.checklist_tsh_yc预测完的表
drop table if exists report.checklist_tsh_yc;
CREATE TABLE report.checklist_tsh_yc (
  `ddate` text COLLATE utf8_bin,
  `inum_person` double DEFAULT NULL,
  `ccusname` text COLLATE utf8_bin
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;


