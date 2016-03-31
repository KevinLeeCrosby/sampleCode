/******************************/
/*     File PHETC.c           */
/*     includes ph1obj(),     */
/*              redgra(),     */
/*              tang(),       */
/*              chuzr(),      */
/*              chuzq(),      */
/*              search(),     */
/*              delcol()      */
/******************************/

#include "gvar.h"

void redobj ( void );

void ph1obj()
{
    /*      IT COMPUTES PHASE 1 OBJECTIVE = SUM OF ABSOLUTE VALUE    */
    /*	  OF CONSTRAINT VIOLATIONS AND STORES AS G(M+1).	   */
    /*	  TRUE OBJECTIVE SAVED AS truobj.			   */

    /*	Local Declaration  */

    double   factor, gj, sinf, sinf0, t, true0;
    int      i, j;

    sinf0 = 0.0;
    true0 = 0.0;
    factor = 100.0;
    ninf = 0;
    sinf = 0.0;
    if ( nnbc == 0 )  goto w300;
    for ( i=1; i<=nnbc; i++ )  {
	j = inbc[i];
	gj = g[j];
	t = alb[n+j] - gj;
	if ( t <= epnewt )  goto w100;
	ninf++;
	sinf = sinf + t;
	goto w200;
w100 :
	t = gj - ub[n+j];
	if ( t <= epnewt )  goto w200;
	ninf++;
	sinf = sinf + t;
w200 :	;
    }
w300 :
    truobj = g[nobj];
    if ( ninf == 0 )  return;
    t = truobj;
    if ( maxim == 1 )  t = -t;

    /*	IF IN MIDDLE OF SEARCH, DO NOT RECOMPUTE phmult  */

    if ( initph == 0 )	goto w400;

    /*	IF STARTING PHASE 1, COMPUTE phmult FROM SCRATCH  */

    if ( initph == 2 )	goto w350;
    truobj = trubst;
    t = truobj;
    if ( maxim == 1 )  t = -t;

    /*	RIGHT AFTER consbs CALL, SEE IF sinf HAS CHANGED ENOUGH TO RESTART  */

    if ( phmult == 0.0 )  goto w350;
    if ( sinf0 > factor * sinf )  goto w350;
    if ( true0 * truobj < 0.0 )  goto w350;
    if ( fabs(true0) < factor * fabs(truobj) &&
	 fabs(truobj) < factor * fabs(true0) )	goto w400;
w350 :
    phmult = 0.0;
    sinf0 = sinf;
    true0 = truobj;
    restrt = 1;
    if ( fabs(truobj) < 0.01 )	goto w400;
    phmult = fabs( (ph1eps * sinf) / truobj );
    if ( maxim == 1 )  phmult = -phmult;
w400 :
    if ( ipr3 >= 2 )  {
	fprintf ( ioout, "NEW PHMULT = %e\n", phmult );
	fprintf ( ioout, "SUM OF INFEASIBILITIES = %e\n", sinf );
	fprintf ( ioout, "TRUOBJ = %e\n", t );
    }
    if ( ninf != 0 )  g[nobj] = sinf + phmult * truobj;
    if ( ph1eps != 0.0 && ipr3 >= 2 )
	fprintf ( ioout, "SINF = %e\nTRUOBJ = %e\n", sinf, t );
    return;

/*       end of ph1obj()     */
}

