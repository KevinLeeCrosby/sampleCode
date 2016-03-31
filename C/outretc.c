/***********************/
/*   File OUTRET       */
/*   includes outres() */
/*            redobj() */
/*            quad()   */
/*            newton() */
/***********************/

#include "gvar.h"

void quad( void );
void newton( void );
void sclgcomp( double *g, double *x );
void heading1(void)
{
    fprintf ( ioout,
"\f\nFINAL RESULTS\n");
    fprintf ( ioout, "\n%s\n", title);
    fprintf ( ioout,
"\nSECTION 1 -- FUNCTIONS\n" );
    fprintf ( ioout,
"\n                                                    DISTANCE" );
    fprintf ( ioout,
"\n                  INITIAL      FINAL                  FROM        LAGRANGE" );
    fprintf ( ioout,
"\nNO.    NAME        VALUE       VALUE      STATUS     NEAREST     MULTIPLIER" );
    fprintf ( ioout,
"\n                                                      BOUND" );
    fprintf ( ioout,
"\n___  _________   _________  ___________ __________  __________   __________\n");

/*       end of heading1()   */
}

void heading2(void)
{
    fprintf ( ioout,
"\n\nFINAL RESULTS\n");
    fprintf ( ioout, "\n%s\n", title);
    fprintf ( ioout,
"\nSECTION 2 -- VARIABLES\n" );
    fprintf ( ioout,
"\n                                                       DISTANCE" );
    fprintf ( ioout,
"\n                   INITIAL      FINAL                    FROM        REDUCED" );
    fprintf ( ioout,
"\nNO.     NAME        VALUE       VALUE      STATUS       NEAREST      GRADIENT" );
    fprintf ( ioout,
"\n                                                         BOUND" );
    fprintf ( ioout,
"\n___   ________    _________  ___________  ________    __________    __________\n");

/*       end of heading2()   */
}

void outres()
{

    /*  Local Declarations  */

    double  ts, ts1, ts2;
    int  i, k, ni;
    char  *symbol[13], *c;

    char  ibl[] = "  ";
    char  iu[]  = ":U";
    char  il[]  = ":L";
    symbol[1]   = "OBJECTIVE";
    symbol[2]   = "IGNORED  ";
    symbol[3]   = "LOWERBND ";
    symbol[4]   = "UPPERBND ";
    symbol[5]   = "EQUALITY ";
    symbol[6]   = "FREE     ";
    symbol[7]   = "FIXED    ";
    symbol[8]   = "NO BOUND ";
    symbol[9]   = "SUPBASIC ";
    symbol[10]  = "NONBASIC ";
    symbol[11]  = "BASIC    ";
    symbol[12]  = "VIOLATED ";
    
    if ( ipr < 0 )  return;
    if ( maxim == 1 )  g[nobj] = -g[nobj];
    if ( ipr3 >= -1 )  goto w10;
    fprintf ( ioout, "\nFINAL OBJECTIVE VALUE IS %e\n", g[nobj] );
    fprintf ( ioout, "\nFINAL VALUES OF VARIABLES ARE :\n" );
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "    %e\n", x[i] );
    goto w210;
w10 :
    if ( maxim == 0 || ninf != 0 )   goto w18;
    for ( i=1; i<=n; i++ )  gradf[i] = -gradf[i];
    if ( nb == 0 )  goto w18;
    for ( i=1; i<=nb; i++ )  u[i] = -u[i];
w18 :
    heading1( );
    for ( i=1; i<=mp1; i++ )  {
	   gtype[i] = symbol[6];
        gg[i] = plinfy;
    }
w25 :
    if ( nb == 0 )  goto w40;
    for ( i=1; i<=nb; i++ )  {
        k = ibc[i];
        gg[k] = u[i];
    }
