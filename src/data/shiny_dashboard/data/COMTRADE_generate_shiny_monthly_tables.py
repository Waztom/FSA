#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis
"""

import os, sys
sys.path.append(os.path.join(os.path.dirname(__file__), "lib"))
import pysqlib
import pandas as pd
import itertools
import time, datetime
import argparse
from rpy2 import robjects
from rpy2.robjects import pandas2ri
import subprocess


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
commodity_codes=args.com_codes #['0905','0905']
trade_period=[args.trade_period_start, args.trade_period_end] #['201601', '201612']

# Duplicate commodity if there is only one in order to have a commoditiy list
if len(commodity_codes)==1:
    commodity_codes=[commodity_codes[0],commodity_codes[0]]
    
# write pandas dataframe to an .RData file


def download_comtrade_data(commodity_codes=['0905','0905'], trade_period=['201601', '201612']):
    '''
    Function to download trade data from FSA Comtrade SQL server and save it as a R-compatible csv file
    '''
    partners_to_ignore=['World', 'EU-27', 'Other Asia, nes', 'Other Europe, nes', 'Areas, nes']

    comtrade_dict = pysqlib.load_comtrade_info()
    # Taking only the first comcode to retrieve the description
    commodity_description = comtrade_dict['comcodes']['text'][comtrade_dict['comcodes']['id']==commodity_codes[0]]
    
    if not commodity_description.empty:
        commodity_description = commodity_description.iloc[0]
    else:
        print("Commodity code doesn't seem to be linked to an actual commodity.")
        commodity_description = 'Unknown'
        
    print('Retrieving: '+commodity_description )
    
    t0 = time.perf_counter()
    # Download all trade data between UK and Brazil for commodities containing 'Meat of bovine' in description
    trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = 'United Kingdom', start_period = trade_period[0], end_period = trade_period[1])
    
    # Keep only the imports
    trade = trade[trade.trade_flow_code == 1]
    
    # Create a trade_dump used for the network modeling
    trade_dump = trade[['partner','period','trade_value_usd']].copy()
    trade_dump['reporter'] = 'United Kingdom'
    # Sum up trade by partner
#    trade_network = trade.groupby('partner')[['trade_value_usd']].sum()
    trade_network = trade.groupby(['period','partner'])[['trade_value_usd']].sum()
    # Get a lits of all the partners
    #partners=trade.partner.unique()
    
    trade_network=trade_network.rename_axis('Importer', axis=1)
    trade_network=trade_network.rename(columns={'trade_value_usd': 'United Kingdom'})
            
    # Discard partners which are country groups
    for pti in partners_to_ignore:
        if pti in trade_network.index:
            trade_network = trade_network.drop(pti)
    
    # Create initial list of partners to scan
#    partners_to_scan=trade_network.index.tolist()
    partners_to_scan = trade_network.index.levels[1].tolist()
    
    trade_quantile = trade_network['United Kingdom'].quantile(q=percentile)
    print('Cutting at :'+str(trade_quantile))
    
    partner_name_errors=[]
    
    # Loop over the partners to recover the whole network
    while True: #
        print('Remaining partners to analyse: '+str(len(partners_to_scan)))
        print(partners_to_scan)
        partner_name=partners_to_scan[0]
        
        new_trade = pysqlib.comtrade_sql_request_all_partners( com_codes = commodity_codes, reporter_name = partner_name, start_period = trade_period[0], end_period = trade_period[1])
        if new_trade is None or new_trade.empty:
            print('Error with '+partner_name+' ignoring it for the moment.')
            new_trade = pd.DataFrame([], columns=['trade_value_usd'], index = trade_network.index)
            partner_name_errors.append(partner_name)
        else:
            new_trade_dump = trade[['partner','period','trade_value_usd']].copy()
            new_trade_dump['reporter'] = partner_name
            
            new_trade = new_trade[new_trade.trade_flow_code == 1]
            new_trade = new_trade.groupby(['period','partner'])[['trade_value_usd']].sum()
        
        # Concatenate the additional data to the trade dump
        trade_dump = pd.concat([trade_dump, new_trade_dump])
        
        # Remove trades which do no reach the cutoff or are NaN
        new_trade = new_trade[~new_trade.trade_value_usd.isnull()]
        new_trade = new_trade[new_trade.trade_value_usd.values > trade_quantile]
    
        # Discard partners which are country groups
        for pti in partners_to_ignore:
            if pti in new_trade.index:
                new_trade = new_trade.drop(pti)
            
        trade_network = trade_network.reset_index().merge(new_trade.reset_index(), on=['period','partner'], how='outer').set_index(trade_network.index.names)
        trade_network = trade_network.rename(columns={'trade_value_usd': partner_name})
    
        # Look for partners which are not yet listed as importers
        partners_to_scan = list(itertools.filterfalse(lambda x: x in trade_network.keys().tolist(), trade_network.index.levels[1].tolist()))
        # Remove partners to ignore
        partners_to_scan = [x for x in partners_to_scan if x not in partners_to_ignore]
        # Check if list is empty
        if not partners_to_scan:
            break # Break out of the loop
            
    t1 = time.perf_counter()
    
    # Get rid of the "World" is the data
    trade_dump = trade_dump[trade_dump.partner != 'World']
    
    # Add a coolumn with first day of the given period month
#    trade_dump['period_date'] = trade_dump.apply(lambda row: str(row.period)[:4]+'-'+str(row.period)[-2:]+'-01' , axis=1)
    trade_dump['period_date'] =pd.to_datetime(trade_dump['period'], format='%Y%m')
    trade_dump = trade_dump.rename(columns={'partner': 'origin', 'reporter': 'destin'})
    
    if not len(partner_name_errors)==0:
        print('Encountered errors on the following partner_names: '+str(partner_name_errors))
    
    trade_network.to_pickle('latest_network.pickle')
    # Create python pickle
    trade_network.to_pickle(commodity_codes[0]+'_network_'+trade_period[0]+'-'+trade_period[1]+'_monthly.pickle')
  

    rdata_filename = commodity_codes[0]+'_'+trade_period[0]+'-'+trade_period[1]+'_total_dump.RData'

    pandas2ri.activate()

    r_si = pandas2ri.py2ri(trade_dump)
    robjects.r.assign("si", r_si)
    robjects.r.assign("commodity_description", commodity_description)
    # Only storing the first commodity code
    robjects.r.assign("commodity_code", commodity_codes[0])
    robjects.r("save(si, commodity_description, commodity_code, file='{}')".format(rdata_filename))

    print('Total request took: ' +str(datetime.timedelta(seconds=t1-t0)))
    print(trade_network.describe())

    subprocess.call (['./generate_all_info_file.R','-f ', rdata_filename])

if __name__ == '__main__':
    download_comtrade_data( commodity_codes = commodity_codes, trade_period = trade_period )