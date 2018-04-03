#import pandas as pd
import re
#import time
#import selenium
from selenium import webdriver
#from selenium.webdriver.common.keys import Keys
#from selenium.webdriver.common.by import By
#from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.support import expected_conditions as EC
from rasff_util import get_origin
from bs4 import BeautifulSoup
import sys
    
urlbase = "https://webgate.ec.europa.eu/rasff-window/portal/?event=notificationsList&StartRow="

try:
    driver = webdriver.Firefox()
except:
    driver = webdriver.Chrome()

entry = []

pages = range(0,1)

for i in pages:
        
	count = i*100+1
	url = urlbase + str(count)
	driver.get(url)

	print('Page: ',i)

	html = driver.page_source
	parsed_html = BeautifulSoup(html,'html.parser')

	text = []
	for link in parsed_html.find_all('td'):
		text.append(link.get_text().strip())

	for i in range(0,100):
		entry.append(text[10*i:10*i+9])

driver.quit()

print(text)

sys.exit()

print('Entry length:',len(entry))

daten = []
cnoti = []
subje = []
categ = []
corig = []
ctype = []

k = 0

for i in entry:
#	if re.match('food',entry[k][7]):
	print(entry[k][7],entry[k][7].find('food'))
	if str(entry[k][7]).find('food') > -1:
		daten.append(entry[k][2])
		cnoti.append(entry[k][4])
		subje.append(entry[k][5])
		categ.append(entry[k][6])
		ctype.append(entry[k][7])
		corig.append(get_origin(entry[k][5]))
		k = k + 1

print('Notifier list:',len(cnoti))
print(ctype)
#
#for i in range(0,k):
#	print(i,k,cnoti[i],corig[i])
#
#
#notify = []
#origin = []
#for i in range(0,len(cnoti)):
#        for k in range(0,len(corig[i])):
#                notify.append(cnoti[i])
#                origin.append(corig[i][k])





