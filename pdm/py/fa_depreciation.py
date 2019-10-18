#!/usr/bin/python
# coding=utf-8
import datetime

import pymysql
import sys
import time,calendar
import warnings
from string import Template

# 参数入口
if len(sys.argv) == 2:
    end_dt = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%d')
    start_dt = end_dt
elif len(sys.argv) == 3:
    start_dt = datetime.datetime.strptime(sys.argv[1], '%Y-%m-%d')
    end_dt = datetime.datetime.strptime(sys.argv[2], '%Y-%m-%d')


#常量
SQL_FILE = '/home/bidata/pdm/sql/fa_depreciation.sql'
LOG_FILE = '/home/bidata/pdm/log/fa_depreciation.log'

# 这里加工时间循环的数字格式
if len(str(end_dt.month)) == 1:
    num1 = str(end_dt.year) + "0" + str(end_dt.month)
else:
    num1 = str(end_dt.year) + str(end_dt.month)

if len(str(start_dt.month)) == 1:
    num2 = str(start_dt.year) + "0" + str(start_dt.month)
else:
    num2 = str(start_dt.year) + str(start_dt.month)

print(num1)
print(num2)
# 需要变成每月最后一天
# d1 = calendar.monthrange(end_dt.year,end_dt.month)
# end_dt = "%d-%d-%d" % (end_dt.year, end_dt.month, d1[1])

# 系统当前时间
sysCurDate=time.strftime("%Y%m%d%H%M%S",time.localtime(time.time()))
warnings.filterwarnings("ignore")
# 参数列表
conf_dict = {
    'sysCurDate':sysCurDate
}

# 获取sql文件,sql语句
def get_sqlfile(conf_dict):
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
    # 这里实现按年月循
    for i in range(int(num2),int(num1)+1):
        try:
            # 需要变成每月最后一天
            year = int(str(i)[0:4])
            mon = int(str(i)[4:6])
            d1 = calendar.monthrange(year,mon)
            end_dt = "%d-%d-%d" % (year,mon, d1[1])
            conf_dict['end_dt'] = end_dt
            print(conf_dict)
            #创建游标对象
            cursor = db.cursor()
            sql_commands=get_sqlfile(conf_dict)
            fo = open(LOG_FILE, "a")
            fo.write(('\n{}开始执行{}数据加载日志:\n').format(sysCurDate,end_dt))
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
        except:
            1
    print('完成')
    db.close()


