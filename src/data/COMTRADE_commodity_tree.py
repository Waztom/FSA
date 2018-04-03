#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis
"""

import os
os.sys.path.append('lib')
import pysqlib
import pandas as pd
import itertools
import time, datetime

import numpy as np


################################################################################################
# Actual code starts here


commodity='Vegetables; cucumbers and gherkins, f..'
commodity_codes=['070700','070700']
year=2014
partners_to_ignore=['World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes']

t0 = time.perf_counter()
# Download all trade data between UK and Brazil for commodities containing 'Meat of bovine' in description
trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = 'United Kingdom', start_period = '201501', end_period = '201512')

# Keep only the imports
trade = trade[trade.trade_flow_code == 1]

# Sum up trade by partner
trade_network = trade.groupby('partner')[['trade_value_usd']].sum()

    
# Get a lits of all the partners
#partners=trade.partner.unique()

trade_network=trade_network.rename_axis('Importer', axis=1)
trade_network=trade_network.rename(columns={'trade_value_usd': 'United Kingdom'})

# Discard partners which are country groups
for pti in partners_to_ignore:
    if pti in trade_network.index:
        trade_network = trade_network.drop(pti)    

# Create initial list of partners to scan
partners_to_scan=trade_network.index.tolist()

partner_name_errors=[]

# Loop over the partners to recover the whole network
while True: #
    print('Remining partners to analyse: '+str(len(partners_to_scan)))
    print(partners_to_scan)
    partner_name=partners_to_scan[0]
    
    new_trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = partner_name, start_period = '201501', end_period = '201512')
    if new_trade is None:
        print('Error with '+partner_name+' ignoring it for the moment.')
        new_trade=pd.DataFrame([], columns=['trade_value_usd'])
        partner_name_errors.append(partner_name)
    else:
        new_trade = new_trade[new_trade.trade_flow_code == 1]
        new_trade = new_trade.groupby('partner')[['trade_value_usd']].sum()
    
    # Discard partners which are country groups
    for pti in partners_to_ignore:
        if pti in new_trade.index:
            new_trade = new_trade.drop(pti)
        
    trade_network=trade_network.join(new_trade, how='outer')
    trade_network=trade_network.rename(columns={'trade_value_usd': partner_name})

    # Look for partners which are not yet listed as importers
    partners_to_scan=list(itertools.filterfalse(lambda x: x in trade_network.keys().tolist(), trade_network.index.tolist()))
    
    # Check if list is empty
    if not partners_to_scan:
        break # Break out of the loop
        
t1 = time.perf_counter()
print('Total request took: ' +str(datetime.timedelta(seconds=t1-t0)))

if not len(partner_name_errors)==0:
    print('Encountered errors on the following partner_names: '+str(partner_name_errors))
    
# Create python pickle
trade_network.to_pickle('cucumber_network_2015.pickle')

# Create csv
trade_network.to_csv('cucumber_network_2015.csv')