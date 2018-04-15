#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 19:18:02 2018

@author: janis
"""

import psycopg2
from psycopg2 import sql
import pandas as pd
import time, datetime
import json
import sys
import numpy as np

################################################################
## Define a function that load the comtrade json files into a dictionary

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

################################################################
## Define three function which lookup comtrade codes in the comtrade dictionary

def get_partner_code(comtrade_dictionary, country):
    '''
    Search the partner country code
    '''
    country_code = comtrade_dictionary['partners'][comtrade_dictionary['partners']['text'].str.contains(country)]
    
    if country_code.empty:
        print('ERROR:' + country + ' not found.')
        country_code = None
    else:
        #take first one if more than one result\
        print('Partner:')
        print(country_code)
        print(' ')
        country_code = country_code['id'].iloc[0]
    return country_code
    
def get_reporter_code(comtrade_dictionary, country):
    '''
    Search the reporter country code
    '''
    country_code = comtrade_dictionary['reporters'][comtrade_dictionary['reporters']['text'].str.contains(country)]
    
    if country_code.empty:
        print('ERROR:' + country + ' not found.')
        country_code = None
    else:
        #take first one if more than one result
        print('Reporter:')
        print(country_code)
        print(' ')
        country_code = country_code['id'].iloc[0]
    return country_code
        
def get_commodity_code(comtrade_dictionary, commodity):
    '''
    Search the commodity code
    '''
    commodity_code = comtrade_dictionary['comcodes'][comtrade_dictionary['comcodes']['text'].str.contains(commodity)]
    
    if commodity_code.empty:
        print('ERROR:' + commodity + ' not found.')
        commodity_code = None
    else:
        #take first one if more than one result
        commodity_code = commodity_code.iloc[0]
        print('Commodity:')
        print(commodity_code['text'])
        print(' ')
    return commodity_code
    
def get_commodity_codes(comtrade_dictionary, commodity):
    '''
    Search the commodity codes and concatenate them into a list
    '''
    commodity_code = comtrade_dictionary['comcodes'][comtrade_dictionary['comcodes']['text'].str.contains(commodity)]
    
    if commodity_code.empty:
        print('ERROR:' + commodity + ' not found.')
        return None
    elif len(commodity_code['id'])>1:
        print(commodity_code['text'])
        commodity_codes=commodity_code['id'].values.tolist()
    else:
        #Repeat the single occurence in order to have a list for the SQL request
        print('Commodities:')
        print(commodity_code['text'])
        print(' ')
        commodity_code =np.repeat(commodity_code['id'].values,2).tolist()
    return commodity_codes

def comtrade_sql_request(partner_name = 'Brazil', commodity_code='Meat of bovine', reporter_name = 'United Kingdom', start_period = '201401', end_period = '201612', requested_columns = ['partner', 'trade_flow_code','netweight_kg', 'trade_value_usd', 'period', 'commodity_codes']):
    '''
    SELECTs the data from the comtrade SQL database and returns it as a pandas DataFrane
    '''
    ################################################################
    ## Connect to the SQLdatabase
    conn = psycopg2.connect(
                     dbname = "comtrade", # could also be "hmrc"
                     host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                     user = "trade_read",
                     password = "2fs@9!^43g")
    cur = conn.cursor()
    
    ################################################################
    ## Get the column names and print them out
    cur.execute("select COLUMN_NAME, DATA_TYPE, NUMERIC_PRECISION from INFORMATION_SCHEMA.COLUMNS where TABLE_NAME='comtrade'")
    column_names=pd.DataFrame(cur.fetchall())
    print(column_names)
    print()
    
    ################################################################
    ## Lookup the needed comtrade codes for the SQL request
    
    comtrade_dict = load_comtrade_info()
    
    reporter_code = get_reporter_code(comtrade_dict, reporter_name)
    partner_code = get_partner_code(comtrade_dict, partner_name)
    com_codes = get_commodity_codes(comtrade_dict, commodity_name)
        
    if partner_code is None or reporter_code is None or com_codes is None:
        print('An error occured fetching a comtrade code. Leaving.')
        sys.exit(1)
        
    # Check if com_code was found
    if com_codes is None:
        print('WARNING: No commodity code found.')
        sys.exit(1)
    
    ################################################################
    ## Download the comtrade data and put it into a pandas DataFrame
    # Start timer to see how long the request takes
    t0 = time.perf_counter()
                
    
    cur.execute("SELECT partner, trade_flow_code, netweight_kg, trade_value_usd, period, commodity_code FROM comtrade WHERE "\
                "partner_code = %(partner)s "\
                "AND period  BETWEEN 201401 AND 201612"\
                "AND commodity_code = ANY(%(comcodes)s)"\
                "AND reporter_code = %(reporter)s", {'partner': partner_code, 'comcodes': com_codes, 'reporter': reporter_code})
#    print(cur.fetchall())
    
    trade_data = pd.DataFrame(cur.fetchall(), columns=requested_columns)
    t1 = time.perf_counter()
    print('Request took: ' +str(datetime.timedelta(seconds=t1-t0)))
    
    # Closing the connection
    cur.close()
    
    return trade_data


def comtrade_sql_request_all_partners(com_codes=['070700','070700'], reporter_name = 'United Kingdom', start_period = '201401', end_period = '201612', requested_columns = ['partner', 'trade_flow_code','netweight_kg', 'trade_value_usd', 'period', 'commodity_codes']):
    '''
    SELECTs the data from the comtrade SQL database and returns it as a pandas DataFrane
    '''
    ################################################################
    ## Connect to the SQLdatabase
    conn = psycopg2.connect(
                     dbname = "comtrade", # could also be "hmrc"
                     host = "data-science-pgsql-dev-01.c8kuuajkqmsb.eu-west-2.rds.amazonaws.com",
                     user = "trade_read",
                     password = "2fs@9!^43g")
    cur = conn.cursor()
    
    
    ################################################################
    ## Lookup the needed comtrade codes for the SQL request
    
    comtrade_dict = load_comtrade_info()
    
    reporter_code = get_reporter_code(comtrade_dict, reporter_name)
            
    if reporter_code is None or com_codes is None:
        print('An error occured fetching a comtrade code.')
        return None
        
    # Check if com_code was found
    if com_codes is None:
        print('WARNING: No commodity code found.')
        return None
    
    ################################################################
    ## Download the comtrade data and put it into a pandas DataFrame
    # Start timer to see how long the request takes
    t0 = time.perf_counter()
                
    
    cur.execute("SELECT partner, trade_flow_code, netweight_kg, trade_value_usd, period, commodity_code FROM comtrade WHERE "\
                "period  BETWEEN 201401 AND 201612"\
                "AND commodity_code = ANY(%(comcodes)s)"\
                "AND reporter_code = %(reporter)s", {'comcodes': com_codes, 'reporter': reporter_code})
#    print(cur.fetchall())
    
    trade_data = pd.DataFrame(cur.fetchall(), columns=requested_columns)
    t1 = time.perf_counter()
    print('Request took: ' +str(datetime.timedelta(seconds=t1-t0)))
    
    # Closing the connection
    cur.close()
    
    return trade_data