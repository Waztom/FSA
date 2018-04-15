#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis
"""

import os, sys
#os.sys.path.append('lib')
sys.path.append(os.path.join(os.path.dirname(__file__), "lib"))
import pysqlib
import pandas as pd
import itertools
import time, datetime
import argparse


import numpy as np


parser = argparse.ArgumentParser(description='Downloads COMTRADE data for a list of commoditites and groups them into a single table.')
parser.add_argument('--commodities', action="store", dest="com_codes", nargs='+', required=True, help='Commodity codes to download. Either a single value can be given or a space separated list.')
parser.add_argument('--trade_period_start', action="store", dest="trade_period_start",  default='201401', help='Give the start date of the trade period to download in YYYYMM format.')
parser.add_argument('--trade_period_end', action="store", dest="trade_period_end",  default='201612', help='Give the end date of the trade period to download in YYYYMM format.')
parser.add_argument('--percentile',action="store", dest="percentile", type=float, default=0.5,    
                    help="Percentile at which to stop exploring for partners based on initial trade values incoming UK.")

args = parser.parse_args()


################################################################################################
# Actual code starts here

percentile=args.percentile
commodity='pork...'
commodity_codes=args.com_codes #['0905','0905']
trade_period=[args.trade_period_start, args.trade_period_end] #['201601', '201612']

# Duplicate commodity if there is only one in order to have a commoditiy list
if len(commodity_codes)==1:
    commodity_codes=[commodity_codes[0],commodity_codes[0]]
    
def download_comtrade_data(commodity_codes=['0905','0905'], trade_period=['201601', '201612']):
    '''
    Function to download trade data from FSA Comtrade SQL server and save it as a R-compatible csv file
    '''
    partners_to_ignore=['World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes']

    t0 = time.perf_counter()
    # Download all trade data between UK and Brazil for commodities containing 'Meat of bovine' in description
    trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = 'United Kingdom', start_period = trade_period[0], end_period = trade_period[1])
    
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

if __name__ == '__main__':
    download_comtrade_data( commodity_codes = commodity_codes, trade_period = trade_period )