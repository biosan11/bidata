
-- x_sales_budget_18 中 温州中心医院的占点重点的原位培养盒改为羊水培养基
update ufdata.x_sales_budget_18 
set item_code = "YC0112" ,item_name = "羊水培养基"
where auto_id in(13477,13478,13479,13480,13481,13482,13483,13484,13485,13486,13487,13488);