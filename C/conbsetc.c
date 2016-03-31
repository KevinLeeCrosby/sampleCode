/*********************************/
/*	  File CONBSETC.C	 */
/*	includes  consbs(),	 */
/*		  parsh(),	 */
/*		  parshc(),	 */
/*		  parshf().	 */
/*********************************/

#include "gvar.h"

void gcomp (double g[zmp1], double x[znpmp1]);
void parsh( void );
void parshc ( void );
void parshf (double g[zmp1], double x[zn]);

void consbs (  )  {

    /*	  consbs() CONSTRUCTS A BASIS FROM THE JACOBIAN OF BINDING  */
    /*	  CONSTRAINTS USING A MODIFIED COMPLETE PIVOTING PROCEDURE  */

    /*	  INPUT VARIABLES ARE --				    */
    /*	     istat  ... STATUS ARRAY FOR CONSTRAINTS		    */

    /*	  OUTPUT VARIABLES ARE --				    */
    /*	     nb     ... NO. OF BASIC VARIABLES			    */
    /*	     ibv    ... INDEX SET OF BASIC VARIABLES		    */
    /*	     inbv   ... INDEX SET OF NON-BASIC VARIABLES	    */
    /*	     ibc    ... INDEX SET OF BINDING CONSTRAINTS	    */
    /*	     inbc   ... INDES SET OF NONBINDING CONSTRAINTS	    */
    /*	     binv   ... INVERSE OF BASIS			    */
    /*	     iub    ... BOUND INDICATOR ARRAY FOR NONBASICS	    */

    /*	  Local Declarations	*/

    int  bschng, slack;      /*  logical  */
    double  c, r, bl, bu, dd, piv, tmp, cmax, dmax, cons3, dmin1;
    double  eltmax, bigelt;
    int  i, j, k, ii, jj, jjj, imax, irow, jcol, jjjt, jpiv;
    int  npnb, ibctr, ictrb, icsupe;
    int  nbp, npiv, nspold;

    /*	  INITIALIZATIONS    */

    if ( ipr >= 5 )  fprintf (ioout, "\nCONSBS ENTERED\n");
    npiv = 0;
    nbp = nb;
    if ( nbp == 0 )  goto w7;
    for ( i=1; i<=nbp; i++ )   ibcold[i] = ibc[i];
w7:
    bschng = 0;
    sbchng = 0;    /*  COMMON SUPBLK  */
    slack = 0;
    nb = 0;
    nnbc = 0;

    /*	  THIS DETERMINES INDEX SETS OF BINDING AND NONBINDING		    */
    /*	  CONSTRAINTS ibc AND inbc.  SETS SLACKS OF BINDING CONSTRAINTS.    */

    for ( i=1; i<=mp1; i++ )  {
	ii = istat[i];

	/*  IF IGNORED CONSTRAINT OR OBJECTIVE, SKIP  */

	if ( ii == 0 )	goto w50;
	if ( ii == 2 )	goto w20;

	/*  EQUALITY CONSTRAINT  */

	bl = alb[n+i];
	if ( fabs(g[i]-bl) >= epnewt )	goto w10;
	nb++;
	ibc[nb] = i;
	x[n+i] = bl;
	goto w50;
w10 :
	nnbc++;
	inbc[nnbc] = i;
	goto w50;

	/*  INEQUALITY CONSTRAINT  */

w20 :
	bu = ub[n+i];
	if ( fabs(g[i]-bu) >= epnewt )	goto w30;
	nb++;
	ibc[nb] = i;
	x[n+i] = bu;
	goto w50;
w30 :
	bl = alb[n+i];
	if ( fabs(g[i]-bl) >= epnewt )	goto w40;
	nb++;
	ibc[nb] = i;
	x[n+i] = bl;
	goto w50;
w40 :
	nnbc++;
	inbc[nnbc] = i;
w50 :	;
    }

    if ( nb > nbmax )  goto w500;
    if ( ipr < 3 )  goto w70;
    if ( nb > 0 ) {
	fprintf ( ioout, "\nBINDING CONSTRAINTS ARE\n");
	for ( i=1; i<=nb; i++ )  fprintf ( ioout, "    %d\n", ibc[i] );
    }
    if ( nnbc > 0 ) {
	fprintf ( ioout, "\nNONBINDING CONSTRAINTS ARE\n");
	for ( i=1; i<=nnbc; i++ )  fprintf (ioout, "    %d\n", inbc[i] );
    }
w70 :
    if ( jstfes == 1 )	bschng = 1;
    if ( nsear == nsear0 )  bschng = 1;
    if ( nb != nbp )  bschng = 1;
    if ( chngsb == 1 )	bschng = 1;
    if ( bschng == 1 || nb == 0 )  goto w77;
    for ( i=1; i<=nb; i++ )  {
	if ( ibc[i] != ibcold[i] )  bschng = 1;
    }
w77 :
    if ( bschng == 1 && ipr > 3 )   fprintf (ioout, "\nBASIS CHANGE\n");

/*08/1991 thru 11/1991*/
    if ( scaled == 1 )
       /*  must unscale the x[*] and g[*]  */
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

    /*	  COMPUTE GRADIENTS OF CONSTRAINTS    */

    ngrad++;
    objbst = g[nobj];
    if ( kderiv == 0 )   parshf( g, x);
    if ( kderiv == 1 )   parshc( );
    if ( kderiv == 2 )	 parsh();

    /*	  PRINT INITIAL grad ARRAY IF ipn4 < 0	  */

    if ( ipn4 >= 0 )  goto w90;
    fprintf ( ioout, "\nGRAD ARRAY IS\n");
    for ( i=1; i<=mp1; i++ )  {
	fprintf ( ioout, "FOR GRAD[%d][]   ", i );
	for ( j=1; j<=n; j++ )
	    fprintf ( ioout, "   %e", grad[i][j] );
	fprintf ( ioout, "\n");
    }
    ipn4 = 0;
w90 :
/*08/1991 thru 11/1991*/
    if (!havescale && doscale)
       {
        /*  scaling has been requested but scale factors have  */
        /*  not yet been calculated.  currently only calculated once */
        scaled = 1;
        havescale = 1;
        for ( i = 1; i <= mp1; i++)
            { /* start for loop 1015 */
              jj = n + i;
              scale[jj] = 1.0;
              if ( i != nobj && istat[i] == 0 ) goto w1015;
              for ( j = 1; j <= n; j++)
                { /* start for loop 1020  */
                  if ( ifix[j] == 1 ) goto w1020;
                  if ( fabs(grad[i][j]) > scale[jj] )
                        scale[jj] = fabs(grad[i][j]);
w1020 :         ;
                } /* end   for loop 1020  */
              scale[jj] = sqrt(scale[jj]);
w1015 :     ;
            } /* end   for loop 1015 */
        for ( i = 1; i <= n; i++ )
            { /* start for loop 1030 */
              scale[i] = 1.0;
              if ( ifix[i] == 1 ) goto w1030;
              for ( j = 1; j <= mp1; j++)
                  { /* start for loop 1035 */
                    jj = n + j;
                    if ( i != nobj && istat[i] == 0 ) goto w1035;
                    if ( fabs(grad[j][i])/scale[jj] > scale[i] )
                        scale[i] = fabs(grad[j][i])/scale[jj];
w1035 :           ;
                  } /* end   for loop 1035 */
w1030 :     ;
            } /* end   for loop 1030 */
            /*  ok now have the scale factors  */
       } /*  end if !havescale && doscale */
    if ( doscale == 1 )
       {
         for ( i = 1; i <= n; i++ )
             { /* start for loop 1100 */
               x[i] *= scale[i];
               if (ub[i] < plinfy)  ub[i]  *= scale[i];
	       if (alb[i] >-plinfy) alb[i] *= scale[i];
               for ( j = 1; j <= mp1; j++ ) grad[j][i] /= scale[i];
w1110 :
w1100 :      ;
             } /* end for loop 1100 */
         for ( i = 1; i <= mp1; i++ )
             { /* start for loop 1150 */
               jj = n + i;
               g[i] /= scale[jj];
               if (ub[jj] < plinfy)  ub[jj]  /= scale[jj];
	       if (alb[jj] >-plinfy) alb[jj] /= scale[jj];
               for ( j = 1; j <= n; j++ ) grad[i][j] /= scale[jj];
w1160 :
w1150 :      ;
             } /* end for loop 1150 */
       }  /* endif doscale == 1 */
/*08/1991 thru 11/1991*/

    if ( ninf != 0 ) g[nobj] = objbst;
    if ( maxim == 0 ) goto w100;
    for ( i=1; i<=n; i++ )   grad[nobj][i] = -grad[nobj][i];

    /*    MORE INITIALIZATION  */
w100 :
    for ( i=1; i<=n; i++ )  {
	icols[i] = i;
	if ( ifix[i] == 1 )  icols[i] = 0;

	/*  SET DISTANCES OF VARIABLES FROM NEAREST BOUND  */

	dd = ((x[i]-alb[i]) <= (ub[i]-x[i])) ? (x[i]-alb[i]) : (ub[i]-x[i]);
	if ( dd <= epnewt )  dd = 0.0;
	if ( dd > 1.0e+10) dd = 1.0e+10;
	dbnd[i] = dd;
    }
    if ( ipr >= 5 )  {
	fprintf ( ioout, "\n\n" );
	for ( i=1; i<=n; i++ )
	    fprintf (ioout, "DBND[%d] = %e\n", i, dbnd[i]);
    }
    npnb = n + nb;
    if ( nb == 0 )  goto w430;
    for ( i=1; i<=nb; i++ )   {
	ibv[i] = 0;
	j = n + i;
	dbnd[j] = 0.0;
	cnorm[j] = 1.0;
	inorm[j] = i;
	icols[j] = j;
    }
    /*	FILL IN binv WITH GRADIENTS OF BINDING CONSTRAINTS  */

    if ( ipr >= 5 )  fprintf ( ioout, "BINV IS\n" );
    for ( i=1; i<=nb; i++ ) {
	ii = ibc[i];
	for ( j=1; j<=n; j++ ) binv[i][j] = grad[ii][j];
	if ( ipr >= 5 )  {
	    for ( j=1; j<=n; j++ )
		fprintf ( ioout, "%e\n", binv[i][j] );
	}
    }

    /*	START MAIN PIVOT LOOP.	NO RETURN TO ABOVE HERE.  */
w150 :
    jpiv = 0;
    if ( bschng == 1 )	goto w185;
    if ( slack == 1 )	goto w235;

    /*	CASE 1 NO bschng DO REGULAR PIVOTS ON OLD BASICS   */
    /*	EXCLUDING SLACK VARIABLES			   */
    /*	FOR UNPIVOTED ROWS AND UNPIVOTED COLUMNS OF binv,  */
    /*	FIND LARGEST ABSOLUTE ELEMENT.			   */

    eltmax = 0.0;
    for ( jjj=1; jjj<=nb; jjj++ )  {
	j = icand[jjj];
	if ( j == 0 || j > n )	goto w180;
	for ( i=1; i<=nb; i++ )   {
	    if ( ibv[i] != 0 )	goto w170;
	    c = fabs(binv[i][j]);
	    if ( c <=eltmax )  goto w170;
	    eltmax = c;
	    jpiv = j;
	    inorm[j] = i;
	    jjjt = jjj;
w170 :	    ;
	}
w180 :	;
    }
    if ( npiv != 0 )  goto w181;
    bigelt = eltmax;
    if ( ipr > 3 )
	fprintf ( ioout, "THE LARGEST ELEMENTIN OLD BASIC COLUMNS IS %e\n", bigelt );
    if ( bigelt <= epspiv )  goto w183;
w181 :

    /*	PIVOT ON eltmax IF LARGE ENOUGH, OTHERWISE EXPAND SELECTION  */
    /*	TO INCLUDE ALL VARIABLES				     */

    if ( lv != 0 && eltmax > 1.0e-15 )	goto w182;
    if ( eltmax < bigelt * epspiv && eltmax < epspiv )	goto w183;
w182 :
    icand[jjjt] = 0;
    goto w270;
w183 :
    if ( ipr >= 4 ) {
	fprintf ( ioout, "BASIC CANDIDATE LIST EXPANDED BECAUSE ELTMAX = %e\n", eltmax );
	fprintf ( ioout, "                                  AND BIGELT = %e\n", bigelt );
    }
    bschng = 1;
w185 :
    eltmax = 0.0;
    for ( j=1; j<=n; j++ )  {
	cnorm[j] = 0.0;
	if ( icols[j] != j )  goto w200;
	imax = 0;
	cmax = 0.0;
	for ( i=1; i<=nb; i++ )  {
	    if ( ibv[i] != 0 ) goto w190;

	    /*	EXAMINE ONLY UNPIVOTED ROWS  */

	    c = fabs(binv[i][j]);
	    if ( c < cmax ) goto w190;
	    cmax = c;
	    imax = i;
w190 :	    ;
	}
	cnorm[j] = cmax;
	inorm[j] = imax;
	if ( cmax <= eltmax )  goto w200;
	eltmax = cmax;
w200 :	;
    }
    if ( npiv == 0 )  bigelt = eltmax;
    if ( ipr < 5 )  goto w205;
    fprintf ( ioout, "CNORM IS\n");
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "%e\n", cnorm[i] );
    fprintf ( ioout, "INORM IS\n");
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "%d\n", inorm[i] );
w205 :
    if ( bigelt < 1.0e-10 )  goto w235;
    if ( eltmax < bigelt * epspiv && eltmax < epspiv )	goto w235;

    /*	SELECT VARIABLE WITH LARGEST PIVOT VALUE BUT WHICH IS  */
    /*	AT LEAST TEN TIMES epnewt FROM ITS NEAREST BOUND       */

