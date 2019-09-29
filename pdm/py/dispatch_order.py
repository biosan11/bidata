#!/usr/bin/python
# coding=utf-8

import pymysql
import sys
import time
import datetime
import ConfigParser
import warnings
from string import Template

# 参数入口
start_dt = sys.argv[1]

#常量
SQL_FILE = '/home/bidata/pdm/sql/dispatch_order.sql'
LOG_FILE = '/home/bidata/pdm/log/dispatch_order.log'

# 系统当前时间
sysCurDate=time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))

warnings.filterwarnings("ignore")

# 参数列表
conf_dict = {
    'start_dt':start_dt,
    'sysCurDate':sysCurDate
}

# 获取sql文件,sql语句
def get_sqlfile():
    tar_sql_commands = []
    with open(SQL_FILE) as f:
            sql_command=''
            for line in f:
                if not line.strip().startswith('--'):
                        if line.strip().endswith(';'):
                                sql_command = sql_command + line[:line.index(';')] + '\n'
                                tar_sql_commands.append(Template(sql_command).substitute(conf_dict))
                                sql_command = ''
                        else:
                                sql_command = sql_command + line
    return tar_sql_commands

if __name__ == '__main__':
    # 可以在sql中切换 database
    #打开数据库连接
    db = pymysql.connect('172.16.0.181','root','biosan','bidata')
    #创建游标对象
    cursor = db.cursor()
    sql_commands=get_sqlfile()
    fo = open(LOG_FILE, "a")
    fo.write(('\n{}开始执行{}数据加载日志:\n').format(sysCurDate,start_dt))
    for sql_command in sql_commands:
        start_time=time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
        fo.write('SQL开始执行时间：'+start_time+'\n')
        fo.write(sql_command+';\n')
        fo.flush()
        result = cursor.execute(sql_command+';\n')
        end_time=time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
        fo.write('SQL结束执行时间：'+end_time+'\n')
        fo.flush()
        if result == 'error':
        	 sys.exit()
    fo.close()
    db.commit()
    print('1')
    db.close()

#使用execute()方法执行sql语句
#cursor.execute('show tables')

#fetchone()方法获取返回对象的单条数据
#data = cursor.fetchone()
#print('Database version:{0}'.format(data))



