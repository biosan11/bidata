#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author:Jin

import os
import schedule,datetime,time
import commands
import sys
import pymysql

t_list = ['invoice_order','dispatch_order','outdepot_order','sales_order']
xx_xs = sys.argv[1]
# 获取7天前的时间戳
threeDayAgo = (datetime.datetime.now() - datetime.timedelta(days = 7))
# t_list = ['outdepot_order']

# 获取当前路径所有的sql脚本
def sqldir(path):
    sqlpath_list = []
    for file in os.listdir(path):
        file_path = os.path.join(path,file)
        if os.path.isfile(file_path):
            if os.path.splitext(file_path)[1] == ".sql":
                sqlpath_list.append(file_path)
    # sqlpath_list.sort(key=lambda x:int(x[len(path):len(path)+x[len(path):].find("_")]))
    return sqlpath_list

# 运行线下excel的脚本
def run_sql(path):
    today = datetime.datetime.today()
    sqlpath_list = sqldir(path)
    with open("/home/bidata/edw/log/log.txt","a+") as log:
        log.write("\n\n\n\nMANUAL")
        log.write("\ndate:%s\n**************************" %today)
    for sqlpath in sqlpath_list:
        if sqlpath != "/home/bidata/edw/xx_sql/x_yj_outdepot.sql":
            print(sqlpath)
            command = "mysql -h172.16.0.181 -p3306 -uroot -pbiosan <%s" %sqlpath
            (status, output) = commands.getstatusoutput(command)
            now = time.strftime("%H:%M:%S")
            print(status)
            with open("/home/bidata/edw/log/log.txt","a+") as log:
                log.write("\ntime:%s\n-----------------------\n" %now)
                log.write("%s\n%s\n%s" %(sqlpath,status,output))

# 运行edw层的脚本
def run_edwpy(t_name):
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    curson.execute("drop table if exists edw18.%s_edw"%(t_name))
    curson.execute("create table edw18.%s_edw as select * from edw.%s"%(t_name,t_name))
    curson.execute("truncate table edw.%s"%(t_name))
    os.system("python /home/bidata/edw/py/%s.py 1900-01-01"%(t_name))
    curson = conn.cursor()
    # curson.execute("insert into edw.%s select * from edw18.%s_edw where state = '无效'"%(t_name,t_name))
    conn.commit()
    # 时间推到7天前
    curson.execute("update edw.%s set sys_time = '%s'"%(t_name,threeDayAgo))
    conn.commit()
    print(t_name+'edw层ok')

# 运行pdm层的脚本
def run_pdmpy(t_name):
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    curson.execute("drop table if exists edw18.%s_pdm"%(t_name))
    curson.execute("create table edw18.%s_pdm as select * from pdm.%s"%(t_name,t_name))
    curson.execute("truncate table pdm.%s"%(t_name))
    os.system("python /home/bidata/pdm/py/%s.py 1900-01-01"%(t_name))
    # curson.execute("insert into edw.%s select * from edw18.%s_all where state = '无效'"%(t_name,t_name))
    conn.commit()
    print(t_name+'pdm层ok')
# 这里是运行线下的脚本
def run_sql_byname(path,t_name,type):
    os.environ['NLS_LANG'] = 'SIMPLIFIED CHINESE_CHINA.utf8'
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    ##读取SQL文件,获得sql语句的list
    with open(u'/home/bidata/%s/sql/%s_%s.sql'%(path,t_name,type), 'r+') as f:
        sql_list = f.read().split(';')[:-1]  # sql文件最后一行加上;
        sql_list = [x.replace('\n', ' ') if '\n' in x else x for x in sql_list]  # 将每段sql里的换行符改成空格
    ##执行sql语句，使用循环执行sql语句
    for sql_item  in sql_list:
        # print (sql_item)
        curson.execute(sql_item)
    curson.close()
    conn.commit()
    conn.close()
    print(t_name+type+'ok')

if __name__=='__main__':
    # 线上全量操作
    if xx_xs == '1':
        run_sql("/home/bidata/edw/xx_sql/")
    elif xx_xs == '2':
        for t_name in t_list:
            print(t_name)
            run_edwpy(t_name)
            # if t_name == 'invoice_order' or t_name == 'outdepot_order':
            #     run_sql_byname('edw',t_name,'final')
            run_pdmpy(t_name)
            if t_name == 'invoice_order':
                os.system("sh /home/bidata/pdm/py/example.sh invoice_order_xx.sql")
            if t_name == 'outdepot_order':
                os.system("sh /home/bidata/pdm/py/example.sh outdepot_order_xx.sql")
    elif xx_xs == '3':
        run_sql("/home/bidata/edw/xx_sql/")
        for t_name in t_list:
            run_edwpy(t_name)
            # if t_name == 'invoice_order' or t_name == 'outdepot_order':
            #     run_sql_byname('edw',t_name,'final')
            run_pdmpy(t_name)
            if t_name == 'invoice_order':
                os.system("sh /home/bidata/pdm/py/example.sh invoice_order_xx.sql")
            if t_name == 'outdepot_order':
                os.system("sh /home/bidata/pdm/py/example.sh outdepot_order_xx.sql")
    elif xx_xs == '4':
        t_name = sys.argv[2]
        run_edwpy(t_name)
        # if t_name == 'invoice_order' or t_name == 'outdepot_order':
        #     run_sql_byname('edw',t_name,'final')
        run_pdmpy(t_name)
        if t_name == 'invoice_order':
            os.system("sh /home/bidata/pdm/py/example.sh invoice_order_xx.sql")
        if t_name == 'outdepot_order':
            os.system("sh /home/bidata/pdm/py/example.sh outdepot_order_xx.sql")
    else:
        print("请输入1，2，3")
        print("1:只运行线下表")
        print("2:只运行线上表")
        print("3:上线都运行")
        print("4:指定表名线上'invoice_order','dispatch_order','outdepot_order','sales_order'")

