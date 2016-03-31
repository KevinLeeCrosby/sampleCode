/*********************/
/*    File GVAR.C    */
/*********************/
#include <stdio.h>
#include <math.h>

/***************************************************/
/*    CONSTANTS USED AS SIZES OF WORKING ARRAYS    */
/*	  --- FOR PHASE I ONLY			   */
/***************************************************/

#define zm         21
#define zn         20
#define zmp1       22
#define znpmp1     42
#define znbmax     21     /* default = m*/
#define znnbmax    21     /* default max of n ,m */
#define zmpnbmx    22     /* default = mp1*/
#define znpnbmx    41
#define znrtot    210

double   fcns[zmp1];
double   rmult[zmp1], redgr[zn];
int      inbind[zmp1], nonbas[zn];
int      nbind, nnonb;

int     nvars, nrows, maxr, maxb;
int     m, n, mp1, npmp1, nbmax, nnbmax, mpnbmx;

int     istat[zmp1], ifix[zn], icand[znpnbmx];
int     inbv[zn], iub[zn], inbc[zn];
int     ibc[znbmax], ibcold[znbmax], ibv[zm];
int     icols[znpnbmx], inorm[znpnbmx];
int     inbvp[zn];
int     init, lastcl,linear=0; /* logical default is nonlinear */
int     maxim=-1;  /* logical; 0 = false, 1 = true */
int     limser=1000, nstop=3, itlim=10;
int     ipr=1, ipr3=0, ipn4=0, ipn5=0, ipn6=0, iper=0;
int     ierr;
int     nb, nnbc, nobj, ninf, nsuper, ncand;
int     modcg=1, kderiv=0, iquad=0;
int     maxrm=-1, nsear, jp, lv, jqq;
int     initph, icon, nsear0, lvlast;
int     nftn, ngrad, nminv, nnfail, ncalls, nit, nbs, nstepc, ndub;
int     ninfb, iter, info, nsupp;
int     dfail, update, sbchng, chngsb;        /*  logicals  */
int     move, restrt, drop, varmet, conjgr;       /*  logical  */
int     uncon, fail, jstfes, mxstep, unbd, succes, unconp;  /*  logical  */

float   grad[zmp1][zn];

double  x[znpmp1], alb[znpmp1], ub[znpmp1], g[zmp1];
double  gradf[zn], u[znbmax];
double  gbest[zmp1];
double  r[znrtot], v[znbmax], d[zn], xbest[zmp1],
	   xb1[znbmax], xb2[znbmax], xb3[znbmax];
double  xstat[zn], gradp[zn], dbnd[znpnbmx], cnorm[znpnbmx],
	   gg[zmp1], rr[znbmax], y[zn];
double  binv[znbmax][znnbmax], rowb[znbmax], colb[znbmax];
double  xo[zn], go[zmp1], xx[zn], xlb[zn], xub[zn], glb[zmp1], gub[zmp1];
double  fnleps;
double  eps, plinfy, plzero, tolx, tolz;
double  epnewt=1.0e-06, epinit=1.0e-06, eplast=1.0e-06, epstop=1.0e-04;
double  epspiv=1.0e-04, pstep=1.0e-08;
double  phmult, ph1eps=0.0;
double  a1, a2, a3;
double  stpbst, objbst, step, stepmx, truobj;
double  cond;
double  trubst;
double  corner, xb, xstep;

char    *colstatus[znpnbmx];
char    con[zmp1][11], var[zn][11];
char    dataline[82];
char    title[81];

FILE    *ioin, *ioout, *iodump;

/*08/1991 thru 11/1991*/
int     scaled,doscale=0,havescale;   /* logicals for scaling option */
double  scale[znpmp1];
char    *gtype[znpmp1];     /* removed from tablin proc in initlz */
char    *gstatus[znpmp1];   /* removed from outret.c */
/*08/1991 thru 11/1991*/




