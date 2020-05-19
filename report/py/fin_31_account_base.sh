
#!/bin/bash
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use report;
source /home/bidata/report/sql/fin_31_account_base.sql
EOF