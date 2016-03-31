/*
 * focus.c
 *
 * Focus Constraints
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"


/*
 * Focus Constraint
 * Input:   rO, nu (position and viewing direction to evaluate constraint at)
 *          rc, rf (closest and furthest vertices along viewing direction)
 *          a (diameter of the aperture of the lens, i.e. aperture length)
 *          c (radius of blur circle)
 *          d (distance from back nodal point of lens to image plane, i.e.
 *             effective focal length)
 *          f (focal length of lens)
 * Output:  near and far focus constraints evaluated at sensor setting
 */
matrix g2(matrix rO, matrix nu, matrix rc, matrix rf, double a, double c,
	  double d, double f) {
  if(rO.cols() != 1 || nu.cols() != 1 || rO.rows() != 3 || nu.rows() != 3) {
    cerr << "rO and nu must be column vectors of length 3." << endl;
    exit(1);
  }
  if(rc.cols() != 1 || rf.cols() != 1 || rc.rows() != 3 || rf.rows() != 3) {
    cerr << "rc and rf must be column vectors of length 3." << endl;
    exit(1);
  }

  /* determine focus constraint */
  double D1 = a*f*d/(a*(d - f) - c*f), D2 = a*f*d/(a*(d - f) + c*f);
  double nearfar[] = {D2 - (rc - rO).dot(nu), (rf - rO).dot(nu) - D1};
  matrix focus(2,1,nearfar);
  
  return focus;
}
