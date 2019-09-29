#!/usr/bin/env python
# -*- coding:utf-8 -*-
# author:Jin

import pymysql
import pandas as pd
import numpy as np
from sqlalchemy import create_engine
pd.options.mode.chained_assignment = None ##关闭pandas警告

def editor_outliers(df):
    if len(df) <= 6:
        df["quarter_1"] = None
        df["quarter_3"] = None
        df["low"] = None
        df["up"]  = None
        df["inum_person_ad"] = df["inum_person"]
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

def job(df):
    data_cusitem = df.drop_duplicates(["ccuscode", "item_code"])[["ccuscode", "item_code"]]
    data_cusitem.reset_index(drop=True, inplace=True)
    conn1 = create_engine('mysql+pymysql://root:biosan@172.16.0.181:3306/pdm', encoding='utf8')
    for index in data_cusitem.index:
        df_cusitem = df[(df["ccuscode"] == data_cusitem.loc[index][0]) & (data_all["item_code"] == data_cusitem.loc[index][1])]
        print(data_cusitem.loc[index][0],"---",data_cusitem.loc[index][1])
        df_ = editor_outliers(df_cusitem)
        pd.io.sql.to_sql(df_, "checklist_fx_pd", conn1, if_exists='append')

if __name__=='__main__':
    conn = pymysql.connect(host="172.16.0.181", port=3306, user="root", passwd="biosan")
    cursor = conn.cursor()
    cursor.execute("drop table if exists pdm.checklist_fx_pd;")
    conn.commit()
    sql_ = "select * from pdm.checklist_fx;"
    data_all = pd.read_sql(sql_, con=conn)
    cursor.close()
    conn.close()
    job(data_all)