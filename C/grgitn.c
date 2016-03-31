/********************************/
/*        File GRGITN.C         */
/*    includes headerline(),    */
/*             printdataline(), */
/*             grgitn().        */
/********************************/

#include "gvar.h"
void sclgcomp (double g[zmp1], double x[znpmp1]);
void gcomp (double g[zmp1], double x[znpmp1]);
void consbs ( void );
void ph1obj ( void );
void redgra (double *redgr);
void direc ( void );
void tang ( void );
void chuzr ( void );
void chuzq ( void );
void search ( void );
void delcol( int *iparm );

void headerline( void )
{
	fprintf ( ioout,
"ITN    OBJECTIVE  BINDING  SUPER   INFEAS  NORM OF   HESSIAN     STEP   DEGEN\n"
"NO.    FUNCTION   CONSTRS  BASICS  CONSTR  RED.GRAD  COND.NO.    SIZE   STEP\n"
"___    _________  _______  ______  ______  ________  ________   ______  _____\n");
}

int    iprhld, iprhd3, degen;
double grnorm;

void printdataline( void )
{
    int i, k;
    static int linect = 50;

    if ( iper != 0 )   goto w330;
    if ( ipr < 1 )   goto w380;
    linect++;
    if ( linect < 48 && ipr3 == 0 )   goto w340;
    if ( ipr3 == 0 && nsear > 1 )   fprintf (ioout,"\f" );
    headerline ( );
    linect = 0;
    goto w340;
w330 :
    k = (nsear / iper) * iper;
    if ( k != nsear && k != (nsear-1) )  goto w340;
    if ( nsear == 0 ) headerline ( );
    if ( nsear < 2 )  goto w340;
    if ( k == (nsear-1) ) headerline ( );
    ipr = iprhld;
    ipr3 = iprhd3;
w340 :
    grnorm = 0.0;
    if ( nsuper == 0 )   goto w360;
    for ( i=1; i<=nsuper; i++ )
	if ( fabs(gradf[i]) > grnorm )   grnorm = fabs(gradf[i]);
w360 :
    if ( nsuper > maxrm )  cond = 0.0;
    if ( degen == 1 )    step = 0.0;
    if ( maxim == 1 && ninf == 0 )   g[nobj] = -g[nobj];
    if ( degen == 1 )
	fprintf (ioout,
	"%3d %12.6g    %3d     %3d     %3d  %10.4g  %8.3g %8.3g     T \n",
	nsear, g[nobj], nb, nsuper, ninf, grnorm, cond, step );
    else
	fprintf (ioout,
	"%3d %12.6g    %3d     %3d     %3d  %10.4g  %8.3g %8.3g\n",
	nsear, g[nobj], nb, nsuper, ninf, grnorm, cond, step );
    if ( ipr < 3 )   goto w370;
    for ( i=1; i<=mp1; i++ )
		{
		fprintf (ioout,"G[%3d] = %-14.7g ", i, g[i] );
		if (i % 3 == 0) fprintf (ioout,"\n");
		}
    fprintf ( ioout, "\n");
    for ( i=1; i<=n; i++ )
		{
		fprintf (ioout,"X[%3d] = %-14.7g ", i, x[i] );
		if (i % 3 == 0) fprintf (ioout,"\n");
		}
    fprintf ( ioout, "\n");
w370 :
    if ( maxim == 1 && ninf == 0 )   g[nobj] = -g[nobj];
    if ( iper == 0 )   goto w380;
    if ( k != (nsear-1 ) )  goto w380;
    if ( nsear != 1 ) headerline ( );
    ipr = 1;
    ipr3 = 0;
w380 :
    return ;
}

