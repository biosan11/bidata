-- ----------------------------------程序头部----------------------------------------------
-- 功能：report层基础表--2018年以后实际收入成本
-- 说明：取自pdm层invoice_order(不含健康检测),匹配标准成本单价,计算标准成本金额
-- ----------------------------------------------------------------------------------------
-- 程序名称：
-- 目标模型：
-- 源    表：
-- ---------------------------------------------------------------------------------------
-- 加载周期：
-- ----------------------------------------------------------------------------------------
-- 作者:
-- 开发日期：
-- ----------------------------------------------------------------------------------------
-- 版本控制：版本号  提交人   提交日期   提交内容
-- 
-- 调用方法　python /home/bidata/edw/invoice_order.py 2019-12-12
-- 建表脚本
-- use report;
-- drop table if exists report.fin_11_sales_cost_base;
-- create table if not exists report.fin_11_sales_cost_base(
--     ddate date comment '自动编码',
--     db varchar(30) comment '来源数据库',
--     cohr varchar(30) comment '公司',
--     csbvcode varchar(30) comment '销售发票号',
--     ccuscode varchar(30) comment '客户编码',
--     ccusname varchar(255) comment '客户名称',
--     sales_dept varchar(30) comment '销售部门',
--     sales_region_new varchar(30) comment '销售区域',
--     province varchar(60) comment '省份',
--     cbustype varchar(30) comment '业务类型',
--     sales_type varchar(30) comment '销售类型',
--     cinvcode varchar(30) comment '产品编码',
--     cinvname varchar(255) comment '产品名称',
--     item_code varchar(30) comment '项目编码',
--     level_three varchar(30) comment '项目明细',
--     level_two varchar(30) comment '产品组',
--     level_one varchar(30) comment '产品线',
--     equipment varchar(30) comment '是否设备',
--     screen_class varchar(30) comment '筛诊分类',
--     iquantity decimal(18,4) comment '数量',
--     tbquantity decimal(18,4) comment '退补数量',
--     itb varchar(30) comment '退补标记',
--     iquantity_adjust decimal(18,4) comment '调整后数量',
--     eq_if_launch varchar(30) comment '是否投放',
--     itaxunitprice decimal(18,4) comment '销售含税单价',
--     itax decimal(18,4) comment '税额',
--     isum decimal(18,4) comment '销售额_含税',
--     isum_notax decimal(18,4) comment '销售额_不含税',
--     if_cost varchar(30) comment '是否有标准成本',
--     cost_price decimal(18,4) comment '标准成本价',
--     cost decimal(18,4) comment '成本金额',
-- key repot_fin_11_sales_cost_base_db (db),
-- key repot_fin_11_sales_cost_base_csbvcode (csbvcode),
-- key repot_fin_11_sales_cost_base_ccuscode (ccuscode),
-- key repot_fin_11_sales_cost_base_cinvcode (cinvcode),
-- key repot_fin_11_sales_cost_base_item_code (item_code)
-- )engine=innodb default charset=utf8 comment='实际收入成本表';

-- drop table if exists report.invoice_order;
-- create temporary table report.invoice_order
-- select *
--   from pdm.invoice_order_cw a
--  where year(a.ddate) >= 2017
-- ;
-- 
-- CREATE INDEX index_invoice_order_cinvcode ON report.invoice_order(cinvcode);


