#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author:Jin

import os
import schedule,datetime,time
import commands


def run_sql(sqlpath_list):
    today = datetime.datetime.today()
    now = time.strftime("%H:%M:%S")
    with open("/home/bidata/report/log/log.txt","a+") as log:
        log.write("\n\n\n\nMANUAL")
        log.write("\ndate:%s\n**************************" %today)
    for sqlpath in sqlpath_list:
        print(sqlpath)
        command = "mysql -h172.16.0.181 -p3306 -uroot -pbiosan <%s" %sqlpath
        (status, output) = commands.getstatusoutput(command)
        print(status)
        with open("/home/bidata/report/log/log.txt","a+") as log:
            log.write("\ntime:%s\n-----------------------\n" %now)
            log.write("%s\n%s\n%s" %(sqlpath,status,output))

def job1():
    sql_0  = "/home/bidata/report/sql/01_auxi_01_ccuscode_per.sql"
    sql_1  = "/home/bidata/report/sql/01_auxi_01_province_per.sql"
    sql_2  = "/home/bidata/report/sql/15_fin_prov_10_expenses.sql"
    sql_3  = "/home/bidata/report/sql/16_fin_prov_10_expenses_else.sql"
    sql_4  = "/home/bidata/report/sql/17_fin_prov_10_expenses_all.sql"
    sql_5  = "/home/bidata/report/sql/18_fin_prov_11_expenses_fw.sql"
    sql_6  = "/home/bidata/report/sql/19_fin_prov_11_expenses_deptshare.sql"
    sql_7  = "/home/bidata/report/sql/20_fin_prov_08_expenses_base.sql"
    sql_8  = "/home/bidata/report/sql/21_fin_prov_08_expenses_share.sql"
    sql_9  = "/home/bidata/report/sql/22_fin_prov_08_expenses_share_qs.sql"
    sql_10 = "/home/bidata/report/sql/23_fin_prov_12_expenses_deptshare_else.sql"
    sqlpath_list = [sql_1,sql_2,sql_3,sql_4,sql_5,sql_6,sql_7,sql_8,sql_9,sql_10]
    run_sql(sqlpath_list)

if __name__=='__main__':
    job1()



