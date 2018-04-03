#import pandas as pd
import re
#import time
#import selenium
from selenium import webdriver
#from selenium.webdriver.common.keys import Keys
#from selenium.webdriver.common.by import By
#from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.support import expected_conditions as EC

from bs4 import BeautifulSoup

    
urlbase = "https://webgate.ec.europa.eu/rasff-window/portal/?event=notificationsList&StartRow="

driver = webdriver.Firefox()

entry = []

pages = range(0,2)

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

print(len(entry))


daten = []
cnoti = []
subje = []
categ = []
k = 0
for i in entry:
	print(entry[k][7])
	if re.match('food',entry[k][7]):
		daten.append(entry[k][2])
		cnoti.append(entry[k][4])
		subje.append(entry[k][5])
		categ.append(entry[k][6])
		k = k + 1
#
print(daten)
print(len(daten))	