void grgitn ( )
{

    /*	  CONTROLS MAIN ITERATIVE LOOP;  CALLS consbs TO COMPUTE    */
    /*	  INITIAL BASIS INVERSE ;  CALLS direc TO COMPUTE SEARCH    */
    /*	  DIRECTION;  CALLS ONE DIMENTIONAL SEARCH SUBROUTINE	    */
    /*	  search;  TEST FOR OPTIMALITY				    */

    /*	  Local Declarations	*/

    double  ts, tst, cons2, phhold, objtst, trubst;
    int   i, j, k, ii, jr, kk, iii, istop, msgcg, nfail, idegct;
    int   linect, iparm;

    /*	  INITIALIZE PERFORMANCE COUNTERS    */

    ncalls = 0;  /*  ncalls = NUMBER OF NEWTON CALLS  */
    nit = 0;     /*  nit    = CUMULATIVE NO. OF NEWTON ITERATIONS    */
    nftn = 1;    /*  nftn   = TOTAL NO. OF gcomp CALLS  */
    ngrad = 0;   /*  ngrad  = NO. OF GRADIENT CALLS  */
    nsear = 0;   /*  nsear  = NO. OF ONE DIMENTIONAL SEARCHES  */
    nsear0 = 0;  /*  nsear0 = VALUE OF NSEAR AT START FOR THIS NEWTON VALUE*/
    istop = 0;   /*  istop  = NO. OF CONSECUTIVE TIMES RELATIVE CHANGE  */
			  /*          IN FUNCTION IS LESS THAN epstop  */
    nbs = 0;     /*  nbs    = NO. OF TIMES BASIC VARIABLE VIOLATES BOUND  */
    nnfail = 0;  /*  nnfail = NO. TIMES NEWTON FAILD TO CONVERGE  */
    nstepc = 0;  /*  nstepc = NO. TIMES STEP SIZE CUT BACK WHEN NEWTON FAILS  */
/*08/1991 thru 11/1991*/
    scaled = 0;
    havescale = 0;
/*08/1991 thru 11/1991*/

    /*	  ADJUSTMENTS FOR USING TWO CONSTRAINT TOLERANCES    */

    epnewt = epinit;
    if ( eplast < epinit )  epstop = 10.0e0 * epstop;
    phhold = ph1eps;
    ipr = ipr3 + 1;
    linect = 60;
    iprhld = ipr;
    iprhd3 = ipr3;

    /*	  THIS IS RETURN POINT FOR epnewt LOOP	  */

w10 :
    drop = 0;		   /* COMMON LOGBLK, SRCHLG, SUPBLK */
    move = 1;
    restrt = 0;
    unbd = 0;
    jstfes = 0;
    degen = 0;
    uncon = 0;
    chngsb = 1;
    sbchng = 0;

    idegct = 0;
    nsuper = 0; 	   /* COMMOM NINTBK */
    trubst = 0.0e0;
    nsupp = 0;		   /* COMMON DIRGRG */
    ierr = 0;
    nfail = 0;
    msgcg = 1;
    stpbst = 1.0e0;
    lv = 0;
    istop = 0;
    objtst = plinfy;
    step = 0.0e0;
    cond = 1.0e0;
    ninf= 0;
    nb = 0;
    if ( iper != 0 )  {  ipr = 1;  ipr3 = 0; }
    for ( i = 1; i <= mp1; i++ )    x[n+i] = g[i];
    for ( i=1; i<=nbmax; i++ )
		for ( j=1; j<=nnbmax; j++ )  binv[i][j] = 0.0e0;

    /*	  THIS IS RETURN POINT FOR MAIN LOOP	*/

w40 : ;

    /*	  COMPUTE BASIS INVERSE, EXCEPT WHEN DEGENERATE    */

    consbs ( );

    if ( ninf == 0 || ph1eps == 0.0e0 )  goto w50;
    initph = 1;
    ph1obj();
    initph = 0;
w50 :
    if ( nsear != nsear0 )  goto w100;

    /*	INITIALIZATIONS THAT MUST BE DONE AFTER 1ST consbs CALLS  */
    /*	FOR EACH VALUE OF epnewt  */

    initph = 2;
    ph1obj();
    initph = 0;
    if ( nb == 0 )  goto w70;
    for ( i=1; i<=nb; i++ )  {
	k = ibv[i];
	xbest[i] = x[k];
    }
w70 :
    if ( nnbc == 0 )  goto w100;
    for ( i=1; i<=nnbc; i++ ) {
	k = inbc[i];
	xbest[nb+i] = g[k];
    }
    for ( i=1; i<=mp1; i++ )   gbest[i] = g[i];
w100 :
    /*	COMPUTE REDUCED GRADIENT  */

    redgra(gradf);

    if ( ipr < 4 ) goto w140;
    for ( i=1; i<=n; i++ )   xstat[i] = gradf[i];
    if ( maxim == 0 || ninf!= 0 )  goto w130;
    for ( i=1; i<=n; i++ )  xstat[i] = -xstat[i];
w130 :
    if ( ipr < 0 )  goto w140;
    fprintf ( ioout, "REDUCED GRADIENT IS\n");
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "   %e\n", xstat[i] );
w140 :
    /*	===CHECK IF ANY OF THE STOP CRITERIA ARE SATISFIED===  */

    /*	UNCONDITIONAL STOP IF NUMBER OF LINEAR SEARCH > LIMSER	*/

    if ( nsear < limser )  goto w155;
    /*	DID REACH LIMIT SO QUIT  */

    if ( ipr < 0 )  goto w151;
    fprintf ( ioout, "NUMBER OF COMPLETED ONE-DIMENSIONAL SEARCHES = LIMSER");
    fprintf ( ioout, " =  %d.\nOPTIMIZATION TERMINATED.\n", nsear);
    linect++;
