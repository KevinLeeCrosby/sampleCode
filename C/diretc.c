/******************************/
/*     File    DIRETC         */
/*   includes direc(),        */
/*            resetr(),       */
/*            comdfp(),       */
/*            r1mod(),        */
/*            r1add,r1sub,    */
/*            rtrsol(),       */
/*            cg(),           */
/*            addcol().       */
/******************************/

#include "gvar.h"

void rtrsol ( double *r, double *y, int ny );
void resetr ( void );
void comdfp (double ytp, double gtp, int *kadd, int *ksub);
void r1sub (double *r, double *y, int ny, double tol, int *posdef);
void r1mod (double *r, double *y, int ny, double sigma, int *k);
void cg( int *msgcg);
void addcol( void );

void direc ( void )
{
    /*    Local Declarations  */

    int      modr;    /*  logical     */
    double   p, t, gtp, ytp, sum, tst, dmax, dmin, gtp1, told, dnorm;
    int      i, j, k, ii, kadd, ksub, nn, nns;
    static int msgcg;

    if ( ipr >= 5 )  fprintf ( ioout, "DIREC ENTERED\n" );
    update = 0;
    dfail = 1;
    drop = ( drop == 1 || nsuper == 0 ) ? 1 : 0;
    varmet = ( nsuper <= maxrm ) ? 1 : 0;
    conjgr = ( varmet == 0 ) ? 1 : 0;
    if ( jstfes == 1 )	restrt = 1;
    if ( drop == 1 )  goto w500;
    if ( conjgr == 1 )	goto w110;

    /*	COMPLEMENTARY DFP VARIABLE METRIC ALGORITHM  */

    if ( nsear == 0 )  goto w60;
    if ( sbchng == 1 )	goto w50;
    if ( restrt == 1 )	goto w60;
    move = ( step > eps ) ? 1 : 0;

    /*	msgcg CAUSES cg TO PRINT ON NEXT CALL  */

    if ( ipr3 >= 0 )  msgcg = 1;
    modr = 0;
    if ( move == 0 )  goto w70;
    ytp = 0.0;
    gtp = 0.0;
    gtp1 = 0.0;
    for ( i=1; i<=nsuper; i++ )  {
	p = d[i];
	y[i] = gradf[i] - gradp[i];
	ytp = y[i] * p + ytp;
	gtp = gradp[i] * p + gtp;
	gtp1 = gradf[i] * p + gtp1;
    }

    /*    USE comdfp UPDATE ONLY IF gtp1/ gtp < 0.9(say).
		  NOTE THAT gtp < 0  */

    modr = ( gtp1 > 0.99 * gtp ) ? 1 : 0;
    if ( modr == 0 && ipr >= 4 )  {
	fprintf ( ioout, "MODR FALSE, SKIP UPDATE OF HESSIAN\n" );
	fprintf ( ioout, "  GTP1 = %e    GTP = %e\n", gtp1, gtp );
    }
    goto w70;

    /*	HESSIAN UPDATE WHEN BASIC VARIABLE HITS BOUND  */

w50 :
    if ( nsupp > maxrm && ipr3 >= 0 )
	fprintf ( ioout, "SWITCH TO VARIABLE METRIC\n" );
    resetr();
    goto w80;

    /*	RESET  HESSIAN	*/

w60 :
    resetr();
    goto w80;

    /*	HESSIAN UPDATE WHEN NO VARIABLE HITS BOUND  */

w70 :
    if ( modr == 0 )  goto w80;
    kadd = 4;
    ksub = 4;
    comdfp( ytp, gtp, &kadd, &ksub );
    update = 1;

    /*	COMPUTE SEARCH DIRECTION, D  */

w80 :
    for ( j=1; j<=nsuper; j++ )   d[j] = -gradf[j];
    rtrsol( r, d, nsuper);

    /*	COMPUTE CONDITION NUMBER OF DIAGONAL OF R  */

    dmin = plinfy;
    dmax = 0.0;
    k = 0;
    for ( i=1; i<=nsuper; i++ )  {
	k += i;
	t = fabs( r[k] );
	if ( dmin > t )  dmin = t;
	if ( dmax < t )  dmax = t;
    }
    cond = plinfy;
    if ( dmin < eps ) goto w120;
    cond = ( dmax / dmin ) * ( dmax / dmin );
    goto w140;

    /*	CONJUGATE GRADIENT METHOD  */
w110 :
    if ( uncon == 0 || sbchng == 1 )  restrt = 1;
    cg(&msgcg);

    /*	CHECK IF DIRECTION IS DOWNHILL	*/
w120 :
    sum = 0.0;
    for ( i=1; i<=nsuper; i++ )   sum = sum + d[i]*gradf[i];
    if ( sum < -eps )  goto w145;

    /*	BAD DIRECTION.	 RESET	*/

    if ( restrt == 1 )	goto w235;
    if ( ipr3 >= 2 )
	fprintf ( ioout, "DIRECTION NOT DOWNHILL.  RESET.\n" );
    restrt = 1;
    if ( varmet == 1 ) goto w60;
    goto w110;
w140 :
    if ( ipr3 < 5 )   goto w145;
    k = nsuper * ( nsuper + 1 ) / 2;
    for ( i=1; i<=k; i++ )
	fprintf ( ioout, "R[%d] = %e\n", i, r[i] );

    /*	THIS CODE DECIDES IF ANY VARIABLES AT BOUNDS ARE TO BE	*/
    /*	RELEASED FROM  THEM	 */

w145 :
    sum = 0.0;
    k = 0;
    for ( i=1; i<=nsuper; i++ )  {
	dnorm = gradf[i];
/*08/1991 - 11/1991*/
/*  Changed line below FROM  ( fabs(dnorm) < epstop ) TO  */
/*                           ( fabs(dnorm) < epnewt )     */
/*08/1991 - 11/1991*/
	if ( fabs(dnorm) < epnewt )   goto w150;
	k++;
	sum = sum + dnorm * dnorm;
w150 :	;
    }
    if ( k == 0 )  goto w400;
    told = sqrt( sum ) / k;
    goto w501;
w400 :
/*08/1991 - 11/1991*/
/*  commented out two lines below  */
/*08/1991 - 11/1991*/
/*    told = epstop;     */
/*    goto w501;      */
w500 :
    /*	RELEASE ALL POSSIBLE NONBASICS	*/

    told = 0.0;
w501 :
    nn = 10;
    nns = nsear;
/*08/1991 - 11/1991*/
/*  Changed line below by removing " && ( nns % nn ) != 0 " from if */
/*08/1991 - 11/1991*/
    if ( told > epnewt )  goto w540;
    j = nsuper + 1;
    if ( j > n )  goto w540;
    for ( ii=j; ii<=n; ii++ )	{
	i = inbv[ii];

	/*  SKIP FIXED VARIABLES AND EQUALITY SLACKS  */

	if ( ub[i] == alb[i] )	 goto w530;
	if ( i <= n )	goto w505;

	/*  REGULAR VARIABLES AND INEQUALITY SLACKS  */

w505 :
	tst = gradf[ii];
	if ( iub[ii] == 1 )  goto w510;

	/*  VARIABLE AT LOWER BOUND  */

	if ( tst >= -told )  goto w530;
	if ( i > n && tst >= -100 * told )   goto w530;
	goto w520;

	/*  VARIABLE AT UPPER BOUND  */
w510 :
	if ( tst <= told )  goto w530;
	if ( i > n && tst <= 100 * told )  goto w530;

	/*  MAKE THIS VARIABLE SUPERBASIC  */

w520 :
	nsuper++;
	inbv[ii] = inbv[nsuper];
	inbv[nsuper] = i;
	gradf[ii] = gradf[nsuper];
	gradf[nsuper] = tst;
	iub[ii] = iub[nsuper];
	iub[nsuper] = 0;
	if ( varmet == 1 )   addcol();
	d[nsuper] = -gradf[nsuper];
	dfail = 0;
w530 :	;
    }
w540 :
    if ( drop == 0 )  goto w220;
    if ( dfail == 1 && restrt == 1 )  goto w237;
    if ( dfail == 1 )
	fprintf ( ioout, "COULD NOT DROP ANY CONSTRAINT.  TRY -VE GRADIENT DIRECTION.\n" );

    /*	UPDATE DIRECTION VECTOR  */

    for ( j=1; j<=nsuper; j++ )  d[j] = -gradf[j];
    restrt = 1;

    if ( varmet == 1 )	resetr();
w215 :
    drop = 0;
w220 :
    for ( i=1; i<=n; i++ )   gradp[i] = gradf[i];
    nsupp = nsuper;
    dfail = 0;
    if ( ipr >= 5 )  fprintf ( ioout, "DIREC COMPLETED.\n" );
    return;

    /*	NEGATIVE GRADIENT DIRECTION NOT DOWNHILL  */

w235 :
    for ( i=1; i<=nsuper; i++ )
	if ( d[i] != 0.0 )  goto w239;

    /*	DIRECTION VECTOR ZERO.	TRY DROPPING A CONSTRAINT.  */

    drop = 1;
    if ( ipr >= 1 )
	fprintf ( ioout, "DIRECTION VECTOR ZERO.  TRY DROPPING A CONSTRAINT.\n" );
    goto w500;
w237 :
    fprintf ( ioout, "DIRECTION VECTOR ZERO AND NO CONSTRAINT COULD BE DROPPED\n");
    fprintf ( ioout, "KUHN-TUCKER CONDITION IMPLIED.\n" );
    return;
w239 :
    fprintf ( ioout, "NEGATIVE GRADIENT DIRECTION NOT DOWNHILL.\n" );
    fprintf ( ioout, "CHECK DERIVATIVES AND/OR TOLERANCES.\n" );
    return;

/*       end of direc()      */
}

