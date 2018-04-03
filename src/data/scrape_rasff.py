import pandas as pd
import re
import time
import selenium
from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.common.by import By
from selenium.webdriver.support.ui import WebDriverWait
from selenium.webdriver.support import expected_conditions as EC
from bs4 import BeautifulSoup

url = "https://webgate.ec.europa.eu/rasff-window/portal/?event=notificationsList&StartRow=1"

driver = webdriver.Firefox()
driver.get(url)

entry = []

html = driver.page_source
parsed_html = BeautifulSoup(html,'html.parser')

text = []
for link in parsed_html.find_all('td'):
	text.append(link.get_text().strip())

for i in range(0,100):
	entry.append(text[10*i:10*i+9])


driver.quit()
