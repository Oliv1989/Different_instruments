import glob
import win32com.client as win32
import os
import ast

path = '' #write path to your file inside ''

year = input('Введите год: ')
mnth = input('Введите месяц: ')

d = {}
with open(r'') as file: #write path to file inside '', you need to open
    for i in file.readlines():
        key, val = i.strip().split(' ')
        d[key] = val

for recepient in d.keys():
    outlook = win32.Dispatch('outlook.application')
    mail = outlook.CreateItem(0)
    mail.To = recepient
    mail.Subject = f'Какое-то сообщение {mnth}.{year}.'
    mail.Body = ''
    mail.HTMLBody = f'Какое-то сообщение'
    if recepient == "" or recepient == "": #write email inside ""
        for x in glob.glob(path + "*Region1*"): #write what phrase need to find into file`s name inside ""
            mail.Attachments.Add(x)
    elif recepient == "" or recepient == "": #write email inside ""
        for x in glob.glob(path + "*Region2*"): #write what phrase need to find into file`s name inside ""
            mail.Attachments.Add(x)
    elif recepient == "": #write email inside ""
        for x in glob.glob(path + "*Region3*"): #write what phrase need to find into file`s name inside ""
            mail.Attachments.Add(x)

    mail.Send()
