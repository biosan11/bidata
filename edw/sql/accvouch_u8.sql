------------------------------------程序头部----------------------------------------------
--功能：整合层订单
------------------------------------------------------------------------------------------
--程序名称：accvouch_u8.sql
--目标模型：accvouch_u8
--源    表：ufdata.gl_accvouch,ufdata.code,ufdata.department,ufdata.person
-----------------------------------------------------------------------------------------
--加载周期：日增
------------------------------------------------------------------------------------------
--作者：jiangsh
--开发日期：2018-11-12
------------------------------------------------------------------------------------------
--版本控制：版本号  提交人   提交日期   提交内容
--         V1.0     jiangsh  2018-11-12   开发上线
--调用方法　python /home/edw/python/accvouch_u8.python 2018-11-12 2018-11-12
------------------------------------开始处理逻辑------------------------------------------

-- CREATE TABLE `accvouch_u8` (
--   `db` varchar(20) DEFAULT NULL COMMENT '来源系统',
--   `i_id` int(11) DEFAULT NULL COMMENT '自动编号',
--   `liuchengbh` varchar(100) DEFAULT NULL COMMENT '流程编号',
--   `iyear` int(11) DEFAULT NULL COMMENT '年份',
--   `iperiod` int(11) DEFAULT NULL COMMENT '月份',
--   `dbill_date` datetime DEFAULT NULL COMMENT '日期',
--   `voucher_id` varchar(60) DEFAULT NULL COMMENT '凭证编码',
--   `ccode` varchar(40) DEFAULT NULL COMMENT '科目（凭证中末级科目）',
--   `ccode_name` varchar(100) DEFAULT NULL COMMENT '科目名称（凭证中末级科目）',
--   `ccode_lv2` varchar(40) DEFAULT NULL COMMENT 'U8二级科目',
--   `ccode_name_lv2` varchar(100) DEFAULT NULL COMMENT 'U8二级科目名称',
--   `cdept_id` varchar(12) DEFAULT NULL COMMENT '部门编码',
--   `cdepname` varchar(255) DEFAULT NULL COMMENT '部门名称',
--   `cdepname_lv1` text COMMENT '对应的U8一级部门',
--   `cdepname_lv2` text COMMENT '对应的U8二级部门',
--   `cdepname_lv3` text COMMENT '对应的U8三级部门',
--   `cdepname_lv4` text COMMENT '对应的U8四级部门',
--   `cperson_id` varchar(20) DEFAULT NULL COMMENT '职员编码',
--   `cpersonname` varchar(40) DEFAULT NULL COMMENT '职员名称',
--   `sales_region` varchar(20) DEFAULT NULL COMMENT '地区',
--   `ccus_id` varchar(20) DEFAULT NULL COMMENT '客户编号',
--   `bi_cuscode` varchar(20) DEFAULT NULL COMMENT 'bi客户编号',
--   `bi_cusname` varchar(120) DEFAULT NULL COMMENT 'bi客户名称',
--   `cdigest` varchar(120) DEFAULT NULL COMMENT 'bi客户名称',
--   `mc` decimal(19,4) DEFAULT NULL COMMENT '金额1',
--   `mc` decimal(19,4) DEFAULT NULL COMMENT '金额2',
--   `sys_time` datetime DEFAULT NULL COMMENT '时间戳',
--   KEY `index_accvouch_u8_db` (`db`),
--   KEY `index_accvouch_u8_i_id` (`i_id`),
--   KEY `index_accvouch_u8_i_cdigest` (`cdigest`)
-- ) ENGINE=InnoDB DEFAULT CHARSET=utf8 COMMENT='u8凭证整合表';

create temporary table edw.code as
select ccode,ccode_name
  from ufdata.code
 where db = 'UFDATA_111_2018'
   and iyear = "2019"
;

insert into edw.code values('640110','人员成本');

-- 创建一个临时表用于字段切割
create temporary table edw.department_pre as
select cdepcode
      ,cdepname
      ,db
      ,idepgrade
      ,case when idepgrade=  4 then cdepfullname
            when idepgrade=  3 then CONCAT(cdepfullname,'/')
            when idepgrade=  2 then CONCAT(cdepfullname,'//')
            when idepgrade=  1 then CONCAT(cdepfullname,'///')
            end as  cdepfullname
  from ufdata.department;

