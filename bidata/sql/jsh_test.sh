
#!/bin/bash
name=$1
cd ${name}
for file in $(ls *.sql)
do
	echo $file
	mysql -h172.16.0.181 -p3306 -uroot -pbiosan </home/bidata/bidata/sql/$file
done