void redgra (double *redgr )
{

    /*	Local Declaration  */

    double  uu, tmp, temp;
    int   i, ii, i2, isv, j, jj, k;

    if ( ninf == 0 )  goto w70;

    /*	IF PHASE 1 THEN    THIS BLOCK COMPUTES GRADIENT OF SUM OF  */
    /*	INFEASIBILITIES, STORES IT IN ROW M+1 OF grad  */

    for ( j=1; j<=n; j++ )  {
	tmp = 0.0;
	for ( i=1; i<=nnbc; i++ )  {
	    k = inbc[i];
	    if ( g[k] < alb[n+k] - epnewt )  goto w20;
	    if ( g[k] > ub[n+k] +epnewt )  goto w30;
	    goto w40;
w20 :
	    tmp = tmp - grad[k][j];
	    goto w40;
w30 :
	    tmp = tmp + grad[k][j];
w40 :	    ;
	}
	grad[nobj][j] = phmult * grad[nobj][j] + tmp;
    }
w70 :
    if ( nb == 0 )  goto w100;

    /*	COMPUTES LAGRANGE MULTIPLIERS U  */

    for ( i=1; i<=nb; i++ )  {
	uu = 0.0;
	for ( j=1; j<=nb; j++ )  {
	    jj = ibv[j];
	    if ( jj > n )  goto w80;
	    uu = uu + grad[nobj][jj] * binv[j][i];
w80 :	    ;
	}
	u[i] = uu;
    }
w100 :
    /*	NOW COMPUTE REDGRA USING MULTIPLIERS.  */

    for ( i=1; i<=n; i++ )  {
	ii = inbv[i];
	if ( ii > n )  goto w130;
	temp = 0.0;
	if ( nb == 0 )	goto w120;
	for ( j=1; j<=nb; j++ )   {
	    jj = ibc[j];
	    temp = temp + u[j] * grad[jj][ii];
	}
w120 :
	redgr[i] = grad[nobj][ii] - temp;
	goto w160;

	/*  HANDLE SLACK VARIABLES  */

w130 :
	i2 = ii - n;
	for ( j=1; j<=nb; j++ )  {
	    isv = j;
	    if ( ibc[j] == i2 ) goto w150;
	}
	goto w170;
w150 :
	redgr[i] = u[isv];
w160 :	;
    }
    return;
w170 :
    fprintf ( ioout, "REDGRA CANNOT FIND IBC INDEX TO MATCH %d\n", i2 );
    exit(8);

/*       end of redgra(     )     */
}

void tang()
{
	/*    Local Declaration  */

    double  tmp, trhs;
    int   i, j, ii, jj;

    /*      COMPUTES TANGENT VECTOR V = -BINV * JACOBIAN * DIRECTION  */
    /*	  BINV IS THE BASIS INVERSE    */
    /*	  JACOBIAN HAS I, J ELEMENT = PARTIAL I'TH BINDING CONSTRAINT  */
    /*		      WITH RESPECT TO J'TH NONBASIC VARIABLE           */

    for ( i=1; i<=nb; i++ )  {
	trhs = 0.0;
	ii = ibc[i];
	for ( j=1; j<=nsuper; j++ )  {
	    jj = inbv[j];
	    if ( jj > n )  goto w20;
	    trhs = trhs + grad[ii][jj] * d[j];
	    goto w30;
w20 :
	    if ( (jj - n) == ii ) trhs = trhs - d[j];
w30 :	    ;
	}
	rr[i] = trhs;
    }
    for ( i=1; i<=nb; i++ )  {
	tmp = 0.0;
	for ( j=1; j<=nb; j++ )   tmp = tmp + binv[i][j] * rr[j];
	v[i] = -tmp;
    }

    return;

/*       end of tang()       */
}

void chuzr()
{
	/*    Local Declaration  */

    double  bndjr,  di, pertbn, pivot, psi, t, theta;
    double  tmax, tr, xjr;
    int    i, j, jr, k;

    if ( ipr >= 5 )  fprintf ( ioout, "CHUZR ENTERED\n" );
    move = 1;
    theta = plinfy;
    psi = plinfy;
    pertbn = epnewt;
    jp = 0;
    for ( j=1; j<=nb; j++ )  {
	t = -v[j];
	if ( fabs(t) <= eps )  goto w100;
	k = ibv[j];
	if ( t < 0.0 )	goto w50;
	di = x[k] - alb[k] + pertbn;
	goto w60;
w50 :
	di = x[k] - ub[k] - pertbn;
w60 :
	t = di / t;
	if ( psi <= t ) goto w100;
	psi = t;
	jp = j;
w100 :	;
    }
    if ( jp == 0 )  goto w160;
    if ( ipr >= 5 )  {
	fprintf ( ioout, "PSI = %e\n", psi );
	for ( i=1; i<=nb; i++ )
	    fprintf ( ioout, "V[%d] = %e\n", i, v[i] );
    }

    /*	SECOND PASS OF HARRIS  */

    tmax = 0.0;
    for ( j=1; j<=nb; j++ )  {
	t = -v[j];
	if ( fabs(t) < eps )  goto w150;
	k = ibv[j];
	if ( t < 0.0 )	goto w120;
	di = x[k] - alb[k];
	goto w130;
w120 :
	di = x[k] - ub[k];
w130 :
	tr = di / t;
	if ( ipr >= 5 )  fprintf ( ioout, "K = %d   TR = %e\n", k, tr );
	if ( tr > psi )  goto w150;
	if ( tmax > fabs(t) )  goto w150;
	tmax = fabs(t);
	jp = j;
	theta = tr;
	if ( ipr >= 5 )  fprintf ( ioout, "JP = %d   TMAX = %e\n", jp, tmax );
w150 :	;
    }
    jr = ibv[jp];
    if ( jr <= n )  goto w2000;
    bndjr = alb[jr];
    pivot = v[jp];
    if ( pivot > 0.0 )	bndjr = ub[jr];
    xjr = g[jr-n];
    theta = ( bndjr - xjr ) / pivot;
w2000 :
    move = ( theta > tolx ) ? 1 : 0;
w160 :
    if ( ipr >= 5 )  fprintf (ioout, "CHUZR COMPLETED\n" );

    return;

/*       end of chuzr()      */
}

