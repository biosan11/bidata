
-- crm订单第二层加工逻辑，暂时只需要知道客户和金额订单状态其他的后续增加
create table edw.crm_sales_order
select a.new_order_date
      ,a.new_prepare_date
      ,a.new_name
      ,a.new_erp_num
      ,b.name as ccusname
      ,c.bi_cuscode
      ,c.bi_cusname
      ,case when a.new_sale_order_status = 1 then '草稿'
            when a.new_sale_order_status = 2 then '已提交'
            when a.new_sale_order_status = 3 then '复核驳回'
            when a.new_sale_order_status = 4 then '复核通过'
            when a.new_sale_order_status = 5 then '已推送ERP'
            when a.new_sale_order_status = 6 then '已提交OA'
            when a.new_sale_order_status = 7 then 'OA通过'
            when a.new_sale_order_status = 8 then 'OA驳回'
            when a.new_sale_order_status = 9 then '订单结束'
            end as sale_order_status
      ,new_new_total2 as isum
  from ufdata.crm_sales_order a
  left join edw.crm_accounts b
    on a._new_account_value = b.crm_num
  left join (select * from edw.dic_customer group by ccusname) c
    on b.name = c.ccusname
;