W210 :
    jpiv = 0;
    cmax = 0.0;
    for ( jcol=1; jcol<=n; jcol++ )  {
	if ( icols[jcol] != jcol )  goto w220;
	if ( dbnd[jcol] < 10.0* epnewt )  goto w220;
	if ( cnorm[jcol] <= cmax )  goto w220;
	jpiv =jcol;
	cmax = cnorm[jcol];
w220 :	;
    }
    if ( cmax < epspiv && cmax < epspiv * eltmax ) jpiv = 0;
    if ( jpiv != 0 )  goto w270;

    /*	MUST SELECT VARIABLE CLOSER TO BOUND.  TRY FURTHEST FROM  */
    /*	BOUND WITHIN FACTOR OF eltmax.	NOTE WILL ALWAYS GET ONE  */
    /*	IE WITH eltmax						  */

    dmax = 0.0;
    for ( jcol=1; jcol<=n; jcol++ )  {
	if ( icols[jcol] != jcol )  goto w230;
	if ( cnorm[jcol] <= 0.01 * eltmax )  goto w230;
	if ( dbnd[jcol] < dmax )  goto w230;
	jpiv = jcol;
	dmax = dbnd[jcol];
w230 :	;
    }
    goto w270;

    /*	MUST SELECT A SLACK AS BASIC VARIABLE  */