-- 抽取每天的增量数据
create temporary table edw.accvouch_u8_pre as
select a.db
      ,a.i_id
      ,a.iyear
      ,a.iperiod
      ,a.dbill_date
      ,case when char_length(a.ino_id) = 1 then CONCAT(a.csign,'-000',a.ino_id) 
            when char_length(a.ino_id) = 2 then CONCAT(a.csign,'-00',a.ino_id) 
            when char_length(a.ino_id) = 3 then CONCAT(a.csign,'-0',a.ino_id) 
            else CONCAT(a.csign,'-',a.ino_id)
            end as voucher_id
      ,a.ccode
      ,b.ccode_name
      ,a.cdept_id
      ,c.cdepname
      ,substring_index(substring_index(c.cdepfullname, '/', 1) , '/', -1) as cdepname_lv1
      ,substring_index(substring_index(c.cdepfullname, '/', 2) , '/', -1) as cdepname_lv2
      ,substring_index(substring_index(c.cdepfullname, '/', 3) , '/', -1) as cdepname_lv3
      ,substring_index(substring_index(c.cdepfullname, '/', 4) , '/', -1) as cdepname_lv4
      ,a.cperson_id
      ,d.cpersonname
      ,a.ccus_id
      ,e.bi_cuscode
      ,e.bi_cusname
      ,a.cdigest
      ,a.mc
      ,a.md
      ,a.ibook
      ,a.csign
      ,localtimestamp() as sys_time
  from ufdata.gl_accvouch a
  left join (select ccode,ccode_name from edw.code group by ccode) b
    on a.ccode = b.ccode
  left join (select * from edw.department_pre group by cdepcode,db) c
    on a.cdept_id = c.cdepcode
   and left(a.db,10) = left(c.db,10)
  left join (select cpersoncode,cpersonname,db from ufdata.person group by cpersoncode,left(db,10)) d
    on a.cperson_id = d.cpersoncode
   and left(a.db,10) = left(d.db,10)
  left join (select ccuscode,bi_cuscode,bi_cusname from edw.dic_customer group by ccuscode) e
    on a.ccus_id = e.ccuscode
 where a.iflag is null
   and a.db <> 'UFDATA_007_2019'
;

insert into edw.accvouch_u8_pre
select a.db
      ,a.i_id
      ,a.iyear
      ,a.iperiod
      ,a.dbill_date
      ,case when char_length(a.ino_id) = 1 then CONCAT(a.csign,'-000',a.ino_id) 
            when char_length(a.ino_id) = 2 then CONCAT(a.csign,'-00',a.ino_id) 
            when char_length(a.ino_id) = 3 then CONCAT(a.csign,'-0',a.ino_id) 
            else CONCAT(a.csign,'-',a.ino_id)
            end as voucher_id
      ,a.ccode
      ,b.ccode_name
      ,a.cdept_id
      ,c.cdepname
      ,substring_index(substring_index(c.cdepfullname, '/', 1) , '/', -1) as cdepname_lv1
      ,substring_index(substring_index(c.cdepfullname, '/', 2) , '/', -1) as cdepname_lv2
      ,substring_index(substring_index(c.cdepfullname, '/', 3) , '/', -1) as cdepname_lv3
      ,substring_index(substring_index(c.cdepfullname, '/', 4) , '/', -1) as cdepname_lv4
      ,a.cperson_id
      ,d.cpersonname
      ,a.ccus_id
      ,e.bi_cuscode
      ,e.bi_cusname
      ,a.cdigest
      ,a.mc
      ,a.md
      ,a.ibook
      ,a.csign
      ,localtimestamp() as sys_time
  from ufdata.gl_accvouch a
  left join (select ccode,ccode_name from ufdata.code group by ccode) b
    on a.ccode = b.ccode
  left join (select * from edw.department_pre group by cdepcode,db) c
    on a.cdept_id = c.cdepcode
   and left(a.db,10) = left(c.db,10)
  left join (select cpersoncode,cpersonname,db from ufdata.person group by cpersoncode,left(db,10)) d
    on a.cperson_id = d.cpersoncode
   and left(a.db,10) = left(d.db,10)
  left join (select ccuscode,bi_cuscode,bi_cusname from edw.dic_customer group by ccuscode) e
    on a.ccus_id = e.ccuscode
 where a.iflag is null
   and a.db = 'UFDATA_007_2019'
