-- 彭丽0318需求，加工一张月中-销售计划进度表，并发送给相关人员，这里是加工底层元数据
-- 现在bidata生成一张可用的表

-- 以下的数据都是以19年为主
-- 计算去除当月ttl计划
create temporary table bidata.ft_12_sales_budget_pre1 as
select true_ccuscode
      ,true_item_code
      ,business_class
      ,sum(isum_budget) as plan_bf_mon
      ,sum(isum_budget_pro) as plan_bf_zb
  from bidata.ft_12_sales_budget
 where left(ddate,4) = '2019'
   and left(ddate,7) < left('${start_dt}',7)
   and cohr = '博圣体系'
 group by true_ccuscode,true_item_code,business_class
;

-- 计算当季ttl计划金额
create temporary table bidata.ft_12_sales_budget_pre2 as
select true_ccuscode
      ,true_item_code
      ,business_class
      ,sum(isum_budget) as plan_quarter_new
      ,sum(isum_budget_pro) as plan_quarter_zb
  from bidata.ft_12_sales_budget
 where left(ddate,4) = '2019'
   and cohr = '博圣体系'
   and QUARTER(ddate) = QUARTER('${start_dt}')
 group by true_ccuscode,true_item_code,business_class
;

-- 计算当月ttl计划
create temporary table bidata.ft_12_sales_budget_pre3 as
select true_ccuscode
      ,true_item_code
      ,business_class
      ,sum(isum_budget) as plan_mon
      ,sum(isum_budget_pro) as plan_mon_zb
  from bidata.ft_12_sales_budget
 where left(ddate,4) = '2019'
   and cohr = '博圣体系'
   and left(ddate,7) = left('${start_dt}',7)
 group by true_ccuscode,true_item_code,business_class
;

-- 计算当月计划金额_new
create temporary table bidata.ft_12_sales_budget_pre4 as
select true_ccuscode
      ,true_item_code
      ,business_class
      ,sum(isum_budget) as plan_mon_new
  from bidata.ft_13_sales_budget_new
 where left(ddate,4) = '2019'
   and cohr = '博圣体系'
   and left(ddate,7) = left('${start_dt}',7)
 group by true_ccuscode,true_item_code,business_class
;
create temporary table bidata.ft_12_sales_budget_pre6 as
select true_ccuscode
      ,true_item_code
      ,business_class
  from bidata.ft_12_sales_budget_pre1
union
select true_ccuscode
      ,true_item_code
      ,business_class
  from bidata.ft_12_sales_budget_pre2
union
select true_ccuscode
      ,true_item_code
      ,business_class
  from bidata.ft_12_sales_budget_pre3
union
select true_ccuscode
      ,true_item_code
      ,business_class
  from bidata.ft_12_sales_budget_pre4
;

-- 计划收入整合
create temporary table bidata.ft_12_sales_budget_pre5 as
select e.true_ccuscode
      ,e.true_item_code
      ,e.business_class
      ,a.plan_bf_mon
      ,a.plan_bf_zb
      ,b.plan_quarter_new
      ,b.plan_quarter_zb
      ,c.plan_mon
      ,c.plan_mon_zb
      ,d.plan_mon_new
  from bidata.ft_12_sales_budget_pre6 e
  left join bidata.ft_12_sales_budget_pre1 a
    on e.true_ccuscode = a.true_ccuscode
   and e.true_item_code = a.true_item_code
   and e.business_class = a.business_class
  left join bidata.ft_12_sales_budget_pre2 b
    on e.true_ccuscode = b.true_ccuscode
   and e.true_item_code = b.true_item_code
   and e.business_class = b.business_class
  left join bidata.ft_12_sales_budget_pre3 c
    on e.true_ccuscode = c.true_ccuscode
   and e.true_item_code = c.true_item_code
   and e.business_class = c.business_class
  left join bidata.ft_12_sales_budget_pre4 d
    on e.true_ccuscode = d.true_ccuscode
   and e.true_item_code = d.true_item_code
   and e.business_class = d.business_class
;

