/*********************/
/*   File GFUNCT.C   */
/*********************/
#include <stdio.h>
#include <math.h>
#include <string.h>
#include "matrix.h"
#include "gvar.h"

char node[15];
int entity_count=0; /* counts current number of entities */
matrix vertices, resolve, visible, C6, camera_parms;
matrix cos_sin, Md, Cd;
matrix length, accuracy;
double multiplier=1e5;


/*
 * Transformation
 * Input:   x (implicit - position and viewing direction)
 * Output:  transformation evaluated at sensor setting
 */
matrix transformation() {
  double txtytz[]={x[1], x[2], x[3]};
  double phi=x[4], theta=x[5], psi=x[6];
  double rotation[]=
  {cos(phi)*cos(theta), -sin(phi)*cos(psi)+cos(phi)*sin(theta)*sin(psi),
   sin(phi)*sin(psi)+cos(phi)*sin(theta)*cos(psi),
   sin(phi)*cos(theta), cos(phi)*cos(psi)+sin(phi)*sin(theta)*sin(psi),
   -cos(phi)*sin(psi)+sin(phi)*sin(theta)*cos(psi),
   -sin(theta), cos(theta)*sin(psi), cos(theta)*cos(psi)};
  matrix R01(3,3,rotation), d01(3,1,txtytz), R10(R01.T()), d10(-R10*d01);
  double bottomrow[]={0,0,0,1};
  matrix bottom(1,4,bottomrow);
  matrix Q((R10.haugment(d10)).vaugment(bottom));

  return Q;
}


/*
 * Position
 * Input:   x (implicit - position and viewing direction)
 * Output:  position extracted from sensor setting
 */
matrix position() {
  double tx=x[1], ty=x[2], tz=x[3];
  double position[] = {tx, ty, tz};
  matrix rO(3,1,position);

  return rO;
}


/*
 * Viewing Direction
 * Input:   x (implicit - position and viewing direction)
 * Output:  viewing direction extracted from sensor setting
 */
matrix viewing() {
  double phi=x[4], theta=x[5], psi=x[6];
  double viewing_direction[] =
  {sin(phi)*sin(psi)+cos(phi)*sin(theta)*cos(psi),
   -cos(phi)*sin(psi)+sin(phi)*sin(theta)*cos(psi),
   cos(theta)*cos(psi)};
  matrix nu(3,1,viewing_direction);

  return nu;
}


void parameters(matrix rO, matrix nu, double f, double Imin,
		matrix &rc, matrix &rf, matrix &rm, double &d, double &alpha) {
  /* initialize far and near vertices and initialize extreme vertex */
  rc = rf = rm = vertices.column(1);
  double closest = fabs((rc - rO).dot(nu)), furthest = closest;
  double extreme = fabs(closest/(rm - rO).Frobenius());

  /*     find closest and furthest vertices along viewing direction    */
  /* and find extreme vertex with largest angle from viewing direction */
  double distance, cosine;
  matrix r(3,1); /* vertex to test */

  int vertex;
  int k = entity_count; /* number of entities */

  for(vertex = 2; vertex <= 2*k; vertex++) {
    r = vertices.column(vertex);
    distance = fabs((r - rO).dot(nu));
    if(distance < closest) {
      rc = r;
      closest = distance;
    }
    else if(distance >= furthest) {
      rf = r;
      furthest = distance;
    }
    cosine = fabs(distance/(r - rO).Frobenius());
    if(cosine < extreme) { /* i.e. if new angle is larger */
      rm = r;
      extreme = cosine;
    }
  }

  /* Tarabanis' approximation for d */
  double Df = (rf - rc).dot(nu), Dmax = (rf - rO).dot(nu);
  d = 2*Dmax*f*(Dmax - Df) / (2*Dmax*(Dmax - f - Df) + f*Df);

  alpha = 2*atan2(Imin,2*d); /* field-of-view angle */
}



void latex(char *format, double number) {
  int exponent=0;
  double mantissa;

  if(number!=0.0) exponent = (int)floor(log10(fabs(number)));
  if (exponent < -4) {
    mantissa = number * pow(10, -exponent);
    sprintf(format, "$%.6f\\times 10^{%d}$", mantissa, exponent);
  }
  else sprintf(format, "%.6g", number);
}


void Mathematica(char *format, double number) {
  int exponent=0;
  double mantissa;

  if(number!=0.0) exponent = (int)floor(log10(fabs(number)));
  mantissa = number * pow(10, -exponent);
  sprintf(format, "%.6f*10^%d", mantissa, exponent);
}



/*
 * catenate prefix and suffix
 * Input:   prefix, suffix
 * Output:  prefix = suffix         FOR prefix="??"  
 *       OR prefix = prefix_suffix  OTHERWISE
 */
void catenate(char *prefix, const char *suffix) {
  if (strcmp(prefix, "??")) {
    strcat(prefix, "_");
  }
  strcat(prefix, suffix);
}



