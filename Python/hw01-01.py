# cf. 3.1-2

from math import ceil, floor

filename = 'IntegerArray.txt'

readit = False
readit = True
if readit:
  a = [0] * 100000 # initialize array
  i = 0
  fid = open(filename, 'rt')  # number of inversions = 2407905288
  for line in fid:
    a[i] = int(line)
    i += 1
  fid.close()
  readit = False
# end if readit

#a = [1, 3, 5, 2, 4, 6] # number of inversions = 3
#a = [6, 5, 4, 3, 2, 1] # number of inversions = 15
n = len(a)


def merge_and_count_split_inv(al, ar, n):
  a = [0] * n
  nl = len(al)
  nr = len(ar)
  i, j = (0, 0)
  c = 0
  for k in range(n):
    if i < nl and (j == nr or al[i] < ar[j]):
      a[k] = al[i]
      i += 1
    else: # al[i] >= ar[j]
      a[k] = ar[j]
      j += 1
      c += nl - i

  return a, c


def sort_and_count(a, n):
  if n == 1:
    return a, 0
  else:
    nl = floor(n/2) # left inversion i,j <= n/2, for i < j
    nr = ceil(n/2)  # right inversion i,j > n/2, for i < j
    al, cl = sort_and_count(a[:nl], nl) # count left
    ar, cr = sort_and_count(a[nl:], nr) # count right (nl is CORRECT)
    a, cs = merge_and_count_split_inv(al, ar, n) # count split inversions

    return a, cl + cr + cs



d, c = sort_and_count(a, len(a))