void resetr ( void )
{

    /*	Local Declarations  */

    int  i, k, ncol;

    /*	RESET THE CHOLESKY FACTOR OF THE HESSIAN  */

    if ( nsuper == 0 )	return;
    if ( ipr >= 4 ) fprintf ( ioout, "CHOLESKY FACTOR OF HESSIAN RESET TO I\n" );
    cond = 1.0;
    ncol = nsuper;
    if ( maxrm < ncol )  ncol = maxrm;
    k = ncol * ( ncol + 1 ) / 2;
    for ( i=1; i<=k; i++ )  r[i] = 0.0;
    k = 0;
    for ( i=1; i<=ncol; i++ )  {
	k = k + i;
	r[k] = 1.0;
    }
    restrt = 1;
    return;

/*       end of resetr()     */
}

void comdfp (double ytp, double gtp, int *kadd, int *ksub)
{

    /*	Local Declaration  */

    double   c1, c2;

    /*	MODIFY R USING COMPLEMENTARY DFP FORMULA  */

    if ( fabs(step) <= eps ) return;
    if ( fabs(ytp) < eps )  return;
    if ( fabs(gtp) < eps )  gtp = eps;
    c1 = 1.0 / ( step * ytp );
    c2 = 1.0 / gtp;
    r1mod ( r, y, nsuper, c1, kadd );
    r1mod ( r, gradp, nsuper, c2, ksub );
    return;

/*       end of comdfp( * )  */
}