w151 :
    info = 3;
    ierr = 11;
    goto w520;

    /*	TEST IF KUHN-TUCKER CONDITIONS SATISFIED  */

w155 :
    for ( i=1; i<=n; i++ )  {
	ii = inbv[i];
	tst = gradf[i];
	if ( ii <= n )	goto w160;
	if ( istat[ii-n] == 1 )  goto w190;
w160 :
	if ( iub[i] == 0 )  goto w180;
	if ( iub[i] == 1 )  goto w170;
	if ( tst < -epstop )  goto w200;
	goto w190;
w170 :
	if ( tst > epstop ) goto w200;
	goto w190;
w180 :
	if ( fabs(tst) > epstop )  goto w200;
w190 :	;
    }

    /*	K-T CONDITIONS ARE SATISFIED.  GO CHECK IF epnewt AT FINAL VALUE  */

    if ( ipr < 0 )  goto w191;
    fprintf ( ioout, "TERMINATION CRITERION MET.  KUHN-TUCKER CONDITIONS");
    fprintf ( ioout, " SATISFIED TO\nWITHIN %e AT CURRENT POINT\n", epstop );
    linect++;
w191 :
    info = 0;
    goto w480;

    /*	CHECK IF RELATIVE CHANGE IN OBJECTIVE IS LESS THAN epstop  */
    /*	FOR nstop CONSECUTIVE ITERATIONS.    */

w200 :
    if ( degen == 1 )  goto w250;
    if ( fabs(g[nobj] - objtst) > fabs(objtst*epstop) )  goto w230;

    /*	FRACTIONAL CHANGE TOO SMALL.  COUNT HOW OFTEN CONSECUTIVELY.  */

    istop++;
    if ( istop < nstop )  goto w250;

    /*    FRACTIONAL CHANGE TOO SMALL nstop OR MORE TIMES.    */
    /*    SO GO CHECK IF epnewt AT FINAL VALUE  */

    if ( ipr < 0 )  goto w201;
    fprintf ( ioout, "TOTAL FRACTIONAL CHANGE IN OBJECTIVE LESS THAN %e\n", epstop);
    fprintf ( ioout, "  FOR %d CONSECUTIVE ITERATIONS\n", istop );
    linect = linect + 2;
w201 :
    ierr = 1;
    info = 1;
    goto w480;
w230 :
    istop = 0;
    chngsb = 0;
    objtst = g[nobj];

    /*	COMPUTE SEARCH DIRECTION FOR SUPERBASICS  */

