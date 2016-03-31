/*
 * field-of-view.c
 *
 * Field-Of-View Constraint
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"

/*
 * Field-Of-View Constraint
 * Input:   rO, nu (position and viewing direction to evaluate constraint at)
 *          rm (extreme vertex with largest angle from viewing direction)
 *          alpha (field-of-view angle)
 * Output:  field-of-view constraint evaluated at sensor setting
 */
matrix g3(matrix rO, matrix nu, matrix rm, double alpha) {
  if(rO.cols() != 1 || nu.cols() != 1 || rO.rows() != 3 || nu.rows() != 3) {
    cerr << "rO and nu must be column vectors of length 3." << endl;
    exit(1);
  }
  if(rm.cols() != 1 || rm.rows() != 3) {
    cerr << "rm must be a column vector of length 3." << endl;
    exit(1);
  }

  matrix field_of_view(1,1); /* make a matrix just like other constraints */
  
  field_of_view(1) = (rm - rO).Frobenius()*cos(alpha/2) - (rm - rO).dot(nu);

  return field_of_view;
}
