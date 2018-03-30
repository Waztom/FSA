#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Wed Mar 28 21:19:44 2018

@author: janis
"""

# libraries
import pandas as pd
import numpy as np
import networkx as nx
import matplotlib.pyplot as plt


from matplotlib.transforms import offset_copy

import matplotlib
import matplotlib.pyplot as plt
from matplotlib import backend_bases
from matplotlib.backends.backend_pgf import FigureCanvasPgf
matplotlib.backend_bases.register_backend('pdf', FigureCanvasPgf)
from matplotlib.ticker import AutoMinorLocator, MultipleLocator, FormatStrFormatter
#
#from bokeh.charts import output_file, Chord
#from bokeh.io import show

import colorcet as cc

from sklearn.preprocessing import scale

font_size=10
#font_weight='medium' #'demibold'
#
#pgf_with_pdflatex = {
#	'pgf.texsystem': 'pdflatex',
#	'font.size' : font_size,
#	'axes.labelsize' : font_size,
#	'axes.linewidth' : font_size/10.,
#	'axes.titlesize' : font_size,
#	'xtick.labelsize' : font_size,
#	'ytick.labelsize' : font_size,
#	'font.weight' : font_weight,
#	'axes.labelweight' : font_weight,
#	'font.family': 'serif',
#	'pgf.preamble': [
#		 r'\usepackage[utf8x]{inputenc}',
#		 r'\usepackage{cmbright}',
#		 ]
#}

#matplotlib.rcParams.update(pgf_with_pdflatex)

 
trade = pd.read_pickle('../data/cucumber_network_2015.pickle')

trade_all = trade.unstack()
trade_quantile = trade_all.quantile(q=0.90)
trade_sum = trade_all.sum()
trade_med = trade_all.median()


print('Cutting at '+str(trade_quantile))

#G = nx.DiGraph()
#G = nx.Graph()


#G.add_nodes_from(trade.keys())

trade_data = pd.DataFrame()

for importer in trade.keys():
    for partner in trade.index:
        if not np.isnan(trade.get_value(partner, importer)):
            if trade.get_value(partner, importer) > trade_quantile:
#                print(partner+ ' -> '+importer+' : '+str(trade.get_value(partner, importer)))
#                G.add_edge(partner, importer, weight= trade.get_value(partner, importer), alpha=0.4)
#                trade_data =  trade_data.append(pd.DataFrame([[[partner], [importer], [trade.get_value(partner, importer)]],columns=['partner', 'importer', 'value']), ignore_index=True)
#                trade_data =  pd.concat([trade_data,pd.DataFrame([[partner, importer, trade.get_value(partner, importer)]],columns=['partner', 'importer', 'value'])], ignore_index = True)
                trade_data = pd.concat([trade_data, pd.DataFrame([[partner, importer, trade.get_value(partner, importer)]],columns=['partner', 'importer', 'value'])], copy=False, ignore_index=True)
#            else:
#                print(partner+ ' -> '+importer+' : '+str(trade.get_value(partner, importer)))
#                G.add_edge(partner, importer, weight= trade.get_value(partner, importer), alpha=0.2)
#nx.draw(G, with_labels=True, node_color='skyblue', node_size=1500, edge_color=df['value'], width=10.0, edge_cmap=plt.cm.Blues)
#trade_data = pd.DataFrame([[partner, importer, trade.get_value(partner, importer)]],columns=['partner', 'importer', 'value'])
#tade_data =   pd.concat([trade_data, pd.DataFrame([[partner, importer, trade.get_value(partner, importer)]],columns=['partner', 'importer', 'value'])], ignore_index = True)

trade_data = trade_data.set_index(trade_data['partner']+' -> '+trade_data['importer'])
trade_data['value'] = trade_data['value']/10**6

f, ax = plt.subplots(1,figsize=(13.7, 9), dpi=600)

ax = trade_data.sort_values('value', ascending=True).plot.barh(color='YellowGreen')

plt.subplots_adjust(left=0.18, right=0.98, top=0.94, bottom=0.04)
#ax.set_title('Cumcumber routes')
plt.title('10% highest valued cucumber trades related to UK [Million USD]', fontsize=8)
ax.legend().set_visible(False)
#ax.yaxis.set_label_coords(-0.05,0.3)
plt.tick_params(axis='both', which='major', labelsize=4)
plt.savefig('figures/cucumber_trade_2015_barchart.pdf', dpi=600)


#pos = nx.nx_agraph.graphviz_layout(G, prog='twopi')
#pos = nx.nx_agraph.graphviz_layout(G, prog='neato')
##pos['United Kingdom'] = np.array([0, 0])
##nx.draw(G, pos, with_labels=True, node_color='skyblue', width=weights, font_size=10, node_size=2, edge_cmap=plt.cm.Blues)
##nx.draw(G, pos, with_labels=True, node_color='skyblue', width=0.1, font_size=10, node_size=5, edge_cmap=plt.cm.Blues)
#nx.draw_networkx_edges(G, pos, width=weights, #0.5
#                                edge_color=weights, #'grey',
#                                alpha=0.6,
#                                edge_cmap=cc.m_bkr)
#
#nx.draw_networkx_nodes(G, pos,  with_labels=True, font_size=5, node_color='skyblue', node_size=20, edge_cmap=plt.cm.Blues) 
##                                node_size=nodesizes,
##                                linewidth=edgewidths,
##                                node_color=edgecolors)
#nx.draw_networkx_labels(G, pos) # , labels=pos)
#
##plt.colorbar()
#plt.axis('off')
#plt.savefig('big_net.pdf', dpi=600)