w250 :
    direc();

    if ( dfail == 1 )  goto  w520;
    if ( ipr >= 4 )    {
	fprintf ( ioout, "DIRECTION VECTOR :\n" );
	for ( i=1; i<=nsuper; i++ )
	    fprintf ( ioout, "  D[%d] = %e\n", i, d[i] );
    }
    if ( nb == 0 )  goto w300;

    /*	COMPUTE TANGENT VECTOR V  */

    tang();

    if ( ipr >= 4 )  {
	fprintf ( ioout, "TANGENT VECTOR :\n" );
	for ( i=1; i<=nb; i++ )
	    fprintf ( ioout, "V[%d] = %e\n", i, v[i] );
    }

    /*	  FIND JP,  INDEX OF FIRST BASIC VARIABLE TO HIT A BOUND    */

    chuzr();

    if ( move == 1 )   goto w300;

    /*	  DEGENERATE AND NO MOVE IN BASICS IS POSSIBLE	  */

    jr = ibv[jp];
    if ( ipr >= 3 )
	fprintf (ioout, "BASIS DEGENERATE-- VARIABLE %d LEAVING BASIS\n", jr );
    lv = jp;
    degen = 1;
    idegct++;
    if ( idegct < 15 )   goto w281;
    if ( ipr < 0 )  goto w281;
    fprintf (ioout, "DEGENERATE FOR %d STEPS.  PROBABLY CYCLING.\n", idegct );

w281 :
    printdataline ( );

    /*      EXCHANGE BASIC WITH SOME SUPERBASIC AND UPDATE BINV   */

    chuzq();

    /*	  SET LOGICALS FOR USE BY DIREC    */

    restrt = 0;
    uncon = 0;
    sbchng = 1;
    mxstep = 1;

    /*	  NOW GO TO BEGIN NEW ITERATION FOR DEGENERATE CASE    */

    goto w100;

w300 :
    degen = 0;
    idegct = 0;

    printdataline ( );

    search();

    /* IF ABSOLUTE VALUE OF X'S IS VERY SMALL, CHANGE TO 0 TO AVOID UNDERFLOW */

    for ( i=1; i<=n; i++ )
	if ( fabs(x[i]) < eps )  x[i] = 0.0;

    nsear++;
    if ( nsear == ipn4 )  ipr = 4;
    if ( nsear == ipn5 )  ipr = 5;
    if ( nsear == ipn6 )  ipr = 6;
    ipr3 = ipr - 1;

    /*	IF SUPERBASIC HAS HIT BOUND, DELETE APPROPRIATE COLUMNS OF HESSIAN  */

    if ( mxstep == 0 )	goto w400;
    ii = nsuper;
    iii = nsuper;
    for ( kk=1; kk<=ii; kk++ )	{
	iparm = ii + 1 - kk;
	j = inbv[i];
	if ( fabs(x[j] - alb[j]) > epnewt && fabs(x[j] - ub[j]) >epnewt )  goto w390;
	iii--;
	if ( varmet == 1 )   delcol( &iparm );
	if ( iparm > iii )   goto w390;
	for ( k=iparm; k<=iii; k++ ) gradp[k] = gradp[k+1];
w390 :	;
    }
w400 :
    if ( succes == 1 )	 goto w440;

    /*	TROUBLE -- NO FUNCTION DECREASE  */
    /*	TRY DROPPING CONSTRAINTS ( AND GRADIENT STEP ) IF NOT DONE ALREADY  */

    if ( drop == 1 )   goto w435;
    drop = 1;
    chngsb = 1;
    goto w40;
w435 :
    /*	NO IMPROVEMENT IN LINESEARCH.  ALL REMEDIES FAILED.  */

    ierr = 2;
    if ( ipr < 0 )   goto w436;
    fprintf (ioout,"ALL REMEDIES HAVE FAILED TO FIND A BETTER POINT.");
    fprintf (ioout,"  PROGRAM TERMINATED.\n");
    linect = linect + 2;
w436 :
    info = 2;
    goto w480;
w440 :
    if ( unbd == 0 )   goto w450;

    /*	UNBOUNDED SOLUTION  */

    ierr = 20;
    if ( ipr < 0 )  goto w441;
    fprintf (ioout,"SOLUTION UNBOUNDED--FUNCTION IMPROVING AFTER DOUBLING STEP");
    fprintf (ioout," %d TIMES.\n", ndub);
    linect++;
