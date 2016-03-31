/*
 * objective.c
 *
 * Objective Function
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"
#include "displacement.h"
#include "quantization.h"


/*
 * Objective Function
 * Input:   setting (position and viewing direction to evaluate function at)
 * Output:  objective function evaluated at sensor setting
 */
double function(double rx, double ry, double f) {
  matrix cosj(entity_count,1), sinj(entity_count,1);

  double disp=displacement(f,cosj,sinj);

  matrix horiz(cosj*rx), vert(sinj*ry);

  double quant=quantization(horiz,vert);

  /* cos_sin is global */
  cos_sin = horiz.haugment(vert);

  return disp + quant;
}


