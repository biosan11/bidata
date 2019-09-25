# -*- coding: utf-8 -*-
# Author: jsh

import pymysql
import os
import time
import datetime

# 获取到连接，获取到需要重新运行的模型
def get_rlist():
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    sql = "select db,tb_name,min(ddate) from tracking.jc_abnormal_day where type = '项目清洗' or type = '客户清洗' " \
          "or type = '产品清洗' or type = '最终客户清洗' and type <> '数量监控' group by tb_name order by db"
    curson.execute(sql)
    rest = curson.fetchall()
    return rest

# 根据相应的模型执行脚本
def run_py():
    rest = get_rlist()
    path1 = 'python /home/bidata/edw/py/'
    path2 = 'python /home/bidata/pdm/py/'
    for list in rest:
        # 线上的收入模块的重新运行
        if (list[0] == 'UFDATA_111' or list[0] == 'UFDATA_889' or list[0] == 'UFDATA_666' or list[0] == 'UFDATA_222' or list[0] == 'UFDATA_588' or list[0] == 'yj') and list[1] != "account_fy":
            if str(list[2]) == 'None' :
                path_edw = path1 + list[1] + ".py" + " " + str(list[2])
                path_edw = path_edw.replace("None",time.strftime("%Y-%m-%d", time.localtime()))
                path_pdm = path2 + list[1] + ".py" + " " + time.strftime("%Y-%m-%d", time.localtime())
                print(path_edw)
                os.system(path_edw)
                print(path_pdm)
                os.system(path_pdm)
            else:
                path_edw = path1 + list[1] + ".py" + " " + str(list[2]+ datetime.timedelta(seconds = -1))
                path_edw = path_edw.replace("None",time.strftime("%Y-%m-%d", time.localtime()))
                path_pdm = path2 + list[1] + ".py" + " " + time.strftime("%Y-%m-%d", time.localtime())
                print(path_edw)
                os.system(path_edw)
                print(path_pdm)
                os.system(path_pdm)
        # 线下的excel的自动运行
        elif list[0] == "excel":
            path_ex = "sh /home/bidata/edw/xx_sql/user.sh " + list[1] + ".sql"
            print(path_ex)
            os.system(path_ex)
            if list[1] == "x_sales_bk":
                os.system("sh /home/bidata/pdm/py/example.sh invoice_order_xx.sql")
            elif list[1] == "x_sales_bkgr":
                os.system("sh /home/bidata/pdm/py/example.sh invoice_order_xx.sql")
                os.system("sh /home/bidata/pdm/py/example.sh outdepot_order_xx.sql")
            elif list[1] == "x_ldt_list_before" or list[1] == "x_ldt_bk" or list[1] == "x_sales_hospital":
                os.system("sh /home/bidata/pdm/py/example.sh checklist.sql")
        # 线上的crm模块的不需要运行第三层
        elif list[0] == "crm":
            path_edw = path1 + list[1] + ".py" + " " + str(list[2])
            path_edw = path_edw.replace("None",time.strftime("%Y-%m-%d", time.localtime()))
            print(path_edw)
            os.system(path_edw)
        # 费用模块的部门清洗只需要运行第三层
        elif list[1] == "account_fy":
            path_pdm = path2 + list[1] + ".py" + " " + time.strftime("%Y-%m-%d", time.localtime())
            os.system(path_pdm)

if __name__ == '__main__':
    # 重新运行当天的数据
    run_py()
    # 重新运行检测数据的统计
    os.system("python /home/bidata/jc/py/jc_abnormal_day.py")
    # 刷新bi层数据
    os.system("python /home/bidata/bidata/schedule/run_sql_manual.py")