w441 :
    info = 4;
    goto w520;
w450 :
    nfail = 0;
    restrt = 0;
    drop = 0;
    goto w40;

    /*********************************************************************/

    /*	SEGMENT CHECKS AND IF NEEDED ADJUSTS EPNEWT TO FINAL VALUE  */

w480 :
    if ( epnewt == eplast )   goto w520;
    printdataline ( );
    epnewt = eplast;
    if ( ipr < 0 )  goto w481;
    fprintf (ioout,"CONSTRAINT TOLERANCE HAS BEEN TIGHTENED TO ITS FINAL ");
    fprintf (ioout,"VALUE OF %e.\n", epnewt );
    linect = linect + 2;
w481 :
    epstop = 0.1 * epstop;
    nsear0 = nsear;
    ph1eps = 0.2;
    for ( i=1; i<=n; i++ )   {
	if ( ifix[i] != 0 )  goto w485;
	ts = ub[i] + epnewt;
	if ( x[i] > ts )  x[i] = ts;
	ts = alb[i] - epnewt;
	if ( x[i] < ts )  x[i] = ts;
w485 :	;
    }
    sclgcomp(g, x);
    nftn++;
    if ( maxim == 1 )	g[nobj] = -g[nobj];
    goto w10;

    /*************************************************************/

    /*	NORMAL TERMINATION STEP  */

w520 :
    printdataline ( );
    if ( ninf == 0 )   goto w540;

    /*	SOLUTION INFEASABLE  */

    if ( ipr < 0 )  goto w521;
    fprintf (ioout,"FEASIBLE POINT NOT FOUND.\n");
    fprintf (ioout,"  FINAL VALUE OF TRUE OBJECTIVE = %e.\n", truobj );
    fprintf (ioout,"  THE FOLLOWING %d CONSTRAINTS WERE IN VIOLATION:\n", ninf);
    linect = linect + 2;
w521 :
    info = info + 10;
    ierr = 9;
    for ( i=1; i<=nnbc; i++ )  {
	j =inbc[i];
	if ( g[j] > alb[n+j] && g[j] < ub[n+j] )   goto w530;
	if ( ipr < 0 )	goto w523;
/*08/1991 thru 11/1991*/
        if (scaled == 1)
            fprintf (ioout, "  %d    %e\n", j, g[j]*scale[n+j] );
        else
            fprintf (ioout, "  %d    %e\n", j, g[j] );
/*08/1991 thru 11/1991*/
w523 :	;
w530 :	;
    }
    g[nobj] = truobj;
w540 :
    if ( epnewt != eplast )    epstop = 0.1 * epstop;
    epnewt = eplast;
    ph1eps = phhold;

/*08/1991 thru 11/1991*/
    if ( scaled == 1 )
       /*  must unscale the x[*] and g[*] before returning */
       { for (i = 1; i <= n; i++ )
	     { x[i] /= scale[i];
	       if (ub[i]  < plinfy) ub[i]  /= scale[i];
	       if (alb[i] >-plinfy) alb[i] /= scale[i];
	     }
w1000 :
	 for (j = 1; j <= mp1; j++ )
	     { i = n + j;
	       g[j] *= scale[i];
	       if (ub[i] < plinfy)  ub[i]  *= scale[i];
	       if (alb[i] >-plinfy) alb[i] *= scale[i];
	     }
       }
w1010 :
/*08/1991 thru 11/1991*/
    return;
}
/*08/1991 thru 11/1991*/
void sclgcomp (double g[zmp1], double x[znpmp1])
{
    int i;
    if ( scaled == 1 ) for ( i = 1; i <= n; i++) x[i] /= scale[i];
    gcomp (g , x );
    if ( scaled == 1 ) for ( i = 1; i <= n; i++) x[i] *= scale[i];
    if ( scaled == 1 ) for ( i = 1; i <= mp1; i++) g[i] /= scale[n+i];
    return;
}
/*08/1991 thru 11/1991*/
