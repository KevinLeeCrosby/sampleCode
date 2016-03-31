/***********************/
/*    File INITLZ.C    */
/*        initlz(),    */
/*	  setup().     */
/*        dump()       */
/*        tablin()     */
/*        report()     */
/***********************/

#include "gvar.h"
#include <stdio.h>
#include <string.h>

void gcomp (double g[zmp1], double x[znpmp1]);

/*================*/
/*    INITLZ	  */
/*================*/
void initlz()
{
/*  SET MACHINE DEPENDENT PARAMETERS */
/*  EPS IS MACHINE ACCUACY FOR DOUBLE PRECISION VARIABLES.  */
/*  PLINFY IS 'PLUS INFINITY' FOR GIVEN MACHINE.  */
/*  PLZERO IS POSITIVE VALUE NEAREST ZERO W/O BEING ZERO ON MACHINE.  */

eps = 1.0e-15;
plinfy = 1.0e30;
plzero = 1.0e-30;
tolz = eps;
tolx = 1.0e-6;

}   /*  End Of initlz()  */


/*=================*/
/*	SETUP	   */
/*=================*/
void setup ()
{

/*  CHECK FOR VALID VALUES FOR NVARS AND NROWS */

    if ( nvars <= 0 || nvars >= 1000 ) {
	printf ("\nNUMBER OF VARIABLES IS %d", nvars);
	printf ("\nNUMBER OF ROWS IS %d", nrows);
	printf ("\nMAXR IS %d", maxr);
	printf ("\nCEILING ON BINDING CONSTRAINTS IS %d", maxb);
	printf ("\n\nIMPROPER VALUE OF NVARS!!");
	exit(9);
    }
    else if (nrows <= 0 || nrows >= 1000 ) {
	printf ("\nNUMBER OF VARIABLES IS %d", nvars);
	printf ("\nNUMBER OF ROWS IS %d", nrows);
	printf ("\nMAXR IS %d", maxr);
	printf ("\nCEILING ON BINDING CONSTRAINTS IS %d", maxb);
	printf ("\n\nIMPROPER VALUE OF NROWS!!");
	exit(9);
    }
    else {

	/*  COMPUTE VARIOUS VARIABLES  */

	n = nvars;
	mp1 = nrows;
	m = mp1 - 1;
	if ( m == 0 ) m = 1;
	npmp1 = n + mp1;
	nbmax = maxb;
	if ( nbmax <= 0 || nbmax > m ) nbmax = m;
	if ( maxr <= 0 || maxr > n ) maxr = n;
	nnbmax = n;
	if ( nbmax > n ) nnbmax = nbmax;
	}
}   /*  End Of setup()  */


