#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author:Jin

import datetime
import pymysql
import pandas as pd
import numpy as np
import subprocess # 运行shell命令
from sqlalchemy import create_engine
from statsmodels.tsa.api import Holt
pd.options.mode.chained_assignment = None ##关闭pandas警告
# 自定义，增加计算增加月份得到日期的函数
def add_month(dt,n):
    if dt.month + n > 12:
        year_interval = int((dt.month + n) / 12)
        dt_new = datetime.datetime(dt.year+year_interval,dt.month+n - year_interval*12,dt.day)
    else:
        dt_new = datetime.datetime(dt.year,dt.month+n,dt.day)
    return dt_new

# 传入一个dataframe 找出异常值（用四分位数法） 并用中位数替换
def editor_outliers(df):
    if len(df) <= 6:
        df["quarter_1"] = None
        df["quarter_3"] = None
        df["low"] = None
        df["up"]  = None
        df["inum_person_ad"] = df["inum_person"]
    elif len(df) >=14:
        df.sort_values(by = "ym",inplace = True)
        df.reset_index(drop = True,inplace= True)
        if (len(df) % 2) == 0:
            n = int(len(df)/2)
        else:
            n = int((len(df)+1)/2)
        df_1 = df.iloc[:n]
        df_2 = df.iloc[n:]
        df = pd.concat([editor_outliers(df_1),editor_outliers(df_2)],ignore_index=True)
    else:
        df.sort_values(by = "ym",inplace = True)
        df.reset_index(drop = True,inplace= True)
        interval = df.inum_person.quantile(0.75)-df.inum_person.quantile(0.25)
        df["quarter_1"] = df.inum_person.quantile(0.25)
        df["quarter_3"] = df.inum_person.quantile(0.75)
        if df.inum_person.quantile(0.25) < 1.5 * interval:
            df["low"] = 1
        else:
            df["low"] = df["quarter_1"] - 1.5 * interval
        df["up"]  = df["quarter_3"] + 1.5 * interval
        index = df[(df.inum_person < df.low) | (df.inum_person > df.up)].index
        df["inum_person_ad"] = df["inum_person"]
        df.at[index,"inum_person_ad"] = df.inum_person.quantile(0.5)
    return df

# 定义用holt方法，进行时间序列预测
def holt_(df,x,y,n):
    df["ym"] = pd.to_datetime(df.ym)
    if len(df) <= 7:
        df_tsa = df.copy()
        df_tsa["mark_forecast"] = "ori"
    else:
        df_1 = df.copy()
        df_1["mark_forecast"] = "ori"
        fit = Holt(np.asarray(df['inum_person_ad'])).fit(smoothing_level=x, smoothing_slope=y)
        df_2 = pd.DataFrame(columns = df_1.columns)
        dt_list = []
        dt_last = max(df["ym"])
        for i in range(1,n+1):
            dt_list.append(add_month(dt_last,i))
        df_2['ym'] = dt_list
        df_2['inum_person_ad'] = fit.forecast(n)
        df_2["mark_forecast"] = "forecast"
        df_2['ccuscode'] = max(df_1['ccuscode'])
        df_2['item_code'] = max(df_1['item_code'])
        df_tsa = pd.concat([df_1,df_2],ignore_index=True)
    return df_tsa

def job(df):
    data_cusitem = df.drop_duplicates(["ccuscode", "item_code"])[["ccuscode", "item_code"]]
    data_cusitem.reset_index(drop=True, inplace=True)
    conn1 = create_engine('mysql+pymysql://root:biosan@172.16.0.181:3306/pdm', encoding='utf8')
    for index in data_cusitem.index:
        df_cusitem = df[(df["ccuscode"] == data_cusitem.loc[index][0]) & (data_all["item_code"] == data_cusitem.loc[index][1])]
        print(index)
        print(data_cusitem.loc[index][0],"---",data_cusitem.loc[index][1])
        df_1 = editor_outliers(df_cusitem)
        df_2 = holt_(df_1,0.3,0.1,4)
        pd.io.sql.to_sql(df_2, "checklist_fx_pd", conn1, if_exists='append')

if __name__=='__main__':
    # 先运行 checklist_fx.sql 脚本
    sqlpath = "/home/bidata/pdm/sql/checklist_fx.sql"
    command = "mysql -h172.16.0.181 -p3306 -uroot -pbiosan <%s" % sqlpath
    (status, output) = subprocess.getstatusoutput(command)
    print(status)
    #运行查找异常值脚本 以及 holt时间序列预测
    conn = pymysql.connect(host="172.16.0.181", port=3306, user="root", passwd="biosan")
    cursor = conn.cursor()
    cursor.execute("drop table if exists pdm.checklist_fx_pd;")
    conn.commit()
    sql_ = "select * from pdm.checklist_fx;"
    data_all = pd.read_sql(sql_, con=conn)
    cursor.close()
    conn.close()
    job(data_all)
    # 如果预测出的数据中有负数，将负数都替换成1
    conn = pymysql.connect(host="172.16.0.181", port=3306, user="root", passwd="biosan")
    cursor = conn.cursor()
    cursor.execute("update pdm.checklist_fx_pd set inum_person_ad = 1 where inum_person_ad < 0 ;")
    conn.commit()
    cursor.close()
    conn.close()