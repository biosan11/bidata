# -*- coding: utf-8 -*-
# Author: jsh
# 所有人口经济相关的数据进行补全分析

import numpy as np
import pandas as pd
import pymysql
import datetime

list_year = [2017,2018,2019,2020]

# 获取tsh所有的地市的数据
def get_tsh(city,year_):
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='report')#链接本地数据库
    sql = "select  ddate,sum(inum_person_new) as inum_person_new from report.checklist_tsh_hb where city = '%s' and left(ddate,4) = '%s' group by city,ddate"%(city,year_)#sql语句
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    return curson.fetchall()

# 获取宏观人后所有数据
# 获取所有地市总人口
def get_madata_tp(city):
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='report')#链接本地数据库
    sql = "select  year_2017,year_2018,year_2019,year_2020 from report.x_macrodata where type = 'tp' and city = '%s'"%(city)#sql语句
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    return curson.fetchall()

# 获取出生率
def get_madata_natality(city):
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='report')#链接本地数据库
    sql = "select  year_2017,year_2018,year_2019,year_2020 from report.x_macrodata where type = 'natality' and city = '%s'"%(city)#sql语句
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    return curson.fetchall()

# 获取所有的城市信息
def get_city():
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='edw')#链接本地数据库
    sql = "select  DISTINCT province,city from edw.dic_address where province in('浙江省','安徽省','江苏省','山东省','湖南省','湖北省','福建省')"#sql语句
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    return curson.fetchall()
# print(data)


# 数据合并
if __name__ == '__main__':
    p_city = get_city()
    conn = pymysql.connect(host='172.16.0.181',user='root',passwd='biosan',db='edw')#链接本地数据库
    curson = conn.cursor()
    curson.execute("update report.ccus_01_map_population set fml = null,tsh = null,macrodata = null,fin_data = null,type = null;")
    for i in range(len(p_city)):
        city = p_city[i][1]
        madata_natality = get_madata_natality(city)
        madata_tp = get_madata_tp(city)
        for j in range(len(list_year)):
            tsh = get_tsh(city,list_year[j])
            if len(madata_natality) > 0:
                madata_natality_y = float(madata_natality[0][j])/12
                macrodata = madata_natality_y * float(madata_tp[0][j])*10
                sql = "update report.ccus_01_map_population set macrodata = '%s' where city = '%s' and year(ddate) = '%s'"%(macrodata,city,list_year[j])
                curson.execute(sql)
                conn.commit()
            for k in range(len(tsh)):
                sql = "update report.ccus_01_map_population set tsh = '%s' where city = '%s' and ddate = '%s'"%(tsh[k][1],city,tsh[k][0])
                curson.execute(sql)
                conn.commit()
        print(city+" is ok")
    sql1 = "update report.ccus_01_map_population set fin_data = fml,type = 'fml' where fml is not null  "
    sql2 = "update report.ccus_01_map_population set fin_data = tsh,type = 'tsh' where tsh is not null and fin_data is null "
    sql3 = "update report.ccus_01_map_population set fin_data = macrodata,type = 'macrodata' where macrodata is not null and fin_data is null "
    sql4 = "update report.ccus_01_map_population set fin_data = 0 where fin_data is null "
    curson.execute(sql1)
    curson.execute(sql2)
    curson.execute(sql3)
    curson.execute(sql4)

    # 删除之前用到的临时表
    curson.execute("drop table if exists report.checklist_tsh")
    curson.execute("drop table if exists report.checklist_tsh_hb")
    curson.execute("drop table if exists report.checklist_tsh_yc")
    curson.execute("drop table if exists report.x_macrodata")

    conn.commit()