truncate table report.fin_11_sales_cost_cw_base;
insert into report.fin_11_sales_cost_cw_base
select
     a.ddate
    ,a.db
    ,a.cohr
    ,a.csbvcode
    ,a.ccuscode
    ,a.ccusname
    ,if(a.finnal_ccuscode = "multi" ,a.ccuscode,a.finnal_ccuscode) as finnal_ccuscode
    ,if(a.finnal_ccuscode = "multi" ,a.ccusname,a.finnal_ccusname) as finnal_ccusname
    ,null as sales_dept
    ,null as sales_region_new
    ,null as province
    ,c.business_class as cbustype
    ,a.sales_type
    ,a.cinvcode
    ,c.bi_cinvname as cinvname
    ,c.item_code 
    ,c.level_three
    ,c.level_two
    ,c.level_one
    ,c.equipment
    ,c.screen_class
    ,a.iquantity
    ,a.tbquantity
    ,a.itb
    ,case 
        when a.db = "UFDATA_889_2018" then ifnull(a.iquantity,0)
        when a.itb = "退补" then ifnull(a.tbquantity,0)
        when a.itb = "1" then ifnull(a.tbquantity,0) 
        else ifnull(a.iquantity,0) 
        end as iquantity_adjust
    ,case 
        when a.sales_type = "固定资产" then "固定资产_线上"
        else null 
        end as eq_if_launch
    ,a.itaxunitprice
    ,ifnull(a.itax,0) as itax 
    ,a.isum
    ,a.isum - ifnull(a.itax,0) as isum_notax
    ,(case when price1 <> 0 then price1 else price end) / (case when a.db = "UFDATA_889_2018" then ifnull(a.iquantity,0)
                                                                when a.itb = "退补" then ifnull(a.tbquantity,0)
                                                                when a.itb = "1" then ifnull(a.tbquantity,0) 
                                                                else ifnull(a.iquantity,0)  end) as cost_price
    ,case 
        when a.sales_type = "固定资产" then 0
--        when tbquantity < 0 then (case when price1 <> 0 then price1 else price end) * -1
        when price1 <> 0 then price1
        else price
     end as cost
    ,0 -- 这里是两个关联公司对于的成本字
    ,0
    ,'正常' as type
  from pdm.invoice_order_cw a 
  left join edw.map_inventory c
    on a.cinvcode = c.bi_cinvcode
;
-- where c.item_code != "jk0101";

update report.fin_11_sales_cost_cw_base as a 
left join edw.map_customer as b 
on a.ccuscode = b.bi_cuscode 
set
    a.ccusname = b.bi_cusname
    ,a.sales_dept = b.sales_dept
    ,a.sales_region_new = b.sales_region_new
    ,a.province = b.province
;

update report.fin_11_sales_cost_cw_base as a 
 inner join edw.x_eq_launch as b 
    on a.cohr = b.cohr
   and a.csbvcode = b.vouchid
   and a.cinvcode = b.cinvcode
   set a.eq_if_launch = '固定资产_线下'
      ,a.cost = 0
 where a.sales_type <> '固定资产'
;

-- 关联公司、美博特的客户类型更新
update report.fin_11_sales_cost_cw_base set type = '美博特' where cohr = '美博特';
update report.fin_11_sales_cost_cw_base set type = '关联公司' where left(ccuscode,2) = 'GL';

-- 根据财务角度修改一波产品档案
-- 档案修改去excel里面调整
-- update report.fin_11_sales_cost_cw_base set level_two = '地贫筛查' where level_two like '%地贫%' and cbustype = '产品类';
-- update report.fin_11_sales_cost_cw_base set level_two = '其他' where level_two = '生产类' and cbustype = '产品类';
-- update report.fin_11_sales_cost_cw_base set level_two = '其他' where level_two = '新筛拓展项目' and cbustype = '产品类';
-- update report.fin_11_sales_cost_cw_base set level_two = '仪器设备' where level_two = '配套设备及软件' and cbustype = '产品类';
-- update report.fin_11_sales_cost_cw_base set cbustype = '服务类' where level_two = '维保服务' and cbustype = '产品类';
-- update report.fin_11_sales_cost_cw_base set cbustype = '服务类' where cbustype = '租赁类';

