import numpy as np
import nltk
import re
import os
from sklearn import feature_extraction
from nltk.stem.snowball import SnowballStemmer
stopwords = nltk.corpus.stopwords.words("english")
stemmer = SnowballStemmer("english")
from sklearn.feature_extraction.text import CountVectorizer
import lda  

#############################documentation preparation###############################

doc1 = "Sugar is bad to consume. My sister likes to have sugar, but not my father."
doc2 = "My father spends a lot of time driving my sister around to dance practice."
doc3 = "Doctors suggest that driving may cause increased stress and blood pressure."
doc4 = "Sometimes I feel pressure to perform well at school, but my father never seems to drive my sister to do better."
doc5 = "Health experts say that Sugar is not good for your lifestyle."

# compile documents
doc = [doc1, doc2, doc3, doc4, doc5]

###########################text preprocessing######################################


def preprocessing(doc, lower = True, stop_word = True, punctuation = True, word = True, stem = False):
    '''
    lower: do lower the words
    doc: one single document
    word: whether we want to word tokenize or sentence tokenize
    stem: whether we want to stem
    
    steps: tokenize -> remove stopwords -> remove punctuation -> stem
    '''
    if lower:
        doc = doc.lower()
    if word:
        if punctuation:
            from nltk.tokenize import RegexpTokenizer
            tokenizer = RegexpTokenizer(r'\w+')
            tokens = tokenizer.tokenize(doc)   
    else:
        tokens = nltk.sent_tokenize(doc)
        
    if stop_word:
        tokens = [i for i in tokens if i not in stopwords]
        
    if stem:
        stems = [stemmer.stem(t) for t in tokens]
    return tokens

tokens = [preprocessing(i) for i in doc]


####################tfidf transformation################################

from sklearn.feature_extraction.text import TfidfVectorizer

tfidf_vectorizer = TfidfVectorizer(max_df = 0.8, max_features = 10000, min_df = 0.05, 
                                  stop_words = None,use_idf = True, 
                                  tokenizer = preprocessing, ngram_range = (1,2))
    
print('vectorizing...')
tfidf_matrix = tfidf_vectorizer.fit_transform(doc)
print('tfidf matrix shape: ')
print(tfidf_matrix.shape)
print


terms = tfidf_vectorizer.get_feature_names()
print('first 100 terms: ')
print(terms[:100])
print

###########################topic modeling####################################

tf_vectorizer = CountVectorizer(max_df=0.95, min_df=2, max_features=1000,
                                    stop_words=None, tokenizer = preprocessing, ngram_range = (1,2))

tf = tf_vectorizer.fit_transform(doc)

model = lda.LDA(n_topics=3, n_iter=50, random_state=1)
model.fit(tf)
vocab = tf_vectorizer.get_feature_names()
topic_word = model.topic_word_  



#########################text clustering####################################

from sklearn.metrics.pairwise import cosine_similarity
dist = 1 - cosine_similarity(tfidf_matrix)
print('distance matrix: ')
print(dist)
print

from sklearn.cluster import KMeans

num_clusters = 2

km = KMeans(n_clusters = num_clusters)
km.fit(tfidf_matrix)


