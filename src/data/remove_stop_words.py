from nltk.corpus import stopwords
import nltk
import pycountry

cachedStopWords = stopwords.words("english")
from_index=cachedStopWords.index('from')
cachedStopWords.pop(from_index)

def remove_stop_words(text):
	text = ' '.join([word for word in text.split() if word not in cachedStopWords])
	print(text)

