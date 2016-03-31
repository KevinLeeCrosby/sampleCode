/*****************************/
/*	 File GRG.C	     */
/*     includes grg().       */
/*  Not used with the        */
/*  subroutine interface.    */
/*****************************/

#include <stdio.h>
#include <string.h>
#include "gvar.h"

void datain( int *stop2);
void tablin();
void report();
void outres();
void initlz();
void setup();

void grg ()
{
    /*	  Main driving routine. 			   */
    /*	  Calls input, solving, and output subroutines.    */

    int stop2;         /*  logical; 0 = false, 1 = true   */
    char filename[31] ;

    ioout = stdout;
    strcpy(filename, "");
    do
    {
	    printf("\nEnter input data file path and name: ");
	    scanf ("%30s", filename);
	    if ((ioin = fopen(filename, "r") ) == NULL)
		{printf("Could not open file: %s. Please retry.\n",filename);
		strcpy(filename, ""); }
	    else
		printf("File %s opened for input.\n",filename);
    }
    while (strcmp(filename, "") == 0 );
 /*   strcpy(filename, "");
    do
    {
	    printf("\nEnter output data file path and name: ");
	    scanf ("%30s", filename);
	    if ((ioout = fopen(filename, "w") ) == NULL)
		{printf("Could not open file: %s. Please retry.\n",filename);
		strcpy(filename, ""); }
	    else
		printf("File %s opened for output.\n",filename);
    }
    while (strcmp(filename, "") == 0 );
   */
    stop2 = 0;
    lastcl = 1;
    initlz();
    maxr = 0;
    maxb = 0;
    fgets(dataline, 81, ioin);
    sscanf (dataline, " %d %d %d %d", &nvars, &nrows, &maxr, &maxb);

    setup();
w30 :
    init = 1;
    datain ( &stop2 );

    if ( stop2 == 1 ) return;
    tablin();
    report();

    init = 0;
    grgitn();

    outres();
    report();
    goto w30;

}
