
#!/bin/bash
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use pdm;
source /home/bidata/pdm/sql/ehr_employee_id.sql
EOF
