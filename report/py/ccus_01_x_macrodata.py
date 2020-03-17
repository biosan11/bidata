# -*- coding: utf-8 -*-
# Author: jsh
# 所有人口经济相关的数据进行补全分析

import numpy as np
import pandas as pd
import pymysql
import datetime
from statsmodels.tsa.api import Holt
from pandas.core.frame import DataFrame



list_type = ['gdp','agdp','hrp','tp','abudget_nc','abudget_cs','natality']
# 获取数据
def get_date(city):
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='edw')#链接本地数据库
    # sql = "select  city,year_,gdp,agdp,hrp,tp,abudget_nc,abudget_cs,natality,province from edw.x_macrodata where city = '三明市' order by city,year_"#sql语句
    sql = "select  city,year_,gdp,agdp,hrp,tp,abudget_nc,abudget_cs,natality,province from edw.x_macrodata where city = '%s' order by city,year_"%(city)#sql语句
    data = pd.read_sql(sql,conn)#获取数据
    return data
# print(data)

# 获取所有的城市信息
def get_city():
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='edw')#链接本地数据库
    sql = "select  DISTINCT city from edw.x_macrodata"#sql语句
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    return curson.fetchall()
# print(data)


def ins_date(sql):
    # engine = create_engine('mysql+pymysql://root:biosan@172.16.0.181:3306/jsh')
    # df.to_sql('x_macrodata', engine, if_exists='append',index= False)
    # print("插入成功")
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='jsh', charset='utf8')
    curson = conn.cursor()
    # 删除19年数据重新导入
    curson.execute(sql)
    conn.commit()



# 返回月份函数，用于判断是否需要增加数据
def months(str1,str2):
    year1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").year
    year2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").year
    month1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").month
    month2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").month
    num=(year1-year2)*12+(month1-month2)
    return num

# 中位数的计算
def median(list_median):
    list_median.sort()
    mid = int(len(list_median) / 2)
    if len(list_median) % 2 == 0:
        median = (list_median[mid-1] + list_median[mid]) / 2.0
    else:
        median = list_median[mid]
    return median


# 返回月份函数，用于判断是否需要增加数据
def months(str1,str2):
    year1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").year
    year2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").year
    month1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").month
    month2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").month
    num=(year1-year2)*12+(month1-month2)
    return num

# list最小不是0的数
def get_min_list(list_value):
    min_list = 0
    for i in list_value:
        if i == '0':
            min_list = min_list +1
        else:
            return min_list

# list最大不是0的数
def get_max_list(list_value):
    list_value1 = list_value.copy()
    list_value1.reverse()
    max_list = 19
    for i in list_value1:
        if i == '0':
            max_list = max_list - 1
        else:
            return max_list

def list_to_df(y_year,list_value):
    c = {
        'y_year':y_year,
        'list_value':list_value
    }
    return DataFrame(c)

#得到一个指定长度并且数值全部是0的数据
def get_zero_list(min_list):
    list = []
    for i in range(min_list):
        list.append("0")
    return list

# list数据修复,修复中间出现0的现象
def error_date(list_value):
    list_value1 = list_value
    for i in range(len(list_value)):
        # print(list_value[i])
        if list_value[i] == "0":
            list_diff = list_value[i+1:]
            for j in range(len(list_diff)):
                if list_diff[j] != "0":
                    list_value1[i] = (float(list_value[i-1]) + float(list_diff[j])) / 2
                    break
    return list_value1

# 补全缺失数据
def date_repair(y_year,list_value):
    min_list = get_min_list(list_value)
    # min_list = 0
    max_list = get_max_list(list_value)
    y_year_fin = y_year + ['2019','2020']
    y_year = y_year[min_list:max_list]
    list_value = list_value[min_list:max_list]
    # 如果这个地市数据只有一个有值，初始化3个进去，然后预测统一了
    if len(list_value) == 1:
        y_year = ['2000','2001','2002']
        list_value = [list_value[0],list_value[0],list_value[0]]
        min_list = 0
    list_value = error_date(list_value)

    my_df = list_to_df(y_year,list_value)
    list_value_for = date_forecast(my_df,min_list)
    return list_value_for
    # print(list_value_for)