void r1add ( double *r, double *y, int ny )
{

    /*	Local Declaration  */

    double   cs, d, sn, t1, t2;
    int      j, j1, k, k0, k1, l;

    /*  MODIFY R SUCH THAT R'R := R'R + YY'  WHERE R IS AN UPPER-  */
    /*  TRIANGULAR MATRIX, STORED BY COLUMNS.     */

    k1 = 1;
    for ( k=1; k<=ny; k++ )   {
	k0 = k1;
	t1 = r[k1];
	t2 = y[k];
	d = sqrt ( t1*t1 + t2*t2 );
	cs = t1 / d;
	sn = t2 / d;
	j1 = k1 + k;
	k1 = j1 + 1;
	if ( fabs( sn ) <= eps )  goto w100;
	r[k0] = d;
	l = k + 1;
	if ( l > ny ) goto w100;
	for ( j=l; j<=ny; j++ )  {
	    t1 = r[j1];
	    t2 = y[j];
	    r[j1] = cs*t1 + sn*t2;
	    y[j] = sn*t1 - cs*t2;
	    j1 = j1 + j;
	}
w100 :	;
    }
    return;

/*       end of r1add( * )   */
}

void r1sub (double *r, double *y, int ny, double tol, int *posdef)
{

    /*	Local Declaration  */

    double  cs, d, s, sn, t, t1, t2, u;
    int     i, ii, i1, j, k, l;

    /*	MODIFY R SUCH THAT R'R := R'R - YY'  WHERE R IS UPPER-  */
    /*	TRIANGULAR, STORED BY COLUMNS.	 */
    /*	SEE SAUNDERS, STANFORD TECHNICAL REPORT STAN-CS-72-252,  */
    /*	CHAPTER 7.  */

    /*	FIRST SOLVE R'P = Y  */

    t = y[1] / r[1];
    d = t * t;
    y[1] = t;
    k = 1;
    if ( ny <= 1 )  goto w50;
    for ( i=2; i<=ny; i++ )  {
	s = y[i];
	i1 = i - 1;
	for ( j=1; j<=i1; j++ )  {
	    k++;
	    s = s - r[k]*y[j];
	}
	k++;
	t = s / r[k];
	d = t*t + d;
	y[i] = t;
    }
    /*	SEE IF NEW R WILL BE POSITIVE DEFINITE.  */

w50 :
    d = 1.0 - d;
    *posdef = ( d > eps ) ? 1 : 0;
    if ( *posdef == 0 )  return;
    s = sqrt (d);

    /*	PERFORM BACKWARD SWEEP OF PLANE ROTATIONS  */

    for ( ii=1; ii<=ny; ii++ )	{
	i = ny + 1 - ii;
	u = s;
	t = y[i];
	d = t*t + d;
	s = sqrt( d );
	cs = u / s;
	sn = t / s;
	y[i] = 0.0;
	l = k;
	k = k - i;
	if ( fabs(sn) <= eps )  goto w80;
	for ( j=i; j<=ny; j++ )  {
	    t1 = y[j];
	    t2 = r[l];
	    y[j] = cs*t1 + sn*t2;
	    r[l] = sn*t1 - cs*t2;
	    l = l + j;
	}
w80 :	;
    }
    return;

/*       end of r1sub( * )   */
}