-- 计算去除当月ttl实际
create temporary table bidata.ft_11_sales_pre1 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_bf_mon
  from bidata.ft_11_sales
 where left(ddate,4) = '2019'
   and left(ddate,7) < left('${start_dt}',7)
 group by finnal_ccuscode,item_code,business_class
;
-- 计算当季ttl实际
create temporary table bidata.ft_11_sales_pre2 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_quarter_new
  from bidata.ft_11_sales
 where left(ddate,4) = '2019'
   and QUARTER(ddate) = QUARTER('${start_dt}')
 group by finnal_ccuscode,item_code,business_class
;
-- 计算当季去除当月的收入
create temporary table bidata.ft_11_sales_pre8 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_quarter_new2
  from bidata.ft_11_sales
 where left(ddate,7) < left('${start_dt}',7)
   and QUARTER(ddate) = QUARTER('${start_dt}')
   and left(ddate,4) = '2019'
 group by finnal_ccuscode,item_code,business_class
;
-- 计算每月1-7实际收入
create temporary table bidata.ft_11_sales_pre3 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_day1
  from bidata.ft_11_sales
 where ddate >= concat(left('${start_dt}',8),'01')
   and ddate <= concat(left('${start_dt}',8),'07')
   and cohr <> '杭州贝生'
 group by finnal_ccuscode,item_code,business_class
;
-- 计算每月8-14实际收入
create temporary table bidata.ft_11_sales_pre4 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_day2
  from bidata.ft_11_sales
 where ddate >= concat(left('${start_dt}',8),'08')
   and cohr <> '杭州贝生'
   and ddate <= concat(left('${start_dt}',8),'14')
 group by finnal_ccuscode,item_code,business_class
;
-- 计算每月15-23实际收入
create temporary table bidata.ft_11_sales_pre5 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_day3
  from bidata.ft_11_sales
 where ddate >= concat(left('${start_dt}',8),'15')
   and ddate <= concat(left('${start_dt}',8),'23')
   and cohr <> '杭州贝生'
 group by finnal_ccuscode,item_code,business_class
;
-- 计算每月24以后实际收入
create temporary table bidata.ft_11_sales_pre6 as
select finnal_ccuscode as ccuscode
      ,item_code
      ,cbustype as business_class
      ,sum(isum) as actual_day4
  from bidata.ft_11_sales
 where ddate >= concat(left('${start_dt}',8),'24')
   and cohr <> '杭州贝生'
   and ddate <= concat(left('${start_dt}',8),'31')
 group by finnal_ccuscode,item_code,business_class
;

create temporary table bidata.ft_11_sales_pre9 as
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre1
union
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre2
union
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre3
union
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre4
union
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre5
union
select ccuscode,item_code,business_class from bidata.ft_11_sales_pre6
;

-- 实际收入整合
create temporary table bidata.ft_11_sales_pre7 as
select h.ccuscode
      ,h.item_code
      ,h.business_class
      ,a.actual_bf_mon
      ,b.actual_quarter_new
      ,c.actual_day1
      ,d.actual_day2
      ,e.actual_day3
      ,f.actual_day4
      ,g.actual_quarter_new2
  from bidata.ft_11_sales_pre9 h
  left join bidata.ft_11_sales_pre1 a
    on h.ccuscode = a.ccuscode
   and h.item_code = a.item_code
   and h.business_class = a.business_class
  left join bidata.ft_11_sales_pre2 b
    on h.ccuscode = b.ccuscode
   and h.item_code = b.item_code
   and h.business_class = b.business_class
  left join bidata.ft_11_sales_pre3 c
    on h.ccuscode = c.ccuscode
   and h.item_code = c.item_code
   and h.business_class = c.business_class
  left join bidata.ft_11_sales_pre4 d
    on h.ccuscode = d.ccuscode
   and h.item_code = d.item_code
   and h.business_class = d.business_class
  left join bidata.ft_11_sales_pre5 e
    on h.ccuscode = e.ccuscode
   and h.item_code = e.item_code
   and h.business_class = e.business_class
  left join bidata.ft_11_sales_pre6 f
    on h.ccuscode = f.ccuscode
   and h.item_code = f.item_code
   and h.business_class = f.business_class
  left join bidata.ft_11_sales_pre8 g
    on h.ccuscode = g.ccuscode
   and h.item_code = g.item_code
   and h.business_class = g.business_class
