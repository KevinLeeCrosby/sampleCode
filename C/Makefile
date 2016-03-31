# Makefile
#
#  Used for GRG2 as applied to Kevin Crosby's thesis
#
#  created in entirety by Kevin Crosby


CC=g++
GCC=gcc
FLAGS=-g
# -Wall
# -fno-builtin -I/usr/local/ua/lib/g++-include

REQUIRED = initlz.o conbsetc.o grgitn.o gvar.o phetc.o outretc.o diretc.o

GRGMAIN = grg.o datain.o $(REQUIRED)
 
SUBMAIN = grgsub.o $(REQUIRED) gcompfyl.o

FWC_SUBMAIN = grgsub.o $(REQUIRED) fwc.globals.o fwc.gcompfyl.o

OBJECTIVE = displacement.o quantization.o

CONSTRAINTS = resolution.o focus.o field-of-view.o visibility.o

TARABANIS = gfunct.o $(CONSTRAINTS) constraints.o

MSE = gfunct.o $(OBJECTIVE) objective.o $(CONSTRAINTS) constraints.o

SPLIT = gvar.o gfunct.o machine_precision.o matrix.o $(OBJECTIVE) objective.o

MERGE = gvar.o gfunct.o machine_precision.o matrix.o $(OBJECTIVE) objective.o

CENTER = grgsub.o $(REQUIRED) machine_precision.o matrix.o $(TARABANIS) Tarabanis.o

PROCESS = grgsub.o $(REQUIRED) machine_precision.o matrix.o $(MSE) mse.o

help:
	@echo '	make matrix	make the matrix library'
	@echo ' make grgmain    make grgmain'
	@echo ' make submain    make submain'
	@echo ' make process    make process'
	@echo ' make center	make center (for Tarabanis' objective)'
	@echo ' make all	make matrix, and everything else'
	@echo '	make clean	remove the object files'
	@echo '	make help	this message'

Tarabanis.o: Tarabanis.c $(TARABANIS)
	$(CC) $(FLAGS) -c -o Tarabanis.o Tarabanis.c

mse.o: mse.c $(MSE)
	$(CC) $(FLAGS) -c -o mse.o mse.c

gcompfyl.o: gcompfyl.c
	$(CC) $(FLAGS) -c -o gcompfyl.o gcompfyl.c

submain: submain.c $(SUBMAIN)
	$(CC) $(FLAGS) -o submain submain.c $(SUBMAIN) -lm

grgmain: grgmain.c $(GRGMAIN)
	$(CC) $(FLAGS) -o grgmain grgmain.c $(GRGMAIN) -lm

center: center.c $(CENTER)
	$(CC) $(FLAGS) -o center center.c $(CENTER) -lm

process: process.c $(PROCESS)
	$(CC) $(FLAGS) -o process process.c $(PROCESS) -lm

split: split.c $(SPLIT)
	$(CC) $(FLAGS) -o split split.c $(SPLIT) -lm

merge: merge.c $(MERGE)
	$(CC) $(FLAGS) -o merge merge.c $(MERGE) -lm

datain.o: datain.c initlz.o grgitn.o
	$(CC) $(FLAGS) -c -o datain.o datain.c

grgsub.o: grgsub.c
	$(CC) $(FLAGS) -c -o grgsub.o grgsub.c

grgmain.o: grgmain.c
	$(CC) $(FLAGS) -c -o grgmain.o grgmain.c

grg.o: grg.c grgitn.o
	$(CC) $(FLAGS) -c -o grg.o grg.c

initlz.o: initlz.c
	$(CC) $(FLAGS) -c -o initlz.o initlz.c

conbsetc.o: conbsetc.c
	$(CC) $(FLAGS) -c -o conbsetc.o conbsetc.c

grgitn.o: grgitn.c grgsub.o
	$(CC) $(FLAGS) -c -o grgitn.o grgitn.c

gvar.o: gvar.h gvar.c
	$(CC) $(FLAGS) -c -o gvar.o gvar.c

gfunct.o: gfunct.h gfunct.c
	$(CC) $(FLAGS) -c -o gfunct.o gfunct.c

phetc.o: phetc.c
	$(CC) $(FLAGS) -c -o phetc.o phetc.c

outretc.o: outretc.c
	$(CC) $(FLAGS) -c -o outretc.o outretc.c

diretc.o: diretc.c
	$(CC) $(FLAGS) -c -o diretc.o diretc.c

matrix.o: matrix.h matrix.c machine_precision.o 
	$(CC) $(FLAGS) -c -o matrix.o matrix.c

machine_precision.o: machine_precision.h machine_precision.c
	$(CC) $(FLAGS) -c -o machine_precision.o machine_precision.c

objective.o: objective.h objective.c $(OBJECTIVE)
	$(CC) $(FLAGS) -c -o objective.o objective.c

quantization.o: quantization.h quantization.c
	$(CC) $(FLAGS) -c -o quantization.o quantization.c

displacement.o: displacement.h displacement.c
	$(CC) $(FLAGS) -c -o displacement.o displacement.c

constraints.o: constraints.h constraints.c $(CONSTRAINTS)
	$(CC) $(FLAGS) -c -o constraints.o constraints.c

resolution.o: resolution.h resolution.c
	$(CC) $(FLAGS) -c -o resolution.o resolution.c

focus.o: focus.h focus.c
	$(CC) $(FLAGS) -c -o focus.o focus.c

field-of-view.o: field-of-view.h field-of-view.c
	$(CC) $(FLAGS) -c -o field-of-view.o field-of-view.c

visibility.o: visibility.h visibility.c
	$(CC) $(FLAGS) -c -o visibility.o visibility.c

all:
	make clean
	make split
	make merge
	make process

clean:
	rm -f *.o split merge process center
