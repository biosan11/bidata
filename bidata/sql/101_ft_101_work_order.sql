/*
-- 建表ft_101_work_order
CREATE TABLE `ft_101_work_order` (
  `new_num` varchar(20) COLLATE utf8_bin DEFAULT NULL COMMENT '工单',
  `num_name` longtext COLLATE utf8_bin COMMENT '标题',
  `bi_cuscode` varchar(50) COLLATE utf8_bin DEFAULT NULL COMMENT '客户编码',
  `bi_cusname` varchar(120) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户名称',
  `new_grade` varchar(20) CHARACTER SET utf8 DEFAULT NULL COMMENT '客户等级',
  `bi_cinvcode` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '产品编号',
  `bi_cinvname` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '产品名称',
  `new_type_3` varchar(60) COLLATE utf8_bin DEFAULT NULL COMMENT '服务内容',
  `new_macover` varchar(2) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '是否在保（维保状态）',
  `problem_happen_time` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '问题发生时间',
  `modifiedon` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '录单时间',
  `assign_time` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '派单时间',
  `acctime` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '接单时间',
  `assign_record_time` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '上门时间',
  `resolution_time` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '解决时间',
  `return_visit_time` varchar(29) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '回访时间',
  `opinion` text COLLATE utf8_bin COMMENT '改进意见或建议',
  `actual_problem_description` text COLLATE utf8_bin COMMENT '实际问题描述',
  `assign_superior` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '上次操作人',
  `ownerid` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '负责人',
  `business_nuit` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '业务部门',
  `title` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '岗位',
  `working` varchar(124) COLLATE utf8_bin DEFAULT NULL COMMENT '预估耗时',
  `estimate_difficulty` varchar(121) COLLATE utf8_bin DEFAULT NULL COMMENT '预估难度',
  `perform_engineer` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '姓名（派单至该工程师）',
  `new_skill` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '技能水平',
  `new_service_hours` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '服务工时',
  `new_satisfied` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '总体满意度',
  `superior_comment` varchar(121) COLLATE utf8_bin DEFAULT NULL COMMENT '主管评价',
  `new_technology_comment` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '技术指导岗评价',
  `new_manager_comment` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '部门经理评价',
  `return_visit` varchar(2) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '是否回访',
  `return_visit_user` varchar(60) CHARACTER SET utf8 DEFAULT NULL COMMENT '回访人',
  `new_ifclose` varchar(2) CHARACTER SET utf8mb4 DEFAULT NULL COMMENT '问题是否解决',
  `new_acknowledgement` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '确认接单',
  `new_troubleshooting` varchar(120) COLLATE utf8_bin DEFAULT NULL COMMENT '是否疑难故障排查',
  `this_repair` varchar(2) CHARACTER SET utf8mb4 DEFAULT NULL,
  `sys_time` datetime DEFAULT NULL COMMENT '系统时间',
  `new_account_equipment` varchar(255) COLLATE utf8_bin DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='crm工单';
*/

-- 清空
TRUNCATE TABLE bidata.ft_101_work_order;
INSERT INTO bidata.ft_101_work_order SELECT
a.new_num,
a.num_name,
ifnull( b.bi_cuscode, "请核查" ),
IFNULL( b.bi_cusname, "请核查" ),
a.new_grade,
a.bi_cinvcode,
a.bi_cinvname,
a.new_type_3,
a.new_macover,
CASE
		WHEN a.problem_happen_time IS NULL THEN
		a.modifiedon 
		WHEN a.problem_happen_time < a.modifiedon THEN
		a.modifiedon ELSE a.problem_happen_time 
	END AS problem_happen_time,
	-- 如果问题发生时间小于录单时间则取录单时间
a.modifiedon,
a.assign_time,
a.acctime,
a.assign_record_time,
a.resolution_time,
a.return_visit_time,
a.opinion,
a.actual_problem_description,
a.assign_superior,
a.ownerid,
a.business_nuit,
a.title,
a.working,
a.estimate_difficulty,
a.perform_engineer,
a.new_skill,
a.new_service_hours,
a.new_satisfied,
a.superior_comment,
a.new_technology_comment,
a.new_manager_comment,
a.return_visit,
a.return_visit_user,
a.new_ifclose,
a.new_acknowledgement,
a.new_troubleshooting,
a.this_repair,
a.sys_time ,
a.new_account_equipment
FROM
	edw.crm_new_work_orders AS a
	LEFT JOIN ( SELECT DISTINCT ccusname, bi_cuscode, bi_cusname FROM edw.dic_customer ) AS b ON a.ccusname = b.ccusname 
WHERE
	IFNULL( a.business_nuit, "" ) NOT IN ( "crmscv", "信息中心" )