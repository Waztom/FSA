import re

def get_date(post):
        date = (re.search('\d{2}\/\d{2}\/\d{4}',post)).group(0)
        return date

def get_notified(post):
    try:
        tmp =  (re.search('Notified by (.*?) on',post)).group(0)
        tmp = tmp[12:-3]
    except:
        tmp = None

    return tmp

def get_packaged(post):
    try:
        tmp = (re.search(' packaged in (.*$)',post)).group(0)
        tmp = tmp[13:]
    except:
        tmp = None

    return tmp

def get_via(post):
    try:
        tmp = (re.search(' via (.*$)',post)).group(0)
        tmp = tmp[4:]
        tmp = re.sub(', via',',',tmp)
        tmp = re.sub(' and via',',',tmp)
        tmp = tmp[1:].split(', ')
    except:
        tmp = None

    return tmp

def get_origin(post):
    try:
        tmp = (re.search(' from [A-Z,t,u][a-z,h,n][a-z,e,k](.*$)',post)).group(0)
        tmp = re.sub(' via (.*$)','',tmp)
        tmp = re.sub(', packaged in(.*$)','',tmp)
        tmp = tmp[6:].split(' from ')
        tmp2 = []
        for i in tmp:
            i = re.sub(' with (.*$)','',i)
            i = re.sub(' and in (.*$)','',i)
            i = re.sub(',$','',i)
            i = re.sub(', purified in (.*$)','',i)
            i = re.sub(', labelled in (.*$)','',i)
            i = re.sub('unfit (.*$)','',i)
            i = re.sub(' infested','',i)
            i = i.split(' and ')
            tmp2.append(i)
        tmp = tmp2
        tmp = [j for i in tmp for j in i]
    except:
        tmp = None


    return tmp

#def get_purifier(orilist):
#	country_pur = []
#	for ll in orilist:
#		for i in ll:
#			try:
#			   tmp = re.search(', purified in ',i).gropu(0)
#			   country_pur.append(tmp[14:])
#			except:
#			   coutry_pur.append(None) 	
#	return(country_pur)
