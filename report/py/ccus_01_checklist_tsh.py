# -*- coding: utf-8 -*-
# Author: jsh

import numpy as np
import pandas as pd
import pymysql
import datetime
from sqlalchemy import create_engine
from dateutil.relativedelta import relativedelta
from pandas.core.frame import DataFrame
from statsmodels.tsa.api import ExponentialSmoothing
import os

# 获取数据
def get_date():
    conn = pymysql.connect(host='172.16.0.181',
                user='root',
                passwd='biosan',
                db='edw')#链接本地数据库
    sql = "select ccusname,ddate,sum(inum_person) as inum_person from report.checklist_tsh group by ccusname,ddate order by ccusname,ddate"#sql语句
    data = pd.read_sql(sql,conn)#获取数据
    return data
# print(data)

def ins_date(df):
    engine = create_engine('mysql+pymysql://root:biosan@172.16.0.181:3306/report')
    df.to_sql('checklist_tsh_yc', engine, if_exists='append',index= False)
    print("插入成功")

# 返回月份函数，用于判断是否需要增加数据
def months(str1,str2):
    year1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").year
    year2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").year
    month1=datetime.datetime.strptime(str1[0:10],"%Y-%m-%d").month
    month2=datetime.datetime.strptime(str2[0:10],"%Y-%m-%d").month
    num=(year1-year2)*12+(month1-month2)
    return num

def y_mon(date_fir):
    #这是起始时间，假设某位博主是2018年10月6日注册的
    start=date_fir
    #计算起止日期之间有多少个月（月份的差值）
    month_num=months("2020-12-01",str(date_fir))
    # print(month_num)
    time_list=[]
    year=start.year
    month=start.month
    for m in range(month_num+1):
        #把年月的小列表追加进大列表
        date_str = str(year)+'-'+str(month)+'-01'
        time_list.append(date_str)
        #月份加1
        month+=1
        #当月份达到13的时候，需要再从1月开始数，而且这代表跨年了，所以年份加1
        if month==13:
            month=1
            year+=1
    #我希望最终的结果是当前月份在最前面，离我越远的月份越靠后，所以这里要反转列表
    time_list.reverse()
    return time_list[:len(time_list)-1]

# 异常值处理，现在定的是取除去他自己周围6个数中位数的1.2倍来处理，异常之修复
#缺失值处理
def error_date(data):
    ddate = date["ddate"].values.tolist()
    inum_person = date["inum_person"].values.tolist()
    # print(inum_person)
    for i in range(len(ddate)):
        if inum_person[i] == 0 and len(ddate)>7:
            if i <= 3:
                list = inum_person[0:7]
                # 删除自己
                list.pop(i)
                # 删除指定值0
                list = list_del(list)
                inum_person[i] = median(list)
            elif i >= len(ddate)-4:
                list = inum_person[len(ddate)-7:len(ddate)]
                # 删除自己
                list.pop(7 - len(ddate) + i)
                # 删除指定值0
                list = list_del(list)
                inum_person[i] = median(list)
            elif  inum_person[i+1] == 0:
                if i <= 7:
                    list = inum_person[0:i-1]
                    inum_person[i] = median(list)
                else:
                    list = inum_person[i-8:i-1]
                    inum_person[i] = median(list)
            else:
                list = inum_person[i-3:i+4]
                # 删除自己
                list.pop(3)
                # 删除指定值0
                list = list_del(list)
                inum_person[i] = median(list)
        elif inum_person[i] == 0:
            list = inum_person
            list = list_del(list)
            inum_person[i] = median(list)
    date['inum_person_true'] = inum_person
    return date


    #异常值处理
    #绘制散点图,价格为横轴
    # data1 = data.T#转置
    # price = data1.values[1]
    # print(price)
    # comment = data1.values[2]
    # plt.plot(price,comment,'o')
    # plt.show()

# 中位数的计算
def median(list_median):
    list_median.sort()
    mid = int(len(list_median) / 2)
    if len(list_median) % 2 == 0:
        median = (list_median[mid-1] + list_median[mid]) / 2.0
    else:
        median = list_median[mid]
    return median

# list 删除指定数值的
def list_del(list):
    list1 = []
    for i in range(len(list)):
        if list[i] != "0" or list[i] != 0:
            list1.append(list[i])
    return list1