def date_forecast(date,min_list):
    ddate = date["y_year"].values.tolist()
    list_value = date["list_value"].values.tolist()
    data = date.set_index('y_year')
    data['list_value'] = data['list_value'].astype('float64')
    ddate_diff = 20 - len(ddate) + 1
    test = date
    # if len(date) <= 12 and len(date) >5:
    #     test = data[12-len(data):12]
    # elif len(data) <= 3:
    #     test = date.copy()
    # else:
    #     test = data[len(data)-12:len(data)]
    #     print(test)
    # 这里是设置特征函数，规划出一条一元一次方程,出生情况直接按照所有数据做出一条直线
    fit = Holt(np.asarray(test['list_value'])).fit(smoothing_level=0.3, smoothing_slope=0.1)
    # 这里预测截止到2020年12月的数据
    # num_list = fit.forecast(len(test)+ddate_diff+1)[:len(test)+1]
    num_list = fit.forecast(ddate_diff)
    # 这里存在一个问题，他不是所有的数据都是从02年开始的，要么就是补全，要么就是全部设为0
    for i in num_list:
        list_value.append(i)
    # 这里是按照02年开始取数，补全前面的删除后面的
    if min_list != None:
        list_value = get_zero_list(min_list) + list_value
        list_value = list_value[:21]
    return list_value


if __name__ == '__main__':
    # 建地市人口表
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='ufdata', charset='utf8')
    curson = conn.cursor()
    create_sql = "CREATE TABLE report.x_macrodata (" \
                          "`province` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '省份'," \
                          " `city` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '城市'," \
                          "`type` varchar(255) COLLATE utf8_bin DEFAULT NULL COMMENT '类型'," \
                          "`year_2000` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2000年份'," \
                          "`year_2001` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2001年份'," \
                          "`year_2002` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2002年份'," \
                          "`year_2003` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2003年份'," \
                          "`year_2004` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2004年份'," \
                          "`year_2005` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2005年份'," \
                          "`year_2006` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2006年份'," \
                          "`year_2007` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2007年份'," \
                          "`year_2008` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2008年份'," \
                          "`year_2009` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2009年份'," \
                          "`year_2010` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2010年份'," \
                          "`year_2011` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2011年份'," \
                          "`year_2012` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2012年份'," \
                          "`year_2013` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2013年份'," \
                          "`year_2014` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2014年份'," \
                          "`year_2015` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2015年份'," \
                          "`year_2016` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2016年份'," \
                          "`year_2017` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2017年份'," \
                          "`year_2018` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2018年份'," \
                          "`year_2019` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2019年份'," \
                          "`year_2020` varchar(24) CHARACTER SET utf8mb4 NOT NULL DEFAULT '' COMMENT '2020年份'" \
                          ") ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_bin COMMENT='宏观数据整合';"
    curson.execute("drop table if exists report.x_macrodata")
    curson.execute(create_sql)
    city = get_city();
    for k in city:
        date = get_date(k)
        list_date = list(date)
        y_year = date["year_"].values.tolist()
        c = {
        'year_':y_year+['2019','2020']
        }
        # 创建一个最终的df
        df_fin = DataFrame(c)
        df_fin['city']=date["city"].values.tolist()[0]
        # 列表循环增加
        for i in range(2,9):
            list_value = date[list_date[i]].values.tolist()
            # print(list_value)
            # print(list_value)
            # 输入两个lsit返回一个已经预测完的数据
            list_value = date_repair(y_year,list_value)
            # print(list_value)
            # sql 拼接
            sql = "insert into report.x_macrodata select '%s','%s','%s',"%(date['province'][0],date['city'][0],list_type[i-2])
            sql = sql + ''.join(str(list_value))
            ins_date(sql.replace( '[','').replace( ']',''))
            # 数据入df
            # df_fin[list_date[i]] = list_value
        print(str(k) + "ok")
        # 插入数据库
        # ins_date(df_fin)



