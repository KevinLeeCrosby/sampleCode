/******************************************************/
/*                                                    */
/*                   File PROCESS.C                   */
/*                                                    */
/*      THIS IS MY MAIN CALLING PROGRAM FOR NODE      */
/*                     PROCESSING                     */
/*                                                    */
/******************************************************/

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <string.h>
#include <time.h>
#include <iostream.h>
#include "matrix.h"
#include "gvar.h"
#include "gfunct.h"

void grgsub( int inprint, int outprint );

void main(int argc, char **argv) {

    /*    Calls grgsub(int inprint,int outprint) - subroutine interface. */
    /*    Calculates processor time for complete run.      */

  const char usage[80] = "Usage:  process [node]";

  /* parse the command line */
  switch(argc) {
  case 1:
    strcpy(node,"??");
    cout << "assuming no filename prefix" << endl;
    break;
  case 2:
    strcpy(node,argv[1]);
    cout << "node is " << node << endl;
    break;
  default:
    cerr << usage << endl;
    exit(1);
  }

  count_entities();

  /* format input and output filenames */
  char initial_file[20], final_file[20];
  char entities_file[20], visible_file[20];
  strcpy(initial_file, node);
  strcpy(final_file, node);
  strcpy(entities_file, node);
  strcpy(visible_file, node);
  catenate(initial_file, "initial.dat");
  catenate(final_file, "final.dat");
  catenate(entities_file, "entities.dat");
  catenate(visible_file, "visible.dat");
  
  char total_entities_file[]="entities.dat";
  char resolve_file[]="resolve.dat";
  char vertices_file[]="vertices.dat";
  char variances_file[]="variances.dat";
  char camera_parms_file[]="camera_parms.dat";
  char accuracy_file[]="accuracy.dat";

  /* read input data */
  matrix initial_point(initial_file); /* get initial point */
  vertices.read(vertices_file);       /* get vertices */
  vertices = vertices.T();
  resolve.read(resolve_file);         /* get l for resolution constraint */
  visible.read(visible_file);         /* get visibility constraint planes */
  C6.read(variances_file);            /* get variances for 6 dof */
  camera_parms.read(camera_parms_file); /* get rx, ry, f, respectively */
  accuracy.read(accuracy_file);         /* get accuracies requirements */


  FILE *total_entities=fopen(total_entities_file, "r");
  FILE *entities=fopen(entities_file, "r");
  char t_entity[10][15], entity[15];

  char t_entities_file[]="entities.dat";
  FILE *t_entities=fopen(t_entities_file, "r");
  int t_entity_count=-1;
  while(fscanf(t_entities, " %s ", t_entity[++t_entity_count])!=EOF);
  cout << "t_entity_count = " << t_entity_count << endl;
  fclose(t_entities);

  int i, j, k, match;

  /* determine resolve matrix and accuracy matrix for current entity set */
  for(i = 0, k = 0; i < t_entity_count; i++) {
    match = 0;
    for(j = 0; j < entity_count && !match; j++) {
      fscanf(entities, " %s ", entity);
      match = !strcmp(entity, t_entity[i]);
    }
    if(!match){ /* if no t_entity matches any entities remove column */
      resolve = resolve.cremove(i - k + 1);
      accuracy = accuracy.cremove(i - k + 1);
      vertices = vertices.cremove(2*(i - k) + 2);
      vertices = vertices.cremove(2*(i - k) + 1);
      k++;
    }
    rewind(entities);
  }
  fclose(entities);

  cout << "resolve matrix = " << endl;
  resolve.print();
  cout << "accuracy matrix = " << endl;
  accuracy.print();
  cout << "vertices matrix = " << endl;
  vertices.print();
  
  length = accuracy; /* just make these same size as accuracy */

  /* original code below */
  char    date [80];
  
  time_t  t, start, finish;
  
  time(&t);
  strftime(date, 80, "%A, %B %d, %Y, at %r", localtime(&t));
  printf("The current date is %s \n",date);
  ioout = stdout;
  
  
  /********************  MAKE CHANGES BELOW **************************/
  
  /*     nvars -- NUMBER OF VARIABLES                                */
  
  nvars = 6;
  
  /*     nrows -- NUMBER OF FUNCTIONS INCLUDING OBJECTIVE            */
  
  nrows = 1 + entity_count + 2 + 1 + visible.rows();
  
  /*     maxr  -- MAXIMUM ALLOWABLE SIZE OF APPROXIMATE              */
  /*              HESSIAN - USE {NVARS} IF YOU WANT A QUASI-NEWTON   */
  /*              METHOD TO BE USED AT EVERY ITERATION (FASTEST      */
  /*              METHOD IF NOT TOO MANY VARIABLES)                  */
  
  maxr = nvars;
  
  /*     maxb  -- UPPER LIMIT ON NUMBER OF BINDING CONSTRAINTS.      */
  /*              USE {NROWS} IF UNSURE OF A SMALLER LIMIT           */
  
  maxb = nrows;
  
  /*     nobj  -- INDEX OF COMPONENT OF VECTOR {G} IN  SUBROUTINE    */
  /*              GCOMP CORRESPONDING TO OBJECTIVE FUNCTION          */
  
  nobj = 1;
  
  /*     title CHARACTER STRING OF AT MOST 80 CHARACTERS USED TO      */
  /*           IDENTIFY THE PROBLEM IN ANY PRINTED REPORTS.           */
  
  strcpy ( title, "Mean Squared Error of Displacement and Quantization." );
  
  /*     xo  - REAL ARRAY WITH MAX SUBSCRIPT {nvars}.CONTAINS INITIAL */
  /*           VARIABLE VALUES. VALUES WHICH DO NOT SATISFY THE GIVEN */
  /*           VARIABLE BOUNDS WILL BE CHANGED TO THE BOUND NEAREST   */
  /*           THE VALUE.  */
  
  for(i=1; i<=nvars; i++)
    xo[i] = initial_point(i);
  
  /*     var - ARRAY WITH MAX SUBSCRIPT {nvars}.  CONTAINS CHARACTER  */
  /*           STRING NAMES FOR THE VARIABLES. UP TO 10 CHARACTERS.   */
  
  strcpy(var[1], " tx");
  strcpy(var[2], " ty");
  strcpy(var[3], " tz");
  strcpy(var[4], " phi");
  strcpy(var[5], " theta");
  strcpy(var[6], " psi");
  
  /*     con - ARRAY WITH MAX SUBSCRIPT {nrows}. CONTAINS CHARACTER   */
  /*           STRING NAMES FOR THE FUNCTIONS. UP TO 10 CHARACTERS.   */

  strcpy(con[1], "MSE");
  for(i=2; i<=entity_count+1; i++) 
    strcpy(con[i], "RESOLUTION");
  for(i=entity_count+2; i<=entity_count+3; i++)
    strcpy(con[i], "FOCUS");
  strcpy(con[entity_count+4], "FLD O VIEW");
  for(i=entity_count+5; i<=nrows; i++)
    strcpy(con[i], "VISIBILITY");
  
  /*     xlb - DOUBLE ARRAY CONTAINING LOWER BOUNDS FOR VARIABLES.  */
  /*           VARIABLE LOWER BOUNDS ARE IN POSITIONS FROM 1 TO {nvars}. */
  /*           IF VARIABLE i HAS NO LOWER BOUND, SET xlb[i] TO -1.0e30 */
  /*     xub - DOUBLE ARRAY CONTAINING UPPER BOUNDS FOR VARIABLES.  */
  /*           VARIABLE LOWER BOUNDS ARE IN POSITIONS FROM 1 TO {nvars}. */
  /*           IF NO UPPER BOUND, SET xub[i] TO 1.0e30   */
  
  for(i=1; i<=6; i++) {
    xlb[i] = -1.0e30;
    xub[i] = 1.0e30;
  };

//  for(i=4; i<=nvars; i++) {
//    xlb[i] = -2*acos(-1);/* -2 pi */
//    xub[i] = 2*acos(-1); /*  2 pi */
//  };

  
  /*     glb - DOUBLE ARRAY CONTAINING LOWER BOUNDS FOR FUNCTIONS.*/
  /*           FUNCTION LOWER BOUNDS ARE IN POSITIONS FROM 1 TO {nrows}.*/
  /*           IF A FUNCTION HAS NO LOWER BOUND, SET xlb[i] TO -1.0e30 */
  /*     gub - DOUBLE ARRAY CONTAINING UPPER BOUNDS FOR FUNCTIONS.  */
  /*           FUNCTION INDEXES ARE THE SAME AS ABOVE FOR glb.  */
  /*           IF NO UPPER BOUND, SET gub[i] TO 1.0e30   */
  /*     NOTE 1: IT DOES NOT MATTER WHAT YOU USE FOR THE BOUNDS OF     */
  /*             THE OBJECTIVE FUNCTION IN {glb} AND {gub}.  */
  /*     NOTE 2: IF YOU WISH TO FIX A VARIABLE AT A CERTAIN VALUE AND  */
  /*             HAVE GRGSUB LEAVE IT UNCHANGED, SET ITS ENTRIES IN alb*/
  /*             AND ub TO THAT VALUE                                  */
  /*     NOTE 3: IF g[i] IS AN EQUALITY CONSTRAINT, EQUAL TO, SAY, B,  */
  /*             SET alb[nvars + i] = ub[nvars + i] = B                */
  /*     NOTE 4: IF FUNCTION g[i] IS TO BE IGNORED IN THE CURRENT RUN  */
  /*             OF GRGSUB, SET alb[i] TO -1.0e30 AND ub[i] TO 1.0e30  */
  
  glb[1]=0.0;    /* lower bound on MSE (in theory) */
  gub[1]=1.0e30;
  
  for (i=1; i<=nrows; i++) {
    glb[i] = -1.0e30;
    gub[i] = 0.0;
  } ;
  
  /*    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   */
  /*    GRG PARAMETERS WITH DEFAULT VALUES                              */
  /*    You may change any of these (or none) before calling GRGSUB     */
  /*    +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++   */
  /*      VARIABLE     DEFAULT
	  /*       NAME         VALUE          DESCRIPTION
		   /*                                                                    */
  /*  EPSILONS */
  /*     1   epnewt---1.0E-06--- A CONSTRAINT IS ASSUMED TO BE          */
  /*                      BINDING IF IT IS WITHIN THIS EPSILON          */
  /*                      OF ONE OF ITS BOUNDS.                         */
  
  
  
  /*     2   epinit---1.0E-06--- IF IT IS DESIRED TO RUN THE            */
  /*                      PROBLEM WITH {epnewt} INITIALLY SET FAIRLY    */
  /*                      LARGE AND THEN TIGHTENED AT THE END OF THE    */
  /*                      OPTIMIZATION THEN THIS IS ACCOMPLISHED BY     */
  /*                      ASSIGNING {epinit} THE INITIAL TOLERANCE      */
  /*                      AND {epnewt} THE FINAL ONE.                   */
  
  
  
  /*     3   epstop---1.0E-04--- IF THE FRACTIONAL CHANGE IN THE        */
  /*                      OBJECTIVE IS LESS THAN {epstop} FOR {nstop}   */
  /*                      CONSECUTIVE ITERATIONS, THE PROGRAM WILL      */
  /*                      STOP. PROGRAM WILL ALSO STOP IF KUHN-TUCKER   */
  /*                      OPTIMALITY CONDITIONS ARE SATISFIED TO WITHIN */
  /*                      {epstop}.                                     */
  
  epstop = 1.0e-6;


  /*     4   epspiv---10.0E-3--- IF, IN CONSTRUCTING THE BASIS          */
  /*                      INVERSE, THE ABSOLUTE VALUE OF A PROSPECTIVE  */
  /*                      PIVOT ELEMENT IS LESS THAN {epspiv}, THE      */
  /*                      PIVOT WILL BE REJECTED AND ANOTHER PIVOT      */
  /*                      ELEMENT WILL BE SOUGHT.                       */
  
  
  
  /*     5   ph1eps--- 0.0   --- IF NONZERO, THE PHASE 1 OBJECTIVE      */
  /*                      IS AUGMENTED BY A MULTIPLE OF THE TRUE        */
  /*                      OBJECTIVE.  THE MULTIPLE IS SELECTED SO THAT, */
  /*                      AT THE INITIAL POINT, THE RATIO OF THE TRUE   */
  /*                      OBJECTIVE AND SUM OF THE INFEASIBILITIES IS   */
  /*                      {ph1eps}.                                     */
  
  
  
  /*     6   pstep --- 1.0E-4  --THIS IS THE STEP SIZE USED IN PARSH    */
  /*                             AND PARSHC FOR ESTIMATING PARTIAL      */
  /*                             PARTIAL DERIVATIVES OF THE FUNCTIONS   */
  /*                             WITH RESPECT TO THE VARIABLES.         */
  
  pstep = 1.0e-7;
  
  /* LIMITS */
  /*     1   nstop --- 3     --- IF THE FRACTIONAL CHANGE IN THE        */
  /*                      OBJECTIVE IS LESS THAN {epstop} FOR {nstop}   */
  /*                      CONSECUTIVE ITERATIONS, THE PROGRAM WILL      */
  /*                      STOP.                                         */
  
  nstop = 5;
  
  /*     2   itlim --- 10    --- IF SUBROUTINE NEWTON TAKES             */
  /*                      {itlim} ITERATIONS WITHOUT CONVERGING         */
  /*                      SATISFACTORILY, THE ITERATIONS ARE STOPPED    */
  /*                      AND CORRECTIVE ACTION IS TAKEN.               */
  
 
  
  /*     3   limser---1,000 --- IF THE NUMBER OF COMPLETED ONE          */
  /*                      DIMENSIONAL SEARCHES EQUALS {limser},         */
  /*                      OPTIMIZATION WILL TERMINATE.                  */
  
  
  
  /* PRINT CONTROL */
  /*     1   ipr   -- 0  - SUPPRESS ALL OUTPUT PRINTING EXCEPT          */
  /*                           INITIAL AND FINAL REPORTS.               */
  /*                     - 1 - PRINT ONE LINE OF OUTPUT FOR EACH ONE    */
  /*                           DIMENSIONAL SEARCH.                      */
  /*                     - 2 - PROVIDE MORE DETAILED INFORMATION ON     */
  /*                           THE PROGRESS OF EACH ONE DIMENSIONAL     */
  /*                           SEARCH.                                  */
  /*                     - 3 - EXPAND THE OUTPUT TO INCLUDE THE PROBLEM */
  /*                           FUNCTION VALUES AND VARIABLE VALUES AT   */
  /*                           EACH ITERATION AS WELL AS THE SEPARATION */
  /*                           OF CONSTRAINTS INTO NONBINDING AND       */
  /*                           BINDING AND VARIABLES INTO BASIC,        */
  /*                           SUPERBASIC AND NONBASIC.                 */
  /*                     - 4 - AT EACH ITERATION THE REDUCED GRADIENT,  */
  /*                           THE SEARCH DIRECTION AND THE TANGENT     */
  /*                           VECTOR ARE PRINTED.                      */
  /*                     - 5 - PROVIDES DETAILS OF THE BASIS INVERSION  */
  /*                           PROCESS INCLUDING THE INITIAL BASIS AND  */
  /*                           ITS INVERSE.  ALSO DISPLAYS THE VARIABLE */
  /*                           VALUES AND CONSTRAINT ERRORS FOR EACH    */
  /*                           NEWTON ITERATION.                        */
  /*                     - 6 - THIS IS THE MAXIMUM LEVEL OF PRINT       */
  /*                           AVAILABLE AND INCLUDES ALL OF THE ABOVE  */
  /*                           ALONG WITH DETAILED PROGRESS OF THE      */
  /*                           BASIS CONSTRUCTION PHASE, INCLUDING      */
  /*                           THE BASIS INVERSE AT EACH PIVOT.         */
  
  ipr = 2;
  
  /*     2   ipn4  -- 0      - IF  ipn# IS GREATER THAN ZERO THEN ipr   */
  /*         ipn5     0        WILL BE SET TO # AFTER  ipn# ITERATIONS  */
  /*         ipn6     0                                                 */
  
  
  
  /*     3   iper  -- 0      - IF iper IS GREATER THAN ZERO THEN        */
  /*                           FOR EVERY IPER-TH ITERATION, PRINT       */
  /*                                USING THE CURRENT VALUE OF {ipr}    */
  /*                                OTHERWISE USE ipr=1 .               */
  
  
  
  /* METHODS  */
  /*     1   iquad--- 0  - METHOD FOR INITIAL ESTIMATES OF BASIC        */
  /*                           VARIABLES FOR EACH ONE DIMENSIONAL       */
  /*                           SEARCH                                   */
  /*                     - 0 - TANGENT VECTOR AND LINEAR EXTRAPOLATION  */
  /*                           WILL BE USED.                            */
  /*                     - 1 - QUADRATIC EXTRAPOLATION WILL BE USED.    */
  
  
  
  
  /*     2   kderiv-- 0  - METHOD FOR OBTAINING PARTIAL DERIVATIVE      */
  /*                     - 0 - FORWARD DIFFERENCE APPROXIMATION         */
  /*                     - 1 - CENTRAL DIFFERENCE APPROXIMATION         */
  /*                     - 2 - USER SUPPLIED SUBROUTINE {parsh} IS USED */
  
  
  
  /*     3   modcg -- 0  - {modcg} AND {maxrm} (SEE BELOW) CONTROL      */
  /*                           USE OF A CONJUGATE GRADIENT ( CG )       */
  /*                           METHOD.  IF THE NUMBER OF SUPERBASIC     */
  /*                           VARIABLES EXCEEDS {maxrm}, THE CG        */
  /*                           METHOD INDICATED BY {modcg} IS USED.     */
  /*                           DEFAULT VALUE OF modcg=1 .  TO USE A     */
  /*                           CG METHOD AT EACH ITERATION, SET         */
  /*                           maxrm=0.                                 */
  /*                     - 1 - USES FLETCHER-REEVES FORMULA.            */
  /*                     - 2 - USES POLAK-RIBIERE FORMULA.              */
  /*                     - 3 - USES PERRY'S FORMULA.                    */
  /*                     - 4 - USES 1 STEP VERSION OF DFP.              */
  /*                     - 5 - USES 1 STEP VERSION OF BFS.              */
  
  
  
  /*     4   maxrm -- maxr - MAXIMUN NUMBER OF ROWS FOR HESSIAN APPROX  */
  /*                         FOR THE BFGS ALGORITHM. IF THE NUMBER OF   */
  /*                         SUPERBASICS EXCEEDS maxrm THEN A CONJUGATE */
  /*                         GRADIENT ALGORITHM IS USED.  TO FORCE A CG */
  /*                         METHOD TO BE ALWAYS USED SET maxrm = 0.    */
  
  maxim = 0;
  
  /*     5   maxim -- 0  - OBJECTIVE FUNCTION WILL BE MINIMIZED         */
  /*                     - 1 - OBJECTIVE WILL BE MAXIMIZED              */
  
  
  /*     6   doscale- 0  - PROBLEM WILL NOT BE SCALED BY GRGC           */
  /*                     - 1 - PROBLEM SCALED SO THAT MAXIMUM VALUE     */
  /*                           OF ANY ROW OR COLUMN OF INITIAL GRAD     */
  /*                           ARRAY LESS THAN OR EQUAL 1               */

  doscale = 0;

  /* ***************************************************************** */
  /*        +++++++++++++++++++++++++++++++++++                        */
  /*        + OUTPUT VARIABLES AND PARAMETERS +                        */
  /*        +++++++++++++++++++++++++++++++++++                        */
  /*     g      -- DOUBLE ARRAY WITH MAX SUBSCRIPT EQUAL TO {nrows}.   */
  /*               g[i] CONTAINS FINAL VALUE OF FUNCTIONS IN GCOMP.    */
  /*     xx     -- DOUBLE ARRAY WITH MAX SUBSCRIPT EQUAL TO {nvars}.   */
  /*               xx[i] CONTAINS FINAL VALUE OF VARIABLE i.           */
  /*     inbind -- INTEGER ARRAY WITH MAX SUBSCRIPT {nrows}. POSITIONS */
  /*               1 TO nbind OF inbind CONTAIN THE INDICES OF         */
  /*               THOSE FUNCTIONS (COMPONENTS OF THE g VECTOR) WHICH  */
  /*               ARE AT THEIR LOWER OR UPPER BOUNDS AT TERMINATION.  */
  /*     rmult --  DOUBLE ARRAY WITH MAX SUBSCRIPT {nrows}. POSITIONS  */
  /*               1 TO nbind OF rmult CONTAIN LAGRANGE MULTIPLIERS    */
  /*               OF THE BINDING CONSTRAINTS, CORRESPONDING TO THE    */
  /*               INDICES IN INBIND.  */
  /*     nonbas -- INTEGER ARRAY WITH MAX SUBSCRIPT {nvars}. POSITIONS */
  /*               1 TO {nnonb} CONTAIN THE INDICES OF THOSE           */
  /*               COMPONENTS OF xx WHICH ARE NOT BASIC (I.E. EITHER   */
  /*               SUPERBASIC OR NONBASIC) AT TERMINATION. THE         */
  /*               REMAINING POSITIONS CONTAIN NO USEFUL INFORMATION.  */
  /*     redgr  -- DOUBLE ARRAY OF SAME SIZE AS nonbas. POSITIONS FROM */
  /*               1 TO {nnonb} CONTAIN THE REDUCED GRADIENTS OF THE   */
  /*               VARIABLES WHOSE INDICES ARE IN CORRESPONDING        */
  /*               POSITIONS IN nonbas.                                */
  /*     nbind  -- INTEGER SCALAR. NUMBER OF BINDING CONSTRAINTS. SEE  */
  /*               DESCRIPTION OF inbind AND rmult ABOVE.              */
  /*     nnonb  -- INTEGER. SEE nonbas AND redgr EXPLNANATION ABOVE    */
  /*     ++++++++++++++++++++  */
  /*     TERMINATION CODES     */
  /*     ++++++++++++++++++++  */
  /*     info   - 0 - KUHN-TUCKER CONDITIONS SATISFIED                 */
  /*            - 1 - FRACTIONAL CHANGE IN OBJECTIVE LESS THAN         */
  /*                  {EPSTOP} FOR {NSTOP} CONSECUTIVE ITERATION       */
  /*            - 2 - ALL REMEDIES HAVE FAILED TO FIND A BETTER        */
  /*                  POINT                                            */
  /*            - 3 - NUMBER OF COMPLETED ONE DIMENSIONAL SEARCHES     */
  /*                  EQUAL TO {limser}                                */
  /*            - 4 - SOLUTION UNBOUNDED                               */
  /*            - 5 - FEASIBLE POINT NOT FOUND                         */
  /* ***************************************************************** */
  /* end original code */

  /* before optimization */

  time(&start);

  /* optimization */
  grgsub(1,1);
  
  /* after optimization */
  time(&finish);
  t = finish - start;
  char min_sec[25];
  strftime(min_sec, 25, "%M minutes, %S seconds", localtime(&t));
  printf("\nProgram completed in %s.\n",min_sec);

  matrix final_point(6,1);
  for(i=1; i<=nvars; i++)
    final_point(i) = xx[i];
  final_point.write(final_file);

  end_latex();

  write_Mathematica();
}

