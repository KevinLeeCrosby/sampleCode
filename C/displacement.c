/*
 * displacement.c
 *
 * Displacement Error
 */
#include <math.h>
#include <iostream.h>
#include "matrix.h"
#include "gfunct.h"

/*
 * Displacement Error
 * Input:   f (focal length)
 * Output:  displacement error evaluated at sensor setting
 *          cosj, sinj (contains matrix of cos(gammaj) and sin(gammaj))
 */
double displacement(double f, matrix &cosj, matrix &sinj) {
  matrix Q(transformation());

  matrix ones(1,vertices.cols(),1.0);          /*    row vector of ones   */
  matrix homogeneous(vertices.vaugment(ones)); /* homogeneous coordinates */

  matrix C(Q*homogeneous);/* calculates C1ij,C2ij,C3ij for i=1,2 & j=1,...,k */

  int m, n, l, point, point1, point2, line, num, denom;
  int k = entity_count; /* number of entities */

  matrix lambda(21,2*k);

  for(m=1; m <= 2*k; m++) { /* define lambdas for each of 2k points */
    lambda(1,m) = f*C(1,m)*C(2,m);
    lambda(2,m) = f*((f - C(3,m))*C(3,m) - C(1,m)*C(1,m));
    lambda(3,m) = f*C(2,m)*(C(3,m) - f);
    lambda(4,m) = f*(f - C(3,m));
    lambda(5,m) = 0.0;
    lambda(6,m) = f*C(1,m);
    lambda(7,m) = 0.0;
    lambda(8,m) = f*(C(2,m)*C(2,m) - (f - C(3,m))*C(3,m));
    lambda(9,m) = -f*C(1,m)*C(2,m);
    lambda(10,m) = f*C(1,m)*(f - C(3,m));
    lambda(11,m) = 0.0;
    lambda(12,m) = f*(f - C(3,m));
    lambda(13,m) = f*C(2,m);
    lambda(14,m) = 0.0;
    lambda(15,m) = -C(2,m)*(f - C(3,m));
    lambda(16,m) = C(1,m)*(f - C(3,m));
    lambda(17,m) = 0.0;
    lambda(18,m) = 0.0;
    lambda(19,m) = 0.0;
    lambda(20,m) = f - C(3,m);
    lambda(21,m) = (f - C(3,m))*(f - C(3,m));
    if(fabs(lambda(21,m)) <= 1e-10) {
      cout << "f = C3 for vertex " << m << "!" << endl;
      exit(1);
    }
  }
  matrix J6(6*k,6);

  /* find means and covariances of all zetas, xis, and chis */
  matrix Mdiv(6*k,1);   /* mean zeta_ij, xi_ij, chi_ij for i=1,2 & j=1,...,k */

  for(m=1; m <= 6*k; m++) {
    l = (m - 1)%3 + 1;        /* l=1 is zeta_ij, l=2 is xi_ij, l=3 is chi_ij */
    point = (m - 1)/3 + 1;       /* index for point number */
    Mdiv(m) = lambda(7*l,point); /*    find means    */
    for(n=1; n <= 6; n++)
      J6(m,n) = lambda(n+7*(l-1),point);
  }
  matrix Cdiv(J6*C6*J6.T());   /* and calculate covariances */

  /* find means and covariances of all edus and edvs */
  matrix Muv(4*k,1);    /* mean edu_ij and edv_ij for i=1,2 & j=1,...,k */
  matrix Jdiv(4*k,6*k); /* jacobian relating zeta, xi, chi to edu, edv */

  for(m=1; m <= 4*k; m++) {
    l = (m - 1)%2 + 1;     /* l=1 is edu_ij, l=2 is edv_ij */
    point = (m - 1)/2 + 1; /* index for point number */
    num = (3*m-l)/2;       /* find appropriate indices using algebra */
    denom = (3*m-3*l+6)/2; /* to obtain zeta,chi or xi,chi */
    Muv(m) = -Cdiv(num, denom) / (Mdiv(denom)*Mdiv(denom)); /* 2nd Taylor */
    Jdiv(m,m + point - 1) = 1/Mdiv(3*point);/* reciprocal of mean of chi_ij */
  }
  matrix Cuv(Jdiv*Cdiv*Jdiv.T()); /* and calculate covariances */


  /* find means and covariances of all edxs and edys */
  matrix Juv(2*k,4*k);   /* jacobian relating edu, edv to edx, edy */

  for(m=1; m <= 2*k; m++) {
    line = (m - 1)/2 + 1;  /* index for line number */
    Juv(m,m+2*line-2) = 1;
    Juv(m,m+2*line) = -1;
  }
  matrix Mxy(Juv*Muv);         /* mean edx_j and edy_j for j=1,...,k */
  matrix Cxy(Juv*Cuv*Juv.T()); /* and covariances */


  /* find means and covariances of all eds */
  matrix Jxy(k,2*k);           /* jacobian relating edx, edy to ed */

  /* find resultant mean and variance for ed */
  matrix Jd(1,k,1.0);

  for(m=1; m <= k; m++) {
    point1 = 2*m - 1;      /* indices for pair of points */
    point2 = 2*m;
    double C11j = C(1,point1), C21j = C(2,point1), C31j = C(3,point1);
    double C12j = C(1,point2), C22j = C(2,point2), C32j = C(3,point2);
    double u1j = f*C11j / (f - C31j), u2j = f*C12j / (f - C32j);
    double v1j = f*C21j / (f - C31j), v2j = f*C22j / (f - C32j);

    /* Compute cosine and sine to avoid numerical problems with vertical */
    length(m) = hypot(u1j - u2j, v1j - v2j);
    cosj(m) = (u1j - u2j) / length(m);
    sinj(m) = (v1j - v2j) / length(m) ;


    Jxy(m,point1) = cosj(m);
    Jxy(m,point2) = sinj(m);

    /* Assign smaller weight to larger lines
    double weight =
      100 * (vertices.column(point1) - vertices.column(point2)).Frobenius();
      */

    double weight = 1;

    Jd(m) = weight;
  }

  /* Md and Cd are global */
  Md = Jxy*Mxy;                  /* mean ed_j for j=1,...,k */
  Cd = Jxy*Cxy*Jxy.T();          /* and covariances */

  double eta = Jd*Md;            /*   mean of ed   */
  double sigma2 = Jd*Cd*Jd.T();  /* variance of ed */

  if(sigma2<0) cout << "Variance of displacement error is negative!  "
		    << sigma2 << endl; 

  /* find resultant mean squared error for displacement */
 
  /*
    cout << "C6 = " << endl;
    C6.print();
    cout << "J6 = " << endl;
    J6.print();
    
    cout << "Mdiv = " << endl;
    Mdiv.print();
    cout << "Cdiv = " << endl;
    Cdiv.print();
    cout << "Jdiv = " << endl;
    Jdiv.print();
    
    cout << "Muv = " << endl;
    Muv.print();
    cout << "Cuv = " << endl;
    Cuv.print();
    cout << "Juv = " << endl;
    Juv.print();
    
    cout << "Mxy = " << endl;
    Mxy.print();
    cout << "Cxy = " << endl;
    Cxy.print();
    cout << "Jxy = " << endl;
    Jxy.print();
    
    cout << "Md = " << endl;
    Md.print();
    cout << "Cd = " << endl;
    Cd.print();
    
    cout << "disp mean " << eta << endl;
    cout << "disp variance " << sigma2 << endl;
    cout << "disp MSE " << sigma2 + eta*eta << endl;
    exit(1);
    */

  return sigma2 + eta*eta;
}













