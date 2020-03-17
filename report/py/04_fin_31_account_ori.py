#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author:Jin

import os
import schedule,datetime,time
import commands
import pymysql
import sys

# 参数 日期
today = datetime.datetime.today()
list_dt = []
for n in range(0,today.month):
    date_ = datetime.date(today.year,today.month - n,1)-datetime.timedelta(1)
    list_dt.append(date_.strftime("%Y-%m-%d"))
for n in range(0,12):
    date_ = datetime.date(today.year - 1,12 -n,1)-datetime.timedelta(1)
    list_dt.append(date_.strftime("%Y-%m-%d"))
for n in range(0,12):
    date_ = datetime.date(today.year - 2,12 -n,1)-datetime.timedelta(1)
    list_dt.append(date_.strftime("%Y-%m-%d"))

# 连接mysql 执行一条代码
def job1():
    try:
        db_ms = pymysql.connect(host="172.16.0.181",port=3306,user="root",passwd="biosan")
        cursor_ms = db_ms.cursor()
        cursor_ms.execute("truncate table report.fin_31_account_ori;")
        db_ms.commit()
        cursor_ms.close()
        db_ms.close()
        print("truncate done")
    except:
        print("[Mysql:connect error]")

    for date_ in list_dt:
        command = "sh /home/bidata/report/sql/04_fin_31_account_ori.sh %s" %date_
        (status, output) = commands.getstatusoutput(command)
        print(status)

# def job1():
    # path = "/home/bidata/bidata/sql/"
    # run_sql(path)
"""
if __name__=='__main__':
    schedule.every().day.at("3:30").do(job1)
    while True:
        schedule.run_pending()
        time.sleep(1)
"""
if __name__=='__main__':
    job1()