w40 :
    for ( i=1; i<=mp1; i++ )  {
        ni = n + i;
        ts1 = ub[ni]  - g[i];
        ts2 = g[i] - alb[ni];
        ts = ts1;
	   gstatus[i] = iu;     /************/
        if ( ts2 > ts1 )  goto w45;
        ts = ts2;
	   gstatus[i] = il;     /************/
w45 :
        x[ni] = ts;
        if ( ts < -epnewt )  goto w65;
        if ( ts > epnewt )  goto w60;
        if ( ub[ni] == alb[ni] )  goto w50;
	   if ( fabs( g[i] - ub[ni]) < epnewt )  gtype[i] = symbol[4];
	   if ( fabs( g[i] - alb[ni]) < epnewt )  gtype[i] = symbol[3];
        goto w70;
w50 :
	   gtype[i] = symbol[5];
	   gstatus[i] = ibl;    /**************/
        goto w70;
w60 :
        if ( istat[i] != 0 )  goto w70;
	   gstatus[i] = ibl;    /**************/
	   gtype[i] = symbol[2];
	   if ( i == nobj )  gtype[i] = symbol[1];
        goto w70;
w65 :   gtype[i] = symbol[12];
w70 :   ;
    }
    for ( i=1; i<=mp1; i++ )  {
        if ( ( i / 40 ) * 40 != i )  goto w75;
    heading1( );
w75 :
        if ( i == nobj )  goto w85;
        if ( gg[i] != plinfy )  goto w80;
	   fprintf ( ioout,
		"%3d%11s%12.5g%13.6g  %9s %10.3g%3s\n",
		i, con[i], go[i], g[i], gtype[i], x[n+i], gstatus[i] ); /*****/
        goto w90;
w80 :   fprintf ( ioout,
		"%3d%11s%12.5g%13.6g  %9s %10.3g%3s %12.5g\n",
		i, con[i], go[i], g[i], gtype[i], x[n+i], gstatus[i], gg[i] );  /*******/
        goto w90;
w85 :     fprintf ( ioout,
		"%3d%11s%12.5g%13.6g  %9s\n",
		i, con[i], go[i], g[i], gtype[i] );
w90 :   ;
    }
    for ( i=1; i<=n; i++ )  {
        gradp[i] = plinfy;
	   colstatus[i] = ibl;     /****************/
	   gstatus[i] = symbol[10];     /********/
        if ( ifix[i] != 0 )  goto w94;
        ts1 = ub[i] - x[i];
        ts2 = x[i] - alb[i];
        ts = ts1;
        c = iu;
        if ( ts2 > ts1 )  goto w92;
        ts = ts2;
        c = il;
w92 :
        if ( ts > 1.0e20 )  goto w96;
        if ( ts < epnewt )  goto w98;
        dbnd[i] = ts;
	   colstatus[i] = c;    /*****************/
        goto w100;
w94 :
	   gtype[i] = symbol[7];
        goto w100;
w96 :
	   gtype[i] = symbol[8];
        goto w100;
w98 :
	   if ( fabs(ub[i] - x[i]) < epnewt )  gtype[i] = symbol[4];
	   if ( fabs(alb[i] - x[i]) < epnewt )  gtype[i] = symbol[3];
w100 :  ;
    }
    if ( nsuper == 0 )  goto w120;
    for ( i=1; i<=nsuper; i++ )  {
        k = inbv[i];
	   if ( k <= n )  gstatus[k] = symbol[9];     /*****************/
    }
w120 :
    if ( nb == 0 )  goto w140;
    for ( i=1; i<=nb; i++ )  {
        k = ibv[i];
	   if ( k <= n )  gstatus[k] = symbol[11];    /****  Double  ****/
    }
w140 :
    for ( i=0; i<=n; i++ )  {
        k = inbv[i];
        if ( k <= n )  gradp[k] = gradf[i];
    }
    heading2 ( );
