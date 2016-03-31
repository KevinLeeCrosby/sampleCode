from math import *

def nCk(n, k):
  return factorial(n) / (factorial(k)*factorial(n - k))


def nPk(n, k):
  return factorial(n) / factorial(k)


# this is partitioning a number into 4 parts

N = 12

partitions = 0
count = 0
for a in range(N + 1):
  for b in range(N - a + 1):
    for c in range(N - a - b + 1):
      d = N - a - b - c
      #comb = nCk(N, a)*nCk(N, b)*nCk(N, c)*nCk(N, d)
      perm = nPk(N, a)*nPk(N, b)*nPk(N, c)*nPk(N, d)
      partitions += perm
      if a*b*c*d > 0:
        count += perm
      print("%2d + %2d + %2d + %2d = %2d" % (a, b, c, d, a+b+c+d))


probability = count / partitions

print("Probability that all 4 cells have at least 1 particle is " + str(probability))

# correct answer 0.8747591972351065
