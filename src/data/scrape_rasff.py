#import pandas as pd
#import re
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

print(entry[10])

daten = []
cnoti = []
subje = []
categ = []
typec = []
for i in entry:
	daten.append(entry[2])

print(daten)	

