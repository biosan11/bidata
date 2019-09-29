#!/usr/bin/python
# coding=utf-8
# Author: jsh
from imp import reload

import pymysql, xlwt
import xlrd
import datetime
from xlutils.copy import copy
import sys
reload(sys)
# sys.setdefaultencoding('utf-8')

list1 = ['产前','新生儿','服务类','仪器设备','all1']
list2 = ['血清学筛查','CMA_产品类','CMA_LDT','NIPT','MSMS','代谢病诊断','all3']
list3 = ['NGS','CMA设备','串联质谱仪','CDS5+GSL120(含KM1,KM2)"','1235+DX6000','GSP','all2']
list4 = ['安徽省','浙江省','江苏省','山东省','福建省','湖南省','湖北省','上海市','all']
list5 = ['2','4','5','6','7','9','10','11','12','13','14','15','16','18','19','20','21','22','23','24','25','26']
# 读取excle内容
def read_excel(bookname, sheetname):
    #获取到excle文件
    workbook=xlrd.open_workbook(bookname,"utf-8")
    worksheet=workbook.sheet_by_name(sheetname)
    nrows = worksheet.nrows
    col_data=worksheet.col_values(0)
    # 获取这个sheet的内容
    for i in range(nrows):
        print(worksheet.row_values(i))

# 删除指定行内容
def updateExcle(bookname,cursor,province):
        workbook=xlrd.open_workbook(bookname,formatting_info=True)
        # 按照格式copy一张新的excle
        workbooknew = copy(workbook)
        ws = workbooknew.get_sheet(0)
        # for i in range(1,nrows):
        #     for j in range(24):
        #         ws.write(i,j,"12")
        # workbooknew.save(u'jsh_test.xls')

def getCon():               #联接到数据库，并封装循环使用，db是数据库名字
    conn = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='bidata', charset='utf8')
    return conn
# 获取特定数据然后放到list中

# 带格式的写入
def setOutCell(outSheet, col, row, value):
    def _getOutCell(outSheet, colIndex, rowIndex):
        row = outSheet._Worksheet__rows.get(rowIndex)
        if not row: return None
        cell = row._Row__cells.get(colIndex)
        return cell
        # HACK to retain cell style.
    previousCell = _getOutCell(outSheet, col, row)
    outSheet.write(row, col, value)
    # HACK, PART II
    if previousCell:
        newCell = _getOutCell(outSheet, col, row)
        if newCell:
            newCell.xf_idx = previousCell.xf_idx

# 这里是省份的操作
def searchALL(bookname):
    conn = getCon()
    workbook=xlrd.open_workbook(bookname,"utf-8",formatting_info=True)
    # 按照格式copy一张新的excle
    workbooknew = copy(workbook)
    ws = workbooknew.get_sheet(0)
    g = 5
    for i in range(len(list4)):
        for j in range(len(list1)):
            sql = "select * from bidata.cusitem_analysis_form where province = '"+ list4[i] +"' and item = '"+ list1[j] +"';"
            cur=conn.cursor()
            cur.execute(sql)
            all = cur.fetchall()
            for k in all:
                for h in range(2,27):
                    setOutCell(ws,h,g,k[h])
            g = g+1
    # 修改内容月份相关
    now = datetime.datetime.now()
    thismon = int(now.month)
    setOutCell(ws,2,1,('当前是'+str(thismon)+'月，以下是1-'+str(thismon-1)+'月'))
    searchinv(workbooknew)
    searchitem(workbooknew)
    searchicity(workbooknew)
    # workbooknew = workbooknew.decode('utf-8')
    workbooknew.save('sale_all.xls')
    # workbooknew.save(r'jsh.xls')


# 这里是对地市的操作
def searchinv(workbooknew):
    ws = workbooknew.get_sheet(1)
    g = 5
    for i in range(len(list4)):
        for j in range(len(list2)):
            sql = "select * from bidata.cusitem_analysis_form where province = '"+ list4[i] +"' and item = '"+ list2[j] +"';"
            conn = getCon()
            cur=conn.cursor()
            cur.execute(sql)
            all = cur.fetchall()
            for k in all:
                for h in range(len(list5)):
                    setOutCell(ws,int(h+2),g,k[int(list5[h])])
            g = g+ 1

def searchitem(workbooknew):
    ws = workbooknew.get_sheet(2)
    g = 5
    for i in range(len(list4)):
        for j in range(len(list3)):
            sql = "select * from bidata.cusitem_analysis_form where province = '"+ list4[i] +"' and item = '"+ list3[j] +"';"
            conn = getCon()
            cur=conn.cursor()
            cur.execute(sql)
            all = cur.fetchall()
            for k in all:
                for h in range(len(list5)):
                    setOutCell(ws,int(h+2),g,k[int(list5[h])])
            g = g+ 1

def searchicity(workbooknew):
    ws = workbooknew.get_sheet(3)
    g = 5
    for i in range(len(list4)):
        sql = "select DISTINCT city from bidata.cusitem_analysis_city where province = '"+ list4[i] +"' "
        conn = getCon()
        cur=conn.cursor()
        cur.execute(sql)
        datalist = []
        all = cur.fetchall()
        for s in all:
            datalist.append(s[0])
        for j in range(len(datalist)):
            for k in range(len(list1)):
                sql1 = "select * from bidata.cusitem_analysis_city where city = '"+ datalist[j] +"'  and item = '"+ list1[k] +"';"
                cur.execute(sql1)
                all1 = cur.fetchall()
                for s in all1:
                    for l in range(25):
                        setOutCell(ws,l,g,s[l])
                g = g+ 1
if __name__ == '__main__':
    # province = sys.argv[1]
    searchALL("example_all.xls")
    # read_excel("halfmon_sales_plan.xlsx","源数据")