-- 增加关联公司的处理方式
-- 先确认是关联公司的然后找到他所关联的上一条记录，把成本单价插入，成本金额先不处理
-- drop table if exists report.mid1_fin_11_sales_cost_cw_base;
-- create temporary table report.mid1_fin_11_sales_cost_cw_base
-- select ddate
--       ,cohr
--       ,csbvcode
--       ,case when ccusname = '浙江博圣生物技术股份有限公司' then '博圣'
--             when ccusname = '上海恩允实业有限公司' then '恩允'
--             when ccusname = '南京卓恩生物技术有限公司' then '卓恩'
--             when ccusname = '杭州宝荣科技有限公司' then '宝荣'
--             when ccusname = '杭州贝安云科技有限公司' then '贝安云'
--             when ccusname = '杭州贝生医疗器械有限公司' then '杭州贝生'
--             when ccusname = '杭州启代医疗门诊部有限公司' then '启代'
--             when ccusname = '杭州甄元健康科技有限公司' then '甄元实验室'
--             when ccusname = '杭州博圣云鼎冷链物流有限公司' then '云鼎'
--             when ccusname = '宁波贝生医疗器械有限公司' then '宁波贝生'
--             when ccusname = '湖北奥博特生物技术有限公司' then '奥博特'
--             when ccusname = '四川美博特生物技术有限公司' then '美博特'
--             else ccusname end as ccusname
--       ,cinvcode
--       ,sum(iquantity_adjust) as iquantity_adjust
--       ,sum(isum) as isum
--       ,sum(cost) as cost
--       ,cost_price
--       ,type
--   from report.fin_11_sales_cost_cw_base a
--  group by ddate,cohr,cinvcode,ccuscode
--  order by ddate,cinvcode,abs(iquantity_adjust)
-- ;

-- 删除收入是0的数据，这里默认是红冲造成的
delete from report.mid1_fin_11_sales_cost_cw_base where isum = 0 and cost = 0; 

-- 得到所有关联公司当月的的非零成本价
drop table if exists report.mid2_fin_11_sales_cost_cw_base;
create temporary table report.mid2_fin_11_sales_cost_cw_base
select left(ddate,7) as y_mon
      ,cohr
      ,case when ccusname = '浙江博圣生物技术股份有限公司' then '博圣'
            when ccusname = '上海恩允实业有限公司' then '恩允'
            when ccusname = '南京卓恩生物技术有限公司' then '卓恩'
            when ccusname = '杭州宝荣科技有限公司' then '宝荣'
            when ccusname = '杭州贝安云科技有限公司' then '贝安云'
            when ccusname = '杭州贝生医疗器械有限公司' then '杭州贝生'
            when ccusname = '杭州启代医疗门诊部有限公司' then '启代'
            when ccusname = '杭州甄元健康科技有限公司' then '甄元实验室'
            when ccusname = '杭州博圣云鼎冷链物流有限公司' then '云鼎'
            when ccusname = '宁波贝生医疗器械有限公司' then '宁波贝生'
            when ccusname = '湖北奥博特生物技术有限公司' then '奥博特'
            when ccusname = '四川美博特生物技术有限公司' then '美博特'
            else ccusname end as ccusname
      ,cinvcode
      ,cost_price
  from report.fin_11_sales_cost_cw_base a
 where type = '关联公司'
   and cost_price <> 0
 group by y_mon,cohr,cinvcode,ccuscode
;

-- 更新一下原始的数据
update report.fin_11_sales_cost_cw_base a
 inner join report.mid2_fin_11_sales_cost_cw_base b
    on left(a.ddate,7) = b.y_mon
   and a.cohr = b.ccusname
   and a.cinvcode = b.cinvcode
   set a.cost_price_gl = b.cost_price
 where a.type <> '关联公司'
;

-- 更新美哟匹配伤的成本单价
update report.fin_11_sales_cost_cw_base set cost_price_gl = cost_price where cost_price_gl = 0;

-- 更新成本金额
update report.fin_11_sales_cost_cw_base set cost_gl = cost_price_gl * iquantity_adjust;

-- 更新固定资产成本为0
update report.fin_11_sales_cost_cw_base set cost_gl = 0 where ifnull(eq_if_launch,0) like '固定资产%';

