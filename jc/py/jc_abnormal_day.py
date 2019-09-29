# -*- coding:utf-8 -*-
# author:Jin

import os
import schedule,datetime,time
import commands
import pymysql
import time

def sqldir(path):
    sqlpath_list = []
    for file in os.listdir(path):
        file_path = os.path.join(path,file)
        if os.path.isfile(file_path):
            if os.path.splitext(file_path)[1] == ".sql":
                sqlpath_list.append(file_path)
    #sqlpath_list.sort(key=lambda x:int(x[len(path):len(path)+x[len(path):].find("_")]))
    return sqlpath_list

def run_sql(path):
    today = datetime.datetime.today()
    sqlpath_list = sqldir(path)
    with open("/home/bidata/jc/log/jc_abnormal_day.txt","a+") as log:
        log.write("\n\n\n\nMANUAL")
        log.write("\ndate:%s\n**************************" %today)
    for sqlpath in sqlpath_list:
        print(sqlpath)
        command = "mysql -h172.16.0.181 -p3306 -uroot -pbiosan <%s" %sqlpath
        (status, output) = commands.getstatusoutput(command)
        now = time.strftime("%H:%M:%S")
        print(status)
        with open("/home/bidata/jc/log/jc_abnormal_day.txt","a+") as log:
            log.write("\ntime:%s\n-----------------------\n" %now)
            log.write("%s\n%s\n%s" %(sqlpath,status,output))

def job1():
    path = "/home/bidata/jc/sql/"
    run_sql(path)

def ins_old():
    # 判断今天的历史表是否已经存在数据，不存在在插入数据
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    curson.execute("select max(date) from tracking.jc_abnormal_all")
    date1 = str(curson.fetchone()[0])
    date2 = str(time.strftime("%Y-%m-%d", time.localtime()))
    if date1 != date2:
        curson.execute("insert into tracking.jc_abnormal_all select * from tracking.jc_abnormal_day")
        conn.commit()
        return "新增成功"
    return "今日已运行过啦"



if __name__=='__main__':
    job1()
    print(ins_old())


