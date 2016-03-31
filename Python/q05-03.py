from random import randrange

m = randrange(10, 100)      # number of buckets
n = randrange(10*m, 100*m)  # number of keys

strings = ['m/(2n)', 'n/m', '1/n', 'm/n', '1/m', 'n/(2m)', 'n/(m^n)']
answers = [ m/(2*n),  n/m ,  1/n ,  m/n ,  1/m ,  n/(2*m),  n/m**n  ]

T = [0] * m

for key in range(n):
  bucket = randrange(m)
  T[bucket] += 1

bucket = randrange(m)
result = T[bucket]

best_delta = float('Infinity')
best_index = -1
for i in range(len(answers)):
  answer = answers[i]
  delta = abs(answer - result)
  if delta < best_delta:
    best_delta = delta
    best_index = i

print('# of buckets = %d, # of keys = %d' % (m, n))
print('best answer = %s, best delta = %.2f' % (strings[i], best_delta))
