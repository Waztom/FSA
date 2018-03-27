#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Tue Mar 27 11:46:43 2018

@author: janis
"""

import os
os.sys.path.append('lib')
import pysqlib

trade=pysqlib.comtrade_sql_request()

trade_argentina=pysqlib.comtrade_sql_request(partner_name = 'Argentina', commodity_name='Meat of bovine')

print(trade_argentina)