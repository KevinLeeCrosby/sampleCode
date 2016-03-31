/*********************************/
/*                               */
/*       File GRGMAIN.C          */
/*                               */
/*********************************/

#include <stdio.h>
#include <time.h>

void grg( void );

void main()
{
    /*    Main program for GRG.                            */
    /*    Calls grg() which is primary driving program.    */
    /*    Calculates processor time for complete run.      */

char    date [9];
time_t  t, start, finish;

time(&t);
strftime(date, 9, "%m-%d-%y", localtime(&t));
// _strdate(date);
printf("The current date is %s \n",date);

time(&start);
grg();
time(&finish);
printf("\nThis run of GRG3C took %f seconds.\n",
       finish - start);
//	difftime(finish,start)/1000 );

}
