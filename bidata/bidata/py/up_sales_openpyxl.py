import openpyxl 
import pymysql

def get_data():
    db = pymysql.connect(host='172.16.0.181', user='root', password='biosan', db='bidata', charset='utf8')
    cursor = db.cursor()
    cursor.execute("select * from bidata.cusitem_analysis_mon;")
    result = cursor.fetchall()
    return result

def make_xl():
    wb = openpyxl.load_workbook(r'example_jj.xlsx')
    ws1 = wb['源数据']
    wb.remove(ws1)
    ws = wb.create_sheet('源数据',0)
    ws.append(['产品线辅助','重点项目（产品）_业务类型','日期','大区','省份','地级市','客户名称','项目层次 - 产品线','项目层次 - 产品组','项目层次 - 项目明细','重点项目（产品）','是否设备','业务类型','b12年度ytd计划_去除当月','b12年度ytd计划_调整占比_去除当月','b11年度ytd收入_去除当月','a42当季ttl计划金额','a42当季ttl计划金额_调整占比','a31季度qtd收入金额','a22当月计划金额','a22当月计划金额_调整占比','a23当月计划金额_new','b03每月1-7实际收入','b04每月8-14实际收入','b05每月15-23实际收入','b05每月24以后实际收入','a21当月收入金额'])
    res = get_data()
    for i in res:
        ws.append(i)
    wb.save('sale_all_new.xlsx')

make_xl()
