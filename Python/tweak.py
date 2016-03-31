from fractions import gcd
from math import log, floor
from collections import defaultdict
from re import sub
from subprocess import check_output, Popen, PIPE, STDOUT
import shlex

# run program and extract score
def evaluate(original, filename):
  no_lines = len(original)

  # write new file
  counter = defaultdict(lambda: 0) # reset counters
  with open(filename, 'wt') as fid:
    for line_no in range(no_lines):
      line = original[line_no]
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
  #result = check_output(command, shell=True, universal_newlines=True) # problem?
  process = Popen(command, bufsize=-1, shell=True, stdout=PIPE, stderr=STDOUT, \
    universal_newlines=True)

  result = process.communicate()  # YES!
  # Interact with process:  Send data to stdin. Read data from stdout and
  #  stderr, until end-of-file is reached. Wait for process to terminate.
  # Note:  The data read is buffered in memory, so do not use this method if
  #  the data size is large or unlimited.

  result = shlex.split(result[0])

  #process.wait()  # NO!
  # Warning:  This will deadlock when using stdout=PIPE and/or stderr=PIPE and
  #  the child process generates enough output to a pipe such that it blocks
  #  waiting for the OS pipe buffer to accept more data. Use communicate() to
  #  avoid that.

  cross_entropy = float(sub('cross-entropy=', '', result[-2]))
  perplexity = float(sub('perplexity=', '', result[-1]))

  return perplexity, cross_entropy


def reduce(values):
  if len(values) < 2:
    return values[0]
  else:
    return gcd(values[0], reduce(values[1:]))

# include START
S1_tags = ['START', 'S1', 'VPComplex', 'VPComplexPl', 'NextSeg', \
  'NP', 'NPPl', 'B4Noun', 'VP', 'VPPl', 'AftVerb', 'PP', 'NumP', \
  'AdjP', 'AdjCompP', 'AdjSupP', 'AdvP', 'ConjP', 'SubP', \
  'PossP', 'PossPPl', 'WDetP', 'WAdvP', 'WProP', 'WP']

# ignore START (S1/S2 balance) for now
#S1_tags = ['S1', 'VPComplex', 'VPComplexPl', 'NextSeg', \
#  'NP', 'NPPl', 'B4Noun', 'VP', 'VPPl', 'AftVerb', 'PP', 'NumP', \
#  'AdjP', 'AdjCompP', 'AdjSupP', 'AdvP', 'ConjP', 'SubP', \
#  'PossP', 'PossPPl', 'WDetP', 'WAdvP', 'WProP', 'WP']

# include ONLY START
#S1_tags = ['START']

S2_tags = ['S2', '_Adj', '_AdjComp', '_AdjSup', '_Adv', '_ConjCoord', \
  '_ConjSub', '_Det', '_Do', '_Does', '_End', '_Modal', '_Neg', \
  '_Noun', '_NounPl', '_NounProp', '_NounPropPl', '_Num', '_Pause', '_Person', \
  '_Poss', '_Prep', '_Pro', '_ProPl', '_ProPoss', '_ProPossPl', '_There', \
  '_To', '_Verb', '_Verb3Pl', '_VerbGer', '_VerbInt3', '_VerbPast', \
  '_VerbPastPart', '_VerbTrans3', '_WAdv', '_WDet', '_WPro', '_WProPoss']

Vocab_tags = ['Noun', 'Det', 'Prep', 'Person', 'VerbTrans3', 'End', 'Pause', \
  'ConjCoord', 'Num', 'There', 'ConjSub', 'Modal', 'Adj', 'AdjComp', 'AdjSup', \
  'NounPl', 'NounProp', 'NounPropPl', 'Pro', 'ProPl', 'ProPoss', 'ProPossPl', \
  'Adv', 'Do', 'Does', 'To', 'Neg', 'Verb', 'VerbPast', 'VerbGer', \
  'VerbPastPart', 'VerbInt3', 'Verb3Pl', 'WDet', 'WPro', 'WProPoss', 'WAdv', \
  'Poss']

filenames = ['S1.gr', 'S2.gr', 'Vocab.gr']
all_tags = [S1_tags, S2_tags, Vocab_tags]
no_filenames = len(filenames)

base = 2
power = 20
ns = defaultdict(lambda: defaultdict(lambda: []))

