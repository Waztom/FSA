#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis and alex
"""

from selenium import webdriver
from bs4 import BeautifulSoup
import pandas as pd

    
urlbase = "https://webgate.ec.europa.eu/rasff-window/portal/?event=notificationsList&StartRow="
column_names=['classification', 'date_of_case', 'reference', 'notifying_country', 'subject', 'product_category', 'type', 'risk_decision']

try:
    driver = webdriver.Firefox()
except:
    driver = webdriver.Chrome()

entry = []
rasff_table = pd.DataFrame()

number_of_pages_to_scan = 100
pages_list=[]


for i in range(number_of_pages_to_scan):
        
    count = i*100+1
    url = urlbase + str(count)
    driver.get(url)

    print('Page: '+str(i)+'/'+str(number_of_pages_to_scan))

    html = driver.page_source
    
    pages_list.append(html)

driver.quit()

print('Retrieved '+str(len(pages_list))+' pages. Start parsing...')

for page in pages_list:
    parsed_html = BeautifulSoup(page,'html.parser')

    
    for row in parsed_html.find_all('tr'):
        entry = pd.Series()
        for cell in row.find_all('td'):
            entry = entry.append(pd.Series(cell.get_text().strip()), ignore_index=True)
        rasff_table = rasff_table.append(entry, ignore_index=True)

# Remove first and last columns which are uuseless
rasff_table= rasff_table.drop([0, 9], axis=1)

#Define the column names
rasff_table.columns = column_names
 
# Remove lines where the commodity type is undefined (usually the row is empty anyway)
rasff_table = rasff_table[~rasff_table.type.isnull()]


# Transform Date of case strings into date objects
rasff_table['date_of_case'] = pd.to_datetime(rasff_table['date_of_case'], format="%d/%m/%Y")

# Dumping table into a pickle
rasff_table.to_pickle('../../data/raw/rassf_dump.pickle')

print('Entry length:'+str(rasff_table.describe()))