w235 :
    for ( i=1; i<=nb; i++ )
	if ( ibv[i] == 0 )  goto w245;
w245 :
    jpiv = i + n;
    slack = 1;
    if ( ipr >= 5 )
	fprintf ( ioout, "PIVOT ON SLACK  , %d", jpiv );

    /*	PIVOT TO UPDATE binv  */

w270 :
    irow = inorm[jpiv];
    jcol = jpiv;
    if ( jpiv > n )  goto w340;

    /*	PIVOT COLUMN IS NON-SLACK  */

    piv = binv[irow][jpiv];
    if ( ipr >= 5 )  {
	fprintf ( ioout, "PIVOT ROW IS  %d\n", irow );
	fprintf ( ioout, "PIVOT COLUMN IS  %d\n", jpiv );
	fprintf ( ioout, "PIV = %e\n", piv );
    }
    for ( i=1; i<=nb; i++ )  {
	rr[i] = binv[i][jpiv];
	binv[i][jpiv] = 0.0;
    }
    if ( ipr >= 5 )  {
	fprintf ( ioout, " RR = \n" );
	for ( i=1; i<=nb; i++ )  fprintf ( ioout, "%e\n", rr[i] );
    }
    binv[irow][jpiv] = 1.0;
    for ( j=1; j<=n; j++ )   binv[irow][j] = binv[irow][j] / piv;
    for ( i=1; i<=nb; i++ )  {
	if ( i == irow )  goto w330;
	r = rr[i];
	for ( j=1; j<=n; j++ )	 binv[i][j] = binv[i][j] - r * binv[irow][j];
w330 :	;
    }

    /*	UPDATE COLUMN STATUS BY SWAPPING PIVOT COLUMN WITH UPDATED   */
    /*	SLACK PLUS OTHER BOOKKEEPING FOR CASE OF PIVOT IN NON-SLACK  */
    /*	OR UPDATED SLACK COLUMN 				     */
    /*	SET dbnd OF BASICS TO 0 TO SIMPLIFY DETERMINATION OF SUPERBASICS  */

    dbnd[jpiv] = 0.0;
    j = icols[jpiv];
    ibv[irow] = j;
    i = n + irow;
    icols[jpiv] = icols[i];
    icols[i] = j;
    goto w360;

    /*	NON-UPDATED SLACK COLUMN PIVOT LOGIC  */

