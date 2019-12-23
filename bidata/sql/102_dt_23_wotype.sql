-- 创建工单类型档案表
-- CREATE TABLE `dt_23_wotype` (
--   `typeid` varchar(255) COLLATE utf8_bin NOT NULL,
--   `name_three` varchar(255) COLLATE utf8_bin DEFAULT NULL,
--   `name_two` varchar(255) COLLATE utf8_bin DEFAULT NULL,
--   `name_one` varchar(255) COLLATE utf8_bin DEFAULT NULL
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin;

truncate table bidata.dt_23_wotype;
INSERT into bidata.dt_23_wotype
	SELECT
	a.new_work_typeid as typeid,
	a.new_name as name_three,
	b.new_name as name_two,
	c.new_name as name_one
FROM
	(SELECT * from ufdata.crm_new_work_types WHERE new_level=3) as a
	LEFT JOIN 
	(SELECT * from ufdata.crm_new_work_types WHERE new_level=2) as b
	on a._new_superior_value=b.new_work_typeid
	LEFT JOIN
	(SELECT * from ufdata.crm_new_work_types WHERE new_level=1) as c
	on b._new_superior_value=c.new_work_typeid;
