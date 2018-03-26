#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 19:18:02 2018

@author: janis
"""

import psycopg2
import pandas as pd
import time, datetime
import json


def load_comtrade_info():
    comtrade_dictionary={}
    json_data=open('lib/classificationHS.json')
    comtrade_dictionary['comcodes']= pd.DataFrame(json.load(json_data)['results'])
    json_data.close()
    json_data=open('lib/partnerAreas.json')
    comtrade_dictionary['partners']= pd.DataFrame(json.load(json_data)['results'])
    json_data.close()
    json_data=open('lib/reporterAreas.json')
    comtrade_dictionary['reporters']= pd.DataFrame(json.load(json_data)['results'])
    json_data.close()
        
    return comtrade_dictionary

def get_partner_code(comtrade_dictionary, country):
    '''
    Search the partner country code
    '''
    return comtrade_dictionary['partners']['id'][comtrade_dictionary['partners']['text'].str.contains(country)].iloc[0]

def get_reporter_code(comtrade_dictionary, country):
    '''
    Search the reporter country code
    '''
    return comtrade_dictionary['reporters']['id'][comtrade_dictionary['reporters']['text'].str.contains(country)].iloc[0]
    
def get_commodity_code(comtrade_dictionary, commodity):
    '''
    Search the commodity code
    '''
    commodity_code = comtrade_dictionary['comcodes'][comtrade_dictionary['comcodes']['text'].str.contains(commodity)]
    if commodity_code.empty:
        print(commodity + ' not found.')
        return -1
    else:
        #take first one if more than one result
        commodity_code = commodity_code.iloc[0]
    print(commodity_code['text'])
    return commodity_code
    
#def get_commodity_codes(comtrade_dictionary, commodity):
#    '''
#    Search the commodity codes and concatenate them into an array
#    '''
#    commodity_code = comtrade_dictionary['comcodes'][comtrade_dictionary['comcodes']['text'].str.contains(commodity)]
#    if commodity_code.empty:
#        print(commodity + ' not found.')
#        return -1
#    elif len(commodity_code['id'])>1:
#        commodity_codes=commodity_code['id'].values
#        print(commodity_code['text'])
#    else:
#        #Repeat the single occurence in order to have a list for the SQL request
#        commodity_code =np.repeat(commodity_code['id'].values,2)
#        print(commodity_code['text'])
#    return commodity_codes
    
conn = psycopg2.connect(
                 dbname = "comtrade", # could also be "hmrc"
                 host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                 user = "trade_read",
                 password = "2fs@9!^43g")

cur = conn.cursor()

cur.execute("select COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='comtrade'")
column_names=pd.DataFrame(cur.fetchall())
print(column_names)
print()

comtrade_dict = load_comtrade_info()
uk_code = get_reporter_code(comtrade_dict, 'United Kingdom')
brazil_code = get_partner_code(comtrade_dict, 'Brazil')
beef = get_commodity_code(comtrade_dict, 'Meat')['id']

t0 = time.perf_counter()

cur.execute("SELECT partner,trade_flow_code, netweight_kg, trade_value_usd, period, commodity_code FROM comtrade WHERE "\
            "partner_code = %(partner)s "\
            "AND period  BETWEEN 201401 AND 201612"\
            "AND commodity_code = %(comcode)s"\
            "AND reporter_code = %(reporter)s", {'partner': brazil_code, 'comcode': beef, 'reporter': uk_code})

imports = pd.DataFrame(cur.fetchall(), columns=['partner', 'trade_flow_code','netweight_kg', 'trade_value_usd', 'period', 'commodity_code'])

t1 = time.perf_counter()
print('Request took: ' +str(datetime.timedelta(seconds=t1-t0)))
print(imports)