void chuzq()
{
    /*    Local Declaration  */

    int    i, icol, ii, j, jj, jq, jq2, jq3, k;
    double   constq, d1, d2, dmax, pivotq, sumq, tolq, ts, xj;

    /*	CHOOSE MAXIMUM PIVOT FROM COLUMNS OF BINV  */
    /*	D[1],...,D[NSUPER] WILL HOLD THE PIVOT CHOICES	*/

    if ( ipr >= 5 )  fprintf ( ioout, "CHUZQ ENTERED\n" );
    jq = 1;
    if ( nsuper == 1 )	goto w70;

    /*	COMPUTE PIVOT ROW IN BINV  */

    for ( i=1; i<=nb; i++ )   v[i] = binv[lv][i];
    pivotq = 0.0;
    for ( i=1; i<=nsuper; i++ )  {
	sumq = 0.0;
	ii = inbv[i];
	for ( j=1; j<=nb; j++ )  {
	    jj = ibc[j];
	    if ( ii > n )  goto w20;
	    ts = grad[jj][ii];
	    goto w30;

	    /*	  SLACK  COLUMN    */
w20 :
	    ts = -1.0;
	    if ( (ii-n) != jj )  goto w40;
w30 :
	    sumq = sumq + v[j] * ts;
w40 :	    ;
	}
	d[i] = sumq;
	if ( pivotq >= fabs(sumq) )  goto w50;
	pivotq = fabs(sumq);
	jq = i;
w50 :	;
    }
    if ( ipr >= 5 )  fprintf (ioout, "CHUZQ  JQ = %d   PIVOT = %e\n", jq, pivotq );

    /*	CHOOSE ONE AWAY FROM ITS BOUNDS IF POSSIBLE  */

    tolq = 0.1 * pivotq;
    dmax = 0.0;
    jq2 = 0;
    for ( j=1; j<=nsuper; j++ )  {
	if ( fabs(d[j]) < tolq )  goto w60;
	k = inbv[j];
	xj = x[k];
	d1 = fabs( xj - alb[k] );
	d2 = fabs( ub[k] - xj );
	if ( d1 > d2 )	d1 = d2;
	if ( dmax > d1 )  goto w60;
	dmax = d1;
	jq2 = j;
w60 :	;
    }
    if ( jq2 > 0 )  jq = jq2;

    /*	NOW PIVOT  */
w70 :
    icol = inbv[jq];
    if ( ipr >= 3 )
	fprintf (ioout,"VARIABLE %d ENTERING BASIS - SUPERBASIC NO. %d\n", icol, jq );
    if ( icol > n )  goto w90;

    /*	SELECT COLUMN FROM GRAD ARRAY  */

    for ( i=1; i<=nb; i++ )  {
	ii = ibc[i];
	v[i] = grad[ii][icol];
    }
    goto w110;
w90 :
    /*	SLACK COLUMN  */

    k = icol - n;
    for ( i=1; i<=nb; i++ )  {
	ii = ibc[i];
	v[i] = 0.0;
	if ( ii == k )	v[i] = -1.0;
    }
w110 :
    for ( i=1; i<=nb; i++ )  {
	sumq = 0.0;
	for ( j=1; j<=nb; j++ )    sumq = sumq + v[j] * binv[i][j];
	colb[i] = sumq;
    }
    pivotq = 1.0 / colb[lv];
    if ( ipr >= 5 )  fprintf (ioout, "BINV PIVOT = %e\n", pivotq );
    for ( i=1; i<=nb; i++ )   binv[lv][i] = binv[lv][i] * pivotq;
    for ( i=1; i<=nb; i++ )  {
	if ( i == lv )	goto w160;
	constq = colb[i];
	for ( j=1; j<=nb; j++ )  binv[i][j] = binv[i][j] - constq * binv[lv][j];
w160 :	;
    }

    /*	UPDATE INDEX SETS OF BASIC AND NONBASIC VARIABLES AND IUB  */

    jq2 = ibv[lv];
    jq3 = icand[lv];
    ibv[lv] = icol;
    if ( icol <= n )  goto w163;
    icol = icol - n;
    for ( i=1; i<=nb; i++ )  {
	if ( ibc[i] != icol )  goto w162;
	icol = n + i;
	goto w163;
w162 :	;
    }
w163 :
    icand[lv] = icol;
    if ( jq == nsuper )  goto w168;
    k = nsuper - 1;
    for ( i=jq; i<=k; i++ ) {
	ii = i + nb;
	icand[ii] = icand[ii+1];
	inbv[i] = inbv[i+1];
    }
w168 :
    iub[nsuper] = 0;
    icand[nb+nsuper] = jq3;
    if ( fabs( x[jq2] - ub[jq2] ) <= epnewt )	iub[nsuper] = 1;
    if ( fabs( x[jq2] - alb[jq2] ) <= epnewt )	 iub[nsuper] = -1;
    inbv[nsuper] = jq2;
    if ( iub[nsuper] != 0 )  nsuper--;
    if ( ipr < 4 )  return;
    for ( i=1; i<=n; i++ )
	fprintf (ioout, "INBV[%d] = %d\n", i, inbv[i] );
    for ( i=1; i<=n; i++ )
	fprintf (ioout, "IUB[%d] = %d\n", i, iub[i] );
    for ( i=1; i<=nb; i++ )
	fprintf (ioout, "IBV[%d] = %d\n", i, ibv[i] );
    for ( i=1; i<=ii; i++ )
	fprintf (ioout, "ICAND[%d] = %d\n", i, icand[i] );
    if ( ipr >= 5 )  fprintf (ioout, "CHUZQ COMPLETED" );

    return;

/*       end of chuzq()      */
}

