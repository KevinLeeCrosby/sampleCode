/*
 * constraints.c
 *
 * Constraints
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"
#include "resolution.h"
#include "focus.h"
#include "field-of-view.h"
#include "visibility.h"

/*
 * Constraints
 * Input:   a bunch of stuff
 * Output:  constraints evaluated at sensor setting
 */
matrix constraints(matrix rO, matrix nu, matrix rc, matrix rf, matrix rm,
		   double alpha, double a, double c, double d, double f,
		   double w) {

  matrix resolution(g1(rO, nu, d, w));
  matrix focus(g2(rO, nu, rc, rf, a, c, d, f));
  matrix field_of_view(g3(rO, nu, rm, alpha));
  matrix visibility(g4(rO));

  matrix constraints;  /* vertically augment all constraints */
  constraints =
    resolution.vaugment(focus).vaugment(field_of_view).vaugment(visibility);

  /*
    cout << "rc = " << endl;
    rc.T().print();
    cout << "rf = " << endl;
    rf.T().print();
    cout << "rm = " << endl;
    rm.T().print();
    
    cout << "d = " << d << endl;
    cout << "alpha = " << alpha << endl;
    
    cout << "resolution = " << endl;
    resolution.T().print();
    cout << "focus = " << endl;
    focus.T().print();
    cout << "field of view = " << endl;
    field_of_view.T().print();
    cout << "visibility = " << endl;
    visibility.T().print();
    
    cout << "constraints = " << endl;
    constraints.print();
    
    exit(1);
  */
  
  return constraints;
}
