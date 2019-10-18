
#!/bin/bash
name=$1 
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use bidata;
source /home/bidata/report/report2/${name}
EOF
