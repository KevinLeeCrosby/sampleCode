/*    mse.c     */

#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gvar.h"
#include "gfunct.h"
#include "objective.h"
#include "constraints.h"

#define min(a, b) (((a) < (b)) ? (a) : (b));

void gcomp( double  g[zmp1], double  x[7] ) {
  int i;

  double rx = camera_parms(1), ry = camera_parms(2), f = camera_parms(3);
  double a = f/16, w = hypot(rx, ry), c = min(rx, ry);
  double Imin = min(512*rx, 480*ry);

  matrix rO = position();
  matrix nu = viewing();

  matrix rc, rf, rm;
  double alpha, d;

  parameters(rO, nu, f, Imin, rc, rf, rm, d, alpha);

  g[1] = multiplier * function(rx, ry, f);

  matrix constraint(constraints(rO, nu, rc, rf, rm, alpha, a, c, d, f, w));

  for(i=2; i<=nrows; i++) {
    g[i] = constraint(i-1);
  }
  
  if (init==1) start_latex();/* will write even if infeasible */

  return;
}