# 补全缺失数据
def date_repair(date):
    ddate = date["ddate"].values.tolist()
    max_mon = str(ddate[len(date)-1])
    min_mon = str(ddate[0])
    mon_int = months(max_mon,min_mon)
    # 得到最大最小月份，进行数据修复
    if mon_int == (len(date)-1):
        print("这个df是饱满的，无需添加0")
    # 这里对缺失数据进行补0操作
    else:
        for i in range(len(ddate)):
            date = date_bu(date)
    return date

# 补全数据细节
def date_bu(date):
    ddate = date["ddate"].values.tolist()
    ccusname = date["ccusname"].values.tolist()
    max_mon = str(ddate[len(date)-1])
    min_mon = str(ddate[0])
    mon_int = months(max_mon,min_mon)
    min_mon1 = ddate[0]
    for i in range(len(ddate)):
        if ddate[i] == min_mon1:
            min_mon1 = min_mon1 + relativedelta(months=+1)
        else:
            # df数据怎加一行
            # print(date)
            # print(len(date["ddate"].values.tolist()))
            # print(ccusname)
            # print(min_mon1)
            date.loc[len(date["ddate"].values.tolist())] = [ccusname[0],min_mon1,0]
            return date.sort_index(by = 'ddate')
            # print(min_mo
    return date.sort_index(by = 'ddate')

# 数据预测
def date_forecast(date):
    ddate = date["ddate"].values.tolist()
    data = date.drop('inum_person', 1).set_index('ddate').drop('ccusname', 1)
    data['inum_person_true'] = data['inum_person_true'].astype('float64')
    ddate_diff = months('2020-12-01',str(ddate[len(ddate)-1]))
    mon_list = y_mon(ddate[len(ddate)-1])
    mon_list = list(reversed(mon_list))
    # print(mon_list)
    test = []
    test = data[len(data)-20:len(data)]
    # test = data
    y_hat_avg = test.copy()
    # 这里是设置特征函数，规划出一条一元一次方程
    # fit = Holt(np.asarray(test['inum_person_true'])).fit(smoothing_level=0.4, smoothing_slope=0.1)
    print(test)
    if len(test) <= 12:
        fit = ExponentialSmoothing(np.asarray(test['inum_person_true']), seasonal_periods=3, trend='add', seasonal='add', ).fit()
    else:
        fit = ExponentialSmoothing(np.asarray(test['inum_person_true']), seasonal_periods=6, trend='add', seasonal='add', ).fit()
    # 这里预测截止到2020年12月的数据
    num_list = fit.forecast(len(test)+ddate_diff+1)[len(test)+1:]
    # print(num_list)

    y_hat_avg['Holt_linear'] = fit.forecast(len(test))
    # print(y_hat_avg)
    # plt.figure(figsize=(8, 6))
    # plt.plot(data['inum_person_true'], label='Train')
    # plt.plot(test['inum_person_true'], label='Test')
    # plt.plot(y_hat_avg['Holt_linear'], label='Holt_linear')
    # plt.legend(loc='best')
    # # plt.show()

    # 训练集数据和预测数据放到一起
    ddate_fin = [str(i) for i in ddate] + mon_list
    inum_person = date["inum_person_true"].values.tolist()
    for i in num_list:
        inum_person.append(i)
    c = {
        'ddate':ddate_fin,
        'inum_person':inum_person
    }
    return DataFrame(c)


if __name__ == '__main__':
    # 先建立表，生成预测之前的数据
    os.system("sh /home/bidata/report/sql/user.sh ccus_01_checklist_tsh_01.sql")
    # 开始预测
    date_all = get_date()
    # df按照-ccusname-来切片
    listType = date_all['ccusname'].unique()
    for i in range(len(listType)):
        date =  date_all[date_all['ccusname'].isin([listType[i]])]
        print(listType[i])
        #增加空值0
        date = date_repair(date)
        #异常数据修复
        if len(date) <= 5:
            print("数据太少不满足预测条件")
        else:
            date = error_date(date)
            # 数据预测到2020年
            df = date_forecast(date)
            # 补全客户名称
            df['ccusname']=listType[i]
            #插入数据
            ins_date(df)
            # print(df)

            # df.plot(kind='line')
            # plt.show()

    # 生成最终表
    os.system("sh /home/bidata/report/sql/user.sh ccus_01_checklist_tsh_02.sql")
