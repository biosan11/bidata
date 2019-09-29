#!/bin/bash
sed -i "1 i\ use report;" test.sql
sed -i "1 i\ set @id=$1;" test.sql
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use report;
source /home/bidata/report/test.sql
EOF
sed -i "1d" test.sql
sed -i "1d" test.sql
