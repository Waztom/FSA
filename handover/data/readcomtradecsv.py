def readcomtradecsv(country):
        kk = pd.read_csv("/home/alex/S2DS/FSA/handover/data/comtrade_rice_201001_201401.csv")
        sel = kk[kk['Reporter'] == country]
        return sel
