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
from xpinyin import Pinyin

# sys.setdefaultencoding('utf-8')

list = ['产前','新生儿','服务类','仪器设备','all1','血清学筛查','CMA_产品类','CMA_LDT','NIPT','MSMS','代谢病诊断','all3','NGS','CMA设备','串联质谱仪','CDS5+GSL120(含KM1,KM2)"','1235+DX6000','GSP','all2']
list3 = ['4','5','6','7','8','12','13','14','15','16','17','18','22','23','24','25','26','27','28']
list2 = ['2','3','4','5','6','7','8','9','10','11','12','13','14','15','16','17','18','19','20','21','22','23','24','25','26']
list4 = ['2','4','5','6','7','9','10','11','12','13','14','15','16','18','19','20','21','22','23','24','25','26']
# 城市的list
list5 = '产前','新生儿','服务类','仪器设备','all1'

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
def searchALL(bookname,province):
    conn = getCon()
    workbook=xlrd.open_workbook(bookname,"utf-8",formatting_info=True)
    # 按照格式copy一张新的excle
    workbooknew = copy(workbook)
    ws = workbooknew.get_sheet(0)
    for i in range(len(list)):
        sql = "select * from bidata.cusitem_analysis_form where province = '"+ province +"' and item = '"+ list[i] +"';"
        cur=conn.cursor()
        cur.execute(sql)
        all = cur.fetchall()
        for k in all:
                if(i<5):
                    for j in range(2,2+len(list2)):
                        setOutCell(ws,int(list2[j-2]),int(list3[i]),k[j])
                else:
                    for j in range(2,len(list4)+2):
                        setOutCell(ws,int(list2[j-2]),int(list3[i]),k[int(list4[j-2])])
    # 修改内容月份相关
    now = datetime.datetime.now()
    thismon = int(now.month)
    setOutCell(ws,2,1,('当前是'+str(thismon)+'月，以下是1-'+str(thismon-1)+'月'))
    searchCity(workbooknew)
    # workbooknew = workbooknew.decode('utf-8')
    p = Pinyin()
    workbooknew.save('sale_'+p.get_pinyin(province[:-1],'')+'.xls')
    # workbooknew.save(r'jsh.xls')


# 这里是对地市的操作
def searchCity(workbooknew):
    ws = workbooknew.get_sheet(1)
    sql = "select DISTINCT city from bidata.cusitem_analysis_city where province = '"+ province +"' "
    conn = getCon()
    cur=conn.cursor()
    cur.execute(sql)
    datalist = []
    all = cur.fetchall()
    for s in all:
        datalist.append(s[0])
    x = 4
    for i in range(len(datalist)):
        for j in range(len(list5)):
            sql1 = "select * from bidata.cusitem_analysis_city where city = '"+ datalist[i] +"'  and item = '"+ list5[j] +"';"
            print(sql1)
            cur.execute(sql1)
            all1 = cur.fetchall()
            for k in all1:
                for h in range(25):
                    setOutCell(ws,int(h),x,k[h])
                    print(int(h),x,str(k[h]))
            x += 1


if __name__ == '__main__':
    province = sys.argv[1]
    # province = '安徽省'
    list = searchALL("example.xls",province)
    # read_excel("halfmon_sales_plan.xlsx","源数据")





