/*
 * resolution.c
 *
 * Resolution Constraint
 */
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"

/*
 * Resolution Constraint
 * Input:   rO, nu (position and viewing direction to evaluate constraint at)
 *          d (distance from back nodal point of lens to image plane)
 *            (i.e. effective focal length)
 *          w (minimum required length of the feature)
 * Output:  resolution constraint evaluated at sensor setting
 */
matrix g1(matrix rO, matrix nu, double d, double w)
{
  if(rO.cols() != 1 || nu.cols() != 1 || rO.rows() != 3 || nu.rows() != 3) {
    cerr << "rO and nu must be column vectors of length 3." << endl;
    exit(1);
  }
  else if(vertices.rows() != 3) {
    cerr << "Vertices must be nonhomogeneous coordinates of length 3." << endl;
    exit(1);
  }
  else if(vertices.cols() % 2) {
    cerr << "Must be an even number of vertices." << endl;
    exit(1);
  }

  int a, b;
  int k = entity_count; /* number of entities */
  double l;
  matrix rA(3,1), rB(3,1), e(3,1), resolution(k,1);

  for(a = 1, b = 2; b <= 2*k; a+=2, b+=2) {
    rA = vertices.column(a);
    rB = vertices.column(b);
    e = (rB - rA) / (rB - rA).Frobenius();
    l = resolve(b/2); /* resolve is global */
    /*
      resolution(b/2) = w/(d*l) - (nu.cross(e.cross(rO - rA))).Frobenius()
      / ((rO - rA).dot(nu) * (rO - rB).dot(nu));
     */

    /* Avoid scaling problem */
    resolution(b/2) = w/(d*l) * (rO - rA).dot(nu) * (rO - rB).dot(nu)
      - (nu.cross(e.cross(rO - rA))).Frobenius();
  }
  
  return resolution;
}

