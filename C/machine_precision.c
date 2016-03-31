/*
 * machine_precision.c
 */

/*
 * machine_precision()
 * Input:   none                    -10
 * Output:  machine_precision, or 10   , whichever is greater
 */
double machine_precision() {
  double a, epsilon;

  /*
   * Determine when "a" is indistinguishable from zero, but terminate early
   * if it becomes too small.  "epsilon" is value of "a" just before this
   * happens.  Keep "epsilon" at a power of 10.
   */
  for(a=.01, epsilon=a; a > 0.0 && epsilon > 1E-10; epsilon=a, a /= 10.0);

  return epsilon;
}

