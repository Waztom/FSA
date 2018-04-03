#import pandas as pd
import re
#import time
#import selenium
from selenium import webdriver
#from selenium.webdriver.common.keys import Keys
#from selenium.webdriver.common.by import By
#from selenium.webdriver.support.ui import WebDriverWait
#from selenium.webdriver.support import expected_conditions as EC
#from rasff_util import get_origin
from bs4 import BeautifulSoup
import pandas as pd

    
urlbase = "https://webgate.ec.europa.eu/rasff-window/portal/?event=notificationsList&StartRow="

try:
    driver = webdriver.Firefox()
except:
    driver = webdriver.Chrome()

entry = []
rasff_table = pd.DataFrame()

number_of_pages_to_scan = 3
pages_list=[]


for i in range(number_of_pages_to_scan):
        
    count = i*100+1
    url = urlbase + str(count)
    driver.get(url)

    print('Page: ',i)

    html = driver.page_source
    
    pages_list.append(html)

driver.quit()

for page in pages_list:
    parsed_html = BeautifulSoup(page,'html.parser')

#    text = []
#    for link in parsed_html.find_all('td'):
#        text.append(link.get_text().strip())
#
#    for i in range(0,100):
#        entry.append(text[10*i:10*i+9])
    
    for row in parsed_html.find_all('tr'):
        entry = pd.Series()
        for cell in row.find_all('td'):
            entry = entry.append(pd.Series(cell.get_text().strip()), ignore_index=True)
        rasff_table = rasff_table.append(entry, ignore_index=True)
        

print('Entry length:',len(entry))


#pd_entry.to_pickle('../../data/raw/rassf_dump.pickle')
