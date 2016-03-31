# The 2-Sum Problem

filename = 'HashInt.txt'

Ts = [231552,234756,596873,648219,726312,981237,988331,1277361,1283379]

no_Ts = len(Ts)
result = 0  # all zeros

#As = [0] * 100000 # initialize array (with repetitions)
H = dict() # hash table
#i = 0
with open(filename, 'rt') as fid:
  for line in fid:
    A = int(line)
    #As[i] = A
    H[A] = True
    #i += 1

bit = 2**no_Ts
for T in Ts:
  bit >>= 1       # shift right 1 bit
  #print('Processing target %d ...' % T)
  for X in H.keys():
    found = False
    Y = T - X
    if Y in H.keys():
      print('1\t%d + %d = %d' % (X, Y, T))
      result |= bit  # change bit to True
      found = True
      break # out of inner loop
  if not found:
    print('0\tNone found for %d' % T)

s = sub('0b', '', bin(result)).zfill(no_Ts)

print('Result is "%s".' % s)