void r1mod (double *r, double *y, int ny, double sigma, int *k)
{
    /*    Local Declaration  */

    int   posdef;     /*  logical  */
    double  s, t, tol;
    int   i;

    /*	MODIFY R SUCH THAT R'R = R'R + SIGMA * YY'  */

    tol = eps;
    s = 0.0;
    t = sqrt( fabs(sigma) );
    for ( i=1; i<=ny; i++ )  {
	s = y[i]*y[i] + s;
	y[i] = y[i] * t;
    }
    s = sigma * s;
    if ( fabs(s) <= tol )  return;
    if ( s <= tol )  goto w200;
    r1add ( r, y, ny );
    return;
w200 :
    r1sub( r, y, ny, tol, &posdef );
    if ( posdef == 0 )  *k = - *k;
    return;

/*       end of r1mod( * )   */
}

void rtrsol ( double *r, double *y, int ny )
 {
/*    Local Declaration  */

    double   s, t;
    int      i, ii, i1, j, k;

    /*	SOLVE R'R*Y = Y ( R TRIANGULAR, STORED BY COLUMNS )  */

    y[1] = y[1] / r[1];
    k = 1;
    if ( ny <= 1 )  goto ww50;
    for ( i=2; i<=ny; i++ )   {
	s = y[i];
	i1 = i - 1;
	for ( j=1; j<=i1; j++ ) {
	    k++;
	    s = s - r[k]*y[j];
	}
	k++;
	y[i] = s / r[k];
    }
ww50 : ;
    for ( ii=1; ii<=ny; ii++ )	{
	i = ny + 1 - ii;
	t = y[i] / r[k];
	y[i] = t;
	if ( i <= 1 )  goto ww80;
	k = k - i;
	i1 = i - 1;
	for ( j=1; j<=i1; j++ )   y[j] = y[j] - r[k+j]*t;
ww80 :	 ;
    }
    return;

/*       end of rtrsol( * )  */
}