w155 :
    for ( i=1; i<=n; i++ )  {
        if ( (i / 40) * 40 != i )  goto w158;
    heading2 ( );
w158 :
        if ( gradp[i] == plinfy )  goto w170;
	   if ( colstatus[i] != ibl )  goto w160;        /****  Integer  ****/
	   fprintf ( ioout,
	   "%3d %10s %12.5g%13.6g %10s  %11s   %11.3g\n",
	   i, var[i], xo[i], x[i], gstatus[i], gtype[i], gradp[i] );  /******/
        goto w190;
w160 :
	   fprintf ( ioout,
	   "%3d %10s %12.5g%13.6g %10s %11.4g%3s %11.3g\n",
	   i, var[i], xo[i], x[i], gstatus[i], dbnd[i], colstatus[i], gradp[i] ); /* */
        goto w190;
w170 :
	if ( colstatus[i] != ibl )  goto w180;
	   fprintf ( ioout,
	   "%3d %10s %12.5g%13.6g %10s  %11s\n",
	   i, var[i], xo[i], x[i], gstatus[i], gtype[i] );    /************/
        goto w190;
w180 :
	   fprintf ( ioout,
	   "%3d %10s %12.5g%13.6g %10s %11.4g%3s\n",
	   i, var[i], xo[i], x[i], gstatus[i], dbnd[i], colstatus[i] );      /**********/
w190 :  ;
    }
    fprintf ( ioout, "\n\f\nRUN STATISTICS\n\n%s\n", title );
    fprintf ( ioout, "\nFINAL OBJECTIVE VALUE IS %14.7g\n", g[nobj] );
w210 :
    fprintf ( ioout,
    "  EPNEWT = %le, EPINIT = %le, EPSTOP = %le\n", eplast, epinit, epstop );
    fprintf ( ioout,
    "  EPPIV  = %le, PH1EPS = %le\n", epspiv, ph1eps );
    if ( iquad == 1 )
	fprintf (ioout,
    "QUADRATIC EXTRAPOLATION.");
    if ( iquad == 0 )
	fprintf (ioout,
    "TANGENT EXTRAPOLATION.  ");
    if ( maxim == 1 )
	fprintf (ioout,
    " OBJECTIVE MAXIMIZED.");
    if ( maxim == 0 )
	fprintf (ioout,
    " OBJECTIVE MINIMIZED.");
    if ( maxrm == 0 )
	fprintf (ioout,
    " CONJUGATE GRADIENT %d USED.\n", modcg);
    else
	fprintf (ioout,
    " DFP USED.\n", maxrm);
    if ( kderiv == 0 )
	fprintf (ioout,
    " FORWARD DIFF PARSH USED: DELTA = %le.\n", pstep);
    if ( kderiv == 1 )
	fprintf (ioout,
    " CENTRAL DIFF PARSH USED: DELTA = %le.\n", pstep);
    if ( kderiv == 2 )
	fprintf (ioout,
    " THE USER SUPPLIED PARSH SUBROUTINE USED.\n");
    fprintf ( ioout, "\nNUMBER OF ONE DIMENSIONAL SEARCHES = %d.", nsear );
    ts = 0.0;
    if ( ncalls == 0 )   goto w220;
    ts = (double)nit / (double)ncalls;
w220 :
    fprintf ( ioout,
    "\nNEWTON CALLS = %d;    NEWTON ITERATIONS = %d;    AVERAGE = %10.3g",
				 ncalls, nit, ts );
    i = n * ( kderiv + 1 );
    if ( kderiv == 2 )  i = 0;
    i = i * ngrad + nftn;
    fprintf ( ioout,
    "\nFUNCTION CALLS = %d;   GRADIENT CALLS = %d.", nftn, ngrad );
    fprintf ( ioout,
    "\nACTUAL FUNCTION CALLS ( INC. FOR GRADIENT ) = %d.", i );
    fprintf ( ioout,
    "\nNUMBER OF TIMES A BASIC VARIABLE VIOLATED A BOUND = %d.", nbs );
    fprintf ( ioout,
    "\nNUMBER OF TIMES NEWTON FAILED TO CONVERGE = %d.", nnfail );
    fprintf ( ioout,
    "\nNO. OF TIMES STEPSIZE CUT BACK DUE TO NEWTON FAILURE = %d.", nstepc );
    
    return;
    
/*       end of outres()     */
}


void ph1obj( void );

