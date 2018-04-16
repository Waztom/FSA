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

percentile=0.5
precentile_trade_data = 'trade_value_usd'
commodity='pork...'
commodity_codes=['0203','0203']
trade_period=['201601', '201612']
partners_to_ignore=['World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes']
table_names = ['trade_flow_code', 'netweight_kg', 'trade_value_usd']

t0 = time.perf_counter()
# Download all trade data between UK and Brazil for commodities containing 'Meat of bovine' in description
trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = 'United Kingdom', start_period = trade_period[0], end_period = trade_period[1])

# Keep only the imports
trade = trade[trade.trade_flow_code == 1]

trade_tables = {}

for trade_data in table_names:
    # Sum up trade by partner
    trade_tables[trade_data] = trade.groupby('partner')[[trade_data]].sum()
    trade_tables[trade_data] = trade_tables[trade_data].rename_axis('Importer', axis=1)
    trade_tables[trade_data] = trade_tables[trade_data].rename(columns={trade_data: 'United Kingdom'})
    # Discard partners which are country groups
    for pti in partners_to_ignore:
        if pti in trade_tables[trade_data].index:
            trade_tables[trade_data] = trade_tables[trade_data].drop(pti)

# Get a lits of all the partners
#partners=trade.partner.unique()


        


# Create initial list of partners to scan
partners_to_scan=trade_network.index.tolist()


trade_all = trade_network.unstack()
trade_quantile = trade_all.quantile(q=percentile)
print('Cutting at :'+str(trade_quantile))

partner_name_errors=[]

# Loop over the partners to recover the whole network
while True: #
    print('Remaining partners to analyse: '+str(len(partners_to_scan)))
    print(partners_to_scan)
    partner_name=partners_to_scan[0]
    
    new_trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = partner_name, start_period = trade_period[0], end_period = trade_period[1])
    if new_trade is None:
        print('Error with '+partner_name+' ignoring it for the moment.')
        new_trade=pd.DataFrame([], columns=['trade_value_usd'])
        partner_name_errors.append(partner_name)
    else:
        new_trade = new_trade[new_trade.trade_flow_code == 1]
        new_trade = new_trade.groupby('partner')[['trade_value_usd']].sum()
    
    # Remove trades which do no reach the cutoff or are NaN
    new_trade = new_trade[~new_trade.trade_value_usd.isnull()]
    new_trade = new_trade[new_trade.trade_value_usd.values > trade_quantile]

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

if not len(partner_name_errors)==0:
    print('Encountered errors on the following partner_names: '+str(partner_name_errors))

trade_network.to_pickle('latest_network.pickle')
# Create python pickle
trade_network.to_pickle(commodity_codes[0]+'_network_'+trade_period[0]+'-'+trade_period[1]+'.pickle')

# Create csv
trade_network.to_csv(commodity_codes[0]+'_'+trade_period[0]+'-'+trade_period[1]+'.csv')

print('Total request took: ' +str(datetime.timedelta(seconds=t1-t0)))
print(trade_network.describe())