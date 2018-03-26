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
payload['p']='724'

payload_import=payload
data_import=comtrade_request(params=payload_import)

payload_export=payload
payload_export['rg']='2'
data_export=comtrade_request(params=payload_export)

chicken_import_params=payload
chicken_import_params['cc']='0207' # - Meat and edible offal of poultry;
chicken_import=comtrade_request(params=chicken_import_params)

chicken_export_params=chicken_import_params
chicken_export_params['rg']='2'
chicken_export=comtrade_request(params=chicken_export_params)

oliveoil_import_params=payload
oliveoil_import_params['cc']='1509' # - Olive oil and its fractions; virgin and other
oliveoil_import=comtrade_request(params=oliveoil_import_params)

oliveoil_export_params=oliveoil_import_params
oliveoil_export_params['rg']='2'
oliveoil_export=comtrade_request(params=oliveoil_export_params)

virginoliveoil_import_params=payload
virginoliveoil_import_params['cc']='150910' # - Olive oil and its fractions; virgin and other
virginoliveoil_import=comtrade_request(params=virginoliveoil_import_params)

virginoliveoil_export_params=virginoliveoil_import_params
virginoliveoil_export_params['rg']='2'
virginoliveoil_export=comtrade_request(params=virginoliveoil_export_params)

nvirginoliveoil_import_params=payload
nvirginoliveoil_import_params['cc']='150990' # - Olive oil and its fractions; virgin and other
nvirginoliveoil_import=comtrade_request(params=nvirginoliveoil_import_params)

nvirginoliveoil_export_params=nvirginoliveoil_import_params
nvirginoliveoil_export_params['rg']='2'
nvirginoliveoil_export=comtrade_request(params=nvirginoliveoil_export_params)


import numpy as np

import matplotlib.pyplot as plt
from matplotlib import rcParams
from matplotlib import pyplot as plt

from matplotlib.transforms import offset_copy

import matplotlib
import matplotlib.pyplot as plt
from matplotlib import backend_bases
from matplotlib.backends.backend_pgf import FigureCanvasPgf
matplotlib.backend_bases.register_backend('pdf', FigureCanvasPgf)
from matplotlib.ticker import AutoMinorLocator, MultipleLocator, FormatStrFormatter

font_size=10
font_weight='medium' #'demibold'

pgf_with_pdflatex = {
	'pgf.texsystem': 'pdflatex',
	'font.size' : font_size,
	'axes.labelsize' : font_size,
	'axes.linewidth' : font_size/10.,
	'axes.titlesize' : font_size,
	'xtick.labelsize' : font_size,
	'ytick.labelsize' : font_size,
	'font.weight' : font_weight,
	'axes.labelweight' : font_weight,
	'font.family': 'serif',
	'pgf.preamble': [
		 r'\usepackage[utf8x]{inputenc}',
		 r'\usepackage{cmbright}',
		 ]
}

matplotlib.rcParams.update(pgf_with_pdflatex)

RVformatter = matplotlib.ticker.FormatStrFormatter('%1.f')
colours=('DodgerBlue', 'LimeGreen', 'DarkOrange', 'Crimson','Magenta', 'MediumBlue', 'Gray')

plt.rcParams['figure.figsize'] = (15, 9)

#ind= np.arange(len(oliveoil_import['period'])) # the x locations for the groups
ind= np.arange(len(oliveoil_import['period'])) # the x locations for the groups

width = 0.35# the width of the bars

oliveoil_imp_array=np.zeros((2,len(oliveoil_import['period'])))
oliveoil_imp_array[0]=oliveoil_import['period'].values-oliveoil_import['yr'].values*100

nvirgin_bottoms=np.zeros(len(virginoliveoil_import['period']))
#nvirgin_bottoms=np.zeros(12)

for i in range(len(nvirginoliveoil_import['period'])):
    print('i='+str(i))
    p = oliveoil_import['period'].values[i]-oliveoil_import['yr'].values[i]*100-1
    print(p)
    nvirgin_bottoms[p] = nvirginoliveoil_import['NetWeight'].values[i]

fig, ax = plt.subplots()
rects1 = ax.bar(oliveoil_import['period'].values-oliveoil_import['yr'].values*100 - width/2, 
                oliveoil_import['NetWeight'].values, width, color='DodgerBlue', label='Total import')
rects2 = ax.bar(nvirginoliveoil_import['period'].values-nvirginoliveoil_import['yr'].values*100 + width/2, 
                nvirginoliveoil_import['NetWeight'].values, width, color='Sienna', label='Non-Virgin import')
rects2 = ax.bar(virginoliveoil_import['period'].values-virginoliveoil_import['yr'].values*100 + width/2, 
                virginoliveoil_import['NetWeight'].values, width, bottom=nvirginoliveoil_import['NetWeight'].values , color='LimeGreen', label='Virgin import')
plt.show()