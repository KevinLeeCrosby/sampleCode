/*******************************/
/*     File DATAIN.C           */
/*    includes datain()        */
/*   Not used with the         */
/*  subroutine interface.      */
/*******************************/


#include "gvar.h"
#include <stdio.h>
#include <string.h>

void gcomp (double g[zmp1], double x[znpmp1]);

void datain ( int *stop2 )
{
 /*  THIS SUBROUTINE READS INITIAL DATA FOR GRG  */

 /*  Local Declations & Data Statements  */

    int i, i1, j, is, input_int, isk, is1, is2;
    int revise_step, iflag, error_count;
    int dumped = 0;	  /*  Logical  */
    char temp[10];
    char *ik[7];
    char ii[11], *iss[12], *ie[6];
    char *il[3], *ip[5];
    char *im[15];

    char blanks[11]      = "          ";
    char end_cmnd[]      = "END";
    char stop_cmnd[]     = "STO";
    char dump_cmnd[]     = "DUM";
    char name[]          = "NAM";
    char revise_cmnd[]   = "REV";
    char separate_cmnd[] = "SEP";
    char together_cmnd[] = "TOG";
    char ix0[]           = "X0";
    char ixo[]           = "XO";

    ie[0]  = "EPN";
    ie[1]  = "EPI";
    ie[2]  = "EPT";
    ie[3]  = "EPP";
    ie[4]  = "PH1";
    ie[5]  = "DEL";

    iss[0] = "ROW";
    iss[1] = "BOU";
    iss[2] = "INI";
    iss[3] = "EPS";
    iss[4] = "LIM";
    iss[5] = "PRI";
    iss[6] = "MET";
    iss[7] = "BAS";
    iss[8] = "GO";
    iss[9] = "FUN";
    iss[10]= "VAR";
    iss[11]= "DUM";

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
    im[12] = "CG";   /*****/
    im[13] = "DFP";
    im[14] = "SCA";

    ik[0]  = "E";
    ik[1]  = "G";
    ik[2]  = "L";
    ik[3]  = "N";
    ik[4]  = "O";
    ik[5]  = "R";
    ik[6]  = "0";

    il[0]  = "NST";
    il[1]  = "ITL";
    il[2]  = "SEA";

    ip[0]  = "IPR";
    ip[1]  = "PN5";
    ip[2]  = "PN4";
    ip[3]  = "PER";
    ip[4]  = "PN6";

    /*	READ AND ECHO BACK INPUT DATA.	*/
    /*  ACCEPTS BOTH ORIGINAL AND REVISE INPUT FILES.  */

    revise_step = 0;
    error_count = 0;
    iflag = 0;
w10 :
    fgets(dataline, 81, ioin);
    sscanf(dataline, "%10s", ii);

    /*	CHECK TO SEE IF FIRST CARD IS 'STOP', OR 'REVISE', OR 'DUMP'  */

    if ( strncmp(ii, dump_cmnd, 3) == 0 )  goto w785;
    if ( strncmp(ii, stop_cmnd, 3) == 0 ||
		strncmp(ii, blanks, 3) == 0 ) *stop2 = 1;
    if ( *stop2 == 0 )	goto w20;
    return;
w20 :
    if ( strncmp(ii, revise_cmnd, 3) != 0 ) goto w25;
    revise_step = 1;
    goto w10;
w25 :
    if ( strncmp(ii, name, 3) != 0 && revise_step  )  goto w45;
    if ( strncmp(ii, name, 3) != 0 )  goto w40;
    strcpy(title, dataline + 5 );
    goto w45;
w40 :
    strcpy(title, blanks);
w45 :
    fprintf (ioout,"\n%s",title);
    maxb = nbmax;
    fprintf (ioout,"\nNUMBER OF VARIABLES IS %d", nvars);
    fprintf (ioout,"\nNUMBER OF FUNCTIONS IS %d", nrows);
    fprintf (ioout,"\nSPACE RESERVED FOR HESSIAN HAS DIMENSION %d", maxr);
    fprintf (ioout,"\nLIMIT ON BINDING CONSTRAINTS IS %d.\n", maxb);
    if ( revise_step ) goto w65;

 /*    INITIALIZE BOUNDS ET AL. TO DEFAULT VALUES IF THIS IS NOT A    */
 /*    REVISION 						      */

    for (i=1; i<=n; i++) {
	ifix[i] = 0;
	x[i] = 0.0;
	strcpy(var[i], blanks);
	alb[i] = -plinfy;
	ub[i] = plinfy;
    }

 /*    DEFAULT CONSTRAINTS STATUS IS INEQUALITY GREATER THAN 0	  */

    for (i=1; i<=mp1; i++) {
	istat[i] = 2;
	alb[i+n] = 0.0;
	strcpy(con[i], blanks);
	ub[i+n] = plinfy;
    }
    nobj = mp1;
    maxim = 0;
    modcg = 1;
    eplast = 1.0e-6;
    epstop = 1.0e-6;
    epspiv = 0.001;
    epinit = 0.0;
    ph1eps = 0.0;
    pstep  = 1.0e-7;
    nstop = 3;
    itlim = 10;
    limser = 1000;
    ipr = 1;
    ipr3 = 0;
    ipn4 = 0;
    ipn5 = 0;
    ipn6 = 0;
    iquad = 0;
    iper = 0;
    kderiv = 0;
    maxrm = maxr;
/*08/1991 thru 11/1991*/
    doscale = 0;
/*08/1991 thru 11/1991*/
w65 :
    if ( strncmp(ii, name, 3) != 0 ) goto w80;

 /*    NORMAL SECTION READ    */

w70 :
    fgets(dataline, 81, ioin);
    sscanf(dataline, "%s", ii);
w80 :
    fprintf (ioout, "%s\n", ii);
    if ( strncmp(ii, end_cmnd, 3) == 0 )  goto w70;
    i = 0;
    while ( i < 12 && strncmp(ii, iss[i], 3) != 0) i++;
    if ( i < 12 )   { isk = i; goto w100;}

 /*    PREVIOUS SECTION HEAD PROBABLY IN ERROR SO CONTINUE    */
 /*    READING UNTIL FIND NEW SECTION HEAD		      */

    if ( iflag != 0 ) goto w70;
    goto w1020;
w100 :
    iflag = 0;
    switch ( isk ) {
	case 0 : goto w110;
	case 1 : goto w210;
	case 2 : goto w300;
	case 3 : goto w330;
	case 4 : goto w410;
	case 5 : goto w480;
	case 6 : goto w580;
	case 7 : goto w1020;
	case 8 : goto w790;
	case 9 : goto w750;
	case 10 : goto w770;
	case 11 : goto w785;
    }

 /*    PROCESS ROW SECTION    */

w110 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", ii );
    if ( strncmp(ii, end_cmnd, 3) == 0 )  goto w200;
    sscanf (dataline + 3, " %d %d %le %le", &is1, &is2, &a1, &a2);
    if ( is2 == 0 ) is2 = is1;
    if ( is1 <= 0 || is1 > mp1 ) goto w940;
    if ( is2 > mp1 )  goto w942;
    if ( is2 < is1 )  goto w945;
    i = 0;
    while ( i < 7 && strncmp(ii, ik[i], 1) != 0 ) i++;
    if ( i < 7 )  { j = i;  goto w130; }
    goto w950;
w130 :
    switch ( j )  {
	case 0 : goto w140;
	case 1 : goto w150;
	case 2 : goto w160;
	case 3 : goto w170;
	case 4 : goto w180;
	case 5 : goto w190;
	case 6 : goto w180;
    }

 /*    EQUALITY    */

w140 :
    for ( is=is1; is<=is2; is++)  {
	alb[n+is] = a1;
	ub[n+is]  = a1;
	istat[is] = 1;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1);
    goto w110;

/*    INEQUALITY,  GE	 */

w150 :
    for ( is=is1; is<=is2; is++)  {
	alb[n+is] = a1;
	ub[n+is]  = plinfy;
	istat[is] = 2;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1);
    goto w110;

/*    INEQUAILITY,  LE	  */

w160 :
    for ( is=is1; is<=is2; is++)  {
	alb[n+is] = -plinfy;
	ub[n+is]  = a1;
	istat[is] = 2;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1);
    goto w110;

/*    CONSTRAINT TO BE IGNORED	  */

w170 :
    for ( is=is1; is<=is2; is++)  {
	alb[n+is] = -plinfy;
	ub[n+is]  = plinfy;
	istat[is] = 0;
    }
    fprintf ( ioout, " %s  %d  %d\n", ii, is1, is2);
    goto w110;

/*    OBJECTIVE ROW    */

w180 :
    nobj = is1;
    fprintf ( ioout, " %s  %d\n", ii, is1);
    goto w110;

/*    RANGE INEQUALITY	  */

w190 :
    for ( is=is1; is<=is2; is++)  {
	alb[n+is] = a1;
	ub[n+is]  = a2;
	istat[is] = 2;
	if ( a1 == a2 ) istat[is] = 1;
    }
    fprintf ( ioout, " %s  %d  %d  %le  %le\n", ii, is1, is2, a1, a2);
    if ( a1 > a2 ) goto w970;
    goto w110;
w200 :
    fprintf ( ioout, "%s\n", ii);
    goto w70;

/*    PROCESS BOUNDS SECTION	*/

w210 :
    fgets ( dataline, 81, ioin );
    sscanf( dataline, "%s", ii );
    if ( strncmp(ii, end_cmnd, 3) == 0 )  goto w290;
    sscanf ( dataline + 3, " %d %d %le %le", &is1, &is2, &a1, &a2 );
    if ( is2 == 0 )  is2 = is1;
    if ( is1 <= 0 || is1 > n )	goto w960;
    if ( is2 > n )  goto w962;
    if ( is1 > is2 )  goto w945;
    i = 0;
    while ( i < 6 && strncmp(ii, ik[i], 1) != 0 ) i++;
    if ( i < 6 ) { j = i; goto w230; }
    goto w950;
w230 :
    switch ( j )  {
	case 0 : goto w240;
	case 1 : goto w250;
	case 2 : goto w260;
	case 3 : goto w280;
	case 4 : goto w950;
	case 5 : goto w270;
    }

/*    FIXED    */

w240 :
    for ( is=is1; is<=is2; is++ )  {
	alb[is] = a1;
	ub[is]  = a1;
	ifix[is] = 1;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1 );
    goto w210;

/*    BOUNDED BELOW    */

w250 :
    for ( is=is1; is<=is2; is++ )  {
	alb[is] = a1;
	ub[is]	= plinfy;
	ifix[is] = 0;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1 );
    goto w210;

/*    BOUNDED ABOVE    */

w260 :
    for ( is=is1; is<=is2; is++ )  {
	alb[is] = -plinfy;
	ub[is]  = a1;
	ifix[is] = 0;
    }
    fprintf ( ioout, " %s  %d  %d  %le\n", ii, is1, is2, a1 );
    goto w210;

/*    BOUNDED ABOVE AND BELOW	 */

w270 :
    for ( is=is1; is<=is2; is++ )  {
	alb[is] = a1;
	ub[is]  = a2;
	if ( a1 == a2 ) ifix[is] = 1;
	else ifix[is] = 0;
    }
    fprintf ( ioout, " %s  %d  %d  %le  %le\n", ii, is1, is2, a1, a2 );
    if ( a1 > a2 )  goto w970;
    goto w210;

/*    UNBOUNDED    */

w280 :
    for ( is=is1; is<=is2; is++ )  {
	alb[is] = -plinfy;
	ub[is]	= plinfy;
	ifix[is] = 0;
    }
    fprintf ( ioout, " %s  %d  %d\n", ii, is1, is2 );
    goto w210;
w290 :
    fprintf ( ioout, "%s\n", ii );
    goto w70;

/*    PROCESS INITIAL VARIABLE VALUES SECTION	 */

w300 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", ii );
    fprintf ( ioout, "%s\n", ii );
    if ( strncmp(ii, separate_cmnd, 3) == 0 )  goto w310;
    if ( strncmp(ii, ix0, 2) == 0 || strncmp(ii, ixo, 2) == 0 )  goto w305;
    if ( strncmp(ii, together_cmnd, 3) != 0 )  goto w990;

/*    TOGETHER FORMAT FOR VARIABLE VALUES     */

    for ( i=1; i<=n; i++ )  fscanf (ioin, "%le", &x[i]);
    fgets(dataline, 70, ioin);
    for ( i=1; i<=n; i++ )  fprintf (ioout, "    %le\n", x[i]);
    goto w70;
w305 :
    if ( revise_step == 0 )  goto w985;
    for (i=1; i<=n; i++)  x[i] = xo[i];
    goto w70;
w310 :
    fgets (dataline, 81, ioin);
    sscanf ( dataline, " %s", ii);
    if ( strncmp(ii, end_cmnd, 3) != 0 ) {
	sscanf ( dataline, " %d %d %le", &is1, &is2, &a1);
	goto w320;
    }
    fprintf (ioout, "%s\n", ii);
    goto w70;
w320 :
    if ( is2 == 0 ) is2 = is1;
    fprintf ( ioout, "  %d  %d  %le\n", is1, is2, a1 );
    if ( is1 < 1 || is1 > n )  goto w1000;
    if ( is2 > n )  goto w1005;
    if ( is1 > is2 )  goto w945;
    for (is=is1; is<=is2; is++)  x[is] = a1;
    goto w310;

/*    PROCESS EPSILONS SECTION	  */

w330 :
    fgets ( dataline, 81, ioin );
    sscanf( dataline, "%s", ii );
    if ( strncmp(ii, end_cmnd, 3) != 0 )  {
	sscanf ( dataline + 10, " %le", &a1 );
	goto w340;
    }
    fprintf ( ioout, "%s\n", end_cmnd );
    goto w70;
w340 :
    fprintf ( ioout, "%s  %le\n", ii, a1 );
    i = 0;
    while ( i < 6 && strncmp(ii, ie[i], 3) != 0 ) i++;
    if ( i < 6 ) {
	j = i;
	goto w360;
    }
    goto w950;
w360 :
    switch ( j )  {
	case 0 : eplast = a1;
		break;
	case 1 : epinit = a1;
		break;
	case 2 : epstop = a1;
		break;
	case 3 : epspiv = a1;
		break;
	case 4 : ph1eps = a1;
		break;
	case 5 : pstep = a1;
		break;
    }
    goto w330;

/*    PROCESS LIMIT SECTION    */

w410 :
    fgets(dataline, 81, ioin);
    sscanf ( dataline, " %s", ii );
    if ( strncmp(ii, end_cmnd, 3) != 0 )  {
	sscanf ( dataline + 6, " %d", &input_int );
	goto w420;
    }
    fprintf ( ioout, "%s\n", ii );
    goto w70;
w420:
    fprintf ( ioout, "%s  %d\n", ii, input_int );
    i = 0;
    while ( i < 3 && strncmp(ii, il[i], 3) != 0 )  i++;
    if ( i < 3 ) {
	j = i;
	goto w440;
    }
    goto w950;
w440 :
    switch ( j )  {
	case 0 : nstop = input_int;
		break;
	case 1 : itlim = input_int;
		break;
	case 2 : limser = input_int;
		break;
    }
    goto w410;

/*    PROCESS PRINT SECTION    */

w480 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", ii );
    if ( strncmp(ii, end_cmnd, 3) != 0 )  {
	sscanf ( dataline + 3, " %d", &input_int);
	goto w490;
    }
    fprintf ( ioout, "%s\n", end_cmnd );
    goto w70;
w490 :
    fprintf ( ioout, "%s  %d\n", ii, input_int );
    i = 0;
    while ( i < 5 && strncmp(ii, ip[i], 3) != 0 ) i++;
    if ( i < 5 )  {
	j = i;
	goto w510;
    }
    goto w950;
w510 :
    switch ( j ) {
	case 0 : ipr = input_int;
		 ipr3 = ipr - 1;
		 break;
	case 1 : ipn5 = input_int;
		 break;
	case 2 : ipn4 = input_int;
		 break;
	case 3 : iper = input_int;
		 break;
	case 4 : ipn6 = input_int;
		 break;
    }
    goto w480;

/*    PROCESS METHOD SECTION	*/

w580 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", ii );
    fprintf ( ioout, "%s\n", ii );
    if ( strncmp(ii, end_cmnd, 3) == 0 )  goto w70;
    i = 0;
    while ( i < 15 && strncmp(ii, im[i], 3) != 0 )  i++;
    if ( i < 15 )  {
	j = i;
	goto w600;
    }
    goto w950;
w600 :
    switch ( j )  {
	case 0	:  iquad = 0;
		break;
	case 1	:  iquad = 1;
		break;
	case 2	:  kderiv = 2;
		break;
	case 3	:  kderiv = 0;
		break;
	case 4	:  modcg = 1;
		break;
	case 5	:  modcg = 2;
		break;
	case 6	:  modcg = 3;
		break;
	case 7	:  modcg = 4;
		break;
	case 8	:  modcg = 5;
		break;
	case 9	:  kderiv = 1;
		break;
	case 10 :  maxim = 1;	 /*    TRUE    */
		break;
	case 11 :  maxim = 0;
		break;
	case 12 :  maxrm = 0;	 /******/
		break;
	case 13 :  maxrm = maxr;
		break;
        case 14 :  doscale = 1;
		break;
    }
    goto w580;

/*    PROCESS FUNCTION NAME    */

w750 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", temp );
    if ( strncmp(temp, end_cmnd, 3) == 0 )  {
	fputs ( dataline, ioout);
	goto w70;
    }
    sscanf ( dataline + 9, " %d", &i );
    if ( i < 1 || i > mp1 )  goto w1010;
    strcpy(con[i], temp);
    fprintf ( ioout, "%s  %d\n", temp, i );
    goto w750;

/*    PROCESS VARIABLE NAME   */
w770 :
    fgets (dataline, 81, ioin);
    sscanf( dataline, "%s", temp );
    if ( strncmp(temp, end_cmnd, 3) == 0 )  {
	fputs ( dataline, ioout);
	goto w70;
    }
    sscanf ( dataline + 9, " %d", &i );
    if ( i < 1 || i > n )  goto w1010;
    strcpy (var[i], temp);
    fprintf ( ioout, "%s  %d\n", temp, i );
    goto w770;

/*    PROCESS  'DUMP'	 */

w785 :
    dump();    /*  NO PARAMETER PASSED	*/
    dumped = 1;
    revise_step = 1;
    goto w10;

/*    PROCESS  'GO'    */

w790 :

    /*	 CHECK TO SEE THAT VARIABLES ARE WITHIN BOUNDS	 */

    for ( i=1; i<=n; i++ )  {
	xo[i] = x[i];
	if ( x[i] >= alb[i] && x[i] <= ub[i] )	goto w810;
	if ( x[i] > ub[i] )  goto w800;
	fprintf ( ioout,
	" FOR SUBSCRIPT =  %d, INITIAL VARIABLE VALUE OF %le\n", i, x[i] );
	fprintf ( ioout,
	"                      WAS CHANGED TO LOWER BOUND = %le\n", alb[i] );
	x[i] = alb[i];
	goto w810;
    w800 :
	fprintf ( ioout,
	" FOR SUBSCRIPT =  %d, INITIAL VARIABLE VALUE OF %le\n", i, x[i] );
	fprintf ( ioout,
	"                      WAS CHANGED TO UPPER BOUND = %le\n", ub[i] );
	x[i] = ub[i];
    w810 :  ;
    }
    if ( error_count != 0 )  exit(1);    /*****/
    istat[nobj] = 0;
    alb[n+nobj] = -plinfy;
    ub[n+nobj]	= plinfy;
w815 :
    if ( epinit == 0.0 || epinit < eplast )  epinit = eplast;
    fprintf ( ioout,
    "  EPNEWT = %le, EPINIT = %le, EPSTOP = %le\n", eplast, epinit, epstop );
    fprintf ( ioout,
    "  EPPIV  = %le, PH1EPS = %le\n", epspiv, ph1eps );
    fprintf ( ioout,
    "  NSTOP  = %3d, ITLIM  = %3d, SEARCH = %3d\n", nstop, itlim, limser );
    fprintf ( ioout,
    "  IPR    = %3d, PN4    = %3d, PN5    = %3d, PN6    = %3d, PER    = %3d.\n",
    ipr, ipn4, ipn5, ipn6, iper );
    if ( iquad == 1 )
	fprintf (ioout,
    " USE QUADRATIC EXTRAPOLATION FOR INITIAL ESTIMATES OF BASIC VARIABLES.\n");
    if ( iquad == 0 )
	fprintf (ioout,
    " USE TANGENT VECTORS FOR INITIAL ESTIMATES OF BASIC VARIABLES.\n");
    if ( maxim == 1 )
	fprintf (ioout,
    " THE OBJECTIVE FUNCTION WILL BE MAXIMIZED.\n");
    if ( maxim == 0 )
	fprintf (ioout,
    " THE OBJECTIVE FUNCTION WILL BE MINIMIZED.\n");
    if ( maxrm == 0 )
	fprintf (ioout,
    " CONJUGATE GRADIENT METHOD %d WILL BE USED.\n", modcg);
    else
	fprintf (ioout,
    " DFP WILL BE USED IF # SUPERBASICS <= %d.\n", maxrm);
    if ( kderiv == 0 )
	fprintf (ioout,
    " FORWARD DIFF PARSH USED: DELTA = %le.\n", pstep);
    if ( kderiv == 1 )
	fprintf (ioout,
    " CENTRAL DIFF PARSH USED: DELTA = %le.\n", pstep);
    if ( kderiv == 2 )
	fprintf (ioout,
    " THE USER SUPPLIED PARSH SUBROUTINE WILL BE USED.\n");
    if ( doscale == 1 )
        fprintf (ioout,
    "THE SCALING OPTION HAS BEEN SELECTED.\n");
    return;

/*    ERROR MESSAGES AND TERMINATIONS	 */

/*    IMPROPER ROW SUBSCRIPT	*/

w940 :
    fprintf (ioout, " ROW SUBSCRIPT = %d,  LESS THAN 1 OR GREATER THAN RWS : %d\n", is1, mp1);
    goto w1030;
w942 :
    fprintf (ioout, " ROW SUBSCRIPT = %d,  LESS THAN 1 OR GREATER THAN RWS : %d\n", is2, mp1);
    goto w1030;

/*    FIRST SUBSCRIPT OF RANGE GREATER THAN SECOND SUBSCRIPT	*/

w945 :
    fprintf (ioout, " FIRST RANGE SUBSCRIPT = %d GREATER THAN\n", is1);
    fprintf (ioout, " SECOND RANGE SUBSCRIPT = %d \n", is2);
    goto w1030;

/*    IMPROPER SYMBOL WITHIN SECTION	*/

w950 :
    fprintf (ioout, " <%s> IS AN IMPROPER SYMBOL OR <END> IS MISSING.\n", ii);
    goto w1030;

/*     IMPROPER BOUNDS SUBSCRIPT    */
w960 :
    fprintf (ioout, " BOUNDS SUBSCRIPT = %d  NOT BETWEEN 1 AND N\n", is1);
    goto w1030;
w962 :
    fprintf (ioout, " BOUNDS SUBSCRIPT = %d  NOT BETWEEN 1 AND N\n", is2);
    goto w1030;

/*    UPPER BOUND LESS THAN LOWER BOUND    */

w970 :
    fprintf (ioout, " FOR SUBSCRIPT = %d,  UPPER BOUND = %le\n", is, a2 );
    fprintf (ioout, "            LESS THAN LOWER BOUND = %le\n", a1 );
    goto w1030;

/*    X0 USED NOT FOLLOWING 'REVISE'	*/

w985 :
    fprintf (ioout, " <X0> WAS USED NOT FOLLOWING <REVISE>\n" );
    goto w1060;

/*    FIRST CARD OF INITIAL VARIABLES SECTION WAS NOT 'TOG', 'SEP', OR 'X00'.	 */

w990 :
    fprintf (ioout, " FIRST CARD OF INITIAL VARIABLES SECTION WAS NOT \n");
    fprintf (ioout, "  <TOG>, <SEP>, OR <X00>." );
    goto w1060;

/*    IMPROPER VARIABLE SUBSCRIPT    */

w1000 :
    fprintf (ioout, " VARIABLE INDEX = %d  IS LESS THAN 1 OR GREATER THAN N\n", is1 );
    goto w1030;
w1005 :
    fprintf (ioout, " VARIABLE INDEX = %d  IS LESS THAN 1 OR GREATER THAN N\n", is2 );
    goto w1030;

/*    IMPROPER NAME SUBSCRIPT	 */

w1010 :
    fprintf (ioout, "%d IS AN IMPROPER NAME SUBSCRIPT FOR <%s>,", i, temp);
    fprintf (ioout, " OR <END> IS MISSING.\n" );
    goto w1030;

/*     IMPROPER SYMBOL IN READING SECTION HEADINGS    */

w1020 :
    fprintf (ioout, "<%s> IS AN IMPROPER SYMBOL OR <GO!> IS MISSING.\n", ii);
    goto w1060;

/*    ERROR RECOVERY PROCEDURE,  USUAL CASE.	*/

w1030 :
    error_count++;
    i = 0;
    while ( i < 11 && strncmp(ii, iss[i], 3) != 0 ) i++;
    if ( i < 11 )  {
	isk = i;
	goto w100;
    }

/*    FAULTY CARD WAS NOT A NEW SECTION HEAD.  RETURN TO PREVIOUS    */
/*    SECTION IF ERRORS HAVE NOT TOTALED 10.			      */

w1040 :
    if ( error_count < 10 && isk == 3 )  goto w310;
    if ( error_count < 10 ) goto w100;
    fprintf (ioout, "PROCESSING TERMINATED BECAUSE 10 OR MORE ERRORS HAVE BEEN DETECTED.\n" );
    exit(1);

/*    ERROR RECOVERY PROCEDURE,  UNUSUAL CASE.	  */
/*	   FIND NEXT SECTION CARD.		  */

w1060 :
    error_count++;
    iflag = 1;
    goto w70;

/*       end of datain()     */
}