;

-- 未知情况，针对奥博特财务推测操作人员问题，手动删除这部分数据
delete from edw.accvouch_u8_pre where ibook = '0' and csign = '记';



truncate table edw.accvouch_u8;
insert into edw.accvouch_u8
select a.db
      ,a.i_id
      ,case when a.cdigest like '%BS-BSFK%' then left(CONCAT(RIGHT(SUBSTRING_INDEX(a.cdigest,'-',1),2),'-',SUBSTRING_INDEX(a.cdigest,'-',-2)),20)
            else a.cdigest end as liuchengbh
      ,a.iyear
      ,a.iperiod
      ,a.dbill_date
      ,a.voucher_id
      ,a.ccode
      ,a.ccode_name
      ,b.ccode
      ,b.ccode_name
      ,a.cdept_id
      ,a.cdepname
      ,a.cdepname_lv1
      ,a.cdepname_lv2
      ,a.cdepname_lv3
      ,a.cdepname_lv4
      ,a.cperson_id
      ,a.cpersonname
      ,c.province
      ,a.ccus_id
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.cdigest
      ,a.mc
      ,a.md
      ,a.sys_time
  from edw.accvouch_u8_pre a
  left join (select ccode,ccode_name from edw.code group by ccode) b
    on SUBSTRING(a.ccode,1,6) = b.ccode
  left join (select bi_cuscode,sales_region,province from edw.map_customer group by bi_cuscode) c
    on a.bi_cuscode = c.bi_cuscode
 where a.db <> 'UFDATA_007_2019';

insert into edw.accvouch_u8
select a.db
      ,a.i_id
      ,case when a.cdigest like '%BS-BSFK%' then left(CONCAT(RIGHT(SUBSTRING_INDEX(a.cdigest,'-',1),2),'-',SUBSTRING_INDEX(a.cdigest,'-',-2)),20)
            else a.cdigest end as liuchengbh
      ,a.iyear
      ,a.iperiod
      ,a.dbill_date
      ,a.voucher_id
      ,a.ccode
      ,a.ccode_name
      ,b.ccode
      ,b.ccode_name
      ,a.cdept_id
      ,a.cdepname
      ,a.cdepname_lv1
      ,a.cdepname_lv2
      ,a.cdepname_lv3
      ,a.cdepname_lv4
      ,a.cperson_id
      ,a.cpersonname
      ,c.province
      ,a.ccus_id
      ,a.bi_cuscode
      ,a.bi_cusname
      ,a.cdigest
      ,a.mc
      ,a.md
      ,a.sys_time
  from edw.accvouch_u8_pre a
  left join (select ccode,ccode_name from ufdata.code group by ccode) b
    on SUBSTRING(a.ccode,1,8) = b.ccode
  left join (select bi_cuscode,sales_region,province from edw.map_customer group by bi_cuscode) c
    on a.bi_cuscode = c.bi_cuscode
 where a.db = 'UFDATA_007_2019';


-- 调整一笔启代因为做账出现问题的数据
update edw.accvouch_u8
   set liuchengbh = 'BS-BSFK-201904241249'
      ,cdigest = '招待费BS-BSFK-201904241249'
 where liuchengbh = 'BS-BSFK-201904010061'
   and db = 'UFDATA_666_2018'
   and mc = '0'
;

update edw.accvouch_u8
   set liuchengbh = 'BS-BSFK-201904241249'
      ,cdigest = '王彩琴报销BS-BSFK-201904010061'
 where liuchengbh = 'BS-BSFK-201904010061'
   and db = 'UFDATA_666_2018'
   and md = '0'
;
