
#!/bin/bash
name=$1
cd /home/jsh
for file in $(ls *.txt)
do
	echo $file
done 
mysql -h172.16.0.181 -p3306 -uroot -pbiosan << EOF
use test;
source /home/bidata/edw/xx_sql/${name}
EOF
