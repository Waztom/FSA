import feedparser
import re
from rasff_util import get_date
from rasff_util import get_notified
from rasff_util import get_packaged
from rasff_util import get_via
from rasff_util import get_origin
import pandas as pd

d = feedparser.parse("https://webgate.ec.europa.eu/rasff-window/consumers/?event=rss&country=all")
#print(len(d['entries']))
#print(d['feed']['title'])

#print('Example: ' + d.entries[10].description)

country_not = []
country_pac = []
country_ori = []
country_via = []
date=[]

for post in d.entries:

    print(post.description + "::::" + post.title)

    date.append(get_date(post.description))
    country_not.append(get_notified(post.description))
    country_pac.append(get_packaged(post.title))
    country_via.append(get_via(post.title))
    country_ori.append(get_origin(post.title))

print(country_not)
print(country_ori)

notify = []
origin = []
for i in range(0,len(country_not)):
	for k in range(0,len(country_ori[i])):
		notify.append(country_not[i])
		origin.append(country_ori[i][k])

#print(' ')        
#for i in country_ori:
#	print(len(i))

#df = pd.DataFrame({'date' : date, 'notifier' : country_not, 'packager' : country_pac,
#                   'origin' : country_ori, 'transit' : country_via})
#df.head()
#df.to_csv('RASFF.csv')

df = pd.DataFrame({'notifier' : notify, 'partner' : origin})
df.head()
df.to_csv('RASFF.csv')

 
