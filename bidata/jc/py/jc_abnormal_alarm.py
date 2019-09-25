
# -*- coding: utf-8 -*-
# Author: hkey
from email.header import Header
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
# from email.utils import parseaddr, formataddr
from email import encoders
from email.mime.base import MIMEBase
import smtplib, os
import pymysql, xlwt

class CreateExcel(object):
    '''查询数据库并生成Excel文档'''
    def __init__(self, mysql_info):
        self.mysql_info = mysql_info
        self.conn = pymysql.connect(host = self.mysql_info['host'], port = self.mysql_info['port'],
                               user = self.mysql_info['user'], passwd = self.mysql_info['passwd'],
                               db = self.mysql_info['db'], charset='utf8')
        self.cursor = self.conn.cursor()
    def getUserData(self, sql):
        # 查询数据库
        self.cursor.execute(sql)
        table_desc = self.cursor.description
        result = self.cursor.fetchall()
        if not result:
            print('没数据。')
            return "1"
        else:
            # 返回查询数据、表字段
            print('数据库查询完毕'.center(30, '#'))
            return result, table_desc

    def writeToExcel(self, data, filename):
        # 生成Excel文档
        # 注意：生成Excel是一列一列写入的。
        result, fileds = data
        wbk = xlwt.Workbook(encoding='utf-8')
        # 创建一个表格
        sheet1 = wbk.add_sheet('sheet1', cell_overwrite_ok=True)
        for filed in range(len(fileds)):
            # Excel插入第一行字段信息
            sheet1.write(0, filed, fileds[filed][0]) # (行，列，数据)

        for row in range(1, len(result)+1):
            # 将数据从第二行开始写入
            for col in range(0, len(fileds)):
                sheet1.write(row, col, result[row-1][col]) #(行, 列, 数据第一行的第一列)
        wbk.save(filename)
    def close(self):
        # 关闭游标和数据库连接
        self.cursor.close()
        self.conn.close()
        print('关闭数据库连接'.center(30, '#'))
class SendMail(object):
    '''将Excel作为附件发送邮件'''
    def __init__(self, email_info):
        self.email_info = email_info
        # 使用SMTP_SSL连接端口为465
        self.smtp = smtplib.SMTP_SSL(self.email_info['server'], self.email_info['port'])
        # 创建两个变量
        self._attachements = []
        self._from = ''
    def login(self):
        # 通过邮箱名和smtp授权码登录到邮箱
        self._from = self.email_info['user']
        self.smtp.login(self.email_info['user'], self.email_info['password'])

    def add_attachment(self):
        # 添加附件内容
        # 注意：添加附件内容是通过读取文件的方式加入
        file_path = self.email_info['file_path']
        with open(file_path, 'rb') as file:
            filename = os.path.split(file_path)[1]
            mime = MIMEBase('application', 'octet-stream', filename=filename)
            mime.add_header('Content-Disposition', 'attachment', filename=('gbk', '', filename))
            mime.add_header('Content-ID', '<0>')
            mime.add_header('X-Attachment-Id', '0')
            mime.set_payload(file.read())
            encoders.encode_base64(mime)
            # 添加到列表，可以有多个附件内容
            self._attachements.append(mime)

    def sendMail(self):
        # 发送邮件，可以实现群发
        msg = MIMEMultipart()
        contents = MIMEText(self.email_info['content'], 'plain', 'utf-8')
        msg['From'] = self.email_info['user']
        msg['To'] = self.email_info['to']
        msg['Subject'] = self.email_info['subject']

        for att in self._attachements:
            # 从列表中提交附件，附件可以有多个
            msg.attach(att)
        msg.attach(contents)
        try:
            self.smtp.sendmail(self._from, self.email_info['to'].split(','), msg.as_string())
            print('邮件发送成功，请注意查收'.center(30, '#'))
        except Exception as e:
            print('Error:', e)

    def close(self):
        # 退出smtp服务
        self.smtp.quit()
        print('logout'.center(30, '#'))


if __name__ == '__main__':
    # 数据库连接信息
    mysql_dict = {
        'host': '172.16.0.181',
        'port': 3306,
        'user': 'root',
        'passwd': 'biosan',
        'db': 'edw'
    }
    # 邮件登录及内容信息
    email_dict = {
    # 手动填写，确保信息无误
        "user": "jiangsunhui@biosan.cn",
        "to": "wangtao@biosan.cn,jiangsunhui@biosan.cn,pengli@biosan.cn,jinjing@biosan.cn", # 多个邮箱以','隔开；
        "server": "smtp.exmail.qq.com",
        'port': 465,    # values值必须int类型
        "username": "jiangsunhui@biosan.cn",
        "password": "JSW19941123aa",
        "subject": "每日新增客户查询",
        "content": '这里是每日新增客户查询的记录，请王涛更新一下',
        'file_path': 'jc.xls'
    }

    sql = 'select source,db,cuscode,cusname,invcode,other1,type,leve,date FROM tracking.jc_abnormal_alarm WHERE date = CURDATE();'
    # filename = 'example.xls'
    create_excel = CreateExcel(mysql_dict)
    sql_res = create_excel.getUserData(sql)
    if sql_res == "1":
        print("今日无数据")
    else:
        create_excel.writeToExcel(sql_res,email_dict['file_path'])
        create_excel.close()
        sendmail = SendMail(email_dict)
        sendmail.login()
        sendmail.add_attachment()
        sendmail.sendMail()
        sendmail.close()

