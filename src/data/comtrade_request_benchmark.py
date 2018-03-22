#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 20 19:18:02 2018

@author: janis
"""

import requests
import pandas as pd
import time, datetime

FSA_token='yGa9ysvivTWUUteZVeQUY4rMsCRBcxGTkDbcFbL773EMywrn6cLEDgIq7Wg3vfwZbYkXyhGsblu0wjZjbiwc2EZC0kh/Zp8SmWsXansq3zNEG17gryZAZaRphkp1Mf95Zkjb3aMX/Rr/uAaiKLJbOOwkmv9X3NoA7TCDAA7Go8Y='

payload={
        'r': '826', # reporting area ALL
        'freq': 'M', # frequency (A:annual, M:monthly)
        'ps': '2012', # time period
        'px': 'HS', # classification
        'p': 'ALL', # partner country 492=EU
        'rg': '1', # trade flow
#       Trade flow: rg
#        { "id": "all", "text": "All" },
#        { "id": "1", "text": "Import" },
#        { "id": "2", "text": "Export" },
#        { "id": "4", "text": "re-Import" },
#        { "id": "3", "text": "re-Export" }
        'cc': 'ALL', # classification code, that's where specific commodities can be selected
        'fmt': 'json', # format
        'type': 'C', # type of trade (c=commodities)
        'max': 'maxrec', # maximum number of records
        'head': 'H',
#       H Human readable headings, meant to be easy to understand. May contain special characters and spaces.
#       M Machine readable headings that match the JSON output, meant to be easy to parse. Does not contain special characters, spaces, etc.
        'token': FSA_token}

def comtrade_request(maxrec=15000, params=payload):
    url="http://comtrade.un.org/api/get?"

    #partner "id": "492",: "Europe EU, nes"

    t0 = time.perf_counter()
    r = requests.get(url, params=params)
    t1 = time.perf_counter()
 
    print('Request took: ' +str(datetime.timedelta(seconds=t1-t0)))

    # Extracting the json data from the request
    data=r.json()

    # Printing out the request validation
    print(data['validation'])

    # Refactoring data into a pandas DataFrame
    df = pd.DataFrame(data['dataset'])

    return df

maxrec=15000 #0000

# Set partner country to Spain "724",
payload['rg']='ALL'
payload['p']='710,724,757,276'
payload['ps']="201001,201101,201201,201301"
payload['r']= "826"
payload['freq']="M"
maxrec=100000

payload_import=payload
data_import=comtrade_request(params=payload_import)

data_import=comtrade_request(params=payload_import)

data_import=comtrade_request(params=payload_import)