void count_entities() {
  char entities_file[30], entity[15];
  FILE *entities;

  entity_count=0; /* a global */

  strcpy(entities_file, node);
  catenate(entities_file, "entities.dat");

  entities=fopen(entities_file, "r");
  while(fscanf(entities, " %s ", entity)!=EOF)
    entity_count++;
  fclose(entities);
}


void start_latex() {
  int i;
  char format[30], entity[15];
  matrix nu = viewing();
  FILE *output, *entities;

  char output_file[30], entities_file[30];
  strcpy(output_file, node);
  strcpy(entities_file, node);
  catenate(output_file, "output.tex");
  catenate(entities_file, "entities.dat");

  output=fopen(output_file, "w");
  fprintf(output, "\\begin{table}[htbp]\n\\centerline{\n");
  fprintf(output, "\\begin{tabular}{|rl|rl|}\n\\hline\n");
  fprintf(output, "$%s$: & $\\{", node);

  entities=fopen(entities_file, "r");
  for(i=0; i<entity_count; i++) {
    fscanf(entities, " %s ", entity);
    fprintf(output, "%s", entity);
    if (i < entity_count - 1) fprintf(output, ", ");
  }
  fclose(entities);

  fprintf(output, "\\}$ &\n\\multicolumn{2}{l|}{\\{");
  for(i=0; i<entity_count; i++) {
    fprintf(output, "0\\%%");
    if (i < entity_count - 1) fprintf(output, ", ");
  }
  fprintf(output, "\\}} \\\\ \\hline \\hline\n");

  fprintf(output, "I: & \\multicolumn{3}{l|}{(");
  for (i=1; i<=6; i++) {
    latex(format, xo[i]);
    fprintf(output, "%s", format);
    if (i < 6) fprintf(output, ", ");
    if (i == 3) fprintf(output, "\n");
  }
  fprintf(output, ")} \\\\ \\hline\n");
  fprintf(output, "$\\vec{\\nu}(I):$ & (");
  for (i=1; i<=3; i++) {
    latex(format, nu(i));
    fprintf(output, "%s", format);
    if (i < 3) fprintf(output, ", ");
  }
  fprintf(output, ") & \n");

  for(i=1; i<=6; i++) /* make initial point current point */
    x[i] = xo[i];

  latex(format, g[nobj]/multiplier);
  fprintf(output, "MSE(I): & %s \\\\ \\hline \\hline \n", format);

  fclose(output);
}


void end_latex() {
  int i;
  char format[30]; 
  matrix nu = viewing();
  FILE *output;
  
  char output_file[30];
  strcpy(output_file, node);
  catenate(output_file, "output.tex");

  output=fopen(output_file, "a");
  fprintf(output, "F: & \\multicolumn{3}{l|}{(");
  for (i=1; i<=6; i++) {
    latex(format, xx[i]);
    fprintf(output, "%s", format);
    if (i < 6) fprintf(output, ", ");
    if (i == 3) fprintf(output, "\n");
  }
  fprintf(output, ")} \\\\ \\hline\n");
  fprintf(output, "$\\vec{\\nu}(F):$ & (");
  for (i=1; i<=3; i++) {
    latex(format, nu(i));
    fprintf(output, "%s", format);
    if (i < 3) fprintf(output, ", ");
  }
  fprintf(output, ") & \n");

  latex(format, g[nobj]/multiplier);
  fprintf(output, "MSE(F): & %s \\\\ \\hline \\hline \n", format);

  fprintf(output, "time: &  & iterations: & %d\n", nsear);
  fprintf(output, "\\\\ \\hline\n\\end{tabular}}\n");
  fprintf(output, "\\caption{Experimental results for observing node $%s$.}\n",node);
  fprintf(output, "\\label{%s_data}\n\\end{table}\n", node);
  fclose(output);
  fclose(output);
}


void write_Mathematica() {
  int i;
  FILE *node_entity, *entities;

  char node_entity_file[30], entities_file[30], entity[15];
  strcpy(entities_file, node);
  catenate(entities_file, "entities.dat");

  entities=fopen(entities_file,"r");

  char fa[30], fb[30], fnd[30], fvd[30], fL[30], facc[30];

  for(i=1; i<=entity_count; i++) {
    fscanf(entities, " %s ", entity);
    strcpy(node_entity_file, node);
    strcat(node_entity_file, "-");
    strcat(node_entity_file, entity);
    strcat(node_entity_file, ".ma");
    node_entity=fopen(node_entity_file, "w");
    Mathematica(fa, cos_sin(i,1));
    Mathematica(fb, cos_sin(i,2));
    Mathematica(fnd, Md(i));
    Mathematica(fvd, Cd(i,i));
    Mathematica(fL, length(i));
    Mathematica(facc, accuracy(i));
    fprintf(node_entity,"a=%s; b=%s; nd=%s; vd=%s;\nL=%s; acc=%s; deltaL=(1-acc)L; prob", fa, fb, fnd, fvd, fL, facc);
    fclose(node_entity);
  }
  fclose(entities);
}