;

-- 取预算和实际的集合整体
create temporary table bidata.cusitem_analysis_mon_pre as
select true_ccuscode
      ,true_item_code
      ,business_class
  from bidata.ft_12_sales_budget_pre5
union
select ccuscode
      ,item_code
      ,business_class
  from bidata.ft_11_sales_pre7 
;

truncate table bidata.cusitem_analysis_mon;
insert into bidata.cusitem_analysis_mon
select case when c.equipment = '是' then '仪器设备'
            else c.level_one end
      ,e.item_key
      ,left('${start_dt}',7)
      ,b.sales_region
      ,b.province
      ,b.city
      ,b.bi_cusname
      ,c.level_one
      ,c.level_two
      ,c.level_three
      ,e.item_key
      ,c.equipment
      ,f.business_class
      ,ifnull(a.plan_bf_mon,0)
      ,ifnull(a.plan_bf_zb,0)
      ,ifnull(d.actual_bf_mon,0)
      ,ifnull(a.plan_quarter_new,0)
      ,ifnull(a.plan_quarter_zb,0)
      ,ifnull(d.actual_quarter_new,0)
      ,ifnull(a.plan_mon,0)
      ,ifnull(a.plan_mon_zb,0)
      ,ifnull(a.plan_mon_new,0)
      ,ifnull(d.actual_day1,0)
      ,ifnull(d.actual_day2,0)
      ,ifnull(d.actual_day3,0)
      ,ifnull(d.actual_day4,0)
      ,ifnull(d.actual_day1,0) + ifnull(d.actual_day2,0) +  ifnull(d.actual_day3,0) + ifnull(d.actual_day4,0)
      ,ifnull(d.actual_quarter_new2,0)
  from bidata.cusitem_analysis_mon_pre f
  left join bidata.ft_12_sales_budget_pre5 a
    on f.true_ccuscode = a.true_ccuscode
   and f.true_item_code = a.true_item_code
   and f.business_class = a.business_class
  left join edw.map_customer b
    on f.true_ccuscode = b.bi_cuscode
  left join edw.map_item c
    on f.true_item_code = c.item_code
  left join bidata.ft_11_sales_pre7 d
    on f.true_ccuscode = d.ccuscode
   and f.true_item_code = d.item_code
   and f.business_class = d.business_class
  left join (select * from bidata.dic_ppt group by level_three,business_class) e
    on c.level_three = e.level_three
   and f.business_class = e.business_class
;

-- 第二部生成报表
-- 按照product_assist来分组排序
truncate table bidata.cusitem_analysis_form;
create temporary table bidata.cusitem_analysis_form1 as
select province
      ,product_assist
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(plan_bf_zb) as plan_bf_zb
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_zb) as plan_quarter_zb
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_zb) as plan_mon_zb
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
  group by province,product_assist
;
create temporary table bidata.cusitem_analysis_form3 as
select * from bidata.cusitem_analysis_form1;
-- 计算个省区这几个项目总和
insert into bidata.cusitem_analysis_form1
select province
      ,'all1'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(plan_bf_zb) as plan_bf_zb
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_zb) as plan_quarter_zb
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_zb) as plan_mon_zb
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_form3
 where product_assist in('产前','新生儿','服务类','仪器设备')
 group by province
;

-- 先按照item_key来分组排序
create temporary table bidata.cusitem_analysis_form2 as
select province
      ,item_key
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
  group by province,item_key
;
create temporary table bidata.cusitem_analysis_form4 as
select * from bidata.cusitem_analysis_form2;
-- 计算个省区这几个项目总和
insert into bidata.cusitem_analysis_form2
select province
      ,'all3'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_form4
 where item_key in('血清学筛查','CMA_产品类','CMA_LDT','NIPT','MSMS','代谢病诊断')
 group by province
