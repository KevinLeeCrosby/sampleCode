# cf. 5.1-2, 5.4

from math import ceil, floor
from random import randrange, randint

filename = 'QuickSort.txt'

A = [0] * 10000 # initialize array
i = 0
fid = open(filename, 'rt')  # number of comparisons = 162085
for line in fid:
  A[i] = int(line)
  i += 1
fid.close()

## CHOOSING PIVOT POINT AT BEGINNING OF ARRAY
#A = [1, 2, 3, 4, 5, 6, 7, 8] # number of comparisons = 28
#A = [3, 8, 2, 5, 1, 4, 7, 6] # number of comparions = 15
#   after 1st rearrangement, should be [2, 1, 3, 5, 8, 4, 7, 6]
#A = [4, 2, 1, 3, 6, 7, 5, 8] # number of comparions = 14
#A = [8, 7, 6, 5, 4, 3, 2, 1] # number of comparions = 28

n = len(A)

no_comparisons = 0  # number of comparisons
cross_check = 0     # number of comparisons cross check


# cf. 5.1-2, 5.4
def QuickSort(A, nc = 0, cc = 0, l = 0, r = len(A)): # [Tony Hoare circa 1961]
  if l < r:
    cc += r - l - 1   # per general directions
    i, A = Partition(A, l, r)

    nc += i - l       # per general directions
    A, nc, cc = QuickSort(A, nc, cc, l, i)

    nc += r - (i + 1) # per general directions
    A, nc, cc = QuickSort(A, nc, cc, i + 1, r)

  return A, nc, cc


# cf. 5.2
def Partition(A, l, r):
  A = ChoosePivot(A, l, r) # put pivot point in first place

  p = A[l] # naively choose first element
  i = l + 1
  for j in range(l + 1, r): # l+1 <= i < r
    if A[j] < p: # if A[j] > p, do nothing
      A[i], A[j] = (A[j], A[i]) # swap (redundant for equal numbers)
      i += 1
  A[i-1], A[l] = (A[l], A[i-1]) # swap to put pivot in correct place

  return i-1, A


# cf. 5.4
def ChoosePivot(A, l, r):
  # choose first element ## Programming Assignment 02-01
  if question == 1:
    k = l

  # choose last element  ## Programming Assignment 02-02
  if question == 2:
    k = r - 1

  # choose random element
  #k = randrange(l, r+1)
  #k = randint(l, r)

  # choose "median-of-three"
  if question == 3:
  # first = l, final = r - 1, middle = l + floor((l+r-1)/2)
    m = (l + r - 1) // 2
    if A[l] > A[r - 1]:
      large = l
      small = r - 1
    else:
      large = r - 1
      small = l
    if A[m] > A[large]:
      k = large
    elif A[m] < A[small]:
      k = small
    else:
      k = m

  if k > l and k < r:
    A[l], A[k] = (A[k], A[l])

  return A # return A in case of swap above


question = 3
B, no_comparisons, cross_check = QuickSort(A, no_comparisons, cross_check)
C = A[:]
C.sort()
if B == C:
  print(no_comparisons, cross_check)
else:
  print('Sort FAILED')


