#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis
"""

import os
os.sys.path.append('lib')
import pysqlib
import pandas

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

font_size=14
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

################################################################################################
# Actual code starts here

partner='Brazil'
commodity='Meat of bovine'

# Download all trade data between UK and Brazil for commodities containing 'Meat of bovine' in description
trade_brazil=pysqlib.comtrade_sql_request(partner_name = partner, commodity_name = commodity)

print(trade_brazil)
# Transform the dates into a datetime format
trade_brazil['period']=pandas.to_datetime(trade_brazil['period'], format='%Y%m')

# Have varying bar width to cover the whole month
x=trade_brazil['period']
widths=[(x[j+1]-x[j]).days for j in range(len(x)-1)] + [28]

# Make the plot
fig, ax = plt.subplots()

# Give a title
plt.title(partner + ' imports to UK of '+ commodity)
# Label the y axis
plt.ylabel('Net weight [Tons]')
ax.bar(trade_brazil['period'], trade_brazil['netweight_kg'].values/1000, color='DodgerBlue', align='edge', width=widths)

# Save the figure
plt.savefig('figures'+os.sep+'imports_' + partner + '_' + commodity.replace(' ','_') + '.png')
plt.savefig('figures'+os.sep+'imports_' + partner + '_' + commodity.replace(' ','_') + '.pdf', format='pdf',dpi=600)

# Show the figure
plt.show()
