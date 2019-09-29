#coding: utf-8

import smtplib
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText

# 发件人
list = ['hunan','hubei','fujian','jiangsu','anhui','zhejiang','shanghai','shandong','all']
# list1 = ['安徽省']
smtpserver = 'smtp.exmail.qq.com'
username = 'jiangsunhui@biosan.cn'
password='JSW19941123aa'
sender='jiangsunhui@biosan.cn'
# 收件人
receiver = ['jiangsunhui@biosan.cn','pengli@biosan.cn','yingxiaojie@biosan.cn','jinjing<jinjing@biosan.cn>']
# 抄送
cc = ['jiangsunhui@biosan.cn']

msg = MIMEMultipart('月中销售计划')
subject = '月中销售计划'
msg['Subject'] = subject
msg['From'] = 'jiangsunhui@biosan.cn'
msg['To'] = ";".join(receiver)
msg['Co'] = ";".join(cc)
# 设置编码
# msg['Accept-Language']='zh-CN'
# msg['Accept-Charset']='ISO-8859-1,utf-8'

# 构造附件
for i in range(len(list)):
    file = '/home/bidata/bidata/py/sale_'+list[i]+'.xls'
    file1 = 'sale_'+list[i]+'.xls'
    sendfile=open(file,'rb').read()
    text_att = MIMEText(sendfile, 'base64', 'utf-8')
    text_att["Content-Type"] = 'application/octet-stream'
    #另一种实现方式
    text_att.add_header('Content-Disposition', 'attachment', filename=('utf-8','',file1))
    msg.attach(text_att)

#发送邮件
smtp = smtplib.SMTP()
smtp.connect('smtp.exmail.qq.com')
#我们用set_debuglevel(1)就可以打印出和SMTP服务器交互的所有信息。
#smtp.set_debuglevel(1)
smtp.login(username, password)
smtp.sendmail(sender, receiver, msg.as_string())
smtp.quit()



