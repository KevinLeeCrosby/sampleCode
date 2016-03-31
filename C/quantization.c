/*
 * quantization.c
 *
 * Quantization Error
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"

/*
 * Quantization Error
 * Input:   horiz, vert (rx*cos(gammaj) and ry*sin*(gammaj));
 * Output:  quantization error evaluated at sensor setting
 */
double quantization(matrix horiz, matrix vert) {
  /* find resultant mean and variance for eq */
  double sigma2 = 0.0;

  int m;
  int k = entity_count;

  for(m=1; m<=k; m++) {
    double weight = 1;

    sigma2 += weight*(horiz(m)*horiz(m) + vert(m)*vert(m));
  }
  sigma2 /= 6.0;               /* variance of eq */
  double eta = 0.0;            /*   mean of eq   */


  /* find resultant mean squared error for quantization */
 
  return sigma2 + eta*eta;
}