void cg( int *msgcg)
{

    /*	Local Declaration  */

    double   cgbeta, gamma, gtd, gty, gyd, g1, g1n, g2, g2n, rho, yj;
    double   ytd, yty;
    int   i, j;
    static int  initcg = 1, itncg = 0;

    /*    CONJUGATE GRADIENT METHOD ON SUPERBASICS  */

    if ( ipr >= 5 )  fprintf ( ioout, "CG ENTERED\n" );
    if ( initcg != 0 || nsear == 0 )  *msgcg = 1;
    initcg = 0;
    if ( *msgcg > 0 && maxr > 0)
    {
	fprintf ( ioout, "HESSIAN IS TOO LARGE FOR VARIABLE METRIC ---\n" );
	fprintf ( ioout, "    SWITCH TO CONJUGATE GRADIENTS\n");
    }
    if ( restrt == 0 && itncg <= nsuper )   goto w20;

    /*	RESTART  */

w9 :
    itncg = 0;
    cgbeta = 0.0;
    for ( i=1; i<=nsuper; i++ )  d[i] = -gradf[i];
    if ( *msgcg == 0 )	goto w210;
    switch ( modcg )  {
	case 1 : fprintf ( ioout, "FLETCHER-REEVES DIRECTION WILL BE USED\n" );
		break;
	case 2 : fprintf ( ioout, "POLAK-RIBIERE DIRECTION WILL BE USED\n" );
		break;
	case 3 : fprintf ( ioout, "PERRY (MARCH 76) DIRECTION WILL BE USED\n" );
		break;
	case 4 : fprintf ( ioout, "DFP DIRECTION WILL BE USED\n");
		break;
	case 5 : fprintf ( ioout, "COMPLEMENTARY DFP DIRECTION WILL BE USED\n");
		break;
    }
    goto w210;
w20 :
    switch ( modcg )  {
	case 1 :  goto w30;
		break;
	case 2 :  goto w60;
		break;
	case 3 :  goto w90;
		break;
	case 4 :  goto w110;
		break;
	case 5 :  goto w120;
		break;
    }

    /*	FLETCHER-REEVES  */

w30 :
    if ( *msgcg > 0 )
	fprintf ( ioout,"FLETCHER-REEVES DIRECTION WILL BE USED\n");
    g1n = 0.0;
    for ( i=1; i<=nsuper; i++ )  g1n = g1n + gradp[i]*gradp[i];
    if ( g1n <= eps )  goto w9;
    g2n = 0.0;
    for ( i=1; i<=nsuper; i++ )  g2n = g2n + gradf[i]*gradf[i];
    cgbeta = g2n / g1n;
    if ( ipr < 5 )  goto w190;
    fprintf ( ioout, "CGBETA = %e\n", cgbeta );
    for ( i=1; i<=nsuper; i++ )
	fprintf ( ioout, "GRADF[%d] = %e\n", i, gradf[i] );
    for ( i=1; i<=nsuper; i++ )
	fprintf ( ioout, "GRADFP[%d] = %e\n", i, gradp[i] );
    goto w190;

    /*	POLAK-RIBIERE  */
w60 :
    if ( *msgcg > 0 )
	fprintf ( ioout, "POLAK-RIBIERE DIRECTION WILL BE USED\n" );
    g1n = 0.0;
    for ( i=1; i<=nsuper; i++ )   g1n = g1n + gradp[i]*gradp[i];
    if ( g1n <= eps )  goto w9;
    gty = 0.0;
    for ( j=1; j<=nsuper; j++ )  {
	g1 = gradp[j];
	g2 = gradf[j];
	gty = gty + g2 * ( g2 - g1 );
    }
    cgbeta = gty / g1n;
    goto w190;

    /*	PERRY  */
w90 :
    if ( *msgcg > 0 )
	fprintf ( ioout, "PERRY (MARCH 76) DIRECTION WILL BE USED\n" );
    gyd = 0.0;
    ytd = 0.0;
    for ( j=1; j<=nsuper; j++ )  {
	yj = gradf[j] - gradp[j];
	gyd = gyd + gradf[j] * ( yj - step*d[j] );
	ytd = ytd + yj*d[j];
    }
    if ( fabs( ytd ) <= eps )  goto w9;
    cgbeta = gyd / ytd;
    goto w190;

    /*	DFP  */
w110 :
    if ( *msgcg > 0 )
	fprintf ( ioout, "DFP DIRECTION WILL BE USED\n" );
    goto w130;

    /*	COMPLEMENTARY DFP  */
w120 :
    if ( *msgcg > 0 )
	fprintf ( ioout, "COMPLEMENTARY DFP DIRECTION WILL BE USED\n" );
w130 :
    gty = 0.0;
    ytd = 0.0;
    yty = 0.0;
    for ( j=1; j<=nsuper; j++ )  {
	g1 = gradp[j];
	g2 = gradf[j];
	yj = g2 - g1;
	gty = gty + g2 * yj;
	ytd = ytd + yj * d[j];
	yty = yty + yj * yj;
    }
    if ( fabs(ytd) <= eps )  goto w9;
    if ( fabs(yty) <= eps )  goto w9;
    gtd = 0.0;
    for ( i=1; i<=nsuper; i++ )  gtd = gtd + gradf[i] * d[i];
    if ( modcg == 5 )  goto w160;

    cgbeta = -step * gtd / ytd;
    gamma = gty / yty;
    goto w170;
w160 :
    rho = step + yty / ytd;
    cgbeta = ( gty - rho * gtd ) / ytd;
    gamma = gtd / ytd;
w170 :
    itncg++;
    if ( ipr >= 5 )   {
	fprintf ( ioout, "CGBETA = %e,   GAMMA = %e,   YTD = %e\n", cgbeta, gamma, ytd);
	fprintf ( ioout, "YTY = %e,   GTD = %e,   GTY = %e\n", yty, gtd, gty );
    }
    for ( j=1; j<=nsuper; j++ )
	d[j] = -gradf[j] + cgbeta *  d[j] + gamma * ( gradf[j] - gradp[j] );
    goto w210;

    /*	SET UP NEXT CG-TYPE SEARCH DIRECTION  */
w190 :
    itncg++;
    for ( j=1; j<=nsuper; j++ )  d[j] = -gradf[j] + cgbeta * d[j];
w210 :
    *msgcg = 0;
    if ( ipr >= 5 )  {
	for ( i=1; i<=nsuper; i++ )
	    fprintf ( ioout, "D[%d] = %e\n", i, d[i] );
	fprintf ( ioout, "CG COMPLETED\n" );
    }
    return;

/*       end of cg()         */
}

void addcol( void )
{
    /*	Local Declaration  */

    double  diag;
    int   i, k, nsprev;

    nsprev = nsuper - 1;
    diag = 1.0;
    for ( i=1; i<=nsuper; i++ )  y[i] = 0.0;

    /*	INSERT NEW COLUMN OF r	*/

    y[nsuper] = diag;
    k = nsprev * nsuper / 2;
    for ( i=1; i<=nsuper; i++ )  r[k+i] = y[i];

    return;

/*       end of addcol()     */
}
