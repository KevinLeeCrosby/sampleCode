/*
 * visibility.c
 *
 * Visibility Constraint
 */
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"

/*
 * Visibility Constraint
 * Input:   rO (position to evaluate constraint at)
 * Output:  visibility constraint evaluated at sensor setting
 */
matrix g4(matrix rO)
{
  if(rO.cols() != 1 || rO.rows() != 3) {
    cerr << "rO must be a vector of length 3." << endl;
    exit(1);
  }

  matrix one(1,1,1.0);
  matrix homogeneous(rO.vaugment(one));

  /* double tx = rO(1), ty = rO(2), tz = rO(3);     coordinates in mm */
  matrix visibility(visible*homogeneous); /* visible is global */

  return visibility;
}