void redobj()
{
    
    /*  Local Declaration  */
    
    double   b1, b2, cons4, denom, d1, d2, gj, sum, t, tb, thet, thmin;
    double   tmp, ts, xbestj, xbi, xj;
    int      i, j, jr, k, kk, knb, l, lv1, nj;
    
    if ( ipr >= 5 )  fprintf ( ioout, "REDOBJ ENTERED\n" );
    fail = 0;
    xb = 0.0;
    lv = 0;
    lv1 = 0;
    mxstep = (step >= stepmx) ? 1 : 0;
    if ( mxstep == 1 )  step = stepmx;
    for ( i=1; i<=nsuper; i++ )  {
        j = inbv[i];
        x[j] = xstat[i] + step * d[i];
    }
    if ( nb != 0 )  goto w20;
    
    /*    10    NO BINDING CONSTRAINTS    */
/*08/1991 thru 11/1991*/
    sclgcomp(g, x);
/*08/1991 thru 11/1991*/
    nftn++;
    
    if ( maxim == 1 )  g[nobj] = -g[nobj];
    goto w60;
w20 :
    if ( icon == 0 )  goto w30;
    
    /*    OBTAIN INITIAL ESTIMATE OF BASIC VARIABLES BY    */
    /*        QUADRATIC EXTRAPOLATION                      */
    
    quad();
    
    goto w50;
w30 :
    /*    LINEAR EXTRAPOLATION    */
    
    for ( i=1; i<=nb; i++ )  {
        k = ibv[i];
        x[k] = xbest[i] + ( step - stpbst ) * v[i];
    }
w50 :
    newton();
    
    if ( fail == 1 )  goto w330;
    
    /*    COMPUTE SLACKS FOR NONBINDING CONSTRAINTS AND MAKE    */
    /*        THEM TEMPORARILY BASIC                            */
    
w60 :
    knb = nb;
    if ( nnbc == 0 )  goto w80;
    for ( i=1; i<=nnbc; i++ )  {
        j = inbc[i];
        x[n+j] = g[j];
        knb = nb + i;
        ibv[knb] = n + j;
    }
w80 :
    if ( knb == 0 )  goto w370;
    if ( lv == 0 )  goto w90;
    if ( xstep >= step || xstep <= stpbst )  goto w320;
    step = xstep;
w90 :
    if ( ninf == 0 )  goto w120;
    
    /*    COME HERE IF INFEASIBLE    */
    /*    --BEGIN CHECKING FOR CHANGES IN STATUS OF BASIC VARIABLES    */
    
    lv = 0;
    thmin = plinfy;
    for ( i=1; i<=knb; i++ )  {
        j = ibv[i];
        xj = x[j];
        xbestj = xbest[i];
        denom = xj - xbestj;
	if ( fabs(denom) <= eps )  goto w110;
        tb = alb[j];
        t = tb - epnewt;
        if ( xbestj >= t && xj < t )  goto w100;
        tb = ub[j];
        t = tb + epnewt;
        if ( xbestj <= t && xj > t )  goto w100;
        goto w110;
w100 :
        thet = ( t - xbestj ) / denom;
        if ( thet >= thmin )  goto w110;
        thmin = thet;
        lv = i;
w110 :  ;
    }
    ph1obj();

    /*    TEST IF BACKUP PHASE NEEDED    */
    
    if ( lv != 0 )  goto w160;
    
    /*    NO BACKUP NEEDED CHECK IF FEASIBLE    */

    if ( ninf == 0 )  goto w340;
    
    /*    STILL INFEASIBLE    */
    
    if ( ipr >= 2 )  
        fprintf(ioout," STEP = %e  OBJ = %e  NEWTON ITERS = %d\n",step, g[nobj], iter );
    goto w350;
    
    /*    WE WERE FEASIBLE BEFORE NEWTON.  CHECK BOUND ON BASICS    */
    /*        TO SEE IF WE ARE STILL FEASIBLE.                      */
    
w120 :
    lv = 0;
    thmin = plinfy;
    for ( i=1; i<=knb; i++ )  {
        j = ibv[i];
        xj = x[j];
        xbestj = xbest[i];
        denom = xj - xbestj;
        if ( fabs(denom) <= eps )  goto w150;
        if ( alb[j] - xj <= epnewt )  goto w130;
        t = alb[j] - xbestj;
        goto w140;
w130 :
        if ( xj - ub[j] <= epnewt )  goto w150;
        t = ub[j] - xbestj;
w140 :
        thet = t / denom;
        if ( thet >= thmin )  goto w150;
        thmin = thet;
        lv = i;
w150 :  ;
    }
w160 :
    if ( ipr >= 5 )  fprintf(ioout, "LV = %d   THMIN = %e\n", lv, thmin );
    if ( thmin < 0.0 )   goto w320;
    if ( ninf == 0 && maxim == 1 )  g[nobj] = -g[nobj];
    if ( ipr3 >= 1 )  
        fprintf(ioout,"STEP = %e  OBJ = %e  NEWTON ITERS = %d\n", step, g[nobj], iter );
    if ( ninf == 0 && maxim == 1 )  g[nobj] = -g[nobj];
    if ( lv == 0 )  goto w350;
    if ( ipr3 < 1 )  goto w167;
    if ( lv > nb )  goto w163;
    fprintf ( ioout, "BASIC VARIABLE #%d VIOLATED BOUND\n", ibv[lv] );
    goto w167;
w163 :
    i = ibv[lv] - n;
    fprintf ( ioout, "CONSTRAINTS #%d VIOLATED BOUND\n", i );
w167 :
    
    /*    BOUND VIOLATED--START BACKUP PHASE    */
    
    /*    SET XB = BOUND NEAREST X[LV]    */
    
    jr = ibv[lv];
    b1 = alb[jr];
    b2 = ub[jr];
    d1 = x[jr] - b1;
    d2 = x[jr] - b2;
    xb = b1;
    if ( fabs(d1) > fabs(d2) )  xb = b2;
    xstep = stpbst + thmin * ( step - stpbst );
    if ( ipr >= 5 )
        fprintf(ioout,"REDOBJ BACKING UP.  OBJ = %e  LV =%d  XSTEP = %e\n",
                       g[nobj], lv, xstep );
    if ( nb == 0 )  goto w210;
    
    /*    COMPUTE COLB=B2*D, COLUMN PART OF JACOBIAN BORDER    */
    
    for ( i=1; i<=nb; i++ )  {
        sum = 0.0;
        k = ibc[i];
        for ( j=1; j<=nsuper; j++ )  {
            kk = inbv[j];
            if ( kk <= n )  goto w170;
            ts = 0.0;
            if ( k == kk - n )  ts = -1.0;
            goto w180;
w170 :
            ts = grad[k][kk];
w180 :
            sum = sum + ts * d[j];
        }
        colb[i] = sum;
    }
    if ( ipr >= 5 )   {
        fprintf ( ioout, "COLUMN BORDER :\n" );
        for ( i=1; i<=nb; i++ )  fprintf ( ioout, "    %e\n", colb[i] );
    }
    
    /*    DO ROW BORDER AND CORNER ELEMENT CALCULATIONS    */
    
    if ( lv > nb )  goto w210;
    
    /*    CASE OF BASIC VARIABLE VIOLATING BOUND    */
    
    for ( i=1; i<=nb; i++ )  rr[i] = 0.0;
    rr[lv] = 1.0;
    corner = 0.0;
    goto w270;
    
    /*    CASE OF CONSTRAINTS VIOLATING BOUND    */
    
w210 :
    j = ibv[lv];
    l = j - n;
    if ( nb == 0 )  goto w240;
    for ( i=1; i<=nb; i++ )  {
        k = ibv[i];
        if ( k > n )  goto w220 ;
        rr[i] = grad[l][k];
        goto w230;
w220 :
        rr[i] = 0.0;
w230 :  ;
    }
w240 :
    corner = 0.0;
    for ( i=1; i<=nsuper; i++ )  {
        j = inbv[i];
        if ( j <= n )  goto w250;
        ts = 0.0;
        goto w260;
w250 :
        ts = grad[l][j];
w260 :
        corner = corner + ts * d[i];
    }
    if ( nb == 0 )  goto w310;
w270 :
    for ( i=1; i<=nb; i++ )  {
        tmp = 0.0;
        for ( j=1; j<=nb; j++ )  tmp = tmp + rr[j]*binv[j][i];
        rowb[i] = tmp;
    }
    if ( ipr >= 5 )  fprintf ( ioout, "CORNER = %e\n", corner );
    if ( ipr >= 5 ) for ( i=1; i<=nb; i++ )
				  fprintf ( ioout, "ROWB[%d] = %e\n", i, rowb[i] );
    
    /*    COMPUTE ESTAMATES OF BASIC VARIABLES    */
    
    for ( i=1; i<=nb; i++ )  {
        j = ibv[i];
        xbi = xbest[i];
        x[j] = xbi + ( x[j] - xbi ) * thmin;
    }
w310 :
    lv1 = lv;
    goto w50;
    
    /*    BACKUP FAILED    */
    
w320 :
    if ( ipr >= 5 )  
        fprintf ( ioout, "REDOBJ CANNOT BACKUP TO FIRST VIOLATED CONSTRAINT\n");
    
    /*    NEWTON CALL FAILED    */

w330 :
    fail = 1;
    if ( ipr3 >= 1 ) 
        fprintf ( ioout, "NEWTON FAILED TO CONVERGE.  NO. ITER = %d\n", iter);
    goto w440;
   
    /*    JUST BECAME FEASIBLE    */
    
w340 :
    jstfes = 1;
    stpbst = step;
    g[nobj] = truobj;
    goto w440;
    
    /*    NORMAL TERMINATION    */
    
w350 :
    if ( lv > 0  || nnbc == 0 )  goto w370;
    
    /*    CHECK FOR NEW BINDING CONSTRAINTS    */
    
    for ( i=1; i<=nnbc; i++ )  {
        j = inbc[i];
        gj = g[j];
        nj = n + j;
	   if ( fabs(gj - alb[nj]) < epnewt || fabs(gj - ub[nj]) < epnewt )  lv1 = nb + i;
    }
    
    /*    UPDATE BEST VALUES    */
    
w370 :
    if ( g[nobj] > objbst )  goto w430;
    if ( nb == 0 )  goto w390;
    for ( i=1; i<=nb; i++ )  {
        j = ibv[i];
        xbest[i] = x[j];
    }
w390 :
    if ( nnbc == 0 )   goto w410;
    for ( i=1; i<=nnbc; i++ )  {
        k = inbc[i];
        xbest[nb+i] = g[k];
    }
w410 :
    for ( i=1; i<=mp1; i++ )  gbest[i] = g[i];
    stpbst = step;
    objbst = g[nobj];
    trubst = truobj;
    ninfb = ninf;
w430 :
    lv = lv1;
w440 :
    if ( ipr >= 5 )  fprintf (ioout, "REDOBJ COMPLETED\n" );
    
    return;
    
/*       end of redobj       */
}