f = 0
antique_score = float('Infinity')
any_progress = True
initialize = True # True - use new values, False - use existing values
first_time = True
while any_progress:
  filename = filenames[f]
  tags = all_tags[f]
  no_tags = len(tags)

  print('Tweaking "%s" ...' % filename)

  # load original file
  original = []
  values = defaultdict(lambda: [])
  with open(filename, 'rt') as fid:
    for line in fid:
      original.append(line)
      parse = line.split()
      if len(parse) > 0 and parse[1] in tags:
        tag = parse[1]
        if initialize:
          value = int(base**power) # initialize to default values
        else:
          value = int(parse[0]) # reuse values already in file
        values[tag].append(value)


  best_score = float('Infinity')
  perplexity, cross_entropy = evaluate(original, filename)
  if perplexity < best_score:
    best_score = perplexity

  # tweak numbers
  improvement = first_time
  if improvement:
    print('\nAttempting MULTIPLICATIVE tweak ...\n')
  while improvement:
    improvement = False
    for tag in tags:
      print('Lowest Perplexity = %.2f,\tWorking on %s ...' % (best_score, tag))
      no_values = len(values[tag])
      if no_values == 1:
        values[tag][0] = 1

      j = 0
      direction = 1
      old_score = best_score
      change = True
      while no_values > 1 and change:
        if direction == 1:
          values[tag][j] *= base
          perplexity, cross_entropy = evaluate(original, filename)
          if perplexity < best_score:
            best_score = perplexity
            improvement = True
          else:
            direction = -1
            values[tag][j] //= base # undo last step
        if direction == -1:
          if values[tag][j] > 1:
            values[tag][j] //= base
            perplexity, cross_entropy = evaluate(original, filename)
            if perplexity < best_score:
              best_score = perplexity
              improvement = True
            else:
              direction = 0
              values[tag][j] *= base # undo last step
          else: # if values[tag][j] == 1
            direction = 0 # go to next index
        if direction == 0:
          j = (j + 1) % no_values
          direction = 1
          change = True
          if j == 0:
            change = False
            if old_score > best_score:
              old_score = best_score
              change = True


  # update powers
  if first_time: # i.e. still in multiplicative phase
    for tag in tags:
      ns[filename][tag] = [floor(log(value, base)) for value in values[tag]]


  # supertweak
  improvement = not first_time
  if improvement:
    print('\nAttempting ADDITIVE tweak ...\n')
  while improvement:
    improvement = False
    for tag in tags:
      print('Lowest Perplexity = %.2f,\tWorking on %s ...' % (best_score, tag))
      no_values = len(values[tag])

      j = 0
      direction = 1
      m = 1
      old_score = best_score
      change = True
      while no_values > 1 and change:
        if direction == 1:
          n = ns[filename][tag][j]
          jump = base**(n-m)
          values[tag][j] += jump
          perplexity, cross_entropy = evaluate(original, filename)
          if perplexity < best_score:
            best_score = perplexity
            improvement = True
          else:
            direction = -1
            values[tag][j] -= jump # undo last step
        if direction == -1:
          if values[tag][j] > 1:
            jump = max(base**(n-1-m), 1)
            values[tag][j] -= jump
            perplexity, cross_entropy = evaluate(original, filename)
            if perplexity < best_score:
              best_score = perplexity
              improvement = True
            else:
              direction = 0
              values[tag][j] += jump # undo last step
          else: # if values[tag][j] == 1
            direction = 0 # go to next index
        if direction == 0:
          j = (j + 1) % no_values
          direction = 1
          change = True
          if j == 0:
            change = False
            if old_score > best_score:
              old_score = best_score
              change = True
            elif m < min(ns[filename][tag]) - 1:
              m += 1
              change = True


  # save latest result
  print('Writing latest result to file ...\n')
  perplexity, cross_entropy = evaluate(original, filename)

  f = no_filenames - f - 1  # toggle between first and last filenames
  #f = (f + 1) % no_filenames # tweak all three files
  if f == 0:
    any_progress = False
    if antique_score > best_score:
      antique_score = best_score
      any_progress = True
      initialize = False # don't reinitialize file again
    if any_progress == False and first_time == True:
      any_progress = True
      first_time = False


# reduce values by greatest common denominator per tag per file
for f in [0, 2]:             # adjust first and last filenames
#for f in range(no_filenames): # adjust all three filenames
  filename = filenames[f]
  tags = all_tags[f]

  # load original file
  original = []
  values = defaultdict(lambda: [])
  with open(filename, 'rt') as fid:
    for line in fid:
      original.append(line)
      parse = line.split()
      if len(parse) > 0 and parse[1] in tags:
        tag = parse[1]
        value = int(parse[0]) # reuse values already in file
        values[tag].append(value)

  print('\nReducing values in %s ...' % filename)
  for tag in tags:
    GCD = reduce(values[tag]) # find GCD
    values[tag] = [value // GCD for value in values[tag]] # reduce value by GCD

  # save latest result
  print('Writing final result to file ...\n')
  perplexity, cross_entropy = evaluate(original, filename)
  print('Best Perplexity = %.2f, Best Cross-Entropy = %f' % \
    (perplexity, cross_entropy))










