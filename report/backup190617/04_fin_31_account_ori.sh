
#!/bin/bash
sed -i "1 i\ use report;" 04_fin_31_account_ori.sql
sed -i "1 i\ set @dt=str_to_date('$1','%Y-%m-%d');;" 04_fin_31_account_ori.sql
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use report;
source /home/bidata/report/04_fin_31_account_ori.sql
EOF
sed -i "1d" 04_fin_31_account_ori.sql
sed -i "1d" 04_fin_31_account_ori.sql