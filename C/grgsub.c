/*******************************/
/*        File GRGSUB.C        */
/*        includes grgsub(),   */
/*******************************/

#include "gvar.h"

void    setup ( void );
void    tablin ( void );
void    report ( void );
void    initlz ( void );
void    grgitn ( void );
void    outres ( void );


void grgsub(int inprint, int outprint )
{
/*     -inprint  0:  DO NOT PRINT ANY ECHO BACK OF INPUT DATA     */
/*               1:  PRINT INPUT DATA                             */
/*     -outprint 1:  DO NOT PRINT ANY FINAL RESULTS               */
/*               0:  PRINT FINAL RESULTS                          */
/* ****************************************************************** */
/*         **************************************************         */
/*         ***               GRGC.0                       ***         */
/*         ***          COPYRIGHT   1989                  ***         */
/*         ***            LEON S. LASDON                  ***         */
/*         ***                 &                          ***         */
/*         ***            ALLAN D. WAREN                  ***         */
/*         **************************************************         */
/* ****************************************************************** */
/*    The following comments describe the global data which the user  */
/*    either must or may initialize.  The external declarations for   */
/*    these  variables are contained in the GVAR.H include file. Their*/
/*    actual declarations are in the file GVAR.C. */
/*    The information below is divided into three parts:      */
/*    the first part is for problem specific data which must be  */
/*    initialized by the user in the calling program which calls this */
/*    subroutine; */
/*    the second part is for GRG options and parameters, which have  */
/*    default values provided, but that can be set by the user;  */
/*    the third part is a description of return data from GRG. */
/* PROBLEM SPECIFIC DATA PROVIDING VARIABLE AND CONSTRAINT INFORMATION */
/*   These items MUST be specified for your problem                */
/*     nvars -- NUMBER OF VARIABLES                                */
/*     nrows -- NUMBER OF FUNCTIONS INCLUDING OBJECTIVE            */
/*     maxr  -- MAXIMUM ALLOWABLE SIZE OF APPROXIMATE              */
/*              HESSIAN - USE {NVARS} IF YOU WANT A QUASI-NEWTON   */
/*              METHOD TO BE USED AT EVERY ITERATION (FASTEST      */
/*              METHOD IF NOT TOO MANY VARIABLES)                  */
/*     maxb  -- UPPER LIMIT ON NUMBER OF BINDING CONSTRAINTS.      */
/*              USE {NROWS} IF UNSURE OF A SMALLER LIMIT           */
/*     nobj  -- INDEX OF COMPONENT OF VECTOR {G} IN  SUBROUTINE    */
/*              GCOMP CORRESPONDING TO OBJECTIVE FUNCTION          */
/*     title CHARACTER STRING OF LESS THAN 80 CHARACTERS USED TO    */
/*           IDENTIFY THE PROBLEM IN ANY PRINTED REPORTS.           */
/*     xo  - REAL ARRAY WITH MAX SUBSCRIPT {nvars}.CONTAINS INITIAL */
/*           VARIABLE VALUES. VALUES WHICH DO NOT SATISFY THE GIVEN */
/*           VARIABLE BOUNDS WILL BE CHANGED TO THE BOUND NEAREST   */
/*           THE VALUE.  */
/*     var - ARRAY WITH MAX SUBSCRIPT {nvars}.  CONTAINS CHARACTER  */
/*           POINTERS TO NAMES FOR THE VARIABLES. */
/*     con - ARRAY WITH MAX SUBSCRIPT {nrows}. CONTAINS CHARACTER   */
/*           POINTERS TO NAMES FOR THE FUNCTIONS. */
/*     xlb - DOUBLE ARRAY CONTAINING LOWER BOUNDS FOR VARIABLES.  */
/*           VARIABLE LOWER BOUNDS ARE IN POSITIONS FROM 1 TO {nvars}. */
/*           IF VARIABLE i HAS NO LOWER BOUND, SET xlb[i] TO -1.0e30 */
/*     xub - DOUBLE ARRAY CONTAINING UPPER BOUNDS FOR VARIABLES.  */
/*           VARIABLE LOWER BOUNDS ARE IN POSITIONS FROM 1 TO {nvars}. */
/*           IF NO UPPER BOUND, SET xub[i] TO 1.0e30   */
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
/*                                                                    */
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
/*     4   epspiv---10.0E-4 -- IF, IN CONSTRUCTING THE BASIS          */
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
/*     6   pstep --- 1.0E-8  --THIS IS THE STEP SIZE USED IN PARSH    */
/*                             AND PARSHC FOR ESTIMATING PARTIAL      */
/*                             PARTIAL DERIVATIVES OF THE FUNCTIONS   */
/*                             WITH RESPECT TO THE VARIABLES.         */
/* LIMITS */
/*     1   nstop --- 3     --- IF THE FRACTIONAL CHANGE IN THE        */
/*                      OBJECTIVE IS LESS THAN {epstop} FOR {nstop}   */
/*                      CONSECUTIVE ITERATIONS, THE PROGRAM WILL      */
/*                      STOP.                                         */
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
/*     5   maxim -- 0  - OBJECTIVE FUNCTION WILL BE MINIMIZED         */
/*                     - 1 - OBJECTIVE WILL BE MAXIMIZED              */
/*     6   doscale- 0  - PROBLEM WILL NOT BE SCALED BY GRGC           */
/*                     - 1 - PROBLEM SCALED SO THAT MAXIMUM VALUE     */
/*                           OF ANY ROW OR COLUMN OF INITIAL GRAD     */
/*                           ARRAY LESS THAN OR EQUAL 1               */
/* *****************************************************************  */
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
/*            - 10,11,12,OR 13                                       */
/*                  FEASIBLE POINT NOT FOUND. GRG2 HAS TERMINATED    */
/*                  IN PHASE 1 (TRYING TO FIND A FEASIBLE POINT WHEN */
/*                  THE INITIAL POINT IS NOT FEASIBLE) WITHOUT FINDING  */
/*                  A FEASIBLE POINT. THE FINAL SOLUTION IS AS CLOSE TO */
/*                  BEING FEASIBLE AS GRG2 COULD COME.               */
/*                  SUBTRACTING 10 FROM INFO YIELDS A VALUE OF 0     */
/*                  THRU 3 WHICH GIVES THE REASON THAT PHASE 1       */
/*                  TERMINATED, AS DESCRIBED ABOVE.                  */
/* ***************************************************************** */
/*  LOCAL  DECLARATIONS  */

    int i, j, ipr3temp, nindex;

    initlz();

    /*    VALIDITY CHECK FOR VARIABLES    */

    if (nvars >= 1 )   goto w20;
    fprintf ( ioout, "FATAL ERROR - nvars LT 1  ( %d )\n", nvars );
    goto w670;
w20 :
    if ( nrows >= 1 )  goto w40;
    fprintf ( ioout, "FATAL ERROR - nrows LT 1 ( %d )\n", nrows );
    goto w670;
w40 :
    if ( maxb == 0 )  maxb = nrows;
    if ( maxb >= 1 )  goto w60;
    fprintf ( ioout, "FATAL ERROR - maxb LT 1 ( %d )\n", maxb );
    goto w670;
w60 :
    if ( maxr == 0 ) maxr = nvars;
    if ( maxr > 0 )  goto w80;
    fprintf ( ioout, "FATAL ERROR - maxr LT 0 ( %d )\n", maxr );
    goto w670;
w80 :
    if ( nobj >= 1 && nobj <= nrows )   goto w100;
    fprintf ( ioout, "FATAL ERROR - nobj LT 1 OR GT nrows ( %d )\n", nobj );
    goto w670;
w100 :
    for ( i=1; i<=nvars; i++ )  {
           if ( xub[i] >= xlb[i] )  goto w120;
           fprintf (ioout,
           "FATAL ERROR IN VARIABLE BOUNDS: ub[%d] = %g < alb[%d] = %g.\n",
                                 i, xub[i], i, xlb[i] );
           goto w670;
w120 :  ;
    }
    for ( i=1; i<=nrows; i++ )   {
           if ( gub[i] >= glb[i] || i== nobj )   goto w140;
                 fprintf( ioout,
                 "FATAL ERROR IN FUNCTION BOUNDS: gub[%d] = %g < glb[%d] = %g.\n",
                                    i, gub[i], i, glb[i] );
           goto w670;
w140 :  ;
    }
    if ( epnewt > 0.0 && epnewt < 1.0 )   goto w160;
           fprintf ( ioout,
           "FATAL ERROR IN EPNEWT = %g. Either <= 0 or >= 1.\n", epnewt );
    goto w670;
w160 :
    if ( epinit > 0.0 && epinit < 1.0 )   goto w180;
           fprintf ( ioout,
           "FATAL ERROR IN EPINIT = %g. Either <= 0 or >= 1. \n", epinit );
    goto w670;
w180 :
    if ( epstop > 0.0 && epstop < 1.0 )   goto w200;
           fprintf ( ioout,
           "FATAL ERROR IN EPSTOP = %g. Either <= 0 or >= 1.\n" , epstop );
    goto w670;
w200 :
    if ( epspiv > 0.0 && epspiv < 1.0 )   goto w220;
           fprintf ( ioout,
           "FATAL ERROR IN EPSPIV = %g. Either <= 0 or >= 1.\n", epspiv );
    goto w670;
w220 :
    if ( ph1eps >= 0.0 && ph1eps < 1.0 )  goto w240;
           fprintf ( ioout,
           "FATAL ERROR IN PH1EPS = %g. Either < 0 or >= 1.\n", ph1eps );
    goto w670;
w240 :
    if ( nstop >= 1 )   goto w260;
           fprintf ( ioout,
           "FATAL ERROR: nstop = %d < 1. \n", nstop );
    goto w670;
w260 :
    if ( itlim >= 1 )   goto w280;
           fprintf ( ioout,
           "FATAL ERROR - itlim = %d < 1.\n", itlim );
    goto w670;
w280 :
    if ( limser >= 1 )   goto w300;
           fprintf ( ioout,
           "FATAL ERROR - limser = %d < 1.\n", limser );
    goto w670;
w300 :
    if ( ipr >= 0 && ipr <= 6 )    goto w310;
           fprintf ( ioout,
           "FATAL ERROR - ipr = %d  Less Than 0 OR Greater Than 6.\n", ipr );
    goto w670;
w310 :
    if ( ipn4 >= 0 )   goto w320;
    fprintf ( ioout, "FATAL ERROR - ipn4 = %d < 0.\n", ipn4 );
    goto w670;
w320 :
    if ( ipn5 >= 0 )   goto w360;
    fprintf ( ioout, "FATAL ERROR - ipn5 = %d < 0.\n", ipn5 );
    goto w670;
w360 :
    if ( ipn6 >= 0 )    goto w380;
    fprintf ( ioout, "FATAL ERROR - ipn6 = %d < 0.\n", ipn6 );
    goto w670;
w380 :
    if ( iper >= 0 )     goto w400;
    fprintf ( ioout, "FATAL ERROR - iper = %d < 0.\n", iper );
    goto w670;
w400 :
    if ( pstep >= 0.0 )    goto w420;
    fprintf ( ioout, "FATAL ERROR: pstep = %g < 0.0.\n", pstep );
    goto w670;
w420 :
    if ( iquad == 0 || iquad == 1 )    goto w440;
    fprintf ( ioout,
    "FATAL ERROR - iquad = %g  MUST BE 0 OR 1.\n", iquad );
    goto w670;
w440 :
    if ( kderiv == 0 || kderiv == 1 || kderiv == 2 )    goto w460;
    fprintf ( ioout,
    "FATAL ERROR - kderiv = %d MUST BE 0, 1 OR 2.\n", kderiv );
    goto w670;
w460 :
    if ( modcg >= 1 && modcg <= 5 )    goto w480;
    fprintf ( ioout,
    "FATAL ERROR - modcg = %d  > 5 OR < 1.\n", modcg );
    goto w670;
w480 :
    if ( inprint == 0 )   goto w510;
    fprintf ( ioout, "%s\n\n", title );
    fprintf ( ioout, "NUMBER OF VARIABLES IS : %d\n", nvars );
    fprintf ( ioout, "NUMBER OF FUNCTIONS IS : %d\n", nrows );
    fprintf ( ioout, "SPACE RESERVED FOR HESSIAN HAS DIMENSION %d\n", maxr);
    fprintf ( ioout, "LIMIT ON BINDING CONSTRAINTS IS : %d\n", maxb );
w510 :
    setup ( );
    eplast = epnewt;
    ipr3 = ipr - 1;
    if ( maxim != 1 )  maxim = 0;

/*   IF MAXRM HAS NOT BEEN CHANGED THEN SET IT TO ITS DEFAULT VALUE  */

    if ( maxrm == -1 ) maxrm = maxr;

/*    ASSIGN BOUNDS FOR VARIABLES    */

    for ( i=1; i<=n; i++ )  {
           alb[i] = xlb[i];
           ub[i] =  xub[i];
           ifix[i] = 0;
           if ( alb[i] == ub[i] ) ifix[i] = 1;
    }

    /*    ASSIGN BOUNDS FOR CONSTRAINTS    */

    for ( i=1; i<=mp1; i++ )  {
           if ( i == nobj )    goto w520;
           alb[n+i] = glb[i];
           ub[n+i] =  gub[i];
           istat[i] = 2;
           if ( alb[n+i] == -plinfy && ub[n+i] == plinfy ) istat[i] = 0;
           if ( alb[n+i] == ub[n+i] )  istat[i] = 1;
w520 :     ;
    }

    /*    ASSIGN INITIAL VARIABLE VALUES    */

    for ( i=1; i<=n; i++ )    x[i] = xo[i];
    if ( inprint == 1 )
           for ( i=1; i<=n; i++ ) {
                  fprintf (ioout,"x[%3d]=%12.6g ", i, x[i] );
                  if ( i%4 == 0 ) fprintf (ioout, "\n");
           }

    /*    CHECK TO SEE THAT VARIABLES ARE WITHIN BOUNDS    */

    for ( i=1; i<=n; i++ )  {
           if ( x[i] >= alb[i] && x[i] <= ub[i] )   goto w560;
           if ( x[i] > ub[i] )    goto w540;
           if ( ipr < 0 )    goto w530;
           fprintf ( ioout,
           "  FOR VARIABLE %d, INITIAL VALUE = %g\n",i, x[i] );
           fprintf ( ioout,
           "      WAS CHANGED TO LOWER BOUND = %g.\n", alb[i] );
w530 :
/*08/1991 thru 11/1991*/
           xo[i] = alb[i];
/*08/1991 thru 11/1991*/
           x[i] = alb[i];
           goto w560;
w540 :
           if ( ipr < 0 )    goto w550;
           fprintf ( ioout,
           "  FOR VARIABLE %d, INITIAL VALUE = %g\n", i, x[i] );
           fprintf ( ioout,
           "      WAS CHANGED TO UPPER BOUND = %g.\n", ub[i] );
w550 :
/*08/1991 thru 11/1991*/
           xo[i] = ub[i];
/*08/1991 thru 11/1991*/
           x[i] = ub[i];
w560  : ;
    }
    istat[nobj] = 0;
    alb[n+nobj] = -plinfy;
    ub[n+nobj]  =  plinfy;
    if ( inprint == 0 )   goto w570;
    fprintf ( ioout, "\nEPNEWT = %g.  EPINIT = %g.  EPSTOP = %g.\n",
                    epnewt, epinit, epstop );
    fprintf ( ioout,   "EPSPIV = %g.  PH1EPS = %g.\n", epspiv, ph1eps );
    fprintf ( ioout,   "NSTOP  = %2d.   ITLIM = %2d.  LIMSER = %4d.\n",
    nstop, itlim, limser );
    fprintf ( ioout,
    "IPR = %1d.  IPN4 = %1d.  IPN5 = %1d.  ", ipr, ipn4, ipn5 );
    fprintf ( ioout, "IPN6 = %1d.  IPER = %1d.\n", ipn6, iper );
    if ( iquad == 1 ) fprintf ( ioout,
           "QUADRATIC EXTRAPOLATION USED FOR INITIAL ESTIMATES OF BASICS.\n" );
    if ( iquad == 0 ) fprintf ( ioout,
           "TANGENT VECTORS WILL BE USED FOR INITIAL ESTIMATES OF BASICS.\n" );
    if ( kderiv == 0 )
           fprintf ( ioout,
           "FORWARD DIFFERENCES WITH STEP SIZE = %g WILL BE USED.\n", pstep );
    if ( kderiv == 1 )
           fprintf ( ioout,
           "CENTRAL DIFFERENCES WITH STEP SIZE = %g WILL BE USED.\n", pstep );
    if ( kderiv == 2)
           fprintf ( ioout, "THE USER'S OWN PARSH SUBROUTINE WILL BE USED.\n");
    if ( maxim == 1 )
           fprintf ( ioout, "OBJECTIVE FUNCTION WILL BE MAXIMIZED\n" );
    if ( maxim == 0 )
           fprintf ( ioout, "OBJECTIVE FUNCTION WILL BE MINIMIZED\n" );
    fprintf ( ioout, "LIMIT ON HESSIAN IS %d\n", maxrm );
w570 : ;
    init = 1;
    if ( inprint == 1 )  goto w600;
    ipr3temp = ipr3;
    ipr3 = -2;
w600 :
    tablin ();
    if ( inprint == 0 )   ipr3 = ipr3temp;
    report();
    init = 0;
    grgitn ( );
    if ( outprint == 0 )   goto w610;
    outres();
    report();
w610 :

     /*    SET OUTPUT ARGUMENTS TO FINAL VALUES FROM Z ARRAY    */

    for ( i=1; i<=nvars; i++ )   xx[i] = x[i];

    for ( i=1; i<=nb; i++ )   {
           rmult[i] = u[i];
           if ( maxim == 1 ) rmult[i] = - rmult[i];
           inbind[i] = ibc[i];
    }
    for ( i=1; i<=n; i++ )  {
        nonbas[i] = 0;
        redgr[i] = 0.0;
    }
    j = 0;
    for ( i=1; i<=n; i++ )  {
        nindex = inbv[i];
           if ( nindex > nvars )  goto w660;
        j++;
        nonbas[j] = nindex;
        redgr[j] = gradf[i];
        if ( maxim == 1 ) redgr[j] = - redgr[j];
w660 :    ;
    }
    nnonb = j;
    nbind = nb;
    return;
w670 :
    exit(5);

}







