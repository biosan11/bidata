update edw.invoice_order as a inner join
(select bi_cuscode,bi_cusname from edw.dic_customer group by bi_cuscode) as b 
on a.true_finnal_ccusname2 = b.bi_cusname 
set a.true_finnal_ccuscode = b.bi_cuscode;
