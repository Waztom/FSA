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

 
trade = pd.read_pickle('cucumber_network_2015.pickle')

trade_all = trade.unstack()
trade_quantile = trade_all.quantile(q=0.5)
trade_sum = trade_all.sum()
trade_med = trade_all.median()


print('Cutting at '+str(trade_quantile))

G = nx.DiGraph()
#G = nx.Graph()


G.add_nodes_from(trade.keys())

for importer in trade.keys():
    for partner in trade.index:
        if not np.isnan(trade.get_value(partner, importer)):
            if trade.get_value(partner, importer) > trade_quantile:
                print(partner+ ' -> '+importer+' : '+str(trade.get_value(partner, importer)))
                G.add_edge(partner, importer, weight= trade.get_value(partner, importer), alpha=0.4)
#            else:
#                print(partner+ ' -> '+importer+' : '+str(trade.get_value(partner, importer)))
#                G.add_edge(partner, importer, weight= trade.get_value(partner, importer), alpha=0.2)
#nx.draw(G, with_labels=True, node_color='skyblue', node_size=1500, edge_color=df['value'], width=10.0, edge_cmap=plt.cm.Blues)

#Remove disconnected nodes                
G.remove_nodes_from(list(nx.isolates(G)))


edges = G.edges()

#weights = [((G[u][v]['weight']-trade_med)/trade_sum) for u,v in edges]
weights = [G[u][v]['weight'] for u,v in edges]
weights = scale(weights, axis=0, with_mean=True, with_std=True, copy=True)


f, ax = plt.subplots(1,figsize=(2*13.7, 2*9), dpi=600)
plt.subplots_adjust(left=0.12, right=0.96, top=0.95, bottom=0.15)
ax.set_title('Cumcumber importer networkn to United Kingdom')

#pos = nx.nx_agraph.graphviz_layout(G, prog='twopi')
pos = nx.nx_agraph.graphviz_layout(G, prog='neato')
#pos['United Kingdom'] = np.array([0, 0])
#nx.draw(G, pos, with_labels=True, node_color='skyblue', width=weights, font_size=10, node_size=2, edge_cmap=plt.cm.Blues)
#nx.draw(G, pos, with_labels=True, node_color='skyblue', width=0.1, font_size=10, node_size=5, edge_cmap=plt.cm.Blues)
nx.draw_networkx_edges(G, pos, width=weights, #0.5
                                edge_color=weights, #'grey',
                                alpha=0.6,
                                edge_cmap=cc.m_bkr)

nx.draw_networkx_nodes(G, pos,  with_labels=True, font_size=5, node_color='skyblue', node_size=20, edge_cmap=plt.cm.Blues) 
#                                node_size=nodesizes,
#                                linewidth=edgewidths,
#                                node_color=edgecolors)
nx.draw_networkx_labels(G, pos) # , labels=pos)

#plt.colorbar()
plt.axis('off')
plt.savefig('big_net.pdf', dpi=600)