;


insert into bidata.cusitem_analysis_form2
select province
      ,'all2'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_form4
 where item_key in('NGS','CMA设备','串联质谱仪','CDS5+GSL120(含KM1,KM2)','1235+DX6000','GSP')
 group by province
;

-- 所有的数据整合到一起，总表数据
insert into bidata.cusitem_analysis_form1
select 'all'
      ,product_assist
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(plan_bf_zb) as plan_bf_zb
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_zb) as plan_quarter_zb
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_zb) as plan_mon_zb
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
   and product_assist in('产前','新生儿','服务类','仪器设备')
 group by product_assist
;

insert into bidata.cusitem_analysis_form1
select 'all'
      ,'all1'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(plan_bf_zb) as plan_bf_zb
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_zb) as plan_quarter_zb
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_zb) as plan_mon_zb
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
   and product_assist in('产前','新生儿','服务类','仪器设备')
;

insert into bidata.cusitem_analysis_form2
select 'all'
      ,item_key
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where item_key in('血清学筛查','CMA_产品类','CMA_LDT','NIPT','MSMS','代谢病诊断')
   and province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
 group by item_key
;

insert into bidata.cusitem_analysis_form2
select 'all'
      ,'all3'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where item_key in('血清学筛查','CMA_产品类','CMA_LDT','NIPT','MSMS','代谢病诊断')
   and province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
;

insert into bidata.cusitem_analysis_form2
select 'all'
      ,item_key
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where item_key in('NGS','CMA设备','串联质谱仪','CDS5+GSL120(含KM1,KM2)','1235+DX6000','GSP')
   and province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
 group by item_key
;

insert into bidata.cusitem_analysis_form2
select 'all'
      ,'all2'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where item_key in('NGS','CMA设备','串联质谱仪','CDS5+GSL120(含KM1,KM2)','1235+DX6000','GSP')
   and province in('湖南省','湖北省','福建省','江苏省','安徽省','浙江省','上海市','山东省')
;


-- 插入报表
insert into bidata.cusitem_analysis_form
select province
      ,product_assist
      ,ifnull(plan_bf_mon,0)
      ,ifnull(plan_bf_zb,0)
      ,ifnull(actual_bf_mon,0)
      ,ifnull(actual_bf_mon,0) - ifnull(plan_bf_zb,0)
      ,ifnull(ifnull(actual_bf_mon,0)/plan_bf_mon,0)
      ,ifnull(plan_quarter_new,0)
      ,ifnull(plan_quarter_zb,0)
      ,ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0)
      ,ifnull(actual_quarter_new,0)
      ,ifnull((ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0))/plan_quarter_zb,0)
      ,ifnull(ifnull(actual_quarter_new,0)/plan_quarter_zb,0)
      ,ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0) - ifnull(plan_quarter_zb,0)
      ,ifnull(actual_quarter_new,0) - ifnull(plan_quarter_zb,0)
      ,0
      ,ifnull(plan_mon,0)
      ,ifnull(plan_mon_zb,0)
      ,ifnull(plan_mon_new,0)
      ,ifnull(actual_day1,0)
      ,ifnull(actual_day2,0)
      ,ifnull(actual_day3,0)
      ,ifnull(actual_day4,0)
      ,ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/plan_mon_zb,0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/plan_mon_new,0)
      ,(ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0)) - ifnull(plan_mon_zb,0)
  from bidata.cusitem_analysis_form1
 where 1 = 1
;