w340 :
    for ( j=1; j<=n; j++ )   binv[irow][j] = -binv[irow][j];
    ibv[irow] = jpiv;
w360 :
    if ( ipr < 5 )  goto w368;
    fprintf ( ioout, "ICOLS IS\n");
    for ( j=1; j<=npnb; j++ )	fprintf ( ioout, " %d\n", icols[j] );
    fprintf ( ioout, "IBV IS\n");
    for ( j=1; j<=nb; j++ )  fprintf ( ioout, " %d\n", ibv[j] );
    if ( ipr < 6 )  goto w368;
    fprintf ( ioout, "THE LARGEST ELEMENT IN OLD BASIC COLUMNS IS :\n");
    for ( i=1; i<=nb; i++ )  {
	for ( j=1; j<=n; j++ )
	  fprintf ( ioout, "  %e\n", binv[i][j]);
    }
w368 :
    npiv++;

    /*	IF HAVE NOT MADE nb PIVOTS GET ANOTHER PIVOT COLUMN  */

    if ( npiv < nb )  goto w150;

    /*	ALL PIVOT DONE.  NOW REARRANGE COLUMNS TO GET INVERSE.	*/
    /*	NOW LOOK FOR SLACK COLUMNS WHICH WERE UPDATED BY PIVOT	*/
    /*	IN ROW J,  J = 1,...,NB SINCE THESE WILL FORM BINV.	*/

    for ( j=1; j<=nb; j++ )  {
	jj = n + j;

	/*  PROCESS NON-SLACK COLUMNS FIRST  */

	for ( i=1; i<=n; i++ )	{
	    ii = icols[i];
	    if ( ii != jj )  goto w380;

	    /*	NOW SWAP COLUMN I AND J  */

	    for ( k=1; k<=nb; k++ )  {
		tmp = binv[k][j];
		binv[k][j] = binv[k][i];
		binv[k][i] = tmp;
	    }
	    icols[i] = icols[j];
	    icols[j] = 0;
	    goto w381;
w380 :	    ;
	}
w381 :	;
    }
    if ( ipr3 >= 4 )  {
	fprintf ( ioout, "ICOLS IS :\n");
	for ( k=1; k<=npnb; k++ )  fprintf ( ioout, " %d\n", icols[k] );
    }

    /*	NOW TO PROCESS SLACK  */

    for ( j=1; j<=nb; j++ )  {
	jj = n + j;
	for ( i=1; i<=nb; i++ )  {
	    ii = n + i;
	    ii = icols[ii];
	    if ( ii != jj )  goto w390;

	    /*	NOW HAVE FOUND SLACK.  GET + OR - UNIT VECTOR.	*/

	    for ( k=1; k<=nb; k++ )  binv[k][j] = 0.0;

	    /*	IF UPDATED SLACK, GET NEGATIVE VECTOR  */

	    if ( i != j )  goto w385;
	    binv[j][j] = -1.0;
	    goto w400;
w385 :
	    /*	UPDATED SLACK -- GET AN UNIT VECTOR  */

	    binv[i][j] = 1.0;
w390 :	    ;
	}
w400 :	;
    }
    /*	 <<<<<<<<  binv NOW COMPLETED  >>>>>>>>    */

    if ( ipr < 5 ) goto w430;
    fprintf ( ioout, "BINV IS :\n");
    for ( i=1; i<=nb; i++ )  {
	for ( j=1; j<=nb; j++ )
	    fprintf ( ioout, "BINV[%d][%d] = %e\n", i, j, binv[i][j] );
    }

    /*	SET UP INDEX SET OF NONBASIC VARIABLES, SUPERBASICS  */
    /*	FIRST AND NONBASIC SLACKS LAST	*/