void dump (void)
{

	/*    IT PROVIDES THE DUMP FILE FOR RESTARTING;      */
	/*    A VALUE FOR IODUMP, GIVING THE OUTPUT UNIT,    */
	/*	MUST HAVE BEEN INITIALIZE IN MAIN.	     */

/*    LOCAL DECLARATION     */

    int i, hi, lo;
/*08/1991 thru 11/1991*/
    char *im[15];
/*08/1991 thru 11/1991*/
    char *blanks;

/*    DATA STATEMENT	*/

    blanks = "       ";
    im[0]  = "TAN";
    im[1]  = "QUA";
    im[2]  = "ANA";
    im[3]  = "FDF";
    im[4]  = "CG1";
    im[5]  = "CG2";
    im[6]  = "CG3";
    im[7]  = "CG4";
    im[8]  = "CG5";
    im[9]  = "FDC";
    im[10] = "MAX";
    im[11] = "MIN";
    im[12] = "CG0";	/*****/
    im[13] = "DFP";
/*08/1991 thru 11/1991*/
    im[14] = "SCA";
/*08/1991 thru 11/1991*/

/*    PROBLEM SIZE AND PROBLEM NAME    */

    fprintf ( iodump, "%d  %d  %d  %d\n", nvars, nrows, maxr, maxb);
    fprintf ( iodump, "NAME " );
    fputs (title, iodump);


    iodump = fopen ( "a:iodump.dat", "r" );    /********/


/*    EPSILONS	  */

    if ( epinit == 0 ) epinit = epnewt;
    fprintf ( iodump, "EPS\n" );
    fprintf ( iodump, "EPN  %le\nEPI  %le\nEPT  %le\n", epnewt, epinit, epstop );
    fprintf ( iodump, "EPP  %le\nPH1  %le\nDEL  %le\n", epspiv, ph1eps, pstep );
    fprintf ( iodump, "END\n");

/*    ITERATION LIMITS AND PRINT CONTROLS    */

    fprintf ( iodump, "LIM\nNST  %d\nITL  %d\nSEA  %d\nEND\n", nstop, itlim, limser );
    fprintf ( iodump, "PRI\nIPR  %d\nPN5  %d\nPN4  %d\n", ipr, ipn5, ipn4 );
    fprintf ( iodump, "PER  %d\nPN6  %d\nEND\n", iper, ipn6 );

/*    METHODS SECTION	 */

    fprintf ( iodump, "MET\n" );
    if (iquad == 0)	    fprintf (iodump, "%s\n", im[0]);
    if (iquad == 1)	    fprintf (iodump, "%s\n", im[1]);
    if (kderiv == 1)	    fprintf (iodump, "%s\n", im[9]);
    if (kderiv == 2)	    fprintf (iodump, "%s\n", im[2]);
    if (kderiv == 0)	    fprintf (iodump, "%s\n", im[3]);
    if (maxrm == 0)	    fprintf (iodump, "%s\n", im[12]);
    if (maxrm == maxr)	    fprintf (iodump, "%s\n", im[13]);
    if (modcg == 1)	    fprintf (iodump, "%s\n", im[4]);
    if (modcg == 2)	    fprintf (iodump, "%s\n", im[5]);
    if (modcg == 3)	    fprintf (iodump, "%s\n", im[6]);
    if (modcg == 4)	    fprintf (iodump, "%s\n", im[7]);
    if (modcg == 5)	    fprintf (iodump, "%s\n", im[8]);
    if (maxim == 1)	    fprintf (iodump, "%s\n", im[10]);
    if (maxim == 0)	    fprintf (iodump, "%s\n", im[11]);
/*08/1991 thru 11/1991*/
    if (doscale == 1)         fprintf (iodump, "%s\n", im[14]);
/*08/1991 thru 11/1991*/
    fprintf ( iodump, "END\n" );

/*    FUNCTION NAMES	*/

    fprintf ( iodump, "FUN\n" );
    for ( i=1; i<=nrows; i++ )
	if ( strncmp (con[i], blanks, 3) != 0 )
	    fprintf (iodump, "%s    %d\n", con[i], i);
    fprintf ( iodump, "END\n" );

/*    VARIABLE NAMES	*/

    fprintf ( iodump, "VAR\n" );
    for ( i=1; i<=nvars; i++ )
	if ( strncmp (var[i], blanks, 3) != 0 )
	    fprintf (iodump, "%s    %d\n", var[i], i);
    fprintf ( iodump, "END\n" );

/*    SPECIFICATION OF BOUNDS	 */

    fprintf ( iodump, "BOU\n" );
    lo = 1;
    hi = 1;
    for ( i=1; i<=nvars; i++ )
	if ( i >= hi )	{
	    lo = i;
	    hi = lo;
	    if ( ifix[i] == 0 )  goto wd210;
    wd201 :
	    hi++;

    /*	  EQUALITY CONSTRAINTS -- VARIABLES    */

	    if (alb[lo] == alb[hi] && hi < nvars )  goto wd201;
	    if (alb[lo] == alb[hi] && hi == nvars )  goto wd205;
	    if ((lo+1) != hi)  goto wd203;
	    fprintf (iodump, " E   %d  %le  %le\n", i, alb[i], ub[i] );
	    goto wd200;
    wd203 :
	    hi--;
    wd205 :
	    fprintf (iodump, " E   %d  %d  %le  %le\n", lo, hi, alb[lo], ub[hi]);
	    hi++;
	    goto wd200;
    wd210 :  ;

    /*	  RANGE CONSTRAINTS -- VARIABLES    */

    wd211 :
	    hi++;
	    if (alb[lo] == alb[hi] && ub[lo] == ub[hi] &&
		hi < nvars )	goto wd211;
	    if (alb[lo] == alb[hi] && ub[lo] == ub[hi] &&
		hi == nvars )	goto wd215;
	    if ((lo+1) != hi)	goto wd213;
	    fprintf (iodump, " R    %d  %le  %le\n", i, alb[i], ub[i]);
	    goto wd200;
    wd213 :
	    hi--;
    wd215 :
	    fprintf (iodump, " R    %d  %d  %le  %le\n", lo, hi, alb[lo], ub[lo]);
	    hi++;
    wd200 :
	    ;
	}
	fprintf (iodump, "END\n" );

/*    SPECIFICATION OF ROWS    */

    fprintf (iodump, "ROW\n" );
    lo = 1;
    hi = 1;
    for ( i=1; i<=nrows; i++ ) {
	if ( i < hi )	goto wd300;
	lo = i;
	hi = lo;

    /*	  CHECK FOR OBJECTIVE FUNCTION	  */

	if ( i != nobj )  goto wd301;
	fprintf (iodump, " O    %d  %le  %le\n", i, alb[n+i], ub[n+i] );
	goto wd300;
    wd301 :
	if (istat[i] != 2 )  goto wd310;

    /*	  RANGE CONSTRAINTS -- FUNCTIONS    */

    wd302 :
	hi++;
	if ( alb[n+lo] == alb[n+hi] && ub[n+lo] == ub[n+hi] &&
	    hi < nrows )   goto wd302;
	if ( alb[n+lo] == alb[n+hi] && ub[n+lo] == ub[n+hi] &&
	    hi == nrows )  goto wd305;
	if ( (lo+1) != hi )  goto wd303;
	fprintf (iodump, " R    %d  %le  %le\n", i, alb[n+i], ub[n+i] );
	goto wd300;
    wd303 :
	hi--;
    wd305 :
	if ( nobj == mp1 && hi == nrows )  hi--;
	fprintf (iodump, " R    %d  %d  %le  %le\n", lo, hi, alb[n+lo], ub[n+lo]);
	hi++;
	goto wd300;
    wd310 :
	if ( istat[i] != 1 )  goto wd320;

    /*	  EQUALITY CONSTRAINTS -- FUNCTIONS    */

    wd311 :
	hi++;
	if (alb[n+lo] == alb[n+hi] && hi < nrows)  goto wd311;
	if (alb[n+lo] == alb[n+hi] && hi == nrows)  goto wd315;
	if ((lo+1) != hi)  goto wd313;
	fprintf (iodump, " E    %d  %le  %le\n", i, alb[n+i], ub[n+i]);  /*!!!!*/
	goto wd300;
    wd313 :
	hi--;
    wd315 :
	if (nobj == mp1 && hi == nrows)  hi--;
	fprintf (iodump, " E    %d  %d  %le  %le\n", lo, hi, alb[n+lo], ub[n+hi]);
	hi++;
	goto wd300;

    /*	  IGNORE FUNCTION    */

    wd320 :
	hi++;
	if (istat[hi] == 0 && hi < nrows)  goto wd320;
	if (istat[hi] == 0 && hi == nrows) goto wd325;
	if ((lo+1) != hi)  goto wd323;
	fprintf (iodump, " N    %d\n", i);
	goto wd300;
    wd323 :
	hi--;
    wd325 :
	if (nobj == mp1 && hi == nrows)  hi--;
	fprintf (iodump, " N    %d  %d\n", lo, hi );
	hi++;
    wd300 :  ;
    }
    fprintf ( iodump, "END\n");

/*    INITIAL VARIABLES SECTION    */

    fprintf (iodump, "INI\nTOG\n");
    for ( i=1; i<=nvars; i++ )  fprintf (iodump, "%le\n", x[i]);

/*    INSERT "GO", "STOP"    */

    fprintf (iodump, "GO\nSTOP\n");
    fclose ( iodump );

/*       end of dump()       */
}

