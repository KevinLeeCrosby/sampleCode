from fractions import gcd
from math import log, floor
from collections import defaultdict
from re import sub
from copy import deepcopy
from subprocess import check_output
import shlex

# run program and extract score
def evaluate(tweaked, filename):
  no_lines = len(tweaked)

  # write new file
  counter = defaultdict(lambda: 0) # reset counters
  with open(filename, 'wt') as fid:
    for line_no in range(no_lines):
      line = tweaked[line_no]
      parse = line.split()
      if len(parse) > 0 and parse[1] in tags:
        tag = parse[1]
        value = values[tag][counter[tag]]
        counter[tag] += 1
        line = sub('^\d+', str(value), line) # update value
      fid.write(line)
  if not fid.closed:
    fid.close()


  # assess new result
  command = 'java -jar pcfg.jar parse dev.sen *.gr'
  result = check_output(command, shell=True, universal_newlines=True)
  result = shlex.split(result)
  cross_entropy = float(sub('cross-entropy=', '', result[-2]))
  perplexity = float(sub('perplexity=', '', result[-1]))

  return perplexity, cross_entropy


def reduce(values):
  if len(values) < 2:
    return values[0]
  else:
    return gcd(values[0], reduce(values[1:]))


filename = 'S1.gr'
# ignore START (S1/S2 balance) for now
tags = ['S1', 'VPComplex', 'VPComplexPl', 'NextSeg', \
  'NP', 'NPPl', 'B4Noun', 'VP', 'VPPl', 'AftVerb', 'PP', 'NumP', \
  'AdjP', 'AdjCompP', 'AdjSupP', 'AdvP', 'ConjP', 'SubP', \
  'PossP', 'PossPPl', 'WDetP', 'WAdvP', 'WProP', 'WP']

#tags = ['START']

#filename = 'S2.gr'
#tags = ['S2', '_Adj', '_AdjComp', '_AdjSup', '_Adv', '_ConjCoord', '_ConjSub', \
#  '_Det', '_Do', '_Does', '_End', '_Modal', '_Neg', '_Noun', '_NounPl', \
#  '_NounProp', '_NounPropPl', '_Num', '_Pause', '_Person', '_Poss', '_Prep', \
#  '_Pro', '_ProPl', '_ProPoss', '_ProPossPl', '_There', '_To', '_Verb', \
#  '_Verb3Pl', '_VerbGer', '_VerbInt3', '_VerbPast', '_VerbPastPart', \
#  '_VerbTrans3', '_WAdv', '_WDet', '_WPro', '_WProPoss']

#filename = 'Vocab.gr'
#tags = ['Noun', 'Det', 'Prep', 'Person', 'VerbTrans3', 'End', 'Pause', \
#  'ConjCoord', 'Num', 'There', 'ConjSub', 'Modal', 'Adj', 'AdjComp', 'AdjSup', \
#  'NounPl', 'NounProp', 'NounPropPl', 'Pro', 'ProPl', 'ProPoss', 'ProPossPl', \
#  'Adv', 'Do', 'Does', 'To', 'Neg', 'Verb', 'VerbPast', 'VerbGer', \
#  'VerbPastPart', 'VerbInt3', 'Verb3Pl', 'WDet', 'WPro', 'WProPoss', 'WAdv', \
#  'Poss']

no_tags = len(tags)

initialize = True # True - use new values, False - use existing values from file
#initialize = False # True - use new values, False - use existing values from file
base = 2
power = 15
#base = 10
#power = 3


# load original file
original = []
with open(filename, 'rt') as fid:
  for line in fid:
    original.append(line)
no_lines = len(original)


# gather information
tweaked = deepcopy(original)
#indices = defaultdict(lambda: [])
values = defaultdict(lambda: [])
for line_no in range(no_lines):
  line = tweaked[line_no]
  parse = line.split()
  if len(parse) > 0 and parse[1] in tags:
    tag = parse[1]
    #indices[tag].append(line_no)
    if initialize:
      value = int(base**power) # initialize to default values
    else:
      value = int(parse[0]) # reuse values already in file
    values[tag].append(value)


best_score = float('Infinity')
perplexity, cross_entropy = evaluate(tweaked, filename)
if perplexity < best_score:
  best_score = perplexity

# tweak numbers
for supertweak in [False, True]: # False - multiplicative, True - additive
  if not supertweak:
    print('\nAttempting MULTIPLICATIVE tweak ...\n')
  else: # if supertweak
    print('\nAttempting ADDITIVE tweak ...\n')
  improvement = True
  while improvement:
    improvement = False
    for tag in tags:
      print('Working on %s...\tLowest Perplexity = %.2f' % (tag, best_score))
      no_values = len(values[tag])

      j = 0
      n = floor(log(values[tag][j], base))
      directions = [1] * no_values # reset
      old_score = best_score
      old_loop = (j > 0)
      change = True
      while no_values > 1 and (change or not old_loop):
        if directions[j] == 1:
          if not supertweak:
            values[tag][j] *= base
            perplexity, cross_entropy = evaluate(tweaked, filename)
          else: # if supertweak
            values[tag][j] += 1
            perplexity, cross_entropy = evaluate(tweaked, filename)
          if perplexity < best_score:
            best_score = perplexity
            improvement = True
          else:
            directions[j] = -1
            if not supertweak:
              values[tag][j] //= base # undo last step
            else: # if supertweak
              values[tag][j] -= 1
        if directions[j] == -1:
          if values[tag][j] > 1:
            if not supertweak:
              values[tag][j] //= base
            else: # if supertweak
              values[tag][j] -= 1
            perplexity, cross_entropy = evaluate(tweaked, filename)
            if perplexity < best_score:
              best_score = perplexity
              improvement = True
            else:
              directions[j] = 0
              if not supertweak:
                values[tag][j] *= base # undo last step
              else: # if supertweak
                values[tag][j] += 1
          else: # if values[tag][j] == 1
            directions[j] = 0 # go to next index
        if directions[j] == 0:
          directions[j] = 1
          j = (j + 1) % no_values
          old_loop = (j > 0)
          if j == 0:
            change = (old_score > best_score)
            old_score = best_score


# reduce values by greatest common denominator per tag
print('\nReducing values ...')
for tag in tags:
  GCD = reduce(values[tag]) # find GCD
  values[tag] = [value // GCD for value in values[tag]] # reduce value by GCD

print('Writing final result to file ...\n')
# save latest result
perplexity, cross_entropy = evaluate(tweaked, filename)
print('Best Perplexity = %.2f, Best Cross-Entropy = %f' % \
  (perplexity, cross_entropy))












