# server

import glob
import mincemeat as mm


filenames = glob.glob('hw3data/*')
def preprocess(filename):
  with open(filename) as f:
    return f.read()


def postprocess(results): # i.e. key, value
  #f = open('results.txt', 'w')
  for author in results.keys():
    count = results[author]
    pairs = count.most_common()
    for pair in pairs:
      term, frequency = pair
      print('{}, {}, {}'.format(author, term, frequency))
      #f.write(str((author, term, frequency)))


sources = dict((filename, preprocess(filename)) for filename in filenames)


# client

def mapfn(filename, source): # i.e. key, value
  import re
  import stopwords
  stopwords = stopwords.allStopWords.keys()
  for line in source.splitlines(): # separate by newline
    paper_id, authors, title = line.split(':::')
    title = re.sub(r'\'', '', title.lower())             # lowercase, remove apostrophes
    title = re.sub(r'\b[a-z]\b|[^0-9a-z\s]', ' ', title) # replace single letters and punctuation with space
    terms = title.split()                                # separate terms
    for term in terms:
      if term not in stopwords:
        for author in authors.split('::'):
          yield author, term


def reducefn(author, terms): # i.e. key, value
  from collections import Counter as count
  return count(terms)


s = mm.Server()
s.datasource = sources
s.mapfn = mapfn
s.reducefn = reducefn

results = s.run_server(password="changeme")
postprocess(results)
