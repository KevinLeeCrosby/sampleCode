# cf. 3.1-2

from math import ceil, floor

#a = [1, 3, 5, 2, 4, 6] # number of inversions = 3
#a = [6, 5, 4, 3, 2, 1] # number of inversions = 15

a = [5, 3, 8, 9, 1, 7, 0, 2, 6, 4]

n = len(a)


def merge(al, ar, n):
  a = [0] * n
  nl = len(al)
  nr = len(ar)
  i, j = (0, 0)
  for k in range(n):
    if i < nl and (j == nr or al[i] < ar[j]):
      a[k] = al[i]
      i += 1
    else: # al[i] >= ar[j]
      a[k] = ar[j]
      j += 1

  return a


def merge_sort(a, n):
  if n == 1:
    return a
  else:
    b = a
    nl = floor(n/2) # left inversion i,j <= n/2, for i < j
    nr = ceil(n/2)  # right inversion i,j > n/2, for i < j
    al = merge_sort(a[:nl], nl) # sort on left
    ar = merge_sort(a[nl:], nr) # sort on right (nl is CORRECT)
    a = merge(al, ar, n)        # merge left and right
    print(b, ' => ', a)

    return a



d = merge_sort(a, len(a))