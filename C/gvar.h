/*********************/
/*    File GVAR.H    */
/*********************/
#ifndef GVAR
#define GVAR

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

/***********************************/
/*  External Variable Definitions  */
/***********************************/

extern double   rmult[zmp1], redgr[zn];

/*08/1991 - 11/1991*/
//void exit( int status );                    /* commented out */
//char *strcpy( char * s1, const char * s2 ); /*      by       */
//char *strcat( char * s1, const char * s2 ); /* Kevin  Crosby */
extern double   fcns[zmp1];
/*08/1991 - 11/1991*/

extern int     inbind[zmp1], nonbas[zn];
extern int     nbind, nnonb;
extern int     nvars, nrows, maxr, maxb;
extern int     m, n, mp1, npmp1, nbmax, nnbmax,  mpnbmx;
extern int     istat[zmp1], ifix[zn], icand[znpnbmx];
extern int     inbv[zm], iub[zn], inbc[zn];
extern int     ibc[znbmax], ibcold[znbmax], ibv[zm];
extern int     icols[znpnbmx], inorm[znpnbmx];
extern int     inbvp[zn];
extern int     init, lastcl, linear;
extern int     maxim;  /* logical; 0 = false, 1 = true */
extern int     limser, nstop, itlim;
extern int     ipr, ipr3, ipn4, ipn5, ipn6, iper;
extern int     ierr;
extern int     nb, nnbc, nobj, ninf, nsuper, ncand;

extern int     modcg;
extern int     maxrm, nsear, jp, lv, jqq;
extern int     kderiv;
extern int     initph;
extern int     icon, iquad;
extern int     nsear0, lvlast;
extern int     nftn, ngrad, nminv, nnfail, ncalls, nit, nbs, nstepc, ndub;
extern int     dfail, update, sbchng, chngsb;    /*  logicals  */
extern int     move, restrt, drop, varmet, conjgr;       /*  logical  */
extern int     uncon, fail, jstfes, mxstep, unbd, succes, unconp;  /*  logical  */
extern int     ninfb, iter, info, nsupp;

extern float   grad[zmp1][zn];

extern double  x[znpmp1], alb[znpmp1], ub[znpmp1], g[zmp1];
extern double  gradf[zn], u[znbmax];
extern double  gbest[zmp1];
extern double  r[znrtot], v[znbmax], d[zn], xbest[zmp1],
               xb1[znbmax],xb2[znbmax], xb3[znbmax];
extern double  xstat[zn], gradp[zn], dbnd[znpnbmx], cnorm[znpnbmx],
               gg[zmp1], rr[znbmax], y[zn];
extern double  binv[znbmax][znnbmax], rowb[znbmax], colb[znbmax];
extern double  xo[zn],go[zmp1],xlb[zn],xub[zn], xx[zn], glb[zmp1],gub[zmp1];

extern double  fnleps;
extern double  eps, plinfy, plzero, tolx, tolz;
extern double  epnewt, epinit, eplast, epstop;
extern double  epspiv, pstep;
extern double  phmult, ph1eps;
extern double  a1, a2, a3;
extern double  stpbst, objbst, step, stepmx, truobj;

extern double  cond;
extern double  trubst;
extern double  corner, xb, xstep;

extern char    *colstatus[znpnbmx];
extern char    con[zmp1][11], var[zn][11];
extern char    dataline[82];
extern char    *msg;
extern char    title[81];

extern FILE    *ioin, *ioout, *iodump;

/*08/1991 thru 11/1991*/
extern int     scaled,doscale,havescale; /* logicals for scaling option */
extern double  scale[znpmp1];
extern char    *gtype[znpmp1];     /* removed from tablin proc in initlz */
extern char    *gstatus[znpmp1];   /* removed from outret.c */
/*08/1991 thru 11/1991*/

#endif
