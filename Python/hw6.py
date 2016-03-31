import sqlite3

database = sqlite3.connect(':memory:')
c = database.cursor()

# Create database:

c.execute('CREATE TABLE A (a text, P float)')
c.execute('INSERT INTO A VALUES ("Y", .01)')
c.execute('INSERT INTO A VALUES ("N", .99)')
database.commit()

c.execute('CREATE TABLE T (t text, a text, P float)')
c.execute('INSERT INTO T VALUES ("Y", "Y", .05)')
c.execute('INSERT INTO T VALUES ("Y", "N", .01)')
c.execute('INSERT INTO T VALUES ("N", "Y", .95)')
c.execute('INSERT INTO T VALUES ("N", "N", .99)')
database.commit()

c.execute('CREATE TABLE S (s text, P float)')
c.execute('INSERT INTO S VALUES ("Y", .50)')
c.execute('INSERT INTO S VALUES ("N", .50)')
database.commit()

c.execute('CREATE TABLE L (l text, s text, P float)')
c.execute('INSERT INTO L VALUES ("Y", "Y", .10)')
c.execute('INSERT INTO L VALUES ("Y", "N", .01)')
c.execute('INSERT INTO L VALUES ("N", "Y", .90)')
c.execute('INSERT INTO L VALUES ("N", "N", .99)')
database.commit()

c.execute('CREATE TABLE B (b text, s text, P float)')
c.execute('INSERT INTO B VALUES ("Y", "Y", .60)')
c.execute('INSERT INTO B VALUES ("Y", "N", .30)')
c.execute('INSERT INTO B VALUES ("N", "Y", .40)')
c.execute('INSERT INTO B VALUES ("N", "N", .70)')
database.commit()

c.execute('CREATE TABLE E (e text, l text, t text, P float)')
c.execute('INSERT INTO E VALUES ("Y", "Y", "Y", 1)')
c.execute('INSERT INTO E VALUES ("Y", "Y", "N", 1)')
c.execute('INSERT INTO E VALUES ("Y", "N", "Y", 1)')
c.execute('INSERT INTO E VALUES ("Y", "N", "N", 0)')
c.execute('INSERT INTO E VALUES ("N", "Y", "Y", 0)')
c.execute('INSERT INTO E VALUES ("N", "Y", "N", 0)')
c.execute('INSERT INTO E VALUES ("N", "N", "Y", 0)')
c.execute('INSERT INTO E VALUES ("N", "N", "N", 1)')
database.commit()

c.execute('CREATE TABLE X (x text, e text, P float)')
c.execute('INSERT INTO X VALUES ("Y", "Y", .98)')
c.execute('INSERT INTO X VALUES ("Y", "N", .05)')
c.execute('INSERT INTO X VALUES ("N", "Y", .02)')
c.execute('INSERT INTO X VALUES ("N", "N", .95)')
database.commit()

c.execute('CREATE TABLE D (d text, e text, b text, P float)')
c.execute('INSERT INTO D VALUES ("Y", "Y", "Y", .90)')
c.execute('INSERT INTO D VALUES ("Y", "Y", "N", .70)')
c.execute('INSERT INTO D VALUES ("Y", "N", "Y", .80)')
c.execute('INSERT INTO D VALUES ("Y", "N", "N", .10)')
c.execute('INSERT INTO D VALUES ("N", "Y", "Y", .10)')
c.execute('INSERT INTO D VALUES ("N", "Y", "N", .30)')
c.execute('INSERT INTO D VALUES ("N", "N", "Y", .20)')
c.execute('INSERT INTO D VALUES ("N", "N", "N", .90)')
database.commit()

# marginalization example:
#c.execute('SELECT R,SUM(P) FROM T(R,W) GROUP BY R')

# joint probability example:
#c.execute('SELECT R,SUM(P1*P2) FROM T1(R,W),T2(W) WHERE W="Y"')

# applying evidence example:
#c.execute('SELECT R,W,P FROM T(R,W) WHERE W1=W2 GROUP BY R')

# naive Bayes classifier example:
#c.execute('SELECT R,SUM(P1*P2) FROM T1(R,W),T2(W) WHERE W="Y" AND R1=R2 GROUP BY R')

# naive Bayes classifier (multiple features - partial evidence) example:
#c.execute('SELECT R,SUM(P1*P2*P3) FROM T1(W,R),T2(T,R),T3(R) WHERE W="Y" AND \
#           R1=R2,R2=R3 GROUP BY R')

# naive Bayes classifier (multiple features - new evidence) example:
#c.execute('SELECT R,SUM(P1*P2*P3) FROM T1(W,R),T2(T,R),T3(R) WHERE W="Y",T="Y" \
#           AND R1=R2,R2=R3 GROUP BY R')

# Bayesian network example:
#c.execute('SELECT R,SUM(Pi*...) FROM Ti(*),... WHERE W="Y",Ri=Rj,Si=Sj GROUP BY R')

# "explaining away" example:
#c.execute('SELECT R,SUM(Pi*...) FROM Ti(*),... WHERE W="Y",S="y",Ri=Rj GROUP BY R')

# graph givens
summation = 'SUM(A.P * T.P * S.P * L.P * B.P * E.P * X.P * D.P)'
tables = 'A, T, S, L, B, E, X, D'
join = 'A.a=T.a AND T.t=E.t AND S.s=L.s AND S.s=B.s AND L.l=E.l AND B.b=D.b AND E.e=X.e AND E.e=D.e'

# question givens
disease = 'B.b'
evidence = 'X.x="Y" AND S.s="N" AND ' # add ' AND ' at end if any evidence
groupby = disease

command = 'SELECT %s,%s FROM %s WHERE %s%s GROUP BY %s' % \
           (disease, summation, tables, evidence, join, groupby)

# SQL query
c.execute(command)

result = c.fetchall()
print result
n = result[0][1]
y = result[1][1]
print y / (y + n)
print n / (y + n)