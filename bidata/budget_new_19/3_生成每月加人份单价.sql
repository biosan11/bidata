

-- 建表
drop table if exists ufdata.sales_budget_19_new_price;
create table if not exists ufdata.sales_budget_19_new_price(
ccuscode varchar(20) comment '客户编码',
item_code varchar(60) comment '项目编码',
cinvcode varchar(60) comment '存货编码',
iunitcost float(13,3) comment '单价',
primary key(ccuscode,item_code,cinvcode)
) ;


-- 3月回收的单价
insert into ufdata.sales_budget_19_new_price values("ZD3704003","CQ0401","HC01225",11);
insert into ufdata.sales_budget_19_new_price values("ZD3704003","CQ0401","HC01245",3);
insert into ufdata.sales_budget_19_new_price values("ZD3704003","CQ0401","HC01180",2500);
insert into ufdata.sales_budget_19_new_price values("ZD3711001","CQ0401","HC01180",2500);
insert into ufdata.sales_budget_19_new_price values("ZD3713008","CQ0101","JC02003",1230);
insert into ufdata.sales_budget_19_new_price values("ZD3717001","XS0923","JC0100019",4000);
insert into ufdata.sales_budget_19_new_price values("ZD3713008","CQ0401","SJ05145",6550);
insert into ufdata.sales_budget_19_new_price values("ZD3713008","CQ0401","SJ05166",2350);

-- 6月回收的单价
insert into ufdata.sales_budget_19_new_price values("ZD3507004","XS0103","SJ01006",13);
insert into ufdata.sales_budget_19_new_price values("ZD3507004","XS0104","SJ01010",5);
insert into ufdata.sales_budget_19_new_price values("ZD3507004","XS0104","SJ01015",9);


-- 7月回收的单价
insert into ufdata.sales_budget_19_new_price values("ZD3504002","CQ0401","SJ05166",6700);
insert into ufdata.sales_budget_19_new_price values("ZD3504002","CQ0401","SJ05145",2400);
insert into ufdata.sales_budget_19_new_price values("ZD3504002","XS0601","HC01180",3050);
insert into ufdata.sales_budget_19_new_price values("ZD3507004","CQ0704","JC02004",2700);
insert into ufdata.sales_budget_19_new_price values("ZD3507004","XS0106","SJ01012",2.8);
insert into ufdata.sales_budget_19_new_price values("ZD3507004","XS0108","SJ01007",9);
insert into ufdata.sales_budget_19_new_price values("ZD3507001","CQ0701","JC02007",1516);
insert into ufdata.sales_budget_19_new_price values("ZD3507001","CQ0704","JC02004",2496);
insert into ufdata.sales_budget_19_new_price values("ZD3509003","CQ0701","JC02007",1980);
insert into ufdata.sales_budget_19_new_price values("ZD3509003","CQ0401","SJ05166",6030);
insert into ufdata.sales_budget_19_new_price values("ZD3509003","CQ0401","SJ05145",2160);
insert into ufdata.sales_budget_19_new_price values("ZD3509003","CQ0704","JC02004",3600);
insert into ufdata.sales_budget_19_new_price values("ZD3501009","CQ0704","JC02004",3700);
insert into ufdata.sales_budget_19_new_price values("ZD3501007","CQ0701","JC02007",1356);
insert into ufdata.sales_budget_19_new_price values("ZD3503002","CQ0401","SJ05166",6700);
insert into ufdata.sales_budget_19_new_price values("ZD3503002","CQ0401","SJ05145",2400);
insert into ufdata.sales_budget_19_new_price values("ZD3503002","CQ0704","JC02004",4000);