void search( void )
{
    /*    IT PERFORMS THE 1-DIMENSIONAL MINIMIZATION  */

    /*	Local Declaration  */

    int        failp;    /*  logical     */
    double     bt, dd, fa, fb, fc, fd, f2, f3, ftemp, pctchg, sa, sb, sc;
    double     sd, si, smax, tmp, tmp2, tmp3, ts, ts2, t2, t3, xi, totalstep;
    int        i, ii, j, k, ncut, next, lmquit, maxcut, maxdub;


    /*	INITIALIZATION FOR QUADRATIC EXTRAPOLATION SCHEME  */

    if ( ipr >= 5 )  fprintf (ioout, "SEARCH ENTERED\n" );
    icon = 0;
    a1 = 0.0;
    if ( nb == 0 )  goto w20;
    for ( i=1; i<=nb; i++ )  {
	ii = ibv[i];
	xb1[i] = x[ii];
    }
w20 :
    /*	INITIALIZATION	*/

    iter = 0;
    lastcl = 1;
    fail = 0;
    uncon = 1;
    succes = 1;
    mxstep = 0;
    jstfes = 0;
    step = 0.0;
    lmquit = itlim / 2;
    if ( iquad == 1 )  lmquit = 4;
    maxcut = 7;
    maxdub = 30;
    sa = 0.0;
    sb = stpbst;
    fa = g[nobj];
    ftemp = -plinfy;
    stpbst = 0.0;
    objbst = g[nobj];

    if ( nb == 0 )  goto w40;
    for ( i=1; i<=nb; i++ )  {
	j = ibv[i];
	xbest[i] = x[j];
    }
w40 :
    for ( i=1; i<=mp1; i++ )  gbest[i] = g[i];
    if ( nnbc == 0 )  goto w70;
    for ( i=1; i<=nnbc; i++ )  {
	j = inbc[i];
	xbest[nb+i] = g[j];
    }
w70 :
    ninfb = ninf;
    smax = 0.0;
    for ( i=1; i<=nsuper; i++ )   {
	ts = fabs( d[i] );
	if ( smax < ts )  smax = ts;
    }

    /*	COMPUTE STEPMX	*/

    stepmx = plinfy;
    for ( i=1; i<=nsuper; i++ )  {
	si = d[i];
	if ( fabs(si) < tolz )	goto w90;
	j = inbv[i];
	bt = ub[j];
	if ( si < 0.0 )  bt = alb[j];
	if ( fabs(bt) > 1.0e20 )  bt = ( bt >= 0 ) ? 1.0e20 : -1.0e20;
	ts = ( bt - x[j] ) / si;
	if ( ts > stepmx )  goto w90;
	jqq = i;
	stepmx = ts;
w90 :	;
    }

    /*	DETERMINE INITIAL STEP SIZE  */

    ts = epnewt / smax;
    if ( sb < ts )  sb = ts;
    pctchg = 0.05;
    ts = stepmx;
    for ( i=1; i<=nsuper; i++ )   {
	j = inbv[i];
	xi = x[j];
	xstat[i] = xi;
	xi = fabs( xi );
	si = fabs( d[i] );
	if ( si < tolz )  goto w120;
	if ( xi < 1.0 )  goto w100;
	ts2 = pctchg * xi / si;
	goto w110;
w100 :
	ts2 = pctchg / si;
w110 :
	if ( ts > ts2 )  ts = ts2;
w120 :	;
    }

    /*	SET SB TO TS UNLESS PREVIOUS SEARCH WAS UNCONSTRAINED  */
    /*	AND SB IS SMALLER THAN TS.	  */

    if ( unconp == 0 || sb > ts )  sb = ts;
/*08/1991 to 11/1991*/
/*  added " || linear " to if in line below   */
/*08/1991 to 11/1991*/
    if ( sb > stepmx || linear == 1) sb = stepmx;
    tmp = g[nobj];
    if ( maxim == 1 && ninf == 0 )  tmp = -tmp;
    if ( ipr >= 5 )
	fprintf (ioout,
"OBJ = %9.5g.  INIT. STEP = %9.5g.  MAX STEP TO BOUND = %9.5g.\n",
			tmp, sb, stepmx );

    /*	THIS LOOP COMPUTES FB AND CUTS BACK STEPSIZE IF FB > FA  */

    for ( ncut=1; ncut<=maxcut; ncut++ )  {
	failp = fail;
	step = sb;
	redobj();
	if ( fail == 1 ) goto w125;

	fb = g[nobj];
	tmp = fb;
	if ( maxim == 1 && ninf == 0 )	tmp = -tmp;
	if ( jstfes == 1 )  goto w200;
	if ( fb <= ( fa + eps ) )  goto w150;
	ftemp = fb;
	sc = step;
	goto w130;
w125 :
	nstepc++;

	/*  REDUCE STEPSIZE  */

w130 :
	sb = step / pow( 2.0, (double)ncut );
    }
    goto w240;

    /*	STEP REDUCTION PHASE COMPLETED -- HAVE FOUND A BETTER POINT.  */
    /*	CONSIDER ALL POSSIBLE CASES	  */

w150 :
    if ( lv != 0 )  goto w210;
    if ( mxstep == 1 )	goto w220;
    if ( failp == 1 )  goto w190;
    fc = ftemp;

    /*	BEGIN QUADRATIC INTERPOLATION BLOCK  */

    if ( iquad == 0 || nb == 0 )  goto w2160;
    icon = 1;
    a2 = sb;
    for ( i=1; i<=nb; i++ )   {
	ii = ibv[i];
	xb2[i] = x[ii];
    }
    next = 3;
w2160 :

    /*	INTERPOLATE IF A BRACKET HAS BEEN FOUND  */

    if ( fc > (fb+eps) )  goto w170;

    /*	STEP DOUBLING PHASE  */

    for (ndub=1; ndub<=maxdub; ndub++ )  {

	/*  QUIT SEARCH IF NEWTON FAILURE ANTICIPATED  */

	if ( iter >= lmquit )  goto w230;
	sc = sb + sb;
	step = sc;
	redobj();

	if ( fail == 1 )  goto w180;
	sc = step;
	fc = g[nobj];
	tmp = fc;
	if ( maxim == 1 && ninf == 0 )	tmp = -tmp;
	if ( jstfes == 1 )  goto w200;

	/*  BEGIN QUADRATIC INTERPOLATION BLOCK  */

	if ( iquad == 0 || nb == 0 )  goto w2260;
	icon = 2;
	switch ( next )  {
	    case 1 :  for ( i=1; i<=nb; i++ ) {
			  ii = ibv[i];
			  xb1[i] = x[ii];
		      }
		      a1 = sc;
		      next = 2;
		      break;
	    case 2 :  for ( i=1; i<=nb; i++ )  {
			  ii = ibv[i];
			  xb2[i] = x[ii];
		      }
		      a2 = sc;
		      next = 3;
		      break;
	    case 3 :  for ( i=1; i<=nb; i++ )  {
			  ii = ibv[i];
			  xb3[i] = x[ii];
		      }
		      a3 = sc;
		      next = 1;
		      break;
	}
w2260 :
	/*  INTERPOLATE IF A BRACKET HAS BEEN FOUND  */

	if ( fc > ( fb+eps ) )	goto w170;
	if ( ninf > 0 && fc >= ( fb-eps ) )  goto w170;
	if ( lv != 0 )	goto w210;
	if ( mxstep == 1 )  goto w220;

	/*  MOVE 3 POINT PATTERN ONE STEP AHEAD  */

	fa = fb;
	sa = sb;
	fb = fc;
	sb = sc;
w160 :	;
    }
    ndub = maxdub;
    goto w250;

    /*	INTERPOLATION PHASE  */

w170 :
    t2 = sb - sa;
    t3 = sc - sa;
    f2 = ( fb - fa ) * t3;
    f3 = ( fc - fa ) * t2;
    if ( fabs(f2-f3) < plzero )  goto w260;

    /*	SD IS MINIMUM POINT FOR QUADRATIC FIT  */

    sd = sa + 0.5 * ( t3 * f2 - t2 * f3 ) / ( f2 - f3 );
    if ( sd <= sa || sd >= sc )  goto w260;
    if ( ipr3 >= 1 )  fprintf ( ioout, "QUADRATIC INTERPOLATION\n" );

    /*	COMPUTE OBJECTIVE AT SD POINT  */

    step = sd;
    redobj();

    if ( ipr3 < 2 )  goto w178;
    fprintf (ioout,
"     A        B        C        D        FA        FB        FC        FD \n");
    tmp = fa;
    tmp2 = fb;
    tmp3 = fc;
    if ( maxim == 0 || ninf != 0 )  goto w175;
    tmp = -tmp;
    tmp2 = -tmp2;
    tmp3 = -tmp3;
w175 :
    fprintf (ioout,
"%9.4g%9.4g%9.4g%9.4g%10.5g%10.5g%10.5g%10.5g\n",
sa, sb, sc, sd, tmp, tmp2, tmp3, g[nobj] );
w178 :

    if ( fail == 1 )  goto w180;
    fd = g[nobj];
    if ( jstfes == 1 )	goto w200;
    if ( lv != 0 && fd < fb )  goto w210;
    if ( fd > fb )  lastcl = 0;
    goto w270;
w180 :
    /*	QUIT BECAUSE NEWTON FAILED AND BETTER POINT FOUND  */

    if ( ipr3 >= 1 )	fprintf (ioout, "NEWTON FAILURE\n");
    lastcl = 0;
    goto w270;
w190 :
    if ( ipr3 >= 1 )	fprintf (ioout, "EARLIER NEWTON FAILURE\n" );
    goto w270;
w200 :

    /*	HAVE JUST BECAME FEASIBLE  */

    if ( ipr3 >= 1 )	{
	fprintf ( ioout, "ALL VIOLATED CONSTRAINTS SATISFIED.\n" );
	fprintf ( ioout, "NOW BEGIN TO OPTIMIZE TRUE OBJECTIVE.\n\n" );
    }
    if ( ipr >= 5 )  fprintf (ioout, "SEARCH COMPLETED\n" );
    return;

w210 :
    /*	BASIC VARIABLE HIT BOUND  */

    uncon = 0;
    nbs++;
    if ( ipr3 < 1 )  goto w270;
    i = ibv[lv];
    k = i - n;
    if ( i <= n )  fprintf (ioout, "BASIC VARIABLE #%d HIT BOUND\n", i );
    if ( i > n )   fprintf (ioout, "CONSTRAINT #%d NOW AT BOUND\n", k );
    goto w270;
w220 :
    /*	SUPERBASIC VARIABLE HIT BOUND  */

    uncon = 0;
    if ( ipr3 >= 1 )  fprintf ( ioout, "SUPERBASIC VARIABLE #%d HIT BOUND\n", inbv[jqq] );
    goto w270;
w230 :
    /*	NEWTON TOOK TOO LONG  */

    if ( ipr3 >= 1 )  fprintf (ioout, "ANTICIPATED NEWTON FAILURE\n" );
    goto w270;
w240 :
    succes = 0;
    lastcl = 0;
    if ( ipr3 >= 1 )  fprintf (ioout, "NO OBJECTIVE IMPROVEMENT AFTER %d STEPSIZE REDUCTION", maxcut );
    goto w270;
w250 :
    /*	STEP SIZE DOUBLED NDUB TIMES  */

    unbd = 1;
    goto w270;
w260 :
    /*	QUADRATIC INTERPOLATION OUT OF RANGE  */

    if ( ipr3 >= 1 )  fprintf (ioout, "QUADRATIC INTERPOLATION ABANDONED\n" );
    goto w270;
w270 :
    unconp = uncon;

    /*  PICK UP BEST POINT ENCOUNTERED AND RETURN  */

    step = stpbst;
    ninf = ninfb;
    for ( i=1; i<=nsuper; i++ )  {
	j = inbv[i];
	x[j] = xstat[i] + step * d[i];
    }
    if ( nb == 0 )  goto w302;
    for ( i=1; i<=nb; i++ )  {
	j = ibv[i];
	x[j] = xbest[i];
    }
w302 :
    for ( i=1; i<=mp1; i++ )
    {
		ts = gbest[i];
		g[i] = ts;
		x[n+i] = ts;
    }
    if ( ipr >= 5 )  fprintf (ioout, "SEARCH COMPLETED\n" );
    return;

/*       end of search()     */
}