w430 :
    /*	STORE OLD SUPERBASICS  */

    nspold = nsuper;
    if ( nspold == 0 )	goto w437;
    for ( i=1; i<=nspold; i++ )  ibcold[i] = inbv[i];
w437 :
    for ( i=1; i<=npnb; i++ )  icols[i] = 0;
    if ( nb == 0 )  goto w448;
    for ( i=1; i<=nb; i++ )   {
	j = ibv[i];
	icols[j] = 1;
    }

    /*	REINDEX SLACKS IN IBV  */

    for ( i=1; i<=nb; i++ )  {
	j = ibv[i];
	icand[i] = j;
	if ( j > n )  j = n + ibc[j-n];
	ibv[i] = j;
    }
w448 :
    /*	DO NONBASIC SLACKS  */

    ibctr = n;
    ictrb = n + nb;
    if ( nb == 0 )  goto w470;
    for ( i=1; i<=nb; i++ )  {
	k = n + i;
	if ( icols[k] == 1 ) goto w460;
	icand[ictrb] = k;
	ictrb--;
	k = n + ibc[i];
	inbv[ibctr] = k;
	ibctr--;
w460 :	;
    }

    /*	HANDLE REST OF NONBASICS  */

w470 :
    icsupe = nb;
    nsuper = 0;
    for ( i=1; i<=n; i++ )   {
	if ( icols[i] == 1 )  goto w490;
	if ( dbnd[i] > 0.0 )  goto w480;
	inbv[ibctr] = i;
	ibctr--;
	icand[ictrb] = i;
	ictrb--;
	goto w490;
w480 :
	/*  SUPERBASIC VARIABLES  */

	icsupe++;
	icand[icsupe] = i;
	nsuper++;
	inbv[nsuper] =i;
w490 :	;
    }
    for ( i=1; i<=n; i++ )  {
	iub[i] = 0;
	k = inbv[i];
	if ( fabs(x[k]-ub[k]) <= epnewt )  iub[i] = 1;
	if ( fabs(x[k]-alb[k]) <= epnewt ) iub[i] = -1;
    }
    lv = 0;
    sbchng = 1;
    if ( nsuper != nspold || nsuper == 0 )  goto w498;
    for ( i=1; i<=nsuper; i++ )  {
	ii = inbv[i];
	for ( j=1; j<=nspold; j++ )
	    if ( ibcold[j] == ii )  goto w497;
	goto w498;
w497 :	;
    }
    sbchng = 0;
