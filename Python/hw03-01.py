from random import random, randrange, randint
from re import findall
from copy import deepcopy

filename = 'kargerAdj.txt'

oG = []
fid = open(filename, 'rt')
for line in fid:
  Vs = [int(V) for V in findall('\d+', line)]  # find all vertices
  oG.append([Vs[0], Vs[1:]]) # allow for parallel edges
fid.close()


def Karger(G):
  n = len(G)                       # number of vertices by convention

  while n > 2:
    V1, V2 = pick_edge(G)
    contract(G, V1, V2) # modifies original G
    n = len(G)                            # number of vertices by convention

  deg = [len(G[i][1]) for i in range(n)]  # number of degrees per vertex
  m = sum(deg)//2                         # number of edges by convention

  return m


def contract(G, V1, V2): # merge nodes V1 and V2
  n = len(G)

  i = 0
  match = False
  while match == False and i < n:
    match = (V1 == G[i][0] and V2 in G[i][1])
    i += 1
  if match:
    for i in range(n):
      if V1 == G[i][0] and V2 in G[i][1]:
        while V2 in G[i][1]:  # to eliminate self loops
          G[i][1].remove(V2)  # remove V2 from vertices
        i1 = i # save for later
      elif V2 == G[i][0] and V1 in G[i][1]: # for undirected graph
        while V1 in G[i][1]:  # to eliminate self loops
          G[i][1].remove(V1)  # remove V1 from vertices
        i2 = i # save for later
      if V2 in G[i][1]:
        while V2 in G[i][1]:  # ensure to catch them all
          G[i][1].append(V1)  # i.e. replace V2 with V1
          G[i][1].remove(V2)
    G[i1][1] += G[i2][1] # merge nodes
    del G[i2] # remove old
  else: # if not match
    print('Edge (%d, %d) not in graph!' % (V1, V2))
  return G


#cf. AIR 3.20 -- Resampling Wheel
def pick_edge(G):
  n = len(G)                              # number of vertices by convention
  deg = [len(G[i][1]) for i in range(n)]  # number of degrees per vertex
  m = sum(deg)//2                         # number of edges by convention

  index = randrange(n)  # random starting point, indexing V1 in G
  beta = randrange(2*m) # random distance from starting point, indexing V2 in edges
  while deg[index] <= beta:
    beta -= deg[index]
    index = (index + 1) % n
  V1 = G[index][0]
  V2 = G[index][1][beta]

  return V1, V2


n = len(oG)                             # number of vertices by convention
deg = [len(oG[i][1]) for i in range(n)] # number of degrees per vertex
m = sum(deg)//2                         # number of edges by convention

T = n*(n-1)//2
min_cut = m
for t in range(T):
  G = deepcopy(oG) # copy original graph
  new_cut = Karger(G)
  if min_cut > new_cut:
    print('@ iteration %3d, found new cut = %d' % (t, new_cut))
    min_cut = new_cut

print('Minimum Cut is %d' % min_cut)
