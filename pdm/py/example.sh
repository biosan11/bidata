
#!/bin/bash
name=$1
cd /home/jsh
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use test;
source /home/bidata/pdm/sql/${name}
EOF