void delcol(int *iparm)
{

    /*    Local Declaration    */
    
    double   dx, cs, sn, t1, t2;
    int      i, j, k, i1, j1, j2, k1, ns;
    
    /*    DELETE THE *iparm'TH COLUMN OF UPPER TRIANGULAR R    */
    
    ns = nsuper;
    if ( *iparm >= ns )  goto w60;
    k = *iparm * ( *iparm + 1 ) / 2;
    i1 = *iparm +1;
    for ( i=i1; i<=ns; i++ )  {
        k = k + i;
        t1 = r[k-1];
        t2 = r[k];
        dx = sqrt( t1 * t1 + t2 * t2 );
        r[k-1] = dx;
        if ( i == ns )  goto w20;
        cs = t1 / dx;
        sn = t2 / dx;
        j1 = i + 1;
        k1 = k + i;
        for ( j=j1; j<=ns; j++ )  {
            t1 = r[k1-1];
            t2 = r[k1];
            r[k1-1] = cs * t1 + sn * t2;
            r[k1] = sn * t1 - cs * t2;
            k1 = k1 + j;
	}
w20 :
        k1 = i - 1;
        j2 = k - i;
        j1 = j2 - i + 2;
        for ( j=j1; j<=j2; j++ )   r[j] = r[j+k1];
    }
w60 :
    nsuper--;
    
    return;

/*       end of delcol( * )  */
}