w498 :
    if ( ipr3 < 2 )  return;
    fprintf ( ioout, "NUMBER OF SUPER BASICS = %d \n", nsuper );
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "INBV[%d] = %d\n", i, inbv[i] );
    for ( i=1; i<=n; i++ )  fprintf ( ioout, "IUB[%d] = %d\n", i, iub[i] );
    if ( nb > 0 )
	for ( i=1; i<=nb; i++ )
	    fprintf ( ioout, "IBV[%d] = %d\n", i, ibv[i] );
    if ( ipr >= 5 )  fprintf ( ioout, "\n====  CONSBS COMPLETED  ====\n");
    return;

    /*	NUMBER OF BINDING CONSTRAINTS TOO LARGE  */

w500 :
    fprintf ( ioout, "\nDIMENTIONS WILL BE EXCEEDED BY NUMBER OF BINDING " );
    fprintf ( ioout, "CONSTRAINTS =  %d\n", nb );
    exit(10);
}

void parsh( void )  {
    fprintf ( ioout, "\nATTEMPT TO USE THE DUMMY PARSH SUBROUTINE\n");
}

void parshc ( void ) {

    /*	  THIS SUBROUTINE COMPUTES FINITE DIFFERENCE DERIVATIVES    */
    /*	  BY CENTRAL DIFFERENCING				    */

    /*	  Local Declarations   */

    double dx, ts;
    int  i, l;
    int  fail1;    /* logical --- not used  */

    for ( i=1; i<=n; i++ ) {
	if ( ifix[i] != 0 )  goto w160;
	dx = fabs(x[i]) * pstep;
	if ( dx < 0.1e0 * pstep )  dx = 0.1e0 * pstep;
	ts = x[i];
	x[i] = x[i] + dx;
	gcomp( gg, x );

	x[i] = ts - dx;
	gcomp( gbest, x );

	for ( l=1; l<=mp1; l++ )
	    grad[l][i] = ( gg[l] - gbest[l] ) / ( dx * 2.0e0 );
	x[i] = ts;
	goto w200;
w160 :
	for ( l=1; l<=mp1; l++ )
	    grad[l][i] = 0.0e0;
w200 :	;
     }
     return;
 }

void parshf ( double g[zmp1], double x[zn]  )  {

    /*	  THIS SUBROUTINE COMPUTES FINITE DIFFERENCE DERIVATIVES    */
    /*	  BY FORWARD DIFFERENCING.				    */

    /*	  Local Declations    */

    double dx, ts, tmp;
    int    i, j;

    tmp = g[nobj];
    if ( maxim == 1 )  tmp = -tmp;
    if ( ninf != 0 )   tmp = truobj;
    for ( i=1; i<=n; i++ )  {
	if ( ifix[i] != 0 )  goto w160;
	dx = fabs(x[i]) * pstep;
	if ( dx < pstep * 0.1e0 )  dx = pstep * 0.1;
	ts = x[i];
	if ( (ub[i] - ts) < dx )  dx = -dx;
	x[i] = x[i] + dx;
	gcomp( gg, x );
	for ( j=1; j<=mp1; j++ )
	    grad[j][i] = ( gg[j] -g[j] ) / dx;
	grad[nobj][i] = ( gg[nobj] - tmp ) / dx;
	x[i] = ts;
	goto w200;
w160 :
	for ( j=1; j<=mp1; j++ )  grad[j][i] = 0.0e0;
w200 :	;
    }
    return;
}
