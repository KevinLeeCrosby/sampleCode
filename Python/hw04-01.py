#import sys, threading
#sys.setrecursionlimit(100000)
#threading.stack_size(2**27)

filename = 'SCC.txt'
n = 875714  # number of vertices (nodes)
m = 5105042 # number of edges

#filename = 'SCCtest1.txt'  # answer [3,3,3,0,0]
#n = 9
#m = 11

#filename = 'SCCtest2.txt'  # answer [4,3,3,0,0]
#n = 10
#m = 23

#filename = 'SCCtest3.txt'  # answer [6,5,3,1,0]
#n = 15
#m = 29

#filename = 'SCCtest4.txt'  # answer [2,1,1,1,0]
#n = 5
#m = 5

readit = False
#readit = True
if readit:
  G  = [[] for _ in range(n+1)] # preallocate for speed
  Gr = [[] for _ in range(n+1)] # preallocate for speed

  with open(filename, 'rt') as fid:
    for line in fid:
      i, j = line.split()
      i, j = int(i), int(j)
      G[i].append(j)
      Gr[j].append(i)
  readit = False


leader  = [[] for _ in range(n+1)]
f       = [[] for _ in range(n+1)]


#def DFS(G, i, s, t, explored): # recursive
#  explored[i] = True
#  leader[i] = s
#  for vertex in G[i]:
#    if not explored[vertex]:
#      t = DFS(G, vertex, s, t, explored)
#  if f[0] == []:    # i.e. if first pass
#    t += 1
#    f[i] = t
#  return t


#def DFS(G, v, s, t, explored): # non-recursive
#  stack = [v]            # initialize stack
#  while len(stack) > 0:  # while stack not empty
#    v = stack[-1]        # reference top of stack
#    if not explored[v]:  # i.e. if not expanded
#      explored[v] = True
#      leader[v] = s
#      if f[0] == []:  # i.e. if first pass
#        i = v
#      else:           # i.e. if second pass
#        i = f.index(v)
#      for j in G[i]:     # expand now
#        if f[0] == []:  # i.e. if first pass
#          w = j
#        else:           # i.e. if second pass
#          w = f[j]
#        #if not explored[w] and w not in stack:
#        if not explored[w]:
#          stack.append(w) # push w onto stack
#    if v == stack[-1]:   # if no children of v on stack
#      v = stack.pop()
#      if f[0] == []:  # i.e. if first pass
#        t += 1
#        f[v] = t
#  return t


def DFS(G, v, s, t, explored): # non-recursive
  stack = [v]            # initialize stack
  while len(stack) > 0:  # while stack not empty
    v = stack[-1]        # reference top of stack
    if not explored[v]:  # i.e. if not expanded
      if f[0] == []:  # i.e. if first pass
        i = v
      else:           # i.e. if second pass
        i = f.index(v)
      barren = True
      for j in G[i]:     # expand now
        if f[0] == []:  # i.e. if first pass
          w = j
        else:           # i.e. if second pass
          w = f[j]
        if not explored[w] and w not in stack:
          barren = False
          stack.append(w) # push w onto stack
          break # push only one child
      if barren:
        explored[v] = True
        leader[v] = s
    if v == stack[-1]:   # if no children of v on stack
      v = stack.pop()
      if f[0] == []:  # i.e. if first pass
        t += 1
        f[v] = t
  return t


def DFS_Loop(G):
  explored = [False] * (n+1)  # initialize
  s = []
  t = 0
  for v in range(n, 0, -1):
    if not explored[v]:  # i.e. if first pass
      s = v
      t = DFS(G, v, s, t, explored)
  if f[0] == []:  # i.e. if first pass
    f[0] = 0 # flag to differentiate first and second pass


def scc(G, Gr):
  # Kosaraju's Two-Pass Algorithm
  DFS_Loop(Gr) # compute "magical ordering" of nodes in f(v)
  DFS_Loop(G)  # discover the SCCs one-by-one (SCCs = nodes with the same "leader")

  del leader[0] # remove empty set
  counts = [leader.count(i) for i in set(leader)]
  counts.sort()
  counts.reverse()

  while len(counts) < 5:
    counts.append(0)

  print('%d,%d,%d,%d,%d' % tuple(counts[0:5]))


#thread = threading.Thread(target=scc, args=(G, Gr))
#thread.start()
#thread.join()

scc(G, Gr)