void quad( void )
{

    /*  Local Declaration  */
    
    double  aa, ta, t2, t3, w1, w2, w3, t32;
    int   i, ii;
    
    if ( icon == 2 )  goto w20;
    aa = ( step / a2 ) * ( step / a2 );
    for ( i=1; i<=nb; i++ )  {
        ii = ibv[i];
        x[ii] = xb1[i] + step * v[i] + aa * ( xb2[i] - xb1[i] - a2 * v[i] );
    }
    goto w40;
w20 :
    t2 = a2 - a1;
    t3 = a3 - a1;
    t32 = a3 - a2;
    ta = step - a1;
    aa = ta * ta;
    w1 = 1.0 - ( ta * ( t2 + t3 ) - aa ) / ( t2 * t3 );
    w2 = ( ta * t3 - aa ) / ( t2 * t32 );
    w3 = ( aa - ta * t2 ) / ( t3 * t32 );
    for ( i=1; i<=nb; i++ )  {
        ii = ibv[i];
        x[ii] = w1 * xb1[i] + w2 * xb2[i] + w3 * xb3[i];
    }
w40 :
    return;

/*       end of quad         */
}

void newton( void )
{

    /*  Local Declaration  */
    
    double  nrr, del, err, xnum, cons5, delta, denom, ernorm, oldnrm;
    int     i, j, k, jr, nc, iii;
    
    /*  NC IS NON-CONVERGENCE  FLAG.  0 = CONVERGED, 1 = DID NOT  */
    
    if ( ipr >= 5 )  fprintf ( ioout, "NEWTON ENTERED\n" );
    nc = 0;
    fail = 0;
    oldnrm = plinfy;
    ncalls++;
    if ( lv != 0 )  jr = ibv[lv];
    if ( ipr3 >= 4 )  
        for ( i=1; i<=npmp1; i++ )  fprintf ( ioout, "X[%d] = %e\n", i, x[i]);
    
    for ( iii=1; iii<=itlim; iii++ )  {
        iter = iii - 1;
        if ( lv == 0 )  goto w20;
        
        /*  MODIFY SUPERBASICS IF IN BACKUP PHASE  */
        
        for ( i=1; i<=nsuper; i++ )  {
            j = inbv[i];
            x[j] = xstat[i] + xstep * d[i];
        }
        
        /*  EVALUATE CONSTRAINTS  */

w20 :
/*08/1991 thru 11/1991*/
        sclgcomp(g, x);
/*08/1991 thru 11/1991*/
        nftn++;
        if ( maxim == 1 )  g[nobj] = -g[nobj];
        
        /*  COMPUTE NORM OF EQUATION ERROR  */
        
        if ( lv == 0 )  goto w30;
        if ( lv > nb )  x[jr] = g[jr - n];
	xnum = xb - x[jr];
w30 :
        ernorm = 0.0;
        if ( lv != 0 )  ernorm = fabs(xnum);
        if ( nb == 0 )  goto w50;
        for ( i=1; i<=nb; i++ )  {
            j = ibc[i];
            err = g[j] - x[n + j];
            if ( fabs(err) > ernorm )  ernorm = fabs(err);
            rr[i] = err;
        }
        if ( ipr3 >= 4 )  
            for ( i=1; i<=nb; i++ )  fprintf ( ioout, "RR[%d] = %e\n", i, rr[i]);
        
        /*  TEST FOR CONVERGENCE  */
        
w50 :
	   if ( ipr3 >= 4 )  fprintf(ioout,
					"XNUM = %e  ERRNORM = %e\n", xnum, ernorm);
        if ( ernorm < epnewt )  goto w140;
        
        /*  TEST FOR NON-CONVERGENCE  */
        
        if ( ernorm > oldnrm || iter == itlim )  goto w130;
        oldnrm = ernorm;
        nit++;
        
        /*  PROCEED WITH NEWTON  */
        
        if ( lv == 0 )  goto w90;
        
        /*  COMPUTATIONS FOR BACKUP PHASE  */
        
        denom = -corner;
        if ( nb == 0 )  goto w70;
        for ( i=1; i<=nb; i++ )  {
            nrr = rowb[i];
            xnum = xnum + nrr * rr[i];
            denom = denom + nrr * colb[i];
        }
w70 :
        if ( ipr3 >= 4 )  fprintf(ioout,"XNUM = %e   DENOM = %e\n", xnum, denom);
        if ( fabs(denom) < tolz )   goto w130;
        delta = xnum / denom;
        xstep = xstep - delta;
        if ( ipr3 >= 4 )  fprintf(ioout,"DELTA = %e   XSTEP = %e\n", delta, xstep);
        if ( nb == 0 )  goto w120;
        for ( i=1; i<=nb; i++ )  rr[i] = rr[i] - delta * colb[i];
        if ( ipr3 >= 4 )
            for ( i=1; i<=nb; i++ ) fprintf(ioout,"RR[%d] = %e\n", i, rr[i] );
        
        /*  COMPUTE NEWTON CORRECTION  */
        
w90 :
        for ( i=1; i<=nb; i++ )  {
            del = 0.0;
            for ( j=1; j<=nb; j++ )  del = del + binv[i][j] * rr[j];
            k = ibv[i];
            x[k] = x[k] - del;
        }
        if ( ipr3 >= 4 )  
            for ( i=1; i<=npmp1; i++ )  fprintf(ioout,"X[%d] = %e\n", i, x[i]);
w120 :  ;
    }
    
    /*  FAILURE  */
    
w130 :
    fail = 1;
    nnfail++;
w140 :
    if ( ipr >= 5 )  fprintf( ioout, "NEWTON COMPLETED\n" );
    
    return;
    
/*       end of newton()     */
}