insert into bidata.cusitem_analysis_form
select province
      ,item_key
      ,ifnull(plan_bf_mon,0)
      ,0
      ,ifnull(actual_bf_mon,0)
      ,ifnull(plan_bf_mon,0) - ifnull(actual_bf_mon,0)
      ,ifnull(ifnull(actual_bf_mon,0)/ifnull(plan_bf_mon,0),0)
      ,ifnull(plan_quarter_new,0)
      ,0
      ,ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0)
      ,ifnull(actual_quarter_new,0)
      ,ifnull((ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0))/ifnull(plan_quarter_new,0),0)
      ,ifnull(ifnull(actual_quarter_new,0)/ifnull(plan_quarter_new,0),0)
      ,ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0)- ifnull(plan_quarter_new,0)
      ,ifnull(actual_quarter_new,0) - ifnull(plan_quarter_new,0)
      ,0
      ,ifnull(plan_mon,0)
      ,0
      ,ifnull(plan_mon_new,0)
      ,ifnull(actual_day1,0)
      ,ifnull(actual_day2,0)
      ,ifnull(actual_day3,0)
      ,ifnull(actual_day4,0)
      ,ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/ifnull(plan_mon,0),0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/ifnull(plan_mon_new,0),0)
      ,ifnull(plan_mon,0) - (ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))
  from bidata.cusitem_analysis_form2
 where 1 = 1
;

-- 城市的计算公式
truncate table bidata.cusitem_analysis_city;
create temporary table bidata.cusitem_analysis_city1 as
select province
      ,city
      ,product_assist
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_mon
 where product_assist in('产前','新生儿','服务类','仪器设备')
  group by province,product_assist,city
;
create temporary table bidata.cusitem_analysis_city2 as
select * from bidata.cusitem_analysis_city1;
-- 计算个省区这几个项目总和
insert into bidata.cusitem_analysis_city1
select province
      ,city
      ,'all1'
      ,sum(plan_bf_mon) as plan_bf_mon
      ,sum(actual_bf_mon) as actual_bf_mon
      ,sum(plan_quarter_new) as plan_quarter_new
      ,sum(plan_quarter_new2) as plan_quarter_new2
      ,sum(actual_quarter_new) as actual_quarter_new
      ,sum(plan_mon) as plan_mon
      ,sum(plan_mon_new) as plan_mon_new
      ,sum(actual_day1) as actual_day1
      ,sum(actual_day2) as actual_day2
      ,sum(actual_day3) as actual_day3
      ,sum(actual_day4) as actual_day4
  from bidata.cusitem_analysis_city2
 group by province,city
;

insert into bidata.cusitem_analysis_city
select province
      ,city
      ,product_assist
      ,ifnull(plan_bf_mon,0)
      ,ifnull(actual_bf_mon,0)
      ,ifnull(actual_bf_mon,0) - ifnull(plan_bf_mon,0)
      ,ifnull(ifnull(actual_bf_mon,0)/ifnull(plan_bf_mon,0),0)
      ,ifnull(plan_quarter_new,0)
      ,ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0)
      ,ifnull(actual_quarter_new,0)
      ,ifnull((ifnull(plan_quarter_new2,0) + ifnull(plan_mon_new,0))/ifnull(plan_quarter_new,0),0)
      ,ifnull(ifnull(actual_quarter_new,0)/ifnull(plan_quarter_new,0),0)
      ,ifnull(plan_quarter_new,0) - ifnull(plan_quarter_new2,0) - ifnull(plan_mon_new,0)
      ,ifnull(plan_quarter_new,0) - ifnull(actual_quarter_new,0)
      ,0
      ,ifnull(plan_mon,0)
      ,ifnull(plan_mon_new,0)
      ,ifnull(actual_day1,0)
      ,ifnull(actual_day2,0)
      ,ifnull(actual_day3,0)
      ,ifnull(actual_day4,0)
      ,ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/ifnull(plan_mon,0),0)
      ,ifnull((ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))/ifnull(plan_mon_new,0),0)
      ,ifnull(plan_mon,0) - (ifnull(actual_day1,0) + ifnull(actual_day2,0) +  ifnull(actual_day3,0) + ifnull(actual_day4,0))
  from bidata.cusitem_analysis_city1
 where 1 = 1
;

insert into bidata.cusitem_analysis_city
select a.province
      ,a.city
      ,a.item
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
      ,0
  from bidata.cusitem_dic_city a
  left join bidata.cusitem_analysis_city1 b
    on a.province = b.province
   and a.city = b.city
   and a.item = b.product_assist
 where b.province is null
;


