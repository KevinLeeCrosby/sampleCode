/*********************/
/*   File GFUNCT.H   */
/*********************/
#ifndef GFUNCT
#define GFUNCT

#include <stdio.h>
#include <math.h>
#include "matrix.h"

extern char node[15];
extern int entity_count;
extern matrix vertices, resolve, visible, C6, camera_parms;
extern matrix cos_sin, Md, Cd;
extern matrix length, accuracy;
extern double multiplier;

matrix transformation(void);
matrix position(void);
matrix viewing(void);
void parameters(matrix rO, matrix nu, double f, double Imin,
		matrix &rc, matrix &rf, matrix &rm, double &d, double &alpha);
void latex(char *format, double number);
void Mathematica(char *format, double number);
void catenate(char *prefix, const char *suffix);
void count_entities(void);
void start_latex(void);
void end_latex(void);
void write_Mathematica(void);

#endif