void tablin ()
{

/*  Local Declarations & Data Statements  */

    double  gi, cons1;
    int     i, ni;
    char    *status, *litst[7], *itype[6], *temp;

    litst[0] = "UL  ";
    litst[1] = "LL  ";
    litst[2] = "EQ  ";
    litst[3] = "****";
    litst[4] = "    ";
    litst[5] = "FREE";
    litst[6] = "FX  ";

    itype[0] = "EQ  ";
    itype[1] = "LE  ";
    itype[2] = "GE  ";
    itype[3] = "RNGE";
    itype[4] = "OBJ ";
    itype[5] = "NA  ";

    gcomp(g, xo);
    for ( i=1; i<=mp1; i++ )  go[i] = g[i];

    if ( ipr3 < -1 )  goto w935;

    /*	  PRINT INITIAL TABLE	 */

    fprintf (ioout,
"\f                    OUTPUT OF INITIAL VALUES \n\n");
    fputs (title, ioout);
    fprintf (ioout,
"\nSECTION 1 -- FUNCTIONS \n");
    fprintf (ioout,
"      FUNCTION                     INITIAL        LOWER        UPPER\n");
    fprintf (ioout,
"NO.     NAME     STATUS  TYPE       VALUE         LIMIT        LIMIT\n");
    fprintf (ioout,
"___   ________   ______  ____     _________     _________     _________\n\n");
    for (i=1; i<=mp1; i++)
    {
	ni = n + i;
	gtype[i] = itype[3];
	if (alb[ni] == ub[ni])   gtype[i] = itype[0];
	if (alb[ni] != -plinfy && ub[ni] != plinfy) goto w825;
	if (alb[ni] == -plinfy && ub[ni] == plinfy) goto w820;
	if (alb[ni] != -plinfy)  gtype[i] = itype[2];
	if (ub[ni] != plinfy)    gtype[i] = itype[1];
	goto w825;
w820 :
	gtype[i] = itype[5];
w825 :	;
    }
    gtype[nobj] = itype[4];
    for (i=1; i<=mp1; i++) {
	ni = n + i;
	gi = g[i];
	strcpy(temp, con[i]);
	status = litst[4];
	if (istat[i] == 1)  goto w840;
	if (istat[i] == 0)  goto w830;
	if (fabs(gi - ub[ni]) < epinit)  status = litst[0];
	if (fabs(alb[ni] - gi) < epinit)  status = litst[1];
	if (gi > ub[ni]+epinit || gi < alb[ni]-epinit)  status = litst[3];
	goto w860;
w830 :
	fprintf (ioout,
	"%3d%11s   %3s    %4s %12.6lg \n",
	i, temp, status, gtype[i], g[i] );
	goto w890;
w840 :
	if (fabs(gi - alb[ni]) < epinit)  goto w850;
	status = litst[3];
	goto w860;
w850 :
	status = litst[2];
w860 :
	if (ub[ni] == plinfy)  goto w870;
	if (alb[ni] == -plinfy)  goto w880;
	fprintf (ioout,
	"%3d%11s   %3s    %4s %12.6lg%15.6lg%15.6lg\n",
	     i, temp, status, gtype[i], g[i], alb[ni], ub[ni]);
	goto w890;
w870 :
	fprintf (ioout,
	"%3d%11s   %3s    %4s %12.6lg%15.6lg          NONE\n",
	     i, temp, status, gtype[i], g[i], alb[ni]);
	goto w890;
w880 :
	fprintf (ioout,
	"%3d%11s   %3s    %4s %12.6lg          NONE %15.6lg\n",
	i, temp, status, gtype[i], g[i], ub[ni]);
w890 :	;
    }
    fprintf (ioout, "\n\n\nSECTION 2 -- VARIABLES\n\n");
    fprintf (ioout,
"      VARIABLE                     INITIAL        LOWER         UPPER\n");
    fprintf (ioout,
"NO.     NAME     STATUS             VALUE         LIMIT         LIMIT\n");
    fprintf (ioout,
"___   ________   ______           _________     _________     _________\n\n");
    for (i=1; i<=n; i++)  {
	strcpy(temp, var[i]);
	status = litst[4];
	if (alb[i] == x[i])  status = litst[1];
	if (ub[i] == x[i])   status = litst[0];
	if (ifix[i] == 1 || alb[i] == ub[i])  status = litst[6];
	if (alb[i] == -plinfy && ub[i] == plinfy)  goto w900;
	if (alb[i] == -plinfy)	goto w910;
	if (ub[i] == plinfy)  goto w920;
	fprintf (ioout,
	"%3d%10s    %4s        %12.6lg  %12.6lg  %12.6lg\n",
	i, temp, status, x[i], alb[i], ub[i]);
	goto w930;
w900 :
	status = litst[5];
	fprintf (ioout,
	"%3d%10s    %4s        %12.6lg         NONE          NONE\n",
	i, temp, status, x[i]);
	goto w930;
w910 :
	fprintf (ioout,
	"%3d%10s    %4s        %12.6lg         NONE  %12.6lg\n",
	i, temp, status, x[i], ub[i]);
	goto w930;
w920 :
	fprintf (ioout,
	"%3d%10s    %4s        %12.6lg  %12.6lg        NONE\n",
	i, temp, status, x[i], alb[i]);
w930 :	;
	}
    fprintf (ioout, "\n\n");
w935 :
    if (maxim == 1) g[nobj] = -g[nobj];
    return;

/*       end of tablin()     */
}

void report() {

    /*      This is a dummy routine to be replaced by the user    */

}
