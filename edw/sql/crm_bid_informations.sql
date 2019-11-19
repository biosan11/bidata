
truncate table edw.crm_bid_informations;
insert into edw.crm_bid_informations
select a.createdon
      ,a.new_name
      ,a.new_contract_sn
      ,a.new_u8_num
      ,a.new_bid_information1
      ,a.new_reason
      ,case when a.new_bid_result = '1' then '中标' 
            when a.new_bid_result = '2' then '未中标'
            when a.new_bid_result = '3' then '废标'
            when a.new_bid_result = '4' then '流标'
            when a.new_bid_result = '5' then '未开标'
            else '未知' end as new_bid_result
      ,b.name
      ,c.bi_cuscode
      ,c.bi_cusname
      ,a.new_product_text
      ,a.new_open_bid_date
      ,e.yomifullname
      ,d.sales_region
      ,d.province
      ,d.city
      ,a.new_account_text
      ,a.new_win_bid_money
      ,a.new_send_bid_text
      ,a.new_bid_company_text
      ,a.new_project_name
  from ufdata.crm_bid_informations a
  left join edw.crm_accounts b
    on a._new_account_value = b.crm_num
   left join (select * from edw.dic_customer group by ccusname) c
     on b.name = c.ccusname
   left join (select * from edw.map_customer group by bi_cuscode) d
     on c.bi_cuscode = d.bi_cuscode
   left join ufdata.crm_systemusers e
     on a._new_opp_owner_value = e.ownerid
 where a.statecode = '0'
;